/**
 * Types TypeScript pour le Studio Runtime
 * Définit les structures JSON stockées dans SurrealDB
 */

/**
 * Structure d'un composant défini en DB
 */
export interface StudioComponentStructure {
  type: string; // "button", "div", "input", "component"
  props?: Record<string, any>;
  children?: StudioComponentChild[];
  variants?: Record<string, VariantStyle>;
}

/**
 * Structure d'un enfant dans children[]
 */
export interface StudioComponentChild {
  type: 'text' | 'component' | string;
  content?: string; // Pour type: "text"
  component?: string; // Pour type: "component"
  props?: Record<string, any>;
  children?: StudioComponentChild[];
  condition?: string; // Template string pour condition
}

/**
 * Variant CSS pour un composant
 */
export interface VariantStyle {
  css_classes?: string[];
  css_variables?: Record<string, string>;
}

/**
 * Schéma de validation des props
 */
export interface PropsSchema {
  name: string;
  type: 'string' | 'number' | 'boolean' | 'array' | 'object';
  required?: boolean;
  default?: any;
  description?: string;
  options?: any[];
}

/**
 * Action définie en DB
 */
export interface ActionDefinition {
  type: 'action';
  action: string; // "navigate", "submit", "state_update", etc.
  target?: string;
  params?: Record<string, any>;
}

/**
 * Contexte pour résoudre les templates
 */
export interface TemplateContext {
  props?: Record<string, any>;
  page?: Record<string, any>;
  user?: Record<string, any>;
  tenant?: Record<string, any>;
  row?: Record<string, any>;
  state?: Record<string, any>;
  [key: string]: any;
}

