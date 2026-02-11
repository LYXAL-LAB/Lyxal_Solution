import React, { memo } from 'react';

/**
 * Props pour le composant SystemMenuItem
 * @interface SystemMenuItemProps
 */
interface SystemMenuItemProps {
  /** ID unique de l'élément */
  id: string;
  /** Label affiché */
  label: string;
  /** Label ARIA pour l'accessibilité */
  ariaLabel: string;
  /** Callback appelé lors du clic */
  onClick?: (() => void) | undefined;
  /** Classes CSS additionnelles */
  className?: string;
  /** Icône optionnelle (JSX) */
  icon?: React.ReactNode;
}

/**
 * Composant pour un élément du menu système
 * @param props - Les propriétés du composant
 * @returns JSX.Element
 */
const SystemMenuItem: React.FC<SystemMenuItemProps> = memo(({
  id,
  label,
  ariaLabel,
  onClick,
  className = 'btn btn-sm btn-ghost justify-start !px-3 !mx-1 text-xs sm:text-sm transition-all duration-200 hover:scale-[1.01] hover:bg-base-300 focus:ring-2 focus:ring-primary',
  icon
}) => {
  return (
    <button 
      id={id}
      className={className}
      onClick={onClick}
      aria-label={ariaLabel}
    >
      {icon && (
        <span className="mr-2">
          {icon}
        </span>
      )}
      {label}
    </button>
  );
});

// Nom d'affichage pour le débogage
SystemMenuItem.displayName = 'SystemMenuItem';

export default SystemMenuItem; 