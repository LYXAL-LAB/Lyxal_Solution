// =========================================================
// Mapping workspace/account → contexte tenant (namespace/database)
// Permet de router à partir de l'identité "in-app" Lyxal.
// =========================================================

import type {
    TenantContextConfig,
    WorkspaceId,
    WorkspaceRoute,
  } from "./contextTypes";
  
  const workspaceRoutes = new Map<WorkspaceId, WorkspaceRoute>();
  
  /**
   * Enregistre un contexte pour un workspace donné.
   */
  export function registerWorkspaceRoute(
    workspaceId: WorkspaceId,
    context: TenantContextConfig,
  ): void {
    const route: WorkspaceRoute = {
      workspaceId,
      context,
    };
    workspaceRoutes.set(workspaceId, route);
  }
  
  /**
   * Récupère la configuration de contexte pour un workspace donné.
   */
  export function getWorkspaceRoute(
    workspaceId: WorkspaceId,
  ): WorkspaceRoute | undefined {
    return workspaceRoutes.get(workspaceId);
  }
  
  /**
   * Liste tous les contextes attachés à des workspaces.
   */
  export function listWorkspaceContexts(): TenantContextConfig[] {
    return Array.from(workspaceRoutes.values()).map((r) => r.context);
  }
  