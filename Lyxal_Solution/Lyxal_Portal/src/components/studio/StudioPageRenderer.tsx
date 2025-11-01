import React from 'react';
import { useStudioPage } from '@/lib/studio/hooks/useStudioPage';
import { StructureRenderer } from './StructureRenderer';
import { ContextManager } from '@/lib/studio/context/ContextManager';
import { useStudioState } from '@/lib/studio/store/useStudioState';
import type { ContextSources } from '@/lib/studio/context/ContextManager';

/**
 * Props pour StudioPageRenderer
 */
export interface StudioPageRendererProps {
  pageCode: string;  // Code de la page (ex: "test_page")
  context?: ContextSources;  // Contexte additionnel (user, tenant, etc.)
}

/**
 * Renderer principal pour les pages définies en DB
 * 
 * Charge une page depuis SurrealDB et rend sa structure complète
 * définie dans content_structure. C'est le composant qui rend
 * les pages 100% DB-driven sans code React en dur.
 * 
 * @example
 * ```tsx
 * // Dans votre router React
 * <Route path="/test" element={<StudioPageRenderer pageCode="test_page" />} />
 * 
 * // Ou avec contexte
 * <StudioPageRenderer 
 *   pageCode="contact_list"
 *   context={{ user, tenant }}
 * />
 * ```
 */
export const StudioPageRenderer: React.FC<StudioPageRendererProps> = ({
  pageCode,
  context = {},
}) => {
  // Charger la page depuis SurrealDB
  const { page, loading, error } = useStudioPage(pageCode);

  // Récupérer le state global
  const globalState = useStudioState((state: any) => state.state);

  // États de chargement et d'erreur
  if (loading) {
    return (
      <div className="studio-page-loading">
        <div>Chargement de la page...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="studio-page-error">
        <div>Erreur de chargement de la page {pageCode}: {error.message}</div>
      </div>
    );
  }

  if (!page) {
    return (
      <div className="studio-page-not-found">
        <div>Page {pageCode} introuvable</div>
      </div>
    );
  }

  // Si la page n'a pas de content_structure, afficher un message
  if (!page.content_structure) {
    return (
      <div className="studio-page-no-structure">
        <div>Page {pageCode} n'a pas de structure de contenu définie</div>
        <div>Ajoutez un champ content_structure dans studio_page:{pageCode}</div>
      </div>
    );
  }

  // Fusionner tous les contextes
  const mergedContext = ContextManager.merge(
    {
      ...context,
      page: {
        title: page.presentation?.title_i18n || {},
        description: page.presentation?.description_i18n || {},
        url: page.presentation?.url,
        layout: page.presentation?.layout,
        ...page,
      },
      state: globalState,
    },
    context
  );

  // Rendre la structure complète de la page via StructureRenderer
  return (
    <StructureRenderer
      structure={page.content_structure}
      componentProps={{}}
      context={mergedContext}
    />
  );
};

