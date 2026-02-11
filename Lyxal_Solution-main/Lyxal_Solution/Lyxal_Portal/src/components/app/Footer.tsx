import React, { memo, useMemo, useCallback } from 'react';
import { announceToScreenReader } from '../../utils/accessibility';
import { useSystemConfig } from '../../hooks/useSystemConfig';

/**
 * Props pour le composant Footer
 * @interface FooterProps
 */
interface FooterProps {
  /** Nom de l'entreprise à afficher dans le copyright */
  companyName?: string;
  /** Thème actuellement sélectionné (pour support multi-thèmes) */
  currentTheme?: string;
  /** Callback optionnel appelé lors du clic sur le copyright */
  onCopyrightClick?: () => void;
}

/**
 * Composant Footer optimisé avec memoization et performance
 * Applique les mêmes standards que le Header selon la feuille de route
 * @param props - Les propriétés du composant
 * @returns JSX.Element
 */
const Footer: React.FC<FooterProps> = memo(({
  companyName,
  currentTheme = "light",
  onCopyrightClick
}) => {
  // Hook pour la configuration système
  const { 
    config, 
    loading: configLoading, 
    error: configError 
  } = useSystemConfig();

  // Nom de la plateforme à afficher (fallback sur companyName ou "LYXAL" si pas encore chargé)
  const platformName = useMemo(() => {
    if (configLoading || configError || !config?.identity?.platformName) {
      return companyName || 'LYXAL';
    }
    return String(config.identity.platformName.value || companyName || 'LYXAL');
  }, [config?.identity?.platformName, configLoading, configError, companyName]);

  // Année de construction à afficher (fallback sur "2025" si pas encore chargé)
  const anneeConstruction = useMemo(() => {
    if (configLoading || configError || !config?.identity?.anneeConstruction) {
      return '2025';
    }
    return String(config.identity.anneeConstruction.value || '2025');
  }, [config?.identity?.anneeConstruction, configLoading, configError]);

  // Memoization du texte de copyright
  const copyrightText = useMemo(() => 
    `© ${platformName} ${anneeConstruction}`, 
    [platformName, anneeConstruction]
  );

  // Memoization des labels ARIA
  const ariaLabels = useMemo(() => ({
    footer: 'Pied de page de l\'application',
    copyright: `Copyright ${platformName} ${anneeConstruction}`,
    copyrightButton: `Informations sur ${platformName}`
  }), [platformName, anneeConstruction]);

  // Callback optimisé pour le clic sur le copyright
  const handleCopyrightClick = useCallback(() => {
    if (onCopyrightClick) {
      announceToScreenReader(`Informations ${platformName} ouvertes`, { priority: 'polite' });
      onCopyrightClick();
    }
  }, [onCopyrightClick, platformName]);

  // Memoization des classes CSS pour le support multi-thèmes
  const footerClasses = useMemo(() => 
    "bg-base-200/80 backdrop-blur-sm border-t border-base-300 !px-4 sm:!px-6 lg:!px-8 !py-2 transition-colors duration-200",
    []
  );

  const contentClasses = useMemo(() => 
    "flex items-center justify-center text-sm text-base-content/70 transition-colors duration-200",
    []
  );

  return (
    <footer 
      id="app-footer" 
      className={footerClasses}
      role="contentinfo"
      aria-label={ariaLabels.footer}
    >
      <div 
        id="footer-container" 
        className="w-full flex items-center justify-center"
      >
        <div 
          id="footer-content" 
          className={contentClasses}
        >
          {onCopyrightClick ? (
            <button
              id="footer-copyright-btn"
              className="text-sm text-base-content/70 hover:text-base-content transition-colors duration-200 focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2 rounded-sm"
              onClick={handleCopyrightClick}
              aria-label={ariaLabels.copyrightButton}
              role="button"
            >
              {copyrightText}
            </button>
          ) : (
            <span 
              id="footer-copyright"
              aria-label={ariaLabels.copyright}
              role="text"
            >
              {copyrightText}
            </span>
          )}
        </div>
      </div>
    </footer>
  );
});

// Nom d'affichage pour le débogage
Footer.displayName = 'Footer';

export default Footer; 