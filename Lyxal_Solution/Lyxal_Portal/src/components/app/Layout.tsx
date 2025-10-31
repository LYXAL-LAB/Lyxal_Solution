import React, { memo, useState, useEffect, useMemo, useCallback, ReactNode } from 'react';
import { Header } from './header';
import Footer from './Footer';
import Sidebar from './Sidebar';
import { usePerformanceMonitor } from '../../hooks/usePerformanceMonitor';
import { useSystemConfig } from '../../hooks/useSystemConfig';
import { announceToScreenReader } from '../../utils/accessibility';
import { logPerformanceMetrics } from '../../utils/performanceLogger';

/**
 * Props pour le composant Layout
 * @interface LayoutProps
 */
interface LayoutProps {
  /** Contenu principal à afficher dans le layout */
  children: ReactNode;
  /** Thème initial (optionnel, défaut: thème système) */
  initialTheme?: string;
  /** État initial de la sidebar (optionnel, défaut: responsive) */
  initialSidebarOpen?: boolean;
  /** Callback appelé lors du changement de thème (optionnel) */
  onThemeChange?: (theme: string) => void;
  /** Callback appelé lors du toggle de sidebar (optionnel) */
  onSidebarToggle?: (isOpen: boolean) => void;
  /** Props additionnelles pour le Footer (optionnel) */
  footerProps?: {
    companyName?: string;
    onCopyrightClick?: () => void;
  };
}

/**
 * Interface pour l'état global du layout
 * @interface LayoutState
 */
interface LayoutState {
  /** Thème actuellement sélectionné */
  currentTheme: string;
  /** État d'ouverture de la sidebar */
  isSidebarOpen: boolean;
  /** État d'ouverture du modal de profil */
  isProfileModalOpen: boolean;
  /** Indicateur de chargement global */
  isLoading: boolean;
}

/**
 * Composant Layout principal orchestrant Header/Sidebar/Footer
 * Applique tous les standards de performance et d'accessibilité
 * Gère l'état global cohérent et les transitions fluides
 * Utilise le thème par défaut configuré dans le système
 * @param props - Les propriétés du composant
 * @returns JSX.Element
 */
