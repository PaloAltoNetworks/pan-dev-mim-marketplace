import { IntegrationMetadata } from "../types";

// A listing's support level can differ per product variant (e.g. EJBCA Enterprise is Supported on
// SaaS/NGTS but Community on Self-Hosted). generate-gallery.js resolves each variant's level into
// _resolved.support, falling back to the root `support`.

type Variant = NonNullable<IntegrationMetadata["productVariants"]>[number];

function variantSupport(variant: Variant, integration: IntegrationMetadata): string | undefined {
    return variant._resolved?.support ?? variant.support ?? integration.support;
}

/** The level for one product, falling back to the root level when the listing has no such variant. */
export function supportForProduct(integration: IntegrationMetadata, product?: string): string | undefined {
    const variant = product ? integration.productVariants?.find((v) => v.product === product) : undefined;
    return variant ? variantSupport(variant, integration) : integration.support;
}

/**
 * Every level the listing resolves to across its variants. When `products` is non-empty, only
 * those products' variants count, so a Product filter narrows which levels a listing matches.
 */
export function supportLevelsOf(integration: IntegrationMetadata, products: string[] = []): string[] {
    const variants = (integration.productVariants ?? []).filter(
        (v) => products.length === 0 || products.includes(v.product),
    );
    const levels = variants.length > 0
        ? variants.map((v) => variantSupport(v, integration))
        : [integration.support];
    return Array.from(new Set(levels.filter((l): l is string => !!l)));
}
