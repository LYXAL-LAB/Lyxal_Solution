import React from 'react';
import type { ContextSources } from '@/lib/studio/context/ContextManager';
/**
 * Props pour StudioComponentRenderer
 */
export interface StudioComponentRendererProps {
    code: string;
    props?: Record<string, any>;
    context?: ContextSources;
}
/**
 * Renderer principal pour les composants définis en DB
 *
 * Charge un composant depuis SurrealDB et le rend avec le parser.
 * Gère automatiquement le chargement, les erreurs, et l'intégration
 * avec le state global et les actions.
 *
 * @example
 * ```tsx
 * <StudioComponentRenderer
 *   code="test_button"
 *   props={{ label: "Click me", disabled: false }}
 * />
 * ```
 */
export declare const StudioComponentRenderer: React.FC<StudioComponentRendererProps>;
