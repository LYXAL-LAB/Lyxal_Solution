import React from 'react';
/**
 * Props pour le composant ThemeColorPreview
 * @interface ThemeColorPreviewProps
 */
interface ThemeColorPreviewProps {
    /** Nom du thème à prévisualiser */
    theme: string;
    /** Classes CSS additionnelles (optionnel) */
    className?: string;
}
/**
 * Composant optimisé pour afficher un aperçu des couleurs d'un thème
 * Utilise React.memo pour éviter les re-renders inutiles
 * @param props - Les propriétés du composant
 * @returns JSX.Element
 */
declare const ThemeColorPreview: React.FC<ThemeColorPreviewProps>;
export default ThemeColorPreview;
