import productsConfig from "../../config/marketplace-products.json";

// The `?product=` query param and the marketplace's product list, shared by the gallery and the
// listing detail page.
//
// docusaurus.config.ts imports this file in Node (for variantPendingScript), so keep it free of
// React, @docusaurus/* and @site imports.

// The products, in display priority, from config/marketplace-products.json, which
// generate-gallery.js also reads for overview/docs file suffixes. The order sets the gallery's
// Product filter, card pills, the detail page's PRODUCT dropdown and default variant. `suffix` is
// the short `?product=` form, so a link reads /marketplace/X?product=selfhosted.
export const PRODUCTS: { name: string; suffix: string }[] = productsConfig.products;

export const PRODUCT_NAMES = PRODUCTS.map((p) => p.name);

// The value to write into `?product=` for a product: its suffix, or the full name when it has none.
export function productParamValue(product: string): string {
    return PRODUCTS.find((p) => p.name === product)?.suffix ?? product;
}

// Resolve a `?product=` value (full name or suffix, any case) to one of `candidates`, or undefined.
export function matchProductParam(value: string, candidates: string[]): string | undefined {
    const v = value.trim().toLowerCase();
    if (!v) return undefined;
    return candidates.find(
        (c) => c.toLowerCase() === v || productParamValue(c).toLowerCase() === v,
    );
}

// Sorts products into PRODUCT_NAMES order. Anything not in the list goes last in its original
// order, since Array.prototype.sort is stable.
export function byProductPriority(products: string[]): string[] {
    const rank = (p: string) => {
        const i = PRODUCT_NAMES.indexOf(p);
        return i === -1 ? PRODUCT_NAMES.length : i;
    };
    return [...products].sort((a, b) => rank(a) - rank(b));
}

// Read `?product=` from a query string.
export function readProductParam(search: string, candidates: string[]): string | undefined {
    const params = new URLSearchParams(search);
    const value = params.get("product");
    return value ? matchProductParam(value, candidates) : undefined;
}

// Attribute set on <html> before first paint when a listing detail page is opened with a ?product=
// value naming a known product. CSS hides the variant-dependent area while it is set,
// so the SSR default variant never flashes before the URL's variant is applied. IntegrationDetail
// removes it once the URL's variant (or the fallback default) is rendered. An attribute rather
// than a class because Docusaurus rewrites <html class> through Helmet on hydration.
export const VARIANT_PENDING_ATTR = "data-mim-variant-pending";

export function clearVariantPending(): void {
    if (typeof document !== "undefined") {
        document.documentElement.removeAttribute(VARIANT_PENDING_ATTR);
    }
}

// Inline <head> script for docusaurus.config.ts headTags. It only acts on /marketplace/<id>
// detail pages with a known ?product=, and with JS disabled it never runs, so nothing is hidden.
//
// It polls every 100ms. IntegrationDetail clears the attribute once the URL's variant has
// rendered. Otherwise the script reveals the page itself:
// - at 3s if React has not started (hydrateRoot marks the root element with a __reactContainer$…
//   property as soon as it starts). That covers a slow download and a JS error: showing the
//   default variant beats a long blank, and it switches when React arrives.
// - at 6s regardless, if React started but hydration stalls.
// While React is running and under 6s it keeps waiting, so a slow CPU with a fast connection,
// where hydration outlasts a short timer, still never shows the default variant.
export function variantPendingScript(): string {
    const known = PRODUCTS.flatMap(({ name, suffix }) => [name.toLowerCase(), suffix]);
    return `(function(){try{
if(!new RegExp("/marketplace/[^/]+/?$").test(location.pathname))return;
var q=new URLSearchParams(location.search);var v=q.get("product");
if(!v||${JSON.stringify(known)}.indexOf(v.trim().toLowerCase())<0)return;
var h=document.documentElement,a=${JSON.stringify(VARIANT_PENDING_ATTR)};h.setAttribute(a,"");
var start=Date.now();
function reactStarted(){var r=document.getElementById("__docusaurus");if(!r)return false;
for(var k in r){if(k.indexOf("__reactContainer")===0)return true;}return false;}
(function tick(){
if(!h.hasAttribute(a))return;
var t=Date.now()-start;
if(t>6000||(t>3000&&!reactStarted())){h.removeAttribute(a);return;}
setTimeout(tick,100);
})();
}catch(e){}})();`;
}
