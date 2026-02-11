// =========================================================
// Gestion des modules SaaS activés par tenant/workspace.
// Exemple: CRM, ERP, AI, MARKETING, etc.
// =========================================================

import type {
    SaaSModuleConfig,
    SaaSModuleId,
    TenantId,
    WorkspaceId,
  } from "./contextTypes";
  
  /**
   * Index: clé composite "tenantId|workspaceId" → configuration des modules.
   */
  const saasModulesByKey = new Map<string, SaaSModuleConfig>();
  
  function makeKey(tenantId?: TenantId, workspaceId?: WorkspaceId): string {
    return `${tenantId || "_"}|${workspaceId || "_"}`;
  }
  
  /**
   * Enregistre ou remplace la config de modules pour un tenant/workspace.
   */
  export function setSaaSModules(
    config: SaaSModuleConfig,
  ): void {
    const key = makeKey(config.tenantId, config.workspaceId);
    saasModulesByKey.set(key, config);
  }
  
  /**
   * Ajoute un module pour un tenant/workspace.
   */
  export function addSaaSModule(
    tenantId: TenantId | undefined,
    workspaceId: WorkspaceId | undefined,
    moduleId: SaaSModuleId,
  ): void {
    const key = makeKey(tenantId, workspaceId);
    const existing = saasModulesByKey.get(key) || {
      tenantId,
      workspaceId,
      modules: [],
    };
  
    if (!existing.modules.includes(moduleId)) {
      existing.modules.push(moduleId);
    }
  
    saasModulesByKey.set(key, existing);
  }
  
  /**
   * Récupère les modules pour un tenant/workspace.
   */
  export function getSaaSModules(
    tenantId?: TenantId,
    workspaceId?: WorkspaceId,
  ): SaaSModuleConfig | undefined {
    const key = makeKey(tenantId, workspaceId);
    return saasModulesByKey.get(key);
  }
  
  /**
   * Vérifie si un module particulier est activé.
   */
  export function isModuleEnabled(
    moduleId: SaaSModuleId,
    tenantId?: TenantId,
    workspaceId?: WorkspaceId,
  ): boolean {
    const config = getSaaSModules(tenantId, workspaceId);
    return !!config?.modules.includes(moduleId);
  }
  