import { jsx as _jsx, jsxs as _jsxs, Fragment as _Fragment } from "react/jsx-runtime";
import { memo, useMemo, useCallback, useState } from 'react';
import { announceToScreenReader } from '../../utils/accessibility';
import { useSystemConfig } from '../../hooks/useSystemConfig';
import { ConfigModal, SystemMenuItem } from './menusysteme';
import ThemeColorPreview from './ThemeColorPreview';
/**
 * Composant Header principal optimisé avec memoization et performance
 * Inclut navigation, sélecteur de thème, et menu système
 * Utilise la configuration système pour afficher le nom de la plateforme
 * @param props - Les propriétés du composant
 * @returns JSX.Element
 */
const Header = memo(({ currentTheme, themes, onThemeChange, onProfileModalOpen, isSidebarOpen, onSidebarToggle, isAgentIAOpen, onAgentIAToggle }) => {
    // Hook pour la configuration système
    const { config } = useSystemConfig();
    // État local pour la modal de configuration
    const [isConfigModalOpen, setIsConfigModalOpen] = useState(false);
    // Nom de la plateforme (défaut géré dans le hook)
    const platformName = useMemo(() => config.identity.platformName.value, [config.identity.platformName.value]);
    // Memoization du tri des thèmes pour éviter les recalculs
    const sortedThemes = useMemo(() => themes.sort((a, b) => a.localeCompare(b)), [themes]);
    // Memoization des labels ARIA avec le nom de plateforme dynamique
    const ariaLabels = useMemo(() => ({
        navbar: 'Navigation principale',
        mobileMenu: 'Ouvrir/fermer le menu de navigation',
        themeSelector: `Thème actuel: ${currentTheme}. Cliquer pour changer de thème`,
        systemMenu: 'Menu système et paramètres',
        themeDropdown: 'Sélection de thème',
        systemDropdown: 'Actions système',
        platformTitle: `Plateforme ${platformName}`
    }), [currentTheme, platformName]);
    // Callbacks optimisés avec useCallback
    const handleThemeChange = useCallback((theme) => {
        announceToScreenReader(`Thème changé vers ${theme}`, { priority: 'polite' });
        onThemeChange(theme);
    }, [onThemeChange]);
    const handleProfileModalOpen = useCallback(() => {
        announceToScreenReader('Ouverture de la console admin', { priority: 'polite' });
        onProfileModalOpen();
    }, [onProfileModalOpen]);
    const handleConfigModalOpen = useCallback(() => {
        announceToScreenReader('Ouverture de la configuration système', { priority: 'polite' });
        setIsConfigModalOpen(true);
    }, []);
    const handleConfigModalClose = useCallback(() => {
        setIsConfigModalOpen(false);
    }, []);
    const handleSidebarToggle = useCallback(() => {
        const message = isSidebarOpen ? 'Menu de navigation fermé' : 'Menu de navigation ouvert';
        announceToScreenReader(message, { priority: 'polite' });
        onSidebarToggle();
    }, [onSidebarToggle, isSidebarOpen]);
    const handleAgentIAToggle = useCallback(() => {
        announceToScreenReader(isAgentIAOpen ? 'Agent IA fermé' : 'Agent IA ouvert', { priority: 'polite' });
        onAgentIAToggle();
    }, [onAgentIAToggle, isAgentIAOpen]);
    const systemMenuItems = useMemo(() => [
        { id: 'menu-console-admin',
            label: 'Console Admin',
            ariaLabel: 'Ouvrir la console d\'administration',
            onClick: handleProfileModalOpen,
            className: 'btn btn-sm btn-ghost justify-start !px-3 !mx-1 text-xs sm:text-sm transition-all duration-200 hover:scale-[1.01] hover:bg-base-300 focus:ring-2 focus:ring-primary' },
        { id: 'menu-monitoring', label: 'Monitoring', ariaLabel: 'Accéder au monitoring système',
            onClick: undefined,
            className: 'btn btn-sm btn-ghost justify-start !px-3 !mx-1 text-xs sm:text-sm transition-all duration-200 hover:scale-[1.01] hover:bg-base-300 focus:ring-2 focus:ring-primary' },
        { id: 'menu-configuration', label: 'Configuration', ariaLabel: 'Ouvrir les paramètres de configuration', onClick: handleConfigModalOpen, className: 'btn btn-sm btn-ghost justify-start !px-3 !mx-1 text-xs sm:text-sm transition-all duration-200 hover:scale-[1.01] hover:bg-base-300 focus:ring-2 focus:ring-primary' },
        { id: 'menu-security', label: 'Sécurité', ariaLabel: 'Accéder aux paramètres de sécurité', onClick: undefined, className: 'btn btn-sm btn-ghost justify-start !px-3 !mx-1 text-xs sm:text-sm transition-all duration-200 hover:scale-[1.01] hover:bg-base-300 focus:ring-2 focus:ring-primary' },
        { id: 'menu-logout', label: 'Déconnexion', ariaLabel: 'Se déconnecter de l\'application', onClick: undefined, className: 'btn btn-sm btn-ghost justify-start text-error !px-3 !mx-1 text-xs sm:text-sm transition-all duration-200 hover:scale-[1.01] hover:bg-error hover:text-error-content focus:ring-2 focus:ring-error' }
    ], [handleProfileModalOpen, handleConfigModalOpen]);
    return (_jsxs(_Fragment, { children: [_jsx("nav", { id: "header-navbar", className: "navbar bg-base-100 border-b border-base-300 !px-4 sm:!px-6 lg:!px-8 transition-colors duration-200", role: "navigation", "aria-label": ariaLabels.navbar, children: _jsxs("div", { id: "header-content", className: "w-full flex items-center justify-between", children: [_jsxs("div", { id: "navbar-start", className: "navbar-start flex items-center", children: [_jsx("button", { id: "mobile-menu-btn", className: "btn btn-ghost btn-circle lg:hidden mr-2 sm:mr-3 transition-all duration-200 hover:scale-105 focus:ring-2 focus:ring-primary focus:ring-offset-2", onClick: handleSidebarToggle, "aria-label": ariaLabels.mobileMenu, "aria-expanded": isSidebarOpen, "aria-controls": "sidebar", children: _jsx("svg", { id: "mobile-menu-icon", className: "w-5 h-5 sm:w-6 sm:h-6", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24", children: _jsx("path", { id: "mobile-menu-path", strokeLinecap: "round", strokeLinejoin: "round", strokeWidth: "2", d: "M4 6h16M4 12h16M4 18h16" }) }) }), !isSidebarOpen && (_jsx("div", { className: "h-10 flex flex-col items-center justify-center", children: _jsx("h1", { id: "header-title", className: "text-lg sm:text-xl font-bold text-primary !m-0 !mb-0", children: platformName }) }))] }), _jsx("div", { id: "navbar-center", className: "navbar-center hidden sm:block", "data-testid": "breadcrumb-container", children: _jsx("div", { id: "breadcrumb", className: "text-sm breadcrumbs", children: _jsxs("ul", { id: "breadcrumb-list", children: [_jsx("li", { id: "breadcrumb-lyxal", children: _jsx("a", { id: "breadcrumb-lyxal-link", children: "LYXAL" }) }), _jsx("li", { id: "breadcrumb-level", children: _jsx("a", { id: "breadcrumb-level-link", children: "Niveau 0" }) }), _jsx("li", { id: "breadcrumb-current", children: "Dashboard" })] }) }) }), _jsx("div", { id: "navbar-end", className: "navbar-end", children: _jsxs("div", { id: "navbar-actions", className: "flex items-center gap-1 sm:gap-2", children: [_jsx("button", { id: "agent-ia-toggle-btn", onClick: handleAgentIAToggle, className: `btn btn-ghost btn-circle transition-all duration-200 hover:scale-105 focus:ring-2 focus:ring-primary focus:ring-offset-2 ${isAgentIAOpen ? 'btn-active' : ''}`, "aria-label": isAgentIAOpen ? 'Fermer l\'agent IA' : 'Ouvrir l\'agent IA', "aria-expanded": isAgentIAOpen, role: "button", children: _jsx("svg", { className: "w-5 h-5 sm:w-6 sm:h-6", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24", "aria-hidden": "true", children: _jsx("path", { strokeLinecap: "round", strokeLinejoin: "round", strokeWidth: "2", d: "M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z" }) }) }), _jsxs("div", { id: "theme-selector", className: "dropdown dropdown-end", children: [_jsx("div", { id: "theme-selector-btn", tabIndex: 0, role: "button", className: "btn btn-ghost btn-circle p-1 transition-all duration-200 hover:scale-105 focus:ring-2 focus:ring-primary focus:ring-offset-2", "aria-label": ariaLabels.themeSelector, "aria-haspopup": "menu", "aria-expanded": "false", "data-testid": "theme-preview-button", children: _jsx(ThemeColorPreview, { theme: currentTheme, className: "" }) }), _jsx("div", { id: "theme-dropdown", tabIndex: 0, className: "dropdown-content bg-base-200 z-[1000] w-64 sm:w-72 p-2 shadow-lg border border-base-300 mt-2 animate-in fade-in duration-200 overflow-hidden", style: {
                                                    borderRadius: 'var(--radius-box, 0.5rem)',
                                                    border: 'var(--border, 1px) solid',
                                                    isolation: 'isolate'
                                                }, role: "menu", "aria-label": ariaLabels.themeDropdown, "data-theme": currentTheme, children: _jsxs("div", { id: "theme-dropdown-container", className: "w-full !p-2", children: [_jsx("h3", { className: "font-semibold text-sm mb-3 text-base-content", children: "Choisir un th\u00E8me" }), _jsx("div", { className: "grid grid-cols-1 gap-2 max-h-64 overflow-y-auto overflow-x-hidden !py-1", children: sortedThemes.map((theme) => (_jsxs("button", { onClick: () => handleThemeChange(theme), className: `btn btn-sm justify-start gap-3 !px-3 !mx-1 transition-all duration-200 hover:scale-[1.01] focus:ring-2 focus:ring-primary focus:ring-offset-1 ${currentTheme === theme ? 'btn-primary' : 'btn-ghost hover:bg-base-300'}`, style: { borderRadius: 'var(--radius-field, 0.25rem)' }, role: "menuitem", "aria-label": `Sélectionner le thème ${theme}`, "aria-current": currentTheme === theme ? 'true' : 'false', children: [_jsx(ThemeColorPreview, { theme: theme }), _jsx("span", { className: "capitalize text-left flex-1 text-xs sm:text-sm", children: theme }), currentTheme === theme && (_jsx("svg", { id: `theme-check-${theme}`, className: "w-3 h-3 sm:w-4 sm:h-4 text-primary-content", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24", children: _jsx("path", { strokeLinecap: "round", strokeLinejoin: "round", strokeWidth: "2", d: "M5 13l4 4L19 7" }) }))] }, theme))) })] }) })] }), _jsxs("div", { id: "system-menu", className: "dropdown dropdown-end", children: [_jsx("div", { id: "system-menu-btn", tabIndex: 0, role: "button", className: "btn btn-ghost btn-circle transition-all duration-200 hover:scale-105 focus:ring-2 focus:ring-primary focus:ring-offset-2", "aria-label": ariaLabels.systemMenu, "aria-haspopup": "menu", "aria-expanded": "false", children: _jsxs("svg", { id: "system-menu-icon", className: "w-5 h-5 sm:w-6 sm:h-6", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24", children: [_jsx("path", { id: "system-menu-path-1", strokeLinecap: "round", strokeLinejoin: "round", strokeWidth: "2", d: "M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" }), _jsx("path", { id: "system-menu-path-2", strokeLinecap: "round", strokeLinejoin: "round", strokeWidth: "2", d: "M15 12a3 3 0 11-6 0 3 3 0 016 0z" })] }) }), _jsx("div", { id: "system-menu-dropdown", tabIndex: 0, className: "dropdown-content bg-base-200 z-[1] w-48 sm:w-52 max-h-80 overflow-y-auto overflow-x-hidden p-2 shadow-lg border border-base-300 mt-2 animate-in fade-in duration-200 !right-0", style: {
                                                    borderRadius: 'var(--radius-box, 0.5rem)',
                                                    border: 'var(--border, 1px) solid'
                                                }, role: "menu", "aria-label": ariaLabels.systemDropdown, children: _jsx("div", { id: "system-menu-container", className: "w-full !p-2", children: _jsx("div", { className: "grid grid-cols-1 gap-2 max-h-80 overflow-y-auto overflow-x-hidden !py-1", children: systemMenuItems.map((item) => (_jsx(SystemMenuItem, { id: item.id, label: item.label, ariaLabel: item.ariaLabel, onClick: item.onClick, className: item.className }, item.id))) }) }) })] })] }) })] }) }), _jsx(ConfigModal, { isOpen: isConfigModalOpen, onClose: handleConfigModalClose })] }));
});
// Nom d'affichage pour le débogage
Header.displayName = 'Header';
export default Header;
