import { resolveTemplate, resolveTemplateObject } from './resolveTemplate';
import type { TemplateContext } from '../types/component';

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
export const resolveProps = (
  structureProps: Record<string, any> = {},
  componentProps: Record<string, any> = {},
  context: TemplateContext = {}
): Record<string, any> => {
  const resolved: Record<string, any> = {};

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
      resolved[key] = resolveTemplateObject(value, context);
    }
  });

  // Fusionner avec les props du composant (prioritaires)
  // Les props du composant écrasent les props de la structure
  const merged = { ...resolved };
  Object.entries(componentProps).forEach(([key, value]) => {
    // Convertir className array en string aussi pour les props du composant
    if (key === 'className' && Array.isArray(value)) {
      merged[key] = value.join(' ');
    } else {
      merged[key] = value;
    }
  });

  // S'assurer que className est une string (pas un array) dans le résultat final
  if (merged.className && Array.isArray(merged.className)) {
    merged.className = merged.className.join(' ');
  }

  return merged;
};

