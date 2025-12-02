import React from 'react';
import type { TemplateContext, StudioComponentChild } from '../types/component';
/**
 * Résout récursivement les children d'un composant
 *
 * Les children peuvent être :
 * - Des éléments texte (type: "text")
 * - Des composants DB (type: "component")
 * - Des éléments HTML natifs (div, span, etc.)
 *
 * @param children - Tableau de structures enfants
 * @param context - Contexte pour résoudre les templates
 * @returns Tableau de ReactNode
 */
export declare const resolveChildren: (children?: StudioComponentChild[], context?: TemplateContext) => React.ReactNode[];
