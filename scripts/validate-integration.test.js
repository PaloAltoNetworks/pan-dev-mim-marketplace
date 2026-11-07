// Unit tests for scripts/validate-integration.js's own validation rules
// (schema checks, product/category vocab enforcement).
//
// The script is a standalone CLI (no exports, calls process.exit(1) on error), so these
// run it as a black-box subprocess against throwaway fixture directories built under
// os.tmpdir() — this exercises real behavior without touching the script itself.
//
// NOTE: PascalCase directory naming is enforced by .github/workflows/pr-checks.yml
// (a shell step), not by this script — it has no test coverage here.
//
// Run with: node --test scripts/validate-integration.test.js

const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('fs');
const os = require('os');
const path = require('path');
const { spawnSync } = require('child_process');

const ROOT = path.resolve(__dirname, '..');
const SCRIPT = path.join(ROOT, 'scripts', 'validate-integration.js');

const APPROVED_CATEGORY = JSON.parse(
  fs.readFileSync(path.join(ROOT, 'Config', 'approved_categories.json'), 'utf8')
).approved_list[0];
const APPROVED_PRODUCT = JSON.parse(
  fs.readFileSync(path.join(ROOT, 'Config', 'approved_products.json'), 'utf8')
).approved_list[0];

function makeFixture(metaOverrides, { releaseNotes } = {}) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'pdmm-validate-test-'));
  const meta = {
    name: 'Test Integration',
    description: 'A fixture integration for validator unit tests.',
    products: [APPROVED_PRODUCT],
    price: 'Free',
    categories: [APPROVED_CATEGORY],
    ...metaOverrides,
  };
  fs.writeFileSync(path.join(dir, 'integration_metadata.json'), JSON.stringify(meta, null, 2));
  if (releaseNotes) {
    const rnDir = path.join(dir, 'ReleaseNotes');
    fs.mkdirSync(rnDir);
    for (const [filename, content] of Object.entries(releaseNotes)) {
      fs.writeFileSync(path.join(rnDir, filename), content);
    }
  }
  return dir;
}

function runValidator(dir) {
  const result = spawnSync('node', [SCRIPT, dir], { encoding: 'utf8' });
  return { status: result.status, stdout: result.stdout };
}

function cleanup(dir) {
  fs.rmSync(dir, { recursive: true, force: true });
}

test('a minimal valid integration passes with 0 errors', () => {
  const dir = makeFixture({});
  try {
    const { status, stdout } = runValidator(dir);
    assert.equal(status, 0, stdout);
    assert.match(stdout, /All validations passed/);
  } finally {
    cleanup(dir);
  }
});

test('missing a required field errors', () => {
  const dir = makeFixture({ name: undefined });
  try {
    const { status, stdout } = runValidator(dir);
    assert.notEqual(status, 0);
    assert.match(stdout, /Missing required field: "name"/);
  } finally {
    cleanup(dir);
  }
});

test('integration_metadata.json missing entirely errors', () => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'pdmm-validate-test-'));
  try {
    const { status, stdout } = runValidator(dir);
    assert.notEqual(status, 0);
    assert.match(stdout, /integration_metadata\.json is missing/);
  } finally {
    cleanup(dir);
  }
});

test('invalid JSON in integration_metadata.json errors', () => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'pdmm-validate-test-'));
  try {
    fs.writeFileSync(path.join(dir, 'integration_metadata.json'), '{ not valid json');
    const { status, stdout } = runValidator(dir);
    assert.notEqual(status, 0);
    assert.match(stdout, /not valid JSON/);
  } finally {
    cleanup(dir);
  }
});

test('a category outside approved_categories.json errors', () => {
  const dir = makeFixture({ categories: ['Not A Real Category'] });
  try {
    const { status, stdout } = runValidator(dir);
    assert.notEqual(status, 0);
    assert.match(stdout, /Category "Not A Real Category" is not in approved_categories\.json/);
  } finally {
    cleanup(dir);
  }
});

