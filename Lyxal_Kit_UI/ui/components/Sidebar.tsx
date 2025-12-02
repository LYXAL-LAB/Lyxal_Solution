import React, { memo, useMemo, useCallback } from 'react';
import { announceToScreenReader } from '../utils/accessibility';
import { useSystemConfig } from '../hooks/useSystemConfig';
import { IconRegistry } from '../services/IconRegistry';

/**
 * Type pour identifier les composants de contenu disponibles
 */
type ContentComponentId = 
  | 'dashboard'
  | 'logs'
  | 'errors'
  | 'users'
  | 'system'
  | 'monitoring'
  | 'i18n'
  | 'buttons'
  | 'buttons-advanced'
  | 'button-custom'
  | 'default';

/**
 * Props pour le composant Sidebar
 * @interface SidebarProps
 */
interface SidebarProps {
  /** État d'ouverture/fermeture de la sidebar */
  isOpen: boolean;
  /** Callback appelé lors du toggle de la sidebar */
  onToggle: () => void;
  /** Callback appelé lors du changement de contenu sélectionné */
  onContentChange?: (contentId: ContentComponentId) => void;
  /** ID du contenu actuellement sélectionné */
  selectedContentId?: ContentComponentId;
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
const Sidebar: React.FC<SidebarProps> = memo(({ isOpen, onToggle, onContentChange, selectedContentId = 'default' }) => {
  // Hook pour la configuration système
  const { config } = useSystemConfig();

  // Nom de la plateforme (valeur par défaut gérée dans useSystemConfig)
  const platformName = useMemo(() => config.identity.platformName.value, 
  [config.identity.platformName.value]);

  // Mapping des IDs du menu vers les ContentComponentId
  const menuIdToContentId = useCallback((menuId: string): ContentComponentId => {
    const mapping: Record<string, ContentComponentId> = {
      'dashboard': 'dashboard',
      'system-config': 'system',
      'logs': 'logs',
      'errors': 'errors',
      'monitoring': 'monitoring',
      'users': 'users',
      'i18n': 'i18n',
      'buttons': 'buttons',
      'buttons-advanced': 'buttons-advanced',
      'button-custom': 'button-custom',
      'daisyui-tester': 'daisyui-tester',
      'settings': 'default'
    };
    return mapping[menuId] || 'default';
  }, []);

  // Menu statique pour Lyxal_System v1
  const items = useMemo<NavigationItem[]>(() => [
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
      id: 'buttons',
      name: 'Boutons',
      tooltip: 'Bibliothèque de boutons',
      icon: (
        <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <rect x="3" y="8" width="18" height="8" rx="2" strokeWidth="2" />
          <circle cx="8" cy="12" r="1" fill="currentColor" />
          <circle cx="12" cy="12" r="1" fill="currentColor" />
          <circle cx="16" cy="12" r="1" fill="currentColor" />
        </svg>
      ),
      onClick: () => {
        onContentChange?.('buttons');
      }
    },
    {
      id: 'buttons-advanced',
      name: 'Boutons Avancés',
      tooltip: 'Effets et animations avancées',
      icon: (
        <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <rect x="3" y="8" width="18" height="8" rx="2" strokeWidth="2" />
          <circle cx="8" cy="12" r="1" fill="currentColor" />
          <circle cx="12" cy="12" r="1" fill="currentColor" />
          <circle cx="16" cy="12" r="1" fill="currentColor" />
          <path d="M12 8L14 6M12 16L14 18M8 12L6 10M16 12L18 14" strokeWidth="2" strokeLinecap="round" />
        </svg>
      ),
      onClick: () => {
        onContentChange?.('buttons-advanced');
      }
    },
    {
      id: 'button-custom',
      name: 'Bouton Custom',
      tooltip: 'Votre bouton sur mesure',
      icon: (
        <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <rect x="3" y="8" width="18" height="8" rx="2" strokeWidth="2" />
          <path d="M12 5v3M12 16v3M8 12h3M13 12h3" strokeWidth="2" strokeLinecap="round" />
        </svg>
      ),
      onClick: () => {
        onContentChange?.('button-custom');
      }
    },
    {
      id: 'daisyui-tester',
      name: 'DaisyUI Tester',
      tooltip: 'Testez les thèmes DaisyUI importés',
      icon: (
        <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <rect x="3" y="3" width="18" height="18" rx="2" strokeWidth="2" />
          <circle cx="9" cy="9" r="2" fill="currentColor" />
          <circle cx="15" cy="9" r="2" fill="currentColor" />
          <path d="M9 15h6" strokeWidth="2" strokeLinecap="round" />
          <circle cx="12" cy="12" r="1" fill="currentColor" />
        </svg>
      ),
      onClick: () => {
        onContentChange?.('daisyui-tester');
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
  const containerClasses = useMemo(() => 
    `bg-base-100 border-r border-base-300 transition-all duration-700 ease-in-out h-screen flex flex-col gap-6 ${
      isOpen ? 'w-64' : 'w-16'
    }`,
    [isOpen]
  );

  const headerClasses = useMemo(() => 
    `transition-all duration-700 ease-in-out !pt-4 ${!isOpen ? '!px-2 !pb-4' : '!px-4 !pb-4'}`,
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
  const handleNavigation = useCallback((item: NavigationItem) => {
    announceToScreenReader(`Navigation vers ${item.name}`, { priority: 'polite' });
    item.onClick?.();
  }, []);

  // Fonction pour rendre un élément de navigation - préservation exacte de la structure
  const renderNavigationItem = useCallback((item: NavigationItem) => {
    // Vérifier si cet élément est actif
    const itemContentId = menuIdToContentId(item.id);
    const isActive = selectedContentId === itemContentId;
    
    const buttonClasses = `btn transition-all duration-700 ease-in-out flex items-center ${
      isActive ? 'btn-active btn-primary' : 'btn-ghost'
    } ${
      isOpen ? 'w-full justify-start !pl-2' : 'w-full justify-center'
    } ${!isOpen ? 'tooltip tooltip-right before:!px-3 before:!py-2' : ''}`;

    return (
      <div key={item.id} id={`${item.id}-content`} className="flex items-center justify-center transition-all duration-700 ease-in-out">
        <div id={`${item.id}-wrapper`} className="transition-all duration-700 ease-in-out w-[90%] mx-auto">
          <button 
            id={item.id}
            className={buttonClasses}
            data-tip={!isOpen ? item.tooltip : undefined}
            onClick={() => handleNavigation(item)}
            aria-label={`Naviguer vers ${item.name}`}
            role="menuitem"
          >
            {item.icon}
            {isOpen && (
              <span className="ml-3 transition-all duration-700 ease-in-out whitespace-nowrap">{item.name}</span>
            )}
          </button>
        </div>
      </div>
    );
  }, [isOpen, handleNavigation, selectedContentId, menuIdToContentId]);

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
              className={`btn btn-ghost h-10 transition-all duration-700 ease-in-out flex items-center ${
                isOpen ? 'w-full justify-start' : 'w-full justify-center'
              }`}
              aria-label={ariaLabels.toggleButton}
              aria-expanded={isOpen}
              role="button"
            >
              <svg 
                className="w-6 h-6 flex-shrink-0 transition-all duration-700 ease-in-out" 
                fill="none" 
                stroke="currentColor" 
                viewBox="0 0 24 24"
                aria-hidden="true"
              >
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 6h16M4 12h16M4 18h16" />
              </svg>
              {isOpen && (
                <span 
                  className="text-xl font-bold text-primary transition-all duration-700 ease-in-out whitespace-nowrap ml-3"
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
        className={`space-y-1 transition-all duration-700 ease-in-out ${
          isOpen ? 'px-2' : '!px-2'
        }`}
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
