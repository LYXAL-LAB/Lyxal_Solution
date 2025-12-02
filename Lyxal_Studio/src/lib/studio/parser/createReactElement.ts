import React from 'react';
import { resolveProps } from './resolveProps';
import { applyVariants } from './applyVariants';
import { resolveChildren } from './resolveChildren';
import type { StudioComponentStructure, TemplateContext } from '../types/component';

/**
 * Crée un élément React final à partir de la structure
 * 
 * Cette fonction est le cœur du parser : elle transforme une structure JSON
 * définie en DB en un élément React réel.
 * 
 * @param structure - Structure du composant définie en DB
 * @param componentProps - Props passées au composant lors du rendu
 * @param context - Contexte pour résoudre les templates
 * @returns Élément React créé
 */
export const createReactElement = (
  structure: StudioComponentStructure,
  componentProps: Record<string, any> = {},
  context: TemplateContext = {}
): React.ReactElement => {
  // Résoudre les props avec le contexte
  const resolvedProps = resolveProps(
    structure.props || {},
    componentProps,
    context
  );

  // Déterminer le variant à appliquer
  const variant = componentProps.variant || resolvedProps.variant || 'default';

  // Appliquer les variants (si définis)
  let propsWithVariant = structure.variants
    ? applyVariants(structure.variants, variant, resolvedProps)
    : resolvedProps;

  // S'assurer que className est une string (pas un array)
  if (propsWithVariant.className && Array.isArray(propsWithVariant.className)) {
    propsWithVariant = {
      ...propsWithVariant,
      className: propsWithVariant.className.join(' ')
    };
  }

  // Résoudre les children récursivement
  const children = structure.children
    ? resolveChildren(structure.children, {
        ...context,
        props: { ...context.props, ...componentProps }
      })
    : null;

  // Si c'est un composant DB (référence à un autre composant)
  if (structure.type === 'component' && structure.props?.component) {
    // Pour l'instant, on retourne un placeholder
    // StudioComponentRenderer sera créé plus tard
    return React.createElement(
      'div',
      {
        'data-component-code': structure.props.component,
        ...propsWithVariant,
      },
      children
    );
  }

  // Élément HTML natif (button, div, input, etc.)
  const Element = structure.type as string;
  
  // Vérifier que le type est valide (pas vide, pas null)
  if (!Element || typeof Element !== 'string') {
    console.error('[createReactElement] Invalid element type:', structure.type);
    return React.createElement('div', { 
      style: { color: 'red', padding: '10px' },
      'data-error': 'invalid-type'
    }, `Invalid element type: ${structure.type}`);
  }
  
  try {
    return React.createElement(
      Element as any,
      propsWithVariant,
      children
    );
  } catch (error) {
    console.error('[createReactElement] Error creating element:', error, { Element, propsWithVariant, children });
    return React.createElement('div', {
      style: { color: 'red', padding: '10px' },
      'data-error': 'create-error'
    }, `Error creating element ${Element}: ${error instanceof Error ? error.message : String(error)}`);
  }
};

