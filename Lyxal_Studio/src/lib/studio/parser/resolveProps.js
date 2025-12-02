import { resolveTemplate, resolveTemplateObject } from './resolveTemplate';
/**
 * Contexte d'actions pour créer des handlers dynamiques
 */
let actionContext = {};
/**
 * Définit le contexte d'actions pour la résolution des props
 */
export const setActionContext = (context) => {
    actionContext = context;
};
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
export const resolveProps = (structureProps = {}, componentProps = {}, context = {}) => {
    const resolved = {};
    // Résoudre les props de la structure
    Object.entries(structureProps).forEach(([key, value]) => {
        // Convertir className array en string
        if (key === 'className' && Array.isArray(value)) {
            resolved[key] = value.join(' ');
        }
        // Si c'est une string, résoudre le template en préservant le type
        else if (typeof value === 'string') {
            resolved[key] = resolveTemplate(value, context, true);
        }
        // Si c'est une action, garder l'objet action tel quel
        else if (value && typeof value === 'object' && value.type === 'action') {
            resolved[key] = value;
        }
        // Sinon, résoudre récursivement (pour objets/arrays)
        else {
            const resolvedValue = resolveTemplateObject(value, context);
            // Si c'est une prop d'événement (onClick, onChange, etc.) et que la valeur résolue est un objet action
            if (key.startsWith('on') && resolvedValue && typeof resolvedValue === 'object') {
                console.log(`[resolveProps] Checking if ${key} value is an action:`, resolvedValue);
                // Vérifier si c'est un objet action
                const isAction = resolvedValue.type === 'alert' ||
                    resolvedValue.type === 'navigation' ||
                    resolvedValue.type === 'modal' ||
                    resolvedValue.type === 'state' ||
                    resolvedValue.type === 'action';
                if (isAction) {
                    console.log(`[resolveProps] ✅ Creating action handler for ${key}:`, resolvedValue);
                    // Normaliser le format d'action pour useActionHandler
                    let normalizedAction;
                    if (resolvedValue.type === 'action') {
                        // Format déjà normalisé
                        normalizedAction = resolvedValue;
                    }
                    else {
                        // Convertir le format simple vers le format attendu
                        normalizedAction = {
                            type: 'action',
                            action: resolvedValue.type,
                            params: { ...resolvedValue },
                        };
                        // Supprimer 'type' des params car il devient 'action'
                        delete normalizedAction.params.type;
                    }
                    // Créer une fonction qui appelle handleAction
                    resolved[key] = (event) => {
                        console.log(`[resolveProps] 🎯 Executing action for ${key}:`, normalizedAction);
                        if (actionContext.handleAction) {
                            actionContext.handleAction(normalizedAction, event);
                        }
                        else {
                            console.warn('[resolveProps] No action context available for', key, normalizedAction);
                        }
                    };
                }
                else {
                    console.log(`[resolveProps] ❌ Not an action for ${key}:`, resolvedValue);
                    resolved[key] = resolvedValue;
                }
            }
            else {
                resolved[key] = resolvedValue;
            }
        }
    });
    // Fusionner avec les props du composant (prioritaires)
    // Les props du composant écrasent les props de la structure
    const merged = { ...resolved };
    Object.entries(componentProps).forEach(([key, value]) => {
        // Convertir className array en string aussi pour les props du composant
        if (key === 'className' && Array.isArray(value)) {
            merged[key] = value.join(' ');
        }
        else {
            merged[key] = value;
        }
    });
    // S'assurer que className est une string (pas un array) dans le résultat final
    if (merged.className && Array.isArray(merged.className)) {
        merged.className = merged.className.join(' ');
    }
    return merged;
};
