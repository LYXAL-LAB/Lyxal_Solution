import React from 'react';
import { parseComponent } from '@/lib/studio/parser';
import { ContextManager } from '@/lib/studio/context/ContextManager';
import { useStudioState } from '@/lib/studio/store/useStudioState';
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
export const StructureRenderer: React.FC<StructureRendererProps> = ({
  structure,
  componentProps = {},
  context = {},
}) => {
  // Récupérer le state global
  const globalState = useStudioState((state: any) => state.state);

  // Fusionner tous les contextes
  const mergedContext = ContextManager.merge(
    {
      ...context,
      state: globalState,
      props: componentProps,
    },
    componentProps
  );

  // Parser et rendre la structure
  const element = parseComponent(structure, componentProps, mergedContext);

  return element;
};

