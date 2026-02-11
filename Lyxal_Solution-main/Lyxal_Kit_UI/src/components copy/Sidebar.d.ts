import React from 'react';
/**
 * Type pour identifier les composants de contenu disponibles
 */
type ContentComponentId = 'dashboard' | 'logs' | 'errors' | 'users' | 'system' | 'monitoring' | 'i18n' | 'default';
/**
 * Props pour le composant Sidebar
 * @interface SidebarProps
 */
interface SidebarProps {
    /** État d'ouverture/fermeture de la sidebar */
    isOpen: boolean;
    /** Callback appelé lors du toggle de la sidebar */
    onToggle: () => void;
    /** Callback appelé lors du changement de contenu sélectionné */
    onContentChange?: (contentId: ContentComponentId) => void;
    /** ID du contenu actuellement sélectionné */
    selectedContentId?: ContentComponentId;
}
/**
 * Composant Sidebar optimisé avec memoization et performance
 * Applique les mêmes standards que le Header selon la feuille de route
 * Préserve parfaitement la structure et fonctionnalité existante
 * @param props - Les propriétés du composant
 * @returns JSX.Element
 */
declare const Sidebar: React.FC<SidebarProps>;
export default Sidebar;
