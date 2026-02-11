// =========================================================
// Gestion du contexte SurrealDB (namespace / database)
// Multi-SaaS / multi-tenant pour l’écosystème LYXAL.
// =========================================================

export interface SurrealContext {
    namespace: string;
    database: string;
    /**
     * Optionnel : permet d'annoter un contexte (ex: "lyxalcrm:customer").
     * Utile pour les logs, traces, monitoring.
     */
    label?: string;
    /**
     * Optionnel : identifiant SaaS/tenant/workspace.
     * Non utilisé directement par Surreal, mais utile pour le routage logique.
     */
    tenantId?: string;
  }
  
  let defaultContext: SurrealContext | null = null;
  
  /**
   * Crée un contexte Surreal strict.
   */
  export function createContext(
    namespace: string,
    database: string,
    options?: { label?: string; tenantId?: string },
  ): SurrealContext {
    const ns = namespace.trim();
    const db = database.trim();
  
    if (!ns || !db) {
      throw new Error(
        "[Lyxal_Surreal] createContext() requires non-empty namespace and database.",
      );
    }
  
    return {
      namespace: ns,
      database: db,
      label: options?.label,
      tenantId: options?.tenantId,
    };
  }
  
  /**
   * Définit le contexte par défaut utilisé par tout LYXAL
   * lorsque aucun contexte spécifique n’est fourni.
   */
  export function setDefaultContext(ctx: SurrealContext): void {
    if (!ctx.namespace || !ctx.database) {
      throw new Error(
        "[Lyxal_Surreal] setDefaultContext() requires a valid namespace and database.",
      );
    }
    defaultContext = ctx;
  }
  
  /**
   * Récupère le contexte par défaut.
   */
  export function getDefaultContext(): SurrealContext {
    if (!defaultContext) {
      throw new Error(
        "[Lyxal_Surreal] Default SurrealContext is not initialized. " +
          "Call getSurrealConfig() (qui initialise le contexte) avant l'utilisation.",
      );
    }
    return defaultContext;
  }
  
  /**
   * Permet de dériver un nouveau contexte à partir du contexte par défaut,
   * en changeant éventuellement la database ou le namespace.
   */
  export function deriveContext(
    overrides: Partial<Pick<SurrealContext, "namespace" | "database" | "label" | "tenantId">>,
  ): SurrealContext {
    const base = getDefaultContext();
    return {
      namespace: overrides.namespace?.trim() || base.namespace,
      database: overrides.database?.trim() || base.database,
      label: overrides.label ?? base.label,
      tenantId: overrides.tenantId ?? base.tenantId,
    };
  }
  