import { jsx as _jsx, jsxs as _jsxs } from "react/jsx-runtime";
import { memo } from 'react';
/**
 * Composant pour un élément du menu système
 * @param props - Les propriétés du composant
 * @returns JSX.Element
 */
const SystemMenuItem = memo(({ id, label, ariaLabel, onClick, className = 'btn btn-sm btn-ghost justify-start !px-3 !mx-1 text-xs sm:text-sm transition-all duration-200 hover:scale-[1.01] hover:bg-base-300 focus:ring-2 focus:ring-primary', icon }) => {
    return (_jsxs("button", { id: id, className: className, onClick: onClick, "aria-label": ariaLabel, children: [icon && (_jsx("span", { className: "mr-2", children: icon })), label] }));
});
// Nom d'affichage pour le débogage
SystemMenuItem.displayName = 'SystemMenuItem';
export default SystemMenuItem;
