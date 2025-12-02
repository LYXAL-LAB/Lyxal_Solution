import React, { ReactNode } from 'react';
/**
 * Props pour le composant Layout
 * @interface LayoutProps
 */
interface LayoutProps {
    /** Contenu principal à afficher dans le layout */
    children: ReactNode;
    /** Thème initial (optionnel, défaut: thème système) */
    initialTheme?: string;
    /** État initial de la sidebar (optionnel, défaut: responsive) */
    initialSidebarOpen?: boolean;
    /** Callback appelé lors du changement de thème (optionnel) */
    onThemeChange?: (theme: string) => void;
    /** Callback appelé lors du toggle de sidebar (optionnel) */
    onSidebarToggle?: (isOpen: boolean) => void;
    /** Props additionnelles pour le Footer (optionnel) */
    footerProps?: {
        companyName?: string;
        onCopyrightClick?: () => void;
    };
}
/**
 * Composant Layout principal orchestrant Header/Sidebar/Footer
 * Applique tous les standards de performance et d'accessibilité
 * Gère l'état global cohérent et les transitions fluides
 * Utilise le thème par défaut configuré dans le système
 * @param props - Les propriétés du composant
 * @returns JSX.Element
 */
declare const Layout: React.FC<LayoutProps>;
export default Layout;
