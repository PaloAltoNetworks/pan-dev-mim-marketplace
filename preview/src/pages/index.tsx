import React from 'react';
import {Redirect} from '@docusaurus/router';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';

// The preview has no landing page of its own — send visitors straight to the marketplace grid.
// (pan-dev-mim's real index.tsx is intentionally not synced.)
export default function Home(): React.ReactElement {
    const {siteConfig: {baseUrl}} = useDocusaurusContext();
    return <Redirect to={`${baseUrl}marketplace`} />;
}