const Layout: React.FC<LayoutProps> = memo(({
  children,
  initialTheme,
  initialSidebarOpen,
  onThemeChange,
  onSidebarToggle,
  footerProps = {}
}) => {
  // Hook pour la configuration système
  const { 
    config, 
    loading: configLoading, 
    error: configError 
  } = useSystemConfig();

  // Calcul du thème par défaut depuis la configuration
  const defaultTheme = useMemo(() => {
    if (configLoading || configError || !config?.identity?.themeParDefaut) {
      return 'corporate'; // Fallback si config pas encore chargée
    }
    return String(config.identity.themeParDefaut.value || 'corporate');
  }, [config?.identity?.themeParDefaut, configLoading, configError]);

  // État global du layout avec gestion cohérente
  const [layoutState, setLayoutState] = useState<LayoutState>(() => ({
    currentTheme: initialTheme || defaultTheme,
    isSidebarOpen: initialSidebarOpen ?? (window.innerWidth >= 1024),
    isProfileModalOpen: false,
    isLoading: false
  }));

  // Monitoring des performances
  const performanceMetrics = usePerformanceMonitor();

  // Memoization de la liste des thèmes DaisyUI
  const availableThemes = useMemo(() => [
    'light', 'dark', 'cupcake', 'bumblebee', 'emerald', 'corporate', 'synthwave', 'retro',
    'cyberpunk', 'valentine', 'halloween', 'garden', 'forest', 'aqua', 'lofi', 'pastel',
    'fantasy', 'wireframe', 'black', 'luxury', 'dracula', 'cmyk', 'autumn', 'business',
    'acid', 'lemonade', 'night', 'coffee', 'winter', 'dim', 'nord', 'sunset'
  ], []);

  // Memoization des labels ARIA dynamiques
  const ariaLabels = useMemo(() => ({
    layout: `Interface LYXAL Master Console avec thème ${layoutState.currentTheme}`,
    overlay: layoutState.isSidebarOpen ? 'Overlay pour fermer le menu sur mobile' : undefined,
    mainContent: 'Contenu principal de l\'application',
    pageContent: 'Zone de contenu de la page courante'
  }), [layoutState.currentTheme, layoutState.isSidebarOpen]);

  // Memoization des classes CSS pour le container principal
  const containerClasses = useMemo(() => 
    `h-screen bg-base-200 flex transition-colors duration-150 ${
      layoutState.isLoading ? 'cursor-wait' : ''
    }`,
    [layoutState.isLoading]
  );

  // Memoization des classes CSS pour la sidebar
  const sidebarClasses = useMemo(() => 
    `fixed lg:relative z-50 h-full transition-transform duration-300 ease-in-out ${
      layoutState.isSidebarOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'
    }`,
    [layoutState.isSidebarOpen]
  );

  // Callback optimisé pour le changement de thème - VERSION SIMPLIFIÉE
  const handleThemeChange = useCallback((theme: string) => {
    // Appliquer immédiatement le thème au document AVANT le state
    document.documentElement.setAttribute('data-theme', theme);
    
    // Mettre à jour l'état local
    setLayoutState(prev => ({ ...prev, currentTheme: theme }));
    
    // Sauvegarder dans localStorage
    localStorage.setItem('lyxal-theme', theme);
    
    announceToScreenReader(`Interface mise à jour avec le thème ${theme}`, { priority: 'polite' });
    onThemeChange?.(theme);
  }, [onThemeChange]);

  // Callback optimisé pour le toggle de la sidebar
  const handleSidebarToggle = useCallback(() => {
    setLayoutState(prev => {
      const newState = !prev.isSidebarOpen;
      const message = newState ? 'Menu de navigation ouvert' : 'Menu de navigation fermé';
      announceToScreenReader(message, { priority: 'polite' });
      onSidebarToggle?.(newState);
      return { ...prev, isSidebarOpen: newState };
    });
  }, [onSidebarToggle]);

  // Callback optimisé pour l'ouverture du modal de profil
  const handleProfileModalOpen = useCallback(() => {
    setLayoutState(prev => ({ ...prev, isProfileModalOpen: true }));
    announceToScreenReader('Modal de profil administrateur ouvert', { priority: 'polite' });
  }, []);

  // Callback optimisé pour la fermeture du modal de profil
  const handleProfileModalClose = useCallback(() => {
    setLayoutState(prev => ({ ...prev, isProfileModalOpen: false }));
    announceToScreenReader('Modal de profil fermé', { priority: 'polite' });
  }, []);

  // Callback optimisé pour la fermeture de l'overlay mobile
  const handleOverlayClick = useCallback(() => {
    if (layoutState.isSidebarOpen && window.innerWidth < 1024) {
      handleSidebarToggle();
    }
  }, [layoutState.isSidebarOpen, handleSidebarToggle]);

  // Effet pour gérer la responsive de la sidebar
  useEffect(() => {
    const handleResize = () => {
      const isDesktop = window.innerWidth >= 1024;
      
      setLayoutState(prev => {
        // Si pas de valeur initiale définie, utiliser la logique responsive
        if (initialSidebarOpen === undefined) {
          return { ...prev, isSidebarOpen: isDesktop };
        }
        return prev;
      });
    };

    // Appeler au montage si pas de valeur initiale
    if (initialSidebarOpen === undefined) {
      handleResize();
    }
    
    // Écouter les changements de taille
    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, [initialSidebarOpen]);

  // Effet pour initialiser le thème au montage et quand defaultTheme change
  useEffect(() => {
    // Charger le thème sauvegardé ou utiliser l'initial ou le défaut système
    const savedTheme = localStorage.getItem('lyxal-theme') || initialTheme || defaultTheme;
    
    // Appliquer le thème au document
    document.documentElement.setAttribute('data-theme', savedTheme);
    
    // Mettre à jour l'état si différent
    if (savedTheme !== layoutState.currentTheme) {
      setLayoutState(prev => ({ ...prev, currentTheme: savedTheme }));
    }
  }, [defaultTheme]); // Réagir aux changements de defaultTheme

  // Effet pour logger les métriques de performance
  useEffect(() => {
    if (performanceMetrics?.metrics) {
      logPerformanceMetrics(performanceMetrics.metrics);
    }
  }, [performanceMetrics]);

  // Effet pour gérer l'accessibilité du focus lors de l'ouverture du modal
  useEffect(() => {
    if (layoutState.isProfileModalOpen) {
      // Focus sur le modal quand il s'ouvre
      const modalElement = document.getElementById('profile-modal');
      if (modalElement) {
        modalElement.focus();
      }
    }
  }, [layoutState.isProfileModalOpen]);

  // Nettoyage des effets au démontage
  useEffect(() => {
    return () => {
      // Annonce de déchargement pour l'accessibilité
      announceToScreenReader('Interface LYXAL fermée', { priority: 'polite' });
    };
  }, []);

  return (
    <div 
      className={containerClasses}
      role="application"
      aria-label={ariaLabels.layout}
      data-theme={layoutState.currentTheme}
    >
      {/* Sidebar */}
      <aside className={sidebarClasses}>
        <Sidebar 
          isOpen={layoutState.isSidebarOpen}
          onToggle={handleSidebarToggle}
        />
      </aside>

      {/* Overlay mobile pour fermer la sidebar */}
      {layoutState.isSidebarOpen && (
        <div 
          className="fixed inset-0 bg-black/50 lg:hidden z-40 cursor-pointer"
          onClick={handleOverlayClick}
          role="button"
          tabIndex={0}
          aria-label={ariaLabels.overlay}
          onKeyDown={(e) => {
            if (e.key === 'Enter' || e.key === ' ') {
              handleOverlayClick();
            }
          }}
        />
      )}

      {/* Contenu principal */}
      <main 
        className="flex-1 flex flex-col min-h-0 relative overflow-hidden"
        role="main"
        aria-label={ariaLabels.mainContent}
      >
        {/* Header */}
        <Header 
          currentTheme={layoutState.currentTheme}
          themes={availableThemes}
          onThemeChange={handleThemeChange}
          onProfileModalOpen={handleProfileModalOpen}
          isSidebarOpen={layoutState.isSidebarOpen}
          onSidebarToggle={handleSidebarToggle}
        />

        {/* Zone de contenu de la page */}
        <div 
          className="flex-1 overflow-auto bg-base-100 relative"
          role="region"
          aria-label={ariaLabels.pageContent}
        >
          {children}
        </div>

        {/* Footer */}
        <Footer 
          {...(footerProps.companyName && { companyName: footerProps.companyName })}
          {...(footerProps.onCopyrightClick && { onCopyrightClick: footerProps.onCopyrightClick })}
        />
      </main>

      {/* Modal de profil (si ouvert) */}
      {layoutState.isProfileModalOpen && (
        <div 
          id="profile-modal"
          className="fixed inset-0 bg-black/80 flex items-center justify-center z-[1000]"
          role="dialog"
          aria-modal="true"
          aria-labelledby="profile-modal-title"
          tabIndex={-1}
        >
          <div className="bg-base-100 p-6 rounded-lg shadow-xl max-w-md w-full mx-4">
            <h2 id="profile-modal-title" className="text-xl font-bold mb-4">
              Profil Administrateur
            </h2>
            <p className="text-base-content/80 mb-4">
              Console d'administration LYXAL Master
            </p>
            <div className="flex justify-end gap-2">
              <button 
                className="btn btn-ghost"
                onClick={handleProfileModalClose}
              >
                Fermer
              </button>
              <button className="btn btn-primary">
                Paramètres
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
});

// Nom d'affichage pour le débogage
Layout.displayName = 'Layout';

export default Layout; 