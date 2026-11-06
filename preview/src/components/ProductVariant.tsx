import React, { useContext } from 'react';
import { ProductContext } from './IntegrationDetail';

export default function ProductVariant({
    product,
    children,
}: {
    product: string;
    children: React.ReactNode;
}) {
    const selectedProduct = useContext(ProductContext);
    if (selectedProduct !== product) return null;
    return <>{children}</>;
}
