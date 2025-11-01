import { resolveTemplate } from '../parser/resolveTemplate';

/**
 * Sources de contexte disponibles pour résoudre les templates
 */
export interface ContextSources {
  page?: any;
  user?: any;
  tenant?: any;
  row?: any;        // Pour les tableaux
  state?: any;      // State local (useStudioState)
  params?: any;     // Paramètres URL
  workspace?: any;  // Contexte workspace
  props?: any;      // Props du composant
}

/**
 * Gestion centralisée des contextes dynamiques
 * 
 * Permet de fusionner et résoudre les templates depuis différentes sources :
 * - page.title.fr
 * - user.email
 * - state.search
 * - etc.
 */
export class ContextManager {
  /**
   * Fusionne tous les contextes disponibles
   * 
   * @param baseContext - Contextes de base (page, user, tenant, etc.)
   * @param extra - Contextes supplémentaires à fusionner
   * @returns Contexte fusionné pour résoudre les templates
   */
  static merge(
    baseContext: ContextSources = {},
    extra?: Record<string, any>
  ): Record<string, any> {
    return {
      page: baseContext.page || {},
      user: baseContext.user || {},
      tenant: baseContext.tenant || {},
      row: baseContext.row || {},
      state: baseContext.state || {},
      params: baseContext.params || {},
      workspace: baseContext.workspace || {},
      props: baseContext.props || {},
      ...extra,
    };
  }

  /**
   * Récupère une valeur depuis un chemin
   * Ex: "user.email" → context.user.email
   * 
   * @param path - Chemin vers la valeur (ex: "user.email")
   * @param context - Contexte à interroger
   * @returns Valeur trouvée ou undefined
   */
  static getValue(
    path: string,
    context: Record<string, any>
  ): any {
    const keys = path.split('.');
    return keys.reduce((acc, key) => acc?.[key], context);
  }

  /**
   * Résout tous les templates d'un objet récursivement
   * 
   * @param obj - Objet contenant potentiellement des templates
   * @param context - Contexte pour résoudre les variables
   * @returns Objet avec templates résolus
   */
  static resolve(
    obj: any,
    context: Record<string, any>
  ): any {
    if (typeof obj === 'string') {
      return resolveTemplate(obj, context, true);
    }

    if (Array.isArray(obj)) {
      return obj.map(item => this.resolve(item, context));
    }

    if (obj && typeof obj === 'object') {
      // Ne pas résoudre les actions (type: "action")
      if (obj.type === 'action') {
        return obj;
      }

      const resolved: Record<string, any> = {};
      Object.entries(obj).forEach(([key, value]) => {
        resolved[key] = this.resolve(value, context);
      });
      return resolved;
    }

    return obj;
  }
}

