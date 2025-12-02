import { jsx as _jsx, jsxs as _jsxs } from "react/jsx-runtime";
import { memo, useMemo } from 'react';
/**
 * Composant optimisé pour afficher un aperçu des couleurs d'un thème
 * Utilise React.memo pour éviter les re-renders inutiles
 * @param props - Les propriétés du composant
 * @returns JSX.Element
 */
const ThemeColorPreview = memo(({ theme, className = "mr-3" }) => {
    // Memoization de l'ID pour éviter les recalculs
    const previewId = useMemo(() => `theme-preview-${theme}`, [theme]);
    const containerId = useMemo(() => `theme-preview-container-${theme}`, [theme]);
    const gridId = useMemo(() => `theme-preview-grid-${theme}`, [theme]);
    // Memoization des IDs des couleurs
    const colorIds = useMemo(() => ({
        primary: `theme-preview-primary-${theme}`,
        secondary: `theme-preview-secondary-${theme}`,
        accent: `theme-preview-accent-${theme}`,
        neutral: `theme-preview-neutral-${theme}`
    }), [theme]);
    // Memoization de l'aria-label
    const ariaLabel = useMemo(() => `Aperçu des couleurs du thème ${theme}`, [theme]);
    return (_jsx("div", { id: previewId, className: `w-6 h-6 flex-shrink-0 overflow-hidden p-0.5 transition-all duration-200 ease-in-out hover:scale-105 isolate rounded-lg border border-base-content/20 ${className}`, style: {
            isolation: 'isolate'
        }, role: "img", "aria-label": ariaLabel, children: _jsx("div", { id: containerId, className: "w-full h-full !p-0.5", "data-theme": theme, children: _jsxs("div", { id: gridId, className: "w-full h-full grid grid-cols-2 grid-rows-2 gap-0.5", children: [_jsx("div", { id: colorIds.primary, className: "bg-primary rounded-full w-2 h-2 transition-colors duration-150", "aria-hidden": "true" }), _jsx("div", { id: colorIds.secondary, className: "bg-secondary rounded-full w-2 h-2 transition-colors duration-150", "aria-hidden": "true" }), _jsx("div", { id: colorIds.accent, className: "bg-accent rounded-full w-2 h-2 transition-colors duration-150", "aria-hidden": "true" }), _jsx("div", { id: colorIds.neutral, className: "bg-neutral rounded-full w-2 h-2 transition-colors duration-150", "aria-hidden": "true" })] }) }) }));
});
// Nom d'affichage pour le débogage
ThemeColorPreview.displayName = 'ThemeColorPreview';
export default ThemeColorPreview;