test('more than one category errors', () => {
  const dir = makeFixture({ categories: [APPROVED_CATEGORY, APPROVED_CATEGORY] });
  try {
    const { status, stdout } = runValidator(dir);
    assert.notEqual(status, 0);
    assert.match(stdout, /Expected exactly one category, found 2/);
  } finally {
    cleanup(dir);
  }
});

test('a product outside approved_products.json errors', () => {
  const dir = makeFixture({ products: ['Not A Real Product'] });
  try {
    const { status, stdout } = runValidator(dir);
    assert.notEqual(status, 0);
    assert.match(stdout, /Product "Not A Real Product" is not in approved_products\.json/);
  } finally {
    cleanup(dir);
  }
});

test('a tag outside approved_tags.json only warns, does not error', () => {
  const dir = makeFixture({ tags: ['Definitely Not A Real Tag'] });
  try {
    const { status, stdout } = runValidator(dir);
    assert.equal(status, 0, stdout);
    assert.match(stdout, /Tag "Definitely Not A Real Tag" is not in approved_tags\.json/);
  } finally {
    cleanup(dir);
  }
});

test('legacy "platforms" field is accepted with a warning, not an error', () => {
  const dir = makeFixture({ products: undefined, platforms: [APPROVED_PRODUCT] });
  try {
    const { status, stdout } = runValidator(dir);
    assert.equal(status, 0, stdout);
    assert.match(stdout, /"platforms" has been renamed to "products"/);
  } finally {
    cleanup(dir);
  }
});

test('both supportUrl and supportEmail set at top level only warns', () => {
  const dir = makeFixture({ supportUrl: 'https://example.com/support', supportEmail: 'support@example.com' });
  try {
    const { status, stdout } = runValidator(dir);
    assert.equal(status, 0, stdout);
    assert.match(stdout, /Both "supportUrl" and "supportEmail" are set at the top level/);
  } finally {
    cleanup(dir);
  }
});

test('a declared currentVersion with no matching release note errors', () => {
  const dir = makeFixture({ currentVersion: '1.0.0' });
  try {
    const { status, stdout } = runValidator(dir);
    assert.notEqual(status, 0);
    assert.match(stdout, /No release note for version 1\.0\.0/);
  } finally {
    cleanup(dir);
  }
});

test('a currentVersion with a matching per-version release note file passes', () => {
  const dir = makeFixture({ currentVersion: '1.0.0' }, { releaseNotes: { '1_0_0.md': '### Version 1.0.0\n\nInitial release.\n' } });
  try {
    const { status, stdout } = runValidator(dir);
    assert.equal(status, 0, stdout);
  } finally {
    cleanup(dir);
  }
});

test('a currentVersion satisfied by a CHANGELOG.md section passes', () => {
  const dir = makeFixture(
    { currentVersion: '2.0.0' },
    { releaseNotes: { 'CHANGELOG.md': '## Version 2.0.0\n\nSecond release.\n' } }
  );
  try {
    const { status, stdout } = runValidator(dir);
    assert.equal(status, 0, stdout);
  } finally {
    cleanup(dir);
  }
});

test('mixing CHANGELOG.md and per-version files for the same suffix errors', () => {
  const dir = makeFixture(
    { currentVersion: '1.0.0' },
    { releaseNotes: { 'CHANGELOG.md': '## Version 1.0.0\n', '1_0_0.md': '### Version 1.0.0\n' } }
  );
  try {
    const { status, stdout } = runValidator(dir);
    assert.notEqual(status, 0);
    assert.match(stdout, /Both a CHANGELOG\.md and individual release-note files exist/);
  } finally {
    cleanup(dir);
  }
});

test('root-level downloadFiles alongside productVariants errors', () => {
  const dir = makeFixture({
    productVariants: [{ product: APPROVED_PRODUCT }],
    downloadFiles: ['script.ps1'],
  });
  try {
    const { status, stdout } = runValidator(dir);
    assert.notEqual(status, 0);
    assert.match(stdout, /root-level "downloadFiles" is not allowed alongside "productVariants"/);
  } finally {
    cleanup(dir);
  }
});

