import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

// ---------------------------------------------------------------------------
// SLIM PREVIEW CONFIG (PDMM-owned scaffold — NOT synced from pan-dev-mim)
//
// This is a deliberately stripped-down copy of pan-dev-mim's docusaurus.config.ts. It hosts the
// SAME marketplace rendering engine (src/**, src/css/custom.css, generate-gallery.js — all synced
// from pan-dev-mim) so a contributor sees exactly what production renders, but drops everything
// unrelated to the marketplace: the OpenAPI (`docusaurus-plugin-openapi-docs`) and GraphQL
// (`@graphql-markdown/docusaurus`) pipelines, the `@theme/ApiItem` doc wrapper, local search, and
// client redirects. API Endpoints / Developer Docs are out of scope here — the navbar links out to
// the public pan.dev site instead.
// ---------------------------------------------------------------------------

// The public site these preview links point at. Override with PUBLIC_SITE_URL if the host moves.
const PUBLIC_SITE = process.env.PUBLIC_SITE_URL || 'https://pan.dev/mim';

const config: Config = {
    title: 'MIM Marketplace Preview',
    tagline: 'Local preview of your integration before you open a PR',
    favicon: 'img/favicon.ico',

    // Match pan-dev-mim so rendering behaviour is identical.
    future: {
        v4: true,
    },

    url: 'http://localhost',
    // Local preview is served at the root, unlike production's /mim/. All in-app links go through
    // @docusaurus/Link, which prepends baseUrl, so "/" is correct for a standalone local server.
    baseUrl: '/',

    // A contributor's in-progress content will have dead links and missing anchors while they work.
    // Warn, never throw — a broken link must not block the preview (production still uses "throw").
    onBrokenLinks: 'warn',
    onBrokenAnchors: 'warn',
    markdown: {
        hooks: {
            onBrokenMarkdownLinks: 'warn',
        },
    },

    i18n: {
        defaultLocale: 'en',
        locales: ['en'],
    },

    presets: [
        [
            'classic',
            {
                docs: {
                    // generate-gallery.js emits pages at slug /marketplace/<Name>; matching
                    // pan-dev-mim, docs are served without a /docs/ prefix.
                    routeBasePath: '/',
                    sidebarPath: './sidebars.ts',
                },
                blog: false,
                theme: {
                    // The synced global stylesheet — carries all marketplace/grid/detail/CTA styling.
                    customCss: './src/css/custom.css',
                },
            } satisfies Preset.Options,
        ],
    ],

    themeConfig: {
        colorMode: {
            respectPrefersColorScheme: true,
        },
        navbar: {
            title: 'MIM Marketplace Preview',
            items: [
                {
                    to: '/marketplace',
                    label: 'Marketplace',
                    position: 'left',
                    activeBasePath: '/marketplace',
                },
                // Out of scope for the preview — link out to the live public site.
                {
                    href: `${PUBLIC_SITE}/api-endpoints`,
                    label: 'API Endpoints',
                    position: 'left',
                },
                {
                    href: `${PUBLIC_SITE}/dev-docs/welcome`,
                    label: 'Developer Docs',
                    position: 'left',
                },
            ],
        },
        footer: {
            style: 'dark',
            links: [],
            copyright: `Local preview harness — rendering engine synced from pan-dev-mim.`,
        },
        prism: {
            theme: prismThemes.github,
            darkTheme: prismThemes.dracula,
        },
    } satisfies Preset.ThemeConfig,
};

export default config;
