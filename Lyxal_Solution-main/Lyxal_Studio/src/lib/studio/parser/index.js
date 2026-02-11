/**
 * Pipeline complet du parser Studio Runtime
 *
 * Ce module exporte la fonction principale `parseComponent` qui transforme
 * une structure JSON définie en SurrealDB en élément React.
 */
import { createReactElement } from './createReactElement';
import { setActionContext } from './resolveProps';
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
export const parseComponent = (structure, props = {}, context = {}) => {
    // Fusionner les props dans le contexte
    const fullContext = {
        ...context,
        props: {
            ...context.props,
            ...props,
        },
    };
    // Définir le contexte d'actions si disponible
    if (context.handleAction) {
        console.log(`[parseComponent] Setting action context with handleAction`);
        setActionContext({ handleAction: context.handleAction });
    }
    else {
        console.warn(`[parseComponent] No handleAction in context!`);
    }
    return createReactElement(structure, props, fullContext);
};
// Ré-exporter tous les modules pour utilisation avancée
export { resolveTemplate, resolveTemplateObject } from './resolveTemplate';
export { resolveProps } from './resolveProps';
export { applyVariants } from './applyVariants';
export { resolveChildren } from './resolveChildren';
export { createReactElement } from './createReactElement';
