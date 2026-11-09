import { IntegrationMetadata } from '../types';
import { listingTypeOf, LISTING_TYPE_NAMES } from '../components/ListingType';

function escapeCsvCell(value: string | undefined | null): string {
    if (!value) return '';
    const stringValue = String(value);

    const escaped = stringValue.replace(/"/g, '""');

    if (escaped.includes(',') || escaped.includes('"') || escaped.includes('\n')) {
        return `"${escaped}"`;
    }

    return escaped;
}

function generateCsvContent(integrations: IntegrationMetadata[]): string {
    const headers = [
        'Name',
        'Type',
        'Short Description',
        'Certification Status',
        'Developed By',
        'Supported By',
        'Product'
    ];

    const rows: string[] = [headers.join(',')];

    integrations.forEach(integration => {
        const products = integration.products && integration.products.length > 0
            ? integration.products
            : [''];

        const certStatus = integration.support === 'Supported' ? 'Certified' :
                          integration.support === 'Community' ? 'Community' : '';

        products.forEach(product => {
            const row = [
                escapeCsvCell(integration.name),
                escapeCsvCell(LISTING_TYPE_NAMES[listingTypeOf(integration)]),
                escapeCsvCell(integration.description),
                escapeCsvCell(certStatus),
                escapeCsvCell(integration.author),
                escapeCsvCell(integration.supported_by || ''),
                escapeCsvCell(product)
            ];
            rows.push(row.join(','));
        });
    });

    return rows.join('\n');
}

function downloadCsv(csvContent: string, filename: string): void {
    const BOM = '﻿';
    const blob = new Blob([BOM + csvContent], { type: 'text/csv;charset=utf-8;' });

    const link = document.createElement('a');
    const url = URL.createObjectURL(blob);

    link.setAttribute('href', url);
    link.setAttribute('download', filename);
    link.style.visibility = 'hidden';

    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);

    URL.revokeObjectURL(url);
}

export function exportIntegrationsToCSV(integrations: IntegrationMetadata[]): void {
    const date = new Date().toISOString().split('T')[0];
    const filename = `ngts-integrations-export-${date}.csv`;

    const csvContent = generateCsvContent(integrations);

    downloadCsv(csvContent, filename);
}
