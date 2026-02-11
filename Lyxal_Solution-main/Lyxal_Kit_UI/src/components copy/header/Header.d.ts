import React from 'react';
/**
 * Props pour le composant Header principal
 * @interface HeaderProps
 */
interface HeaderProps {
    /** Thème actuellement sélectionné */
    currentTheme: string;
    /** Liste de tous les thèmes disponibles */
    themes: string[];
    /** Callback appelé lors du changement de thème */
    onThemeChange: (theme: string) => void;
    /** Callback pour ouvrir la modal de profil */
    onProfileModalOpen: () => void;
    /** État d'ouverture/fermeture de la sidebar */
    isSidebarOpen: boolean;
    /** Callback pour basculer l'état de la sidebar */
    onSidebarToggle: () => void;
    /** État d'ouverture/fermeture de l'agent IA */
    isAgentIAOpen: boolean;
    /** Callback pour basculer l'état de l'agent IA */
    onAgentIAToggle: () => void;
}
/**
 * Composant Header principal optimisé avec memoization et performance
 * Inclut navigation, sélecteur de thème, et menu système
 * Utilise la configuration système pour afficher le nom de la plateforme
 * @param props - Les propriétés du composant
 * @returns JSX.Element
 */
declare const Header: React.FC<HeaderProps>;
export default Header;