test('a downloadFiles entry that does not exist on disk errors', () => {
  const dir = makeFixture({ downloadFiles: ['does-not-exist.ps1'] });
  try {
    const { status, stdout } = runValidator(dir);
    assert.notEqual(status, 0);
    assert.match(stdout, /downloadFiles lists "does-not-exist\.ps1", which does not exist/);
  } finally {
    cleanup(dir);
  }
});

test('a forbidden file (e.g. .env) errors', () => {
  const dir = makeFixture({});
  try {
    fs.writeFileSync(path.join(dir, '.env'), 'SECRET=1');
    const { status, stdout } = runValidator(dir);
    assert.notEqual(status, 0);
    assert.match(stdout, /Forbidden file found: \.env/);
  } finally {
    cleanup(dir);
  }
});

test('productVariants[] product not in the root products array errors', () => {
  const dir = makeFixture({
    products: [APPROVED_PRODUCT],
    productVariants: [{ product: 'Zero Touch PKI', currentVersion: '1.0.0' }],
  });
  try {
    const { status, stdout } = runValidator(dir);
    assert.notEqual(status, 0);
    assert.match(stdout, /productVariants product "Zero Touch PKI" is not listed in the root "products" array/);
  } finally {
    cleanup(dir);
  }
});

test('an invalid primaryCta.type errors', () => {
  const dir = makeFixture({ primaryCta: { type: 'not-a-real-type' } });
  try {
    const { status, stdout } = runValidator(dir);
    assert.notEqual(status, 0);
    assert.match(stdout, /primaryCta\.type must be one of/);
  } finally {
    cleanup(dir);
  }
});

const STLA_URL = 'https://www.paloaltonetworks.com/content/dam/pan/en_US/assets/pdf/legal/software-tool-license-agreement.pdf';

test('"license": "MIT" without licenseUrl passes', () => {
  const dir = makeFixture({ license: 'MIT' });
  try {
    const { status, stdout } = runValidator(dir);
    assert.equal(status, 0, stdout);
  } finally {
    cleanup(dir);
  }
});

test('a non-MIT license with an https licenseUrl passes', () => {
  const dir = makeFixture({ license: 'Software Tool License Agreement', licenseUrl: STLA_URL });
  try {
    const { status, stdout } = runValidator(dir);
    assert.equal(status, 0, stdout);
  } finally {
    cleanup(dir);
  }
});

test('a non-MIT license without licenseUrl errors', () => {
  const dir = makeFixture({ license: 'Software Tool License Agreement' });
  try {
    const { status, stdout } = runValidator(dir);
    assert.notEqual(status, 0);
    assert.match(stdout, /needs a root-level "licenseUrl"/);
  } finally {
    cleanup(dir);
  }
});

test('a non-https licenseUrl errors', () => {
  const dir = makeFixture({ license: 'Software Tool License Agreement', licenseUrl: 'http://example.com/terms.pdf' });
  try {
    const { status, stdout } = runValidator(dir);
    assert.notEqual(status, 0);
    assert.match(stdout, /licenseUrl must use https/);
  } finally {
    cleanup(dir);
  }
});

test('licenseUrl without license errors', () => {
  const dir = makeFixture({ licenseUrl: STLA_URL });
  try {
    const { status, stdout } = runValidator(dir);
    assert.notEqual(status, 0);
    assert.match(stdout, /"licenseUrl" is set but "license" is not/);
  } finally {
    cleanup(dir);
  }
});

test('a "defaults" object errors and names its fields', () => {
  const dir = makeFixture({ defaults: { supportUrl: 'https://example.com/support' } });
  try {
    const { status, stdout } = runValidator(dir);
    assert.notEqual(status, 0);
    assert.match(stdout, /"defaults" is not supported.*\(supportUrl\)/);
  } finally {
    cleanup(dir);
  }
});
