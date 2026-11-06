import React from 'react';

interface DocumentationLink {
    title: string;
    description?: string;
    url: string;
}

interface DocumentationTabProps {
    documentationLinks?: DocumentationLink[];
}

export default function DocumentationTab({
    documentationLinks
}: DocumentationTabProps): React.JSX.Element {
    // Show external documentation links
    if (!documentationLinks || documentationLinks.length === 0) {
        return (
            <div className="documentation-tab">
                <p>No documentation available for this integration.</p>
            </div>
        );
    }

    return (
        <div className="documentation-tab">
            <ul className="documentation-links-list">
                {documentationLinks.map((link, idx) => (
                    <li key={idx} className="documentation-link-item">
                        <a href={link.url} target="_blank" rel="noopener noreferrer">
                            <div className="documentation-link-content">
                                <span className="documentation-link-icon">📄</span>
                                <div>
                                    <div className="documentation-link-title">{link.title}</div>
                                    {link.description && (
                                        <div className="documentation-link-description">
                                            {link.description}
                                        </div>
                                    )}
                                </div>
                            </div>
                        </a>
                    </li>
                ))}
            </ul>
        </div>
    );
}
