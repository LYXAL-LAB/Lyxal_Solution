/**
 * Types TypeScript pour le Studio Runtime
 * Définit les structures JSON stockées dans SurrealDB
 */
/**
 * Structure d'un composant défini en DB
 */
export interface StudioComponentStructure {
    type: string;
    props?: Record<string, any>;
    children?: StudioComponentChild[];
    variants?: Record<string, VariantStyle>;
}
/**
 * Structure d'un enfant dans children[]
 */
export interface StudioComponentChild {
    type: 'text' | 'component' | string;
    content?: string;
    component?: string;
    props?: Record<string, any>;
    children?: StudioComponentChild[];
    condition?: string;
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
    action: string;
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
    handleAction?: (action: any, event?: any) => Promise<any>;
    [key: string]: any;
}
