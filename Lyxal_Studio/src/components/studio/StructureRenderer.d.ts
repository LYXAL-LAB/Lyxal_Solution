import React from 'react';
import type { StudioComponentStructure } from '@/lib/studio/types/component';
import type { ContextSources } from '@/lib/studio/context/ContextManager';
/**
 * Props pour StructureRenderer
 */
export interface StructureRendererProps {
    structure: StudioComponentStructure;
    componentProps?: Record<string, any>;
    context?: ContextSources;
}
/**
 * Renderer récursif pour les structures définies en DB
 *
 * Rend une structure JSON définie dans SurrealDB en composant React.
 * Utilisé pour rendre des composants imbriqués ou des structures complexes.
 *
 * @example
 * ```tsx
 * <StructureRenderer
 *   structure={{
 *     type: "div",
 *     children: [
 *       { type: "text", content: "{{props.label}}" }
 *     ]
 *   }}
 *   componentProps={{ label: "Hello" }}
 * />
 * ```
 */
export declare const StructureRenderer: React.FC<StructureRendererProps>;
