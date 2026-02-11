import type { TemplateContext } from '../types/component';
/**
 * Définit le contexte d'actions pour la résolution des props
 */
export declare const setActionContext: (context: {
    handleAction: (action: any, event?: any) => Promise<any>;
}) => void;
/**
 * Résout et fusionne les props d'un composant
 *
 * Les props de la structure sont résolues avec le contexte,
 * puis les props du composant (passées en paramètre) sont fusionnées
 * et écrasent les props de la structure.
 *
 * @param structureProps - Props définies dans la structure JSON du composant
 * @param componentProps - Props passées au composant lors du rendu
 * @param context - Contexte pour résoudre les templates
 * @returns Props résolues et fusionnées
 */
export declare const resolveProps: (structureProps?: Record<string, any>, componentProps?: Record<string, any>, context?: TemplateContext) => Record<string, any>;
