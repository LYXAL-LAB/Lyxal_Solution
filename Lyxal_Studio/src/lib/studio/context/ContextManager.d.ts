/**
 * Sources de contexte disponibles pour résoudre les templates
 */
export interface ContextSources {
    page?: any;
    user?: any;
    tenant?: any;
    row?: any;
    state?: any;
    params?: any;
    workspace?: any;
    props?: any;
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
export declare class ContextManager {
    /**
     * Fusionne tous les contextes disponibles
     *
     * @param baseContext - Contextes de base (page, user, tenant, etc.)
     * @param extra - Contextes supplémentaires à fusionner
     * @returns Contexte fusionné pour résoudre les templates
     */
    static merge(baseContext?: ContextSources, extra?: Record<string, any>): Record<string, any>;
    /**
     * Récupère une valeur depuis un chemin
     * Ex: "user.email" → context.user.email
     *
     * @param path - Chemin vers la valeur (ex: "user.email")
     * @param context - Contexte à interroger
     * @returns Valeur trouvée ou undefined
     */
    static getValue(path: string, context: Record<string, any>): any;
    /**
     * Résout tous les templates d'un objet récursivement
     *
     * @param obj - Objet contenant potentiellement des templates
     * @param context - Contexte pour résoudre les variables
     * @returns Objet avec templates résolus
     */
    static resolve(obj: any, context: Record<string, any>): any;
}
