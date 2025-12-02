import { jsx as _jsx, jsxs as _jsxs } from "react/jsx-runtime";
import { memo, useMemo } from 'react';
import ErrorCodes from './pages/ErrorCodes';
/**
 * Composants de contenu par défaut (placeholders)
 */
const ContentComponents = {
    dashboard: () => (_jsxs("div", { className: "text-center", children: [_jsx("h2", { className: "text-2xl font-bold mb-4", children: "Tableau de bord" }), _jsx("p", { className: "text-base-content/70", children: "Contenu du tableau de bord \u00E0 venir" })] })),
    logs: () => (_jsxs("div", { className: "text-center", children: [_jsx("h2", { className: "text-2xl font-bold mb-4", children: "Logs" }), _jsx("p", { className: "text-base-content/70", children: "Gestion des logs syst\u00E8me" })] })),
    errors: () => _jsx(ErrorCodes, {}),
    users: () => (_jsxs("div", { className: "text-center", children: [_jsx("h2", { className: "text-2xl font-bold mb-4", children: "Utilisateurs" }), _jsx("p", { className: "text-base-content/70", children: "Gestion des utilisateurs" })] })),
    system: () => (_jsxs("div", { className: "text-center", children: [_jsx("h2", { className: "text-2xl font-bold mb-4", children: "Syst\u00E8me" }), _jsx("p", { className: "text-base-content/70", children: "Configuration syst\u00E8me" })] })),
    monitoring: () => (_jsxs("div", { className: "text-center", children: [_jsx("h2", { className: "text-2xl font-bold mb-4", children: "Monitoring" }), _jsx("p", { className: "text-base-content/70", children: "Surveillance du syst\u00E8me" })] })),
    i18n: () => (_jsxs("div", { className: "text-center", children: [_jsx("h2", { className: "text-2xl font-bold mb-4", children: "Internationalisation" }), _jsx("p", { className: "text-base-content/70", children: "Gestion des traductions" })] })),
    default: () => (_jsxs("div", { className: "text-center", children: [_jsx("h2", { className: "text-2xl font-bold mb-4", children: "Bienvenue" }), _jsx("p", { className: "text-base-content/70", children: "S\u00E9lectionnez un \u00E9l\u00E9ment du menu pour commencer" })] })),
};
/**
 * Composant ContentWrapper - Wrapper centré pour le contenu principal
 * Affiche des composants en fonction du menu sélectionné (sans système de routes)
 * @param props - Les propriétés du composant
 * @returns JSX.Element
 */
const ContentWrapper = memo(({ selectedContentId, children }) => {
    // Sélectionner le composant à afficher
    const SelectedComponent = useMemo(() => {
        return ContentComponents[selectedContentId] || ContentComponents.default;
    }, [selectedContentId]);
    return (_jsx("div", { id: "content-wrapper", className: "h-full w-full overflow-auto", children: _jsx("div", { className: "w-full max-w-7xl mx-auto p-8", children: _jsx(SelectedComponent, {}) }) }));
});
// Nom d'affichage pour le débogage
ContentWrapper.displayName = 'ContentWrapper';
export default ContentWrapper;
