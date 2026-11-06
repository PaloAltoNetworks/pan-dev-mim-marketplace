import React from "react";

// Marker component — content is extracted by IntegrationTabs via props inspection.
// This component is never rendered directly.
export default function IntegrationTabItem(_props: {
    value: string;
    label: string;
    default?: boolean;
    children: React.ReactNode;
}): React.ReactElement | null {
    return null;
}
