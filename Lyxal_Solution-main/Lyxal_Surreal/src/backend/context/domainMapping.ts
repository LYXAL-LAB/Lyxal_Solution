// =========================================================
// Mapping domaine → contexte tenant (namespace/database)
// Marque blanche 100% Surreal.
// =========================================================

import type { DomainRoute, TenantContextConfig } from "./contextTypes";

/**
 * Map interne : domain -> DomainRoute
 * Exemple:
 *   "acme.com"      -> { context: { namespace:"CRM", database:"acme" } }
 *   "oceane.fr"     -> { context: { namespace:"CRM", database:"oceane" } }
 *   "demo.lyxal.io" -> { context: { namespace:"DEMO", database:"demo" } }
 */
const domainRoutes = new Map<string, DomainRoute>();

/**
 * Enregistre ou met à jour un routeur de domaine.
 */
export function registerDomainRoute(
  domain: string,
  context: TenantContextConfig,
): void {
  const normalized = domain.trim().toLowerCase();
  const route: DomainRoute = {
    domain: normalized,
    context,
  };
  domainRoutes.set(normalized, route);
}

/**
 * Récupère la configuration de contexte pour un domaine donné.
 * Retourne undefined si aucune correspondance.
 */
export function getDomainRoute(domain: string): DomainRoute | undefined {
  const normalized = domain.trim().toLowerCase();
  return domainRoutes.get(normalized);
}

/**
 * Liste tous les contextes enregistrés via les domaines.
 */
export function listDomainContexts(): TenantContextConfig[] {
  return Array.from(domainRoutes.values()).map((r) => r.context);
}
