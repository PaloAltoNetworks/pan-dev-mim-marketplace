import React, { useContext } from "react";
import Link from "@docusaurus/Link";
import { ProductContext } from "./IntegrationDetail";
import integrationsData from "../data/integrations.json";
import { IntegrationMetadata } from "../types";
import { integrationId } from "../utils/integrationId";
import styles from "./RecommendedIntegrations.module.css";

const integrations = integrationsData as IntegrationMetadata[];

function getIntegrationRoute(integration: IntegrationMetadata): string {
    return `/marketplace/${integrationId(integration)}`;
}

function calculateSimilarity(
    current: IntegrationMetadata,
    candidate: IntegrationMetadata
): number {
    let score = 0;

    const sharedCategories = current.categories?.filter(c =>
        candidate.categories?.includes(c)
    ) || [];
    score += sharedCategories.length * 5;

    const sharedUseCases = current.useCases?.filter(u =>
        candidate.useCases?.includes(u)
    ) || [];
    score += sharedUseCases.length * 4;

    const sharedTags = current.tags?.filter(t =>
        candidate.tags?.includes(t)
    ) || [];
    score += sharedTags.length * 3;

    const sharedKeywords = current.keywords?.filter(k =>
        candidate.keywords?.includes(k)
    ) || [];
    score += sharedKeywords.length * 1;

    return score;
}

function getRecommendations(
    currentIntegrationId: string,
    selectedProduct: string,
    allIntegrations: IntegrationMetadata[],
    maxResults: number = 4
): IntegrationMetadata[] {
    const current = allIntegrations.find(
        i => integrationId(i) === currentIntegrationId
    );

    if (!current) return [];

    const candidates = allIntegrations.filter(integration => {
        const isNotCurrent = integration.name !== current.name;
        const matchesProduct = integration.productVariants?.some(
            v => v.product === selectedProduct
        );
        return isNotCurrent && matchesProduct;
    });

    const scored = candidates.map(candidate => ({
        integration: candidate,
        score: calculateSimilarity(current, candidate)
    }));

    scored.sort((a, b) => {
        if (b.score !== a.score) return b.score - a.score;
        return a.integration.name.localeCompare(b.integration.name);
    });

    return scored.slice(0, maxResults).map(s => s.integration);
}

function RecommendedCard({ integration }: { integration: IntegrationMetadata }) {
    return (
        <Link to={getIntegrationRoute(integration)} className={styles.card}>
            <h4 className={styles.cardTitle}>{integration.name}</h4>
            <p className={styles.cardDescription}>{integration.description}</p>
            <div className={styles.cardCategories}>
                {integration.categories?.slice(0, 2).map(cat => (
                    <span key={cat} className="badge badge--secondary">
                        {cat}
                    </span>
                ))}
            </div>
        </Link>
    );
}

export default function RecommendedIntegrations({
    currentIntegrationId,
}: {
    currentIntegrationId: string;
}) {
    const selectedProduct = useContext(ProductContext);
    const recommendations = getRecommendations(
        currentIntegrationId,
        selectedProduct,
        integrations
    );

    if (recommendations.length === 0) {
        return null;
    }

    return (
        <section
            aria-labelledby="recommendations-heading"
            className={styles.recommendedSection}
        >
            <h3 id="recommendations-heading" className={styles.recommendedHeading}>
                You might also be interested in these integrations:
            </h3>
            <div className={styles.recommendedGrid} role="list">
                {recommendations.map(integration => (
                    <article role="listitem" key={integration.name}>
                        <RecommendedCard integration={integration} />
                    </article>
                ))}
            </div>
        </section>
    );
}
