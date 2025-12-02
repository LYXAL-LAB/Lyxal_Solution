import React, { memo, useMemo } from 'react';
import ErrorCodes from './pages/ErrorCodes';

/**
 * Type pour identifier les composants de contenu disponibles
 */
export type ContentComponentId = 
  | 'dashboard'
  | 'logs'
  | 'errors'
  | 'users'
  | 'system'
  | 'monitoring'
  | 'i18n'
  | 'default';

/**
 * Props pour le composant ContentWrapper
 * @interface ContentWrapperProps
 */
interface ContentWrapperProps {
  /** ID du composant de contenu à afficher */
  selectedContentId: ContentComponentId;
  /** Contenu par défaut (children) si aucun composant spécifique n'est sélectionné */
  children?: React.ReactNode;
}

/**
 * Composants de contenu par défaut (placeholders)
 */
const ContentComponents: Record<ContentComponentId, React.FC> = {
  dashboard: () => (
    <div className="text-center">
      <h2 className="text-2xl font-bold mb-4">Tableau de bord</h2>
      <p className="text-base-content/70">Contenu du tableau de bord à venir</p>
    </div>
  ),
  logs: () => (
    <div className="text-center">
      <h2 className="text-2xl font-bold mb-4">Logs</h2>
      <p className="text-base-content/70">Gestion des logs système</p>
    </div>
  ),
  errors: () => <ErrorCodes />,
  users: () => (
    <div className="text-center">
      <h2 className="text-2xl font-bold mb-4">Utilisateurs</h2>
      <p className="text-base-content/70">Gestion des utilisateurs</p>
    </div>
  ),
  system: () => (
    <div className="text-center">
      <h2 className="text-2xl font-bold mb-4">Système</h2>
      <p className="text-base-content/70">Configuration système</p>
    </div>
  ),
  monitoring: () => (
    <div className="text-center">
      <h2 className="text-2xl font-bold mb-4">Monitoring</h2>
      <p className="text-base-content/70">Surveillance du système</p>
    </div>
  ),
  i18n: () => (
    <div className="text-center">
      <h2 className="text-2xl font-bold mb-4">Internationalisation</h2>
      <p className="text-base-content/70">Gestion des traductions</p>
    </div>
  ),
  default: () => (
    <div className="text-center">
      <h2 className="text-2xl font-bold mb-4">Bienvenue</h2>
      <p className="text-base-content/70">Sélectionnez un élément du menu pour commencer</p>
    </div>
  ),
};

/**
 * Composant ContentWrapper - Wrapper centré pour le contenu principal
 * Affiche des composants en fonction du menu sélectionné (sans système de routes)
 * @param props - Les propriétés du composant
 * @returns JSX.Element
 */
const ContentWrapper: React.FC<ContentWrapperProps> = memo(({ selectedContentId, children }) => {
  // Sélectionner le composant à afficher
  const SelectedComponent = useMemo(() => {
    return ContentComponents[selectedContentId] || ContentComponents.default;
  }, [selectedContentId]);

  return (
    <div 
      id="content-wrapper"
      className="h-full w-full overflow-auto"
    >
      <div className="w-full max-w-7xl mx-auto p-8">
        <SelectedComponent />
      </div>
    </div>
  );
});

// Nom d'affichage pour le débogage
ContentWrapper.displayName = 'ContentWrapper';

export default ContentWrapper;

