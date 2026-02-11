import React from 'react';
/**
 * Props pour le composant Sidebar
 * @interface SidebarProps
 */
interface SidebarProps {
    /** État d'ouverture/fermeture de la sidebar */
    isOpen: boolean;
    /** Callback appelé lors du toggle de la sidebar */
    onToggle: () => void;
}
/**
 * Copie legacy de Sidebar avant refonte (menu dynamique piloté DB)
 */
declare const SidebarLegacy: React.FC<SidebarProps>;
export default SidebarLegacy;
