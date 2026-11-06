import React from 'react';
import { ListBuilderProvider } from '../contexts/ListBuilderContext';

export default function Root({ children }: { children: React.ReactNode }): React.JSX.Element {
    return (
        <ListBuilderProvider>
            {children}
        </ListBuilderProvider>
    );
}
