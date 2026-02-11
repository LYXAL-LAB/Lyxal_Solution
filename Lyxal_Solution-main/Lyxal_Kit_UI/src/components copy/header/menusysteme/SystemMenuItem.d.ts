import React from 'react';
/**
 * Props pour le composant SystemMenuItem
 * @interface SystemMenuItemProps
 */
interface SystemMenuItemProps {
    /** ID unique de l'élément */
    id: string;
    /** Label affiché */
    label: string;
    /** Label ARIA pour l'accessibilité */
    ariaLabel: string;
    /** Callback appelé lors du clic */
    onClick?: (() => void) | undefined;
    /** Classes CSS additionnelles */
    className?: string;
    /** Icône optionnelle (JSX) */
    icon?: React.ReactNode;
}
/**
 * Composant pour un élément du menu système
 * @param props - Les propriétés du composant
 * @returns JSX.Element
 */
declare const SystemMenuItem: React.FC<SystemMenuItemProps>;
export default SystemMenuItem;
