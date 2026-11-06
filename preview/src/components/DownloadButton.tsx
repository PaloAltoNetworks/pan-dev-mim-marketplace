import React, { useState } from 'react';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';

interface DownloadButtonProps {
    filename: string;
    url: string;
}

export default function DownloadButton({ filename, url }: DownloadButtonProps): React.JSX.Element {
    const [isDownloading, setIsDownloading] = useState(false);
    const [error, setError] = useState<string | null>(null);
    const { siteConfig: { baseUrl } } = useDocusaurusContext();

    const handleDownload = async () => {
        setIsDownloading(true);
        setError(null);

        try {
            // url is generated as a root-relative path; join with baseUrl so it still
            // resolves on non-root deploys (e.g. per-branch preview builds under /<branch>/).
            const resolvedUrl = `${baseUrl}${url.replace(/^\//, '')}`;
            const response = await fetch(resolvedUrl);

            if (!response.ok) {
                throw new Error(`Failed to download file: ${response.statusText}`);
            }

            const blob = await response.blob();

            // Create a download link and trigger it
            const blobUrl = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = blobUrl;
            a.download = filename;
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);

            // Clean up the blob URL
            setTimeout(() => URL.revokeObjectURL(blobUrl), 100);
        } catch (err) {
            console.error('Download failed:', err);
            setError(err instanceof Error ? err.message : 'Download failed');
        } finally {
            setIsDownloading(false);
        }
    };

    return (
        <div className="download-button-container">
            <button
                className="download-button"
                onClick={handleDownload}
                disabled={isDownloading}
                aria-label={`Download ${filename}`}
            >
                {isDownloading ? (
                    <>Downloading...</>
                ) : (
                    <>{filename}</>
                )}
            </button>
            {error && <div className="download-button-error">{error}</div>}
        </div>
    );
}
