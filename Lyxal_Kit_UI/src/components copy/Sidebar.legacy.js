import { jsx as _jsx, jsxs as _jsxs } from "react/jsx-runtime";
import { memo, useMemo, useCallback } from 'react';
import { announceToScreenReader } from '../utils/accessibility';
import { useSystemConfig } from '../hooks/useSystemConfig';
/**
 * Copie legacy de Sidebar avant refonte (menu dynamique piloté DB)
 */
const SidebarLegacy = memo(({ isOpen, onToggle }) => {
    const { config } = useSystemConfig();
    const platformName = useMemo(() => config.identity.platformName.value, [config.identity.platformName.value]);
    const modules = config.ui?.modules || {};
    const allItems = useMemo(() => [
        { id: 'dashboard', name: 'Dashboard', tooltip: 'Dashboard', icon: (_jsxs("svg", { className: "w-5 h-5 flex-shrink-0 transition-all duration-700 ease-in-out", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24", "aria-hidden": "true", children: [_jsx("path", { strokeLinecap: "round", strokeLinejoin: "round", strokeWidth: "2", d: "M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2H5a2 2 0 00-2-2z" }), _jsx("path", { strokeLinecap: "round", strokeLinejoin: "round", strokeWidth: "2", d: "M8 5a2 2 0 012-2h4a2 2 0 012 2v2H8V5z" })] })) },
        { id: 'investors', name: 'Investisseurs', tooltip: 'Investisseurs', icon: (_jsx("svg", { className: "w-5 h-5 flex-shrink-0 transition-all duration-700 ease-in-out", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24", "aria-hidden": "true", children: _jsx("path", { strokeLinecap: "round", strokeLinejoin: "round", strokeWidth: "2", d: "M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 0 1 5.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 0 1 9.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" }) })) },
        { id: 'platforms', name: 'Plateformes', tooltip: 'Plateformes', icon: (_jsx("svg", { className: "w-5 h-5 flex-shrink-0 transition-all dur\u00E9e-700 ease-in-out", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24", "aria-hidden": "true", children: _jsx("path", { strokeLinecap: "round", strokeLinejoin: "round", strokeWidth: "2", d: "M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v2M7 7h10" }) })) },
        { id: 'analytics', name: 'Analytics', tooltip: 'Analytics', icon: (_jsx("svg", { className: "w-5 h-5 flex-shrink-0 transition-all duration-700 ease-in-out", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24", "aria-hidden": "true", children: _jsx("path", { strokeLinecap: "round", strokeLinejoin: "round", strokeWidth: "2", d: "M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" }) })) },
        { id: 'finance', name: 'Finance', tooltip: 'Finance', icon: (_jsx("svg", { className: "w-5 h-5 flex-shrink-0 transition-all duration-700 ease-in-out", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24", "aria-hidden": "true", children: _jsx("path", { strokeLinecap: "round", strokeLinejoin: "round", strokeWidth: "2", d: "M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" }) })) },
        { id: 'integrations', name: 'Intégrations', tooltip: 'Intégrations', icon: (_jsx("svg", { className: "w-5 h-5 flex-shrink-0 transition-all duration-700 ease-in-out", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24", "aria-hidden": "true", children: _jsx("path", { strokeLinecap: "round", strokeLinejoin: "round", strokeWidth: "2", d: "M13 7H7v6m0 0h6m-6 0l8 8 6-6-8-8-6 6z" }) })) },
        { id: 'settings', name: 'Paramètres', tooltip: 'Paramètres', icon: (_jsxs("svg", { className: "w-5 h-5 flex-shrink-0 transition-all duration-700 ease-in-out", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24", "aria-hidden": "true", children: [_jsx("path", { strokeLinecap: "round", strokeLinejoin: "round", strokeWidth: "2", d: "M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" }), _jsx("path", { strokeLinecap: "round", strokeLinejoin: "round", strokeWidth: "2", d: "M15 12a3 3 0 11-6 0 3 3 0 016 0z" })] })) },
    ], []);
    const items = useMemo(() => allItems.filter(i => modules[i.id] !== false), [allItems, modules]);
    const ariaLabels = useMemo(() => ({
        sidebar: isOpen ? 'Navigation principale ouverte' : 'Navigation principale fermée',
        toggleButton: isOpen ? 'Fermer la navigation' : 'Ouvrir la navigation',
        navigationMenu: 'Menu de navigation principal'
    }), [isOpen]);
    const containerClasses = useMemo(() => `bg-base-100 border-r border-base-300 transition-all duration-700 ease-in-out h-screen flex flex-col gap-6 ${isOpen ? 'w-64' : 'w-16'}`, [isOpen]);
    const headerClasses = useMemo(() => `transition-all duration-700 ease-in-out ${!isOpen ? '!pt-4 !px-2' : '!p-4'}`, [isOpen]);
    const headerContentClasses = useMemo(() => `flex items-center transition-all duration-700 ease-in-out ${!isOpen ? 'justify-center' : ''}`, [isOpen]);
    const toggleWrapperClasses = useMemo(() => `flex flex-row transition-all duration-700 ease-in-out ${!isOpen ? 'w-[90%] mx-auto' : 'w-full'}`, [isOpen]);
    const handleToggle = useCallback(() => {
        const message = isOpen ? 'Navigation fermée' : 'Navigation ouverte';
        announceToScreenReader(message, { priority: 'polite' });
        onToggle();
    }, [onToggle, isOpen]);
    const handleNavigation = useCallback((item) => {
        announceToScreenReader(`Navigation vers ${item.name}`, { priority: 'polite' });
        item.onClick?.();
    }, []);
    const renderNavigationItem = useCallback((item) => {
        const buttonClasses = `btn btn-ghost w-full transition-all durée-700 ease-in-out ${!isOpen ? 'justify-center' : 'justify-start !pl-2'} ${!isOpen ? 'tooltip tooltip-right before:!px-3 before:!py-2' : ''}`;
        return (_jsx("div", { id: `${item.id}-content`, className: "flex items-center justify-center transition-all duration-700 ease-in-out", children: _jsx("div", { id: `${item.id}-wrapper`, className: "w-[90%] mx-auto transition-all duration-700 ease-in-out", children: _jsxs("button", { id: item.id, className: buttonClasses, "data-tip": !isOpen ? item.tooltip : undefined, onClick: () => handleNavigation(item), "aria-label": `Naviguer vers ${item.name}`, role: "menuitem", children: [item.icon, isOpen && _jsx("span", { className: "ml-3 transition-all duration-700 ease-in-out", children: item.name })] }) }) }, item.id));
    }, [isOpen, handleNavigation]);
    return (_jsxs("div", { id: "sidebar-container", className: containerClasses, role: "navigation", "aria-label": ariaLabels.sidebar, "aria-expanded": isOpen, children: [_jsx("div", { id: "sidebar-header", className: headerClasses, children: _jsx("div", { id: "sidebar-header-content", className: headerContentClasses, children: _jsx("div", { id: "toggle-wrapper", className: toggleWrapperClasses, children: _jsxs("button", { id: "sidebar-toggle-btn", onClick: handleToggle, className: "btn btn-ghost w-full h-10 transition-all duration-700 ease-in-out", "aria-label": ariaLabels.toggleButton, "aria-expanded": isOpen, role: "button", children: [_jsx("svg", { className: "w-6 h-6 transition-all dur\u00E9e-700 ease-in-out", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24", "aria-hidden": "true", children: _jsx("path", { strokeLinecap: "round", strokeLinejoin: "round", strokeWidth: "2", d: "M4 6h16M4 12h16M4 18h16" }) }), isOpen && (_jsx("span", { className: "ml-3 text-xl font-bold text-primary transition-all duration-700 ease-in-out", "aria-label": `Logo ${platformName}`, children: platformName }))] }) }) }) }), _jsx("div", { id: "sidebar-menu", className: "px-2 space-y-1 transition-all duration-700 ease-in-out", role: "menu", "aria-label": ariaLabels.navigationMenu, children: items.map(renderNavigationItem) })] }));
});
SidebarLegacy.displayName = 'SidebarLegacy';
export default SidebarLegacy;
