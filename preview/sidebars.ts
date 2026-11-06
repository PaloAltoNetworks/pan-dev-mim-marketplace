import type {SidebarsConfig} from '@docusaurus/plugin-content-docs';

// The preview has no sidebar: every generated marketplace page sets `displayed_sidebar: null` in
// its front matter, so an empty config is all that's needed. (API/GraphQL sidebars live only in
// pan-dev-mim and are out of scope here.)
const sidebars: SidebarsConfig = {};

export default sidebars;
