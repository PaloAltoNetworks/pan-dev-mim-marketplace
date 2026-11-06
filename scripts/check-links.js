#!/usr/bin/env node
// scripts/check-links.js
//
// Checks every link a listing shows, per product variant, the way the site resolves them:
// a variant's own field wins, else the root field. For each link it reports
//   - wrong-product: the link is on one product's docs site but sits on another product's
//     variant (e.g. a SaaS variant pointing at Self-Hosted docs)
//   - legacy-domain: the link is on a retired docs host
//   - broken: the URL does not answer 2xx/3xx (after following redirects)
//   - redirected: the URL answers, but only after redirecting to a different page
//
// Usage:
//   npm run check:links                 # full check, network included
//   npm run check:links -- --offline    # product/domain checks only, no requests
//   npm run check:links -- --only ACME,FortinetFortiGate
//
// Writes link-check-report.csv (every link) to the repo root and prints a summary.
// Exits 1 when any wrong-product, legacy-domain or broken link is found.

const fs = require('fs');
const path = require('path');

const ROOT = path.join(__dirname, '..');
const INTEGRATIONS_DIR = path.join(ROOT, 'Integrations');
const REPORT_PATH = path.join(ROOT, 'link-check-report.csv');

const args = process.argv.slice(2);
const OFFLINE = args.includes('--offline');
const onlyIdx = args.indexOf('--only');
const ONLY = onlyIdx >= 0 ? new Set(args[onlyIdx + 1].split(',')) : null;

const TIMEOUT_MS = 20000;
const CONCURRENCY = 8;
const MAX_REDIRECTS = 8;

// Which product's docs a URL belongs to, or null for third-party and neutral hosts.
function docsProduct(url) {
    let u;
    try { u = new URL(url); } catch { return null; }
    const host = u.hostname.toLowerCase();
    const p = u.pathname.toLowerCase();
    // ZTPKI docs are published inside the SaaS docs tree.
    if (host === 'docs.cyberark.com' && p.startsWith('/mis-saas/ztpki')) return 'Zero Touch PKI';
    if (host === 'docs.cyberark.com' && p.startsWith('/mis-saas')) return 'Certificate Manager SaaS';
    if (host === 'docs.cyberark.com' && (p.startsWith('/mis-selfhosted') || p.startsWith('/mis-self-hosted'))) {
        return 'Certificate Manager Self-Hosted';
    }
    if (host === 'docs.venafi.com') return 'Certificate Manager Self-Hosted';
    if (host === 'docs.venafi.cloud') return 'Certificate Manager SaaS';
    if (host === 'docs.paloaltonetworks.com' && p.startsWith('/next-gen-trust-security')) return 'Next-Gen Trust Security';
    return null;
}

const LEGACY_HOSTS = new Set(['docs.venafi.cloud']);
const PLACEHOLDER_HOSTS = /(^|\.)example\.(com|org|net)$/;

function linksFor(meta, variant) {
    const out = [];
    const add = (field, url, title) => { if (url) out.push({ field, url, title: title || '' }); };

    const docLinks = variant.documentationLinks ?? meta.documentationLinks ?? [];
    docLinks.forEach((l) => add('documentationLinks', l.url, l.title));
    add('externalDocsUrl', variant.externalDocsUrl ?? meta.externalDocsUrl, variant.externalDocsLabel ?? meta.externalDocsLabel);
    add('supportUrl', variant.supportUrl ?? meta.supportUrl);
    add('partnerContactUrl', variant.partnerContactUrl ?? meta.partnerContactUrl);

    for (const res of [meta.resources, variant.resources]) {
        if (!res) continue;
        for (const kind of ['videos', 'otherResources', 'solutionGuides', 'externalLinks']) {
            (res[kind] ?? []).forEach((r) => add(`resources.${kind}`, r.url, r.title));
        }
    }
    return out;
}

function collect() {
    const rows = [];
    const folders = fs.readdirSync(INTEGRATIONS_DIR, { withFileTypes: true })
        .filter((d) => d.isDirectory() && !d.name.startsWith('.'))
        .map((d) => d.name)
        .filter((name) => !ONLY || ONLY.has(name))
        .sort();

    for (const folder of folders) {
        const metaPath = path.join(INTEGRATIONS_DIR, folder, 'integration_metadata.json');
        if (!fs.existsSync(metaPath)) continue;
        const meta = JSON.parse(fs.readFileSync(metaPath, 'utf8'));
        const variants = Array.isArray(meta.productVariants) && meta.productVariants.length > 0
            ? meta.productVariants
            : (meta.products ?? ['(none)']).map((product) => ({ product }));

        for (const variant of variants) {
            for (const link of linksFor(meta, variant)) {
                const issues = [];
                let host = '';
                if (!/^[a-z][a-z0-9+.-]*:/i.test(link.url)) {
                    // A relative path is a file shipped in the listing folder.
                    link.local = true;
                    if (!fs.existsSync(path.join(INTEGRATIONS_DIR, folder, link.url))) issues.push('missing-local-file');
                    rows.push({ folder, name: meta.name, product: variant.product, ...link, issues, status: 'local', finalUrl: '' });
                    continue;
                }
                try { host = new URL(link.url).hostname.toLowerCase(); } catch { issues.push('invalid-url'); }
                const linkProduct = docsProduct(link.url);
                if (linkProduct && linkProduct !== variant.product) {
                    issues.push(`wrong-product (links to ${linkProduct} docs)`);
                }
                if (LEGACY_HOSTS.has(host)) issues.push('legacy-domain');
                if (PLACEHOLDER_HOSTS.test(host)) issues.push('placeholder-url');
                rows.push({ folder, name: meta.name, product: variant.product, ...link, issues, status: '', finalUrl: '' });
            }
        }
    }
    return rows;
}

