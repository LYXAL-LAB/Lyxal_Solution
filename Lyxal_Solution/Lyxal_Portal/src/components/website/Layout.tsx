import React, { memo, useEffect, useMemo, ReactNode } from 'react';
import { Header } from './';
import Footer from './Footer';
import { useSystemConfig } from '../../hooks/useSystemConfig';
import { announceToScreenReader } from '../../utils/accessibility';

/**
 * Props pour le composant Layout Website
 * @interface WebsiteLayoutProps
 */
interface WebsiteLayoutProps {
  /** Contenu principal à afficher dans le layout */
  children: ReactNode;
  /** Props additionnelles pour le Footer (optionnel) */
  footerProps?: {
    companyName?: string;
    onCopyrightClick?: () => void;
  };
}

/**
 * Composant Layout pour le site marketing LYXAL
 * Utilise le thème fixe configuré dans le système (non modifiable par l'utilisateur)
 * Optimisé pour les performances et l'accessibilité
 * @param props - Les propriétés du composant
 * @returns JSX.Element
 */
const WebsiteLayout: React.FC<WebsiteLayoutProps> = memo(({
  children,
  footerProps = {}
}) => {
  // Hook pour la configuration système
  const { 
    config, 
    loading: configLoading, 
    error: configError 
  } = useSystemConfig();

  // Calcul du thème website depuis la configuration
  const websiteTheme = useMemo(() => {
    if (configLoading || configError || !config?.identity?.themeWebsite) {
      return 'corporate'; // Fallback si config pas encore chargée
    }
    return String(config.identity.themeWebsite.value || 'corporate');
  }, [config?.identity?.themeWebsite, configLoading, configError]);

  // Memoization des labels ARIA
  const ariaLabels = useMemo(() => ({
    layout: `Site web LYXAL avec thème ${websiteTheme}`,
    mainContent: 'Contenu principal du site web',
    pageContent: 'Zone de contenu de la page courante'
  }), [websiteTheme]);

  // Memoization des classes CSS pour le container principal
  const containerClasses = useMemo(() => 
    'min-h-screen bg-base-100 flex flex-col transition-colors duration-150',
    []
  );

  // Effet pour appliquer le thème website au document
  useEffect(() => {
    // Appliquer le thème au document
    document.documentElement.setAttribute('data-theme', websiteTheme);
    
    // Annoncer le thème pour l'accessibilité
    announceToScreenReader(`Site web chargé avec le thème ${websiteTheme}`, { priority: 'polite' });
  }, [websiteTheme]);

  // Nettoyage au démontage
  useEffect(() => {
    return () => {
      announceToScreenReader('Site web LYXAL fermé', { priority: 'polite' });
    };
  }, []);

  return (
    <div 
      className={containerClasses}
      role="document"
      aria-label={ariaLabels.layout}
      data-theme={websiteTheme}
    >
      {/* Header du site marketing */}
      <Header />

      {/* Contenu principal */}
      <main 
        className="flex-1 flex flex-col"
        role="main"
        aria-label={ariaLabels.mainContent}
      >
        {/* Zone de contenu de la page */}
        <div 
          className="flex-1"
          role="region"
          aria-label={ariaLabels.pageContent}
        >
          {children}
        </div>
      </main>

      {/* Footer du site marketing */}
      <Footer 
        {...(footerProps.companyName && { companyName: footerProps.companyName })}
        {...(footerProps.onCopyrightClick && { onCopyrightClick: footerProps.onCopyrightClick })}
      />
    </div>
  );
});

// Nom d'affichage pour le débogage
WebsiteLayout.displayName = 'WebsiteLayout';

export default WebsiteLayout; 