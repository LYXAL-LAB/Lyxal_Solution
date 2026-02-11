import React, { memo, useMemo, useCallback, useEffect, useState } from 'react';
import { announceToScreenReader } from '../../utils/accessibility';
import { useSystemConfig } from '../../hooks/useSystemConfig';
import { MenuService, type DbMenuItem } from '../../services/MenuService';
import { I18nService } from '../../services/I18nService';
import { EventRunner } from '../../services/EventRunner';
import { IconRegistry } from '../../services/IconRegistry';

/**
 * Props pour le composant Sidebar
 * @interface SidebarProps
 */
interface SidebarProps {
  /** État d'ouverture/fermeture de la sidebar */
  isOpen: boolean;
  /** Callback appelé lors du toggle de la sidebar */
  onToggle: () => void;
}

/**
 * Interface pour un élément de navigation
 * @interface NavigationItem
 */
interface NavigationItem {
  /** Identifiant unique de l'élément */
  id: string;
  /** Nom affiché de l'élément */
  name: string;
  /** Tooltip affiché quand la sidebar est fermée */
  tooltip: string;
  /** Icône SVG de l'élément */
  icon: React.ReactNode;
  /** Callback appelé lors du clic (optionnel) */
  onClick?: () => void;
}

/**
 * Composant Sidebar optimisé avec memoization et performance
 * Applique les mêmes standards que le Header selon la feuille de route
 * Préserve parfaitement la structure et fonctionnalité existante
 * @param props - Les propriétés du composant
 * @returns JSX.Element
 */
