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
  console.log(`[StudioPageRenderer] 🎯 Rendering page: ${pageCode}`);
  console.log(`[StudioPageRenderer] 📋 Context provided:`, context);

  // Charger la page depuis SurrealDB
  const { page, loading, error } = useStudioPage(pageCode);

  console.log(`[StudioPageRenderer] 📊 Hook result:`, { page: !!page, loading, error: error?.message });

  // Récupérer le state global
  const globalState = useStudioState((state: any) => state.state);
  console.log(`[StudioPageRenderer] 🌍 Global state:`, globalState);

  // États de chargement et d'erreur
  if (loading) {
    console.log(`[StudioPageRenderer] ⏳ Still loading page ${pageCode}...`);
    return (
      <div className="studio-page-loading">
        <div>Chargement de la page...</div>
      </div>
    );
  }

  if (error) {
    console.error(`[StudioPageRenderer] 💥 Error loading page ${pageCode}:`, error);
    return (
      <div className="studio-page-error">
        <div>Erreur de chargement de la page {pageCode}: {error.message}</div>
        <details>
          <summary>Détails de debug</summary>
          <pre>{JSON.stringify(error, null, 2)}</pre>
        </details>
      </div>
    );
  }

  if (!page) {
    console.error(`[StudioPageRenderer] ❌ Page ${pageCode} is null after loading`);
    return (
      <div className="studio-page-not-found">
        <div>Page {pageCode} introuvable</div>
      </div>
    );
  }

  console.log(`[StudioPageRenderer] ✅ Page ${pageCode} found:`, page.identity);
  console.log(`[StudioPageRenderer] 📄 Content structure:`, !!page.content_structure);

  // Si la page n'a pas de content_structure, afficher un message
  if (!page.content_structure) {
    console.error(`[StudioPageRenderer] ❌ Page ${pageCode} has no content_structure`);
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

  console.log(`[StudioPageRenderer] 🎨 Rendering StructureRenderer for ${pageCode}`);
  console.log(`[StudioPageRenderer] 🔧 Merged context keys:`, Object.keys(mergedContext));

  // Rendre la structure complète de la page via StructureRenderer
  return (
    <StructureRenderer
      structure={page.content_structure}
      componentProps={{}}
      context={mergedContext}
    />
  );
};

