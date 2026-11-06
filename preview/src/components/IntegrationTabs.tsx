import React, { useContext } from "react";
import { TabContext } from "./IntegrationDetail";

interface TabData {
    value: string;
    label: string;
    content: React.ReactNode;
    isDefault: boolean;
}

function extractTabs(children: React.ReactNode): TabData[] {
    const tabs: TabData[] = [];
    React.Children.forEach(children, (child) => {
        if (React.isValidElement(child)) {
            const props = child.props as Record<string, unknown>;
            tabs.push({
                value: props.value as string,
                label: props.label as string,
                content: props.children as React.ReactNode,
                isDefault: !!(props.default),
            });
        }
    });
    return tabs;
}

export default function IntegrationTabs({ children }: { children: React.ReactNode }) {
    const tabs = extractTabs(children);
    const defaultTab = tabs.find((t) => t.isDefault) ?? tabs[0];
    // Selection lives in TabContext (provided by IntegrationDetail) rather than local state,
    // so a sibling — PrimaryCTA's "docs" banner — can switch to the Documentation tab.
    const { activeTab: selected, setActiveTab: setSelected } = useContext(TabContext);

    const activeTab = tabs.find((t) => t.value === selected) ?? defaultTab;

    return (
        <div className="integration-tabs">
            <div className="integration-tabs-bar" role="tablist">
                {tabs.map((tab) => {
                    const isActive = tab.value === activeTab?.value;
                    let className = "integration-tabs-tab";
                    if (isActive) className += " integration-tabs-tab--active";
                    return (
                        <button
                            key={tab.value}
                            role="tab"
                            aria-selected={isActive}
                            className={className}
                            onClick={() => setSelected(tab.value)}
                        >
                            {tab.label}
                        </button>
                    );
                })}
            </div>
            <div className="integration-content-card">
                {activeTab?.content}
            </div>
        </div>
    );
}
