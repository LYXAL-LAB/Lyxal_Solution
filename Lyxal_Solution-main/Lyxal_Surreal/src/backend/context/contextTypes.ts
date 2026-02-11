// =========================================================
// Types de haut niveau pour le routage multi-tenant Lyxal
// (100% Surreal, sans Logto)
// =========================================================

import type { SurrealContext } from "../client/surrealContext";

/**
 * Identifiants logiques Lyxal (business).
 * Tu pourras les aligner sur tes tables Surreal (account, workspace, etc.).
 */
export type TenantId = string;
export type WorkspaceId = string;
export type SaaSModuleId = string; // ex: "crm", "erp", "ai", "marketing"

/**
 * Contexte Surreal résolu par le moteur Lyxal.
 * C’est un SurrealContext enrichi d’informations multi-tenant.
 */
export interface ResolvedSurrealContext extends SurrealContext {
  source: "domain" | "workspace" | "manual" | "fallback";
  tenantId?: TenantId;
  workspaceId?: WorkspaceId;
  enabledModules?: SaaSModuleId[];
}

/**
 * Configuration minimale d’un contexte lié à un tenant.
 */
export interface TenantContextConfig {
  namespace: string;
  database: string;
  tenantId?: TenantId;
  workspaceId?: WorkspaceId;
  label?: string;
}

/**
 * Entrée de mapping de domaine (marque blanche).
 */
export interface DomainRoute {
  domain: string; // ex: "acme.com"
  context: TenantContextConfig;
}

/**
 * Entrée de mapping de workspace.
 */
export interface WorkspaceRoute {
  workspaceId: WorkspaceId;
  context: TenantContextConfig;
}

/**
 * Modules SaaS activés pour un tenant/workspace donné.
 */
export interface SaaSModuleConfig {
  tenantId?: TenantId;
  workspaceId?: WorkspaceId;
  modules: SaaSModuleId[];
}
