import React, { useState } from 'react';
import { IntegrationMetadata } from '../types';
import { exportIntegrationsToCSV } from '../utils/csvExport';

interface ExportButtonProps {
    integrations: IntegrationMetadata[];
    totalCount: number;
}

function DownloadIcon() {
    return (
        <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
            <path d="M19 12v7H5v-7H3v7c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2v-7h-2zm-6 .67l2.59-2.58L17 11.5l-5 5-5-5 1.41-1.41L11 12.67V3h2v9.67z"/>
        </svg>
    );
}

export default function ExportButton({ integrations, totalCount }: ExportButtonProps) {
    const [isExporting, setIsExporting] = useState(false);

    const handleExport = () => {
        if (integrations.length === 0) return;

        setIsExporting(true);

        // Small delay to show loading state
        setTimeout(() => {
            exportIntegrationsToCSV(integrations);
            setIsExporting(false);
        }, 100);
    };

    const disabled = integrations.length === 0 || isExporting;

    const tooltipText = integrations.length === totalCount
        ? `Export all ${totalCount} integrations to CSV`
        : `Export ${integrations.length} of ${totalCount} integrations to CSV`;

    return (
        <button
            className="export-btn"
            onClick={handleExport}
            disabled={disabled}
            aria-label={tooltipText}
            title={tooltipText}
        >
            <span className="export-btn-icon">
                <DownloadIcon />
            </span>
            <span className="export-btn-text">
                {isExporting ? 'Exporting...' : 'Export CSV'}
            </span>
        </button>
    );
}
