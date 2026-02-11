import { jsx as _jsx, jsxs as _jsxs } from "react/jsx-runtime";
import { memo, useMemo, useCallback } from 'react';
import { announceToScreenReader } from '../utils/accessibility';
import { useSystemConfig } from '../hooks/useSystemConfig';
import { IconRegistry } from '../services/IconRegistry';
/**
 * Composant Sidebar optimisé avec memoization et performance
 * Applique les mêmes standards que le Header selon la feuille de route
 * Préserve parfaitement la structure et fonctionnalité existante
 * @param props - Les propriétés du composant
 * @returns JSX.Element
 */
const Sidebar = memo(({ isOpen, onToggle, onContentChange, selectedContentId = 'default' }) => {
    // Hook pour la configuration système
    const { config } = useSystemConfig();
    // Nom de la plateforme (valeur par défaut gérée dans useSystemConfig)
    const platformName = useMemo(() => config.identity.platformName.value, [config.identity.platformName.value]);
    // Mapping des IDs du menu vers les ContentComponentId
    const menuIdToContentId = useCallback((menuId) => {
        const mapping = {
            'dashboard': 'dashboard',
            'system-config': 'system',
            'logs': 'logs',
            'errors': 'errors',
            'monitoring': 'monitoring',
            'users': 'users',
            'i18n': 'i18n',
            'settings': 'default'
        };
        return mapping[menuId] || 'default';
    }, []);
    // Menu statique pour Lyxal_System v1
    const items = useMemo(() => [
        {
            id: 'dashboard',
            name: 'Tableau de bord',
            tooltip: 'Accéder au tableau de bord',
            icon: IconRegistry.get('dashboard'),
            onClick: () => {
                onContentChange?.('dashboard');
            }
        },
        {
            id: 'system-config',
            name: 'Configuration',
            tooltip: 'Configuration du système',
            icon: IconRegistry.get('system'),
            onClick: () => {
                onContentChange?.('system');
            }
        },
        {
            id: 'logs',
            name: 'Logs',
            tooltip: 'Consulter les logs système',
            icon: IconRegistry.get('logs'),
            onClick: () => {
                onContentChange?.('logs');
            }
        },
        {
            id: 'errors',
            name: 'Codes d\'erreur',
            tooltip: 'Gérer les codes d\'erreur',
            icon: IconRegistry.get('errors'),
            onClick: () => {
                onContentChange?.('errors');
            }
        },
        {
            id: 'monitoring',
            name: 'Monitoring',
            tooltip: 'Surveillance du système',
            icon: IconRegistry.get('monitoring'),
            onClick: () => {
                onContentChange?.('monitoring');
            }
        },
        {
            id: 'users',
            name: 'Utilisateurs',
            tooltip: 'Gestion des utilisateurs',
            icon: IconRegistry.get('users'),
            onClick: () => {
                onContentChange?.('users');
            }
        },
        {
            id: 'i18n',
            name: 'Internationalisation',
            tooltip: 'Gérer les traductions',
            icon: IconRegistry.get('i18n'),
            onClick: () => {
                onContentChange?.('i18n');
            }
        },
        {
            id: 'settings',
            name: 'Paramètres',
            tooltip: 'Paramètres généraux',
            icon: IconRegistry.get('settings'),
            onClick: () => {
                onContentChange?.('default');
            }
        }
    ], [onContentChange]);
    // Memoization des labels ARIA
    const ariaLabels = useMemo(() => ({
        sidebar: isOpen ? 'Navigation principale ouverte' : 'Navigation principale fermée',
        toggleButton: isOpen ? 'Fermer la navigation' : 'Ouvrir la navigation',
        navigationMenu: 'Menu de navigation principal'
    }), [isOpen]);
    // Memoization des classes CSS - préservation exacte de la structure originale
    const containerClasses = useMemo(() => `bg-base-100 border-r border-base-300 transition-all duration-700 ease-in-out h-screen flex flex-col gap-6 ${isOpen ? 'w-64' : 'w-16'}`, [isOpen]);
    const headerClasses = useMemo(() => `transition-all duration-700 ease-in-out !pt-4 ${!isOpen ? '!px-2 !pb-4' : '!px-4 !pb-4'}`, [isOpen]);
    const headerContentClasses = useMemo(() => `flex items-center transition-all duration-700 ease-in-out ${!isOpen ? 'justify-center' : ''}`, [isOpen]);
    const toggleWrapperClasses = useMemo(() => `flex flex-row transition-all duration-700 ease-in-out ${!isOpen ? 'w-[90%] mx-auto' : 'w-full'}`, [isOpen]);
    // Callback optimisé pour le toggle
    const handleToggle = useCallback(() => {
        const message = isOpen ? 'Navigation fermée' : 'Navigation ouverte';
        announceToScreenReader(message, { priority: 'polite' });
        onToggle();
    }, [onToggle, isOpen]);
    // Callback optimisé pour la navigation
    const handleNavigation = useCallback((item) => {
        announceToScreenReader(`Navigation vers ${item.name}`, { priority: 'polite' });
        item.onClick?.();
    }, []);
    // Fonction pour rendre un élément de navigation - préservation exacte de la structure
    const renderNavigationItem = useCallback((item) => {
        // Vérifier si cet élément est actif
        const itemContentId = menuIdToContentId(item.id);
        const isActive = selectedContentId === itemContentId;
        const buttonClasses = `btn transition-all duration-700 ease-in-out flex items-center ${isActive ? 'btn-active btn-primary' : 'btn-ghost'} ${isOpen ? 'w-full justify-start !pl-2' : 'w-full justify-center'} ${!isOpen ? 'tooltip tooltip-right before:!px-3 before:!py-2' : ''}`;
        return (_jsx("div", { id: `${item.id}-content`, className: "flex items-center justify-center transition-all duration-700 ease-in-out", children: _jsx("div", { id: `${item.id}-wrapper`, className: "transition-all duration-700 ease-in-out w-[90%] mx-auto", children: _jsxs("button", { id: item.id, className: buttonClasses, "data-tip": !isOpen ? item.tooltip : undefined, onClick: () => handleNavigation(item), "aria-label": `Naviguer vers ${item.name}`, role: "menuitem", children: [item.icon, isOpen && (_jsx("span", { className: "ml-3 transition-all duration-700 ease-in-out whitespace-nowrap", children: item.name }))] }) }) }, item.id));
    }, [isOpen, handleNavigation, selectedContentId, menuIdToContentId]);
    return (_jsxs("div", { id: "sidebar-container", className: containerClasses, role: "navigation", "aria-label": ariaLabels.sidebar, "aria-expanded": isOpen, children: [_jsx("div", { id: "sidebar-header", className: headerClasses, children: _jsx("div", { id: "sidebar-header-content", className: headerContentClasses, children: _jsx("div", { id: "toggle-wrapper", className: toggleWrapperClasses, children: _jsxs("button", { id: "sidebar-toggle-btn", onClick: handleToggle, className: `btn btn-ghost h-10 transition-all duration-700 ease-in-out flex items-center ${isOpen ? 'w-full justify-start' : 'w-full justify-center'}`, "aria-label": ariaLabels.toggleButton, "aria-expanded": isOpen, role: "button", children: [_jsx("svg", { className: "w-6 h-6 flex-shrink-0 transition-all duration-700 ease-in-out", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24", "aria-hidden": "true", children: _jsx("path", { strokeLinecap: "round", strokeLinejoin: "round", strokeWidth: "2", d: "M4 6h16M4 12h16M4 18h16" }) }), isOpen && (_jsx("span", { className: "text-xl font-bold text-primary transition-all duration-700 ease-in-out whitespace-nowrap ml-3", "aria-label": `Logo ${platformName}`, children: platformName }))] }) }) }) }), _jsx("div", { id: "sidebar-menu", className: `space-y-1 transition-all duration-700 ease-in-out ${isOpen ? 'px-2' : '!px-2'}`, role: "menu", "aria-label": ariaLabels.navigationMenu, children: items.map(renderNavigationItem) })] }));
});
// Nom d'affichage pour le débogage
Sidebar.displayName = 'Sidebar';
export default Sidebar;
