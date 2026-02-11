import React from 'react';
import type { ContextSources } from '@/lib/studio/context/ContextManager';
/**
 * Props pour StudioPageRenderer
 */
export interface StudioPageRendererProps {
    pageCode: string;
    context?: ContextSources;
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
export declare const StudioPageRenderer: React.FC<StudioPageRendererProps>;
