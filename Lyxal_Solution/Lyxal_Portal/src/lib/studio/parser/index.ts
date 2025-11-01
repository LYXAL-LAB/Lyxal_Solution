/**
 * Pipeline complet du parser Studio Runtime
 * 
 * Ce module exporte la fonction principale `parseComponent` qui transforme
 * une structure JSON définie en SurrealDB en élément React.
 */

import React from 'react';
import { createReactElement } from './createReactElement';
import type { StudioComponentStructure, TemplateContext } from '../types/component';

/**
 * Parse une structure de composant en élément React
 * 
 * @example
 * ```tsx
 * const structure = {
 *   type: "button",
 *   props: { className: ["btn"] },
 *   children: [{ type: "text", content: "{{props.label}}" }]
 * };
 * 
 * const element = parseComponent(structure, { label: "Click me" });
 * ```
 * 
 * @param structure - Structure du composant définie en DB
 * @param props - Props passées au composant
 * @param context - Contexte pour résoudre les templates (optionnel)
 * @returns Élément React créé
 */
export const parseComponent = (
  structure: StudioComponentStructure,
  props: Record<string, any> = {},
  context: TemplateContext = {}
): React.ReactElement => {
  // Fusionner les props dans le contexte
  const fullContext: TemplateContext = {
    ...context,
    props: {
      ...context.props,
      ...props,
    },
  };

  return createReactElement(structure, props, fullContext);
};

// Ré-exporter tous les modules pour utilisation avancée
export { resolveTemplate, resolveTemplateObject } from './resolveTemplate';
export { resolveProps } from './resolveProps';
export { applyVariants } from './applyVariants';
export { resolveChildren } from './resolveChildren';
export { createReactElement } from './createReactElement';

// Ré-exporter les types
export type {
  StudioComponentStructure,
  StudioComponentChild,
  VariantStyle,
  PropsSchema,
  ActionDefinition,
  TemplateContext,
} from '../types/component';