async function probe(url) {
    let current = url;
    for (let hop = 0; hop <= MAX_REDIRECTS; hop++) {
        const ctrl = new AbortController();
        const timer = setTimeout(() => ctrl.abort(), TIMEOUT_MS);
        try {
            const res = await fetch(current, {
                method: 'GET',
                redirect: 'manual',
                signal: ctrl.signal,
                headers: { 'User-Agent': 'Mozilla/5.0 (pan-dev-mim-marketplace link check)', Accept: 'text/html,*/*' },
            });
            const loc = res.headers.get('location');
            if (res.status >= 300 && res.status < 400 && loc) {
                current = new URL(loc, current).toString();
                continue;
            }
            return { status: res.status, finalUrl: current };
        } catch (err) {
            return { status: err.name === 'AbortError' ? 'timeout' : `error: ${err.cause?.code ?? err.message}`, finalUrl: current };
        } finally {
            clearTimeout(timer);
        }
    }
    return { status: 'too-many-redirects', finalUrl: current };
}

// Same page after normalizing trailing slash, case of host and http->https.
function samePage(a, b) {
    const norm = (s) => {
        try {
            const u = new URL(s);
            return `${u.hostname.toLowerCase()}${u.pathname.replace(/\/+$/, '')}${u.search}`;
        } catch { return s; }
    };
    return norm(a) === norm(b);
}

async function runProbes(rows) {
    const urls = [...new Set(rows.filter((r) => !r.local && !r.issues.includes('invalid-url') && !r.issues.includes('placeholder-url')).map((r) => r.url))];
    const results = new Map();
    let next = 0;
    let done = 0;
    async function worker() {
        while (next < urls.length) {
            const url = urls[next++];
            results.set(url, await probe(url));
            done++;
            if (done % 50 === 0) process.stderr.write(`  checked ${done}/${urls.length} URLs\n`);
        }
    }
    await Promise.all(Array.from({ length: CONCURRENCY }, worker));

    for (const row of rows) {
        const r = results.get(row.url);
        if (!r) continue;
        row.status = String(r.status);
        row.finalUrl = r.finalUrl;
        const ok = typeof r.status === 'number' && r.status >= 200 && r.status < 400;
        // Bot walls answer 401/403/429 to scripts but load in a browser: report them apart.
        if (typeof r.status === 'number' && [401, 403, 429].includes(r.status)) {
            row.issues.push(`blocked-${r.status} (check in a browser)`);
        } else if (/CERT|SSL|TLS/.test(String(r.status))) {
            // Corporate TLS inspection on the machine running the check can break the chain;
            // only a browser off the corporate network settles it.
            row.issues.push('tls-unverified (check in a browser)');
        } else if (!ok) {
            row.issues.push('broken');
        } else if (!samePage(row.url, r.finalUrl)) {
            row.issues.push('redirected');
            const finalProduct = docsProduct(r.finalUrl);
            if (finalProduct && finalProduct !== row.product && !row.issues.some((i) => i.startsWith('wrong-product'))) {
                row.issues.push(`wrong-product after redirect (lands on ${finalProduct} docs)`);
            }
        }
    }
    return urls.length;
}

function csvCell(v) {
    const s = String(v ?? '');
    return /[",\n]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s;
}

(async () => {
    const rows = collect();
    let probed = 0;
    if (!OFFLINE) {
        process.stderr.write(`Checking links for ${new Set(rows.map((r) => r.folder)).size} integrations...\n`);
        probed = await runProbes(rows);
    }

    const header = ['folder', 'name', 'product', 'field', 'title', 'url', 'status', 'finalUrl', 'issues'];
    const lines = [header.join(',')].concat(rows.map((r) =>
        [r.folder, r.name, r.product, r.field, r.title, r.url, r.status, r.finalUrl, r.issues.join('; ')].map(csvCell).join(',')));
    fs.writeFileSync(REPORT_PATH, lines.join('\n') + '\n');

    const count = (pred) => rows.filter((r) => r.issues.some(pred)).length;
    const failing = rows.filter((r) => r.issues.some((i) =>
        i.startsWith('wrong-product') || i === 'legacy-domain' || i === 'broken' || i === 'invalid-url'
        || i === 'placeholder-url' || i === 'missing-local-file'));

    console.log(`\nLinks checked: ${rows.length} (${probed} unique URLs requested${OFFLINE ? ', offline mode' : ''})`);
    console.log(`  wrong-product: ${count((i) => i.startsWith('wrong-product'))}`);
    console.log(`  legacy-domain: ${count((i) => i === 'legacy-domain')}`);
    console.log(`  broken:        ${count((i) => i === 'broken')}`);
    console.log(`  blocked:       ${count((i) => i.startsWith('blocked-'))} (bot walls; check in a browser)`);
    console.log(`  tls:           ${count((i) => i.startsWith('tls-unverified'))} (certificate errors; check in a browser)`);
    console.log(`  missing file:  ${count((i) => i === 'missing-local-file')}`);
    console.log(`  redirected:    ${count((i) => i === 'redirected')}`);
    console.log(`  placeholder:   ${count((i) => i === 'placeholder-url')}`);
    console.log(`Report: ${path.relative(ROOT, REPORT_PATH)}`);

    if (failing.length) {
        console.log('\nNeeds a fix:');
        for (const r of failing) {
            console.log(`  [${r.folder}] ${r.product} · ${r.field}: ${r.url} -> ${r.issues.join('; ')}${r.status ? ` (${r.status})` : ''}`);
        }
        process.exit(1);
    }
})();
