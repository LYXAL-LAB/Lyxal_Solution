import React from 'react';
/**
 * Type pour identifier les composants de contenu disponibles
 */
export type ContentComponentId = 'dashboard' | 'logs' | 'errors' | 'users' | 'system' | 'monitoring' | 'i18n' | 'buttons' | 'buttons-advanced' | 'button-custom' | 'daisyui-tester' | 'default';
/**
 * Props pour le composant ContentWrapper
 * @interface ContentWrapperProps
 */
interface ContentWrapperProps {
    /** ID du composant de contenu à afficher */
    selectedContentId: ContentComponentId;
    /** Contenu par défaut (children) si aucun composant spécifique n'est sélectionné */
    children?: React.ReactNode;
}
/**
 * Composant ContentWrapper - Wrapper centré pour le contenu principal
 * Affiche des composants en fonction du menu sélectionné (sans système de routes)
 * @param props - Les propriétés du composant
 * @returns JSX.Element
 */
declare const ContentWrapper: React.FC<ContentWrapperProps>;
export default ContentWrapper;
