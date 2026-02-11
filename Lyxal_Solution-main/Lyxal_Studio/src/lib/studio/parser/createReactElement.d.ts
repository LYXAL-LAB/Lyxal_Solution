import React from 'react';
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
export declare const createReactElement: (structure: StudioComponentStructure, componentProps?: Record<string, any>, context?: TemplateContext) => React.ReactElement;
