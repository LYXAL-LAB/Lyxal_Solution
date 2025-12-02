import React from 'react';
/**
 * Props pour le composant Footer
 * @interface FooterProps
 */
interface FooterProps {
    /** Nom de l'entreprise à afficher dans le copyright */
    companyName?: string;
    /** Thème actuellement sélectionné (pour support multi-thèmes) */
    currentTheme?: string;
    /** Callback optionnel appelé lors du clic sur le copyright */
    onCopyrightClick?: () => void;
}
/**
 * Composant Footer optimisé avec memoization et performance
 * Applique les mêmes standards que le Header selon la feuille de route
 * @param props - Les propriétés du composant
 * @returns JSX.Element
 */
declare const Footer: React.FC<FooterProps>;
export default Footer;