const Sidebar: React.FC<SidebarProps> = memo(({ isOpen, onToggle }) => {
  // Hook pour la configuration système
  const { config } = useSystemConfig();
  const [dbItems, setDbItems] = useState<DbMenuItem[] | null>(null);

  // Nom de la plateforme (valeur par défaut gérée dans useSystemConfig)
  const platformName = useMemo(() => config.identity.platformName.value, 
  [config.identity.platformName.value]);
  const modules = config.ui?.modules || {};

  // Chargement DB
  useEffect(() => {
    MenuService.listActive(config as any)
      .then((items) => setDbItems(items))
      .catch(() => setDbItems(null));
  }, [config]);

  // (liste statique retirée)

  const items = useMemo(() => {
    if (!dbItems) return [];
    return dbItems
      .filter(i => i.enabled !== false)
      .filter(i => (i.module_key ? modules[i.module_key as keyof typeof modules] !== false : true))
      .sort((a, b) => (a.order ?? 0) - (b.order ?? 0))
      .map<NavigationItem>(i => ({ 
        id: i.key as NavigationItem['id'], 
        name: i.name_text || I18nService.resolveKey(i.name_i18n, 'FR') || i.key, 
        tooltip: i.tooltip_text || I18nService.resolveKey(i.tooltip_i18n, 'FR') || i.key, 
        icon: IconRegistry.get(i.icon_key) 
      }));
  }, [dbItems, modules]);

  // Memoization des labels ARIA
  const ariaLabels = useMemo(() => ({
    sidebar: isOpen ? 'Navigation principale ouverte' : 'Navigation principale fermée',
    toggleButton: isOpen ? 'Fermer la navigation' : 'Ouvrir la navigation',
    navigationMenu: 'Menu de navigation principal'
  }), [isOpen]);

  // Memoization des classes CSS - préservation exacte de la structure originale
  const containerClasses = useMemo(() => 
    `bg-base-100 border-r border-base-300 transition-all duration-700 ease-in-out h-screen flex flex-col gap-6 ${
      isOpen ? 'w-64' : 'w-16'
    }`,
    [isOpen]
  );

  const headerClasses = useMemo(() => 
    `transition-all duration-700 ease-in-out ${!isOpen ? '!pt-4 !px-2' : '!p-4'}`,
    [isOpen]
  );

  const headerContentClasses = useMemo(() => 
    `flex items-center transition-all duration-700 ease-in-out ${!isOpen ? 'justify-center' : ''}`,
    [isOpen]
  );

  const toggleWrapperClasses = useMemo(() => 
    `flex flex-row transition-all duration-700 ease-in-out ${!isOpen ? 'w-[90%] mx-auto' : 'w-full'}`,
    [isOpen]
  );

  // Callback optimisé pour le toggle
  const handleToggle = useCallback(() => {
    const message = isOpen ? 'Navigation fermée' : 'Navigation ouverte';
    announceToScreenReader(message, { priority: 'polite' });
    onToggle();
  }, [onToggle, isOpen]);

  // Callback optimisé pour la navigation
  const handleNavigation = useCallback(async (item: NavigationItem) => {
    announceToScreenReader(`Navigation vers ${item.name}`, { priority: 'polite' });
    if (dbItems) {
      await EventRunner.runForItem(item.id);
    } else {
      item.onClick?.();
    }
  }, []);

  // Fonction pour rendre un élément de navigation - préservation exacte de la structure
  const renderNavigationItem = useCallback((item: NavigationItem) => {
    const buttonClasses = `btn btn-ghost w-full transition-all duration-700 ease-in-out ${
      !isOpen ? 'justify-center' : 'justify-start !pl-2'
    } ${!isOpen ? 'tooltip tooltip-right before:!px-3 before:!py-2' : ''}`;

    return (
      <div key={item.id} id={`${item.id}-content`} className="flex items-center justify-center transition-all duration-700 ease-in-out">
        <div id={`${item.id}-wrapper`} className="w-[90%] mx-auto transition-all duration-700 ease-in-out">
          <button 
            id={item.id}
            className={buttonClasses}
            data-tip={!isOpen ? item.tooltip : undefined}
            onClick={() => handleNavigation(item)}
            aria-label={`Naviguer vers ${item.name}`}
            role="menuitem"
          >
            {item.icon}
            {isOpen && <span className="ml-3 transition-all duration-700 ease-in-out">{item.name}</span>}
          </button>
        </div>
      </div>
    );
  }, [isOpen, handleNavigation]);

  return (
    <div 
      id="sidebar-container" 
      className={containerClasses}
      role="navigation"
      aria-label={ariaLabels.sidebar}
      aria-expanded={isOpen}
    >
      {/* modal de debug supprimé */}
      {/* Header avec bouton toggle - structure parfaitement préservée */}
      <div id="sidebar-header" className={headerClasses}>
        <div id="sidebar-header-content" className={headerContentClasses}>
          <div id="toggle-wrapper" className={toggleWrapperClasses}>
            <button 
              id="sidebar-toggle-btn"
              onClick={handleToggle}
              className="btn btn-ghost w-full h-10 transition-all duration-700 ease-in-out"
              aria-label={ariaLabels.toggleButton}
              aria-expanded={isOpen}
              role="button"
            >
              <svg 
                className="w-6 h-6 transition-all duration-700 ease-in-out" 
                fill="none" 
                stroke="currentColor" 
                viewBox="0 0 24 24"
                aria-hidden="true"
              >
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 6h16M4 12h16M4 18h16" />
              </svg>
              {isOpen && (
                <span 
                  className="ml-3 text-xl font-bold text-primary transition-all duration-700 ease-in-out"
                  aria-label={`Logo ${platformName}`}
                >
                  {platformName}
                </span>
              )}
            </button>
          </div>
        </div>
      </div>

      {/* Menu de navigation avec divs - structure parfaitement préservée */}
      <div 
        id="sidebar-menu" 
        className="px-2 space-y-1 transition-all duration-700 ease-in-out"
        role="menu"
        aria-label={ariaLabels.navigationMenu}
      >
        {items.map(renderNavigationItem)}
      </div>
    </div>
  );
});

// Nom d'affichage pour le débogage
Sidebar.displayName = 'Sidebar';

export default Sidebar; 
