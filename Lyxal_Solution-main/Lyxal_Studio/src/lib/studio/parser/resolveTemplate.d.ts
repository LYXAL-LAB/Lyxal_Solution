import type { TemplateContext } from '../types/component';
/**
 * Résout un template string avec le contexte donné
 *
 * @example
 * resolveTemplate("{{props.label}}", { props: { label: "Click me" } })
 * // → "Click me"
 *
 * resolveTemplate("{{page.title.fr}}", { page: { title: { fr: "Contact" } } })
 * // → "Contact"
 *
 * @param template - String contenant des templates {{...}}
 * @param context - Contexte pour résoudre les variables
 * @param preserveType - Si true, préserve les types (booléens, nombres), sinon convertit en string
 * @returns String résolu ou valeur originale (si preserveType=true)
 */
export declare const resolveTemplate: (template: string | any, context?: TemplateContext, preserveType?: boolean) => string | any;
/**
 * Résout un objet récursivement (pour les props complexes)
 *
 * @param obj - Objet contenant potentiellement des templates
 * @param context - Contexte pour résoudre les variables
 * @returns Objet avec templates résolus
 */
export declare const resolveTemplateObject: (obj: any, context?: TemplateContext) => any;
