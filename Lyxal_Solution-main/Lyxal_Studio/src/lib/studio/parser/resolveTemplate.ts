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
export const resolveTemplate = (
  template: string | any,
  context: TemplateContext = {},
  preserveType: boolean = false
): string | any => {
  // Si ce n'est pas une string, retourner tel quel
  if (!template || typeof template !== 'string') {
    return template;
  }

  // Si le template n'a qu'une seule variable et qu'on veut préserver le type
  if (preserveType) {
    const singleMatch = template.match(/^\{\{([^}]+)\}\}$/);
    if (singleMatch) {
      const keys = singleMatch[1].trim().split('.');
      let value: any = context;

      for (const key of keys) {
        value = value?.[key];
        if (value === undefined || value === null) {
          break;
        }
      }

      // Retourner la valeur originale (booléen, nombre, etc.)
      if (value !== undefined && value !== null) {
        return value;
      }
      return template;
    }
  }

  // Remplacer tous les patterns {{...}} (mode string)
  return template.replace(/\{\{([^}]+)\}\}/g, (match, path) => {
    const keys = path.trim().split('.');
    let value: any = context;

    // Parcourir le chemin (ex: "page.title.fr" → context.page.title.fr)
    for (const key of keys) {
      value = value?.[key];
      if (value === undefined || value === null) {
        break;
      }
    }

    // Si la valeur existe, la retourner (convertie en string)
    // Sinon, retourner le template original (pour debug)
    return value !== undefined && value !== null 
      ? String(value) 
      : match;
  });
};

/**
 * Résout un objet récursivement (pour les props complexes)
 * 
 * @param obj - Objet contenant potentiellement des templates
 * @param context - Contexte pour résoudre les variables
 * @returns Objet avec templates résolus
 */
export const resolveTemplateObject = (
  obj: any,
  context: TemplateContext = {}
): any => {
  if (typeof obj === 'string') {
    // Pour les objets, on veut préserver les types (booléens, nombres)
    return resolveTemplate(obj, context, true);
  }

  if (Array.isArray(obj)) {
    return obj.map(item => resolveTemplateObject(item, context));
  }

  if (obj && typeof obj === 'object') {
    // Ne pas résoudre les actions (type: "action")
    if (obj.type === 'action') {
      return obj;
    }

    const resolved: Record<string, any> = {};
    for (const [key, value] of Object.entries(obj)) {
      resolved[key] = resolveTemplateObject(value, context);
    }
    return resolved;
  }

  return obj;
};

