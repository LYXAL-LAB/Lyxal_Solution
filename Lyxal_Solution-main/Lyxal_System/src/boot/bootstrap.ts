// src/boot/bootstrap.ts
import {
  createContext,
  selectAll,
  registerDomainRoute,
  registerWorkspaceRoute,
  setSaaSModules,
  warmupSurrealConnections,
  getSurrealContextFor,
} from "@lyxal/surreal";

// Types pour nos tables System (simplifiés pour le boot)
interface Tenant {
  id: string;
  target_namespace: string;
  target_database: string;
  status: string;
}

interface TenantDomain {
  domain: string;
  tenant: string; // record<tenant> ID
  target_namespace?: string; // optionnel si surcharge
  target_database?: string;
}

interface TenantModule {
  tenant: string; // record<tenant> ID
  module_id: string;
  status: string;
}

// 1. Définir le contexte système (fixe via ENV)
// Par défaut : Namespace=LYXAL_SYSTEM, Database=core
const SYSTEM_CTX = createContext(
  process.env.LYXAL_SYSTEM_NS || "LYXAL_SYSTEM",
  process.env.LYXAL_SYSTEM_DB || "core",
  { label: "system:core" }
);

/**
 * Charge la configuration multi-tenant depuis la DB System
 * et configure le moteur de routage Lyxal_Surreal.
 */
export async function bootstrapMultiTenancy() {
  console.log("🚀 [Lyxal_System] Bootstrapping Multi-Tenant Engine...");

  try {
    // 2. Lire la configuration depuis la DB System
    // On interroge les tables que nous venons de définir
    console.log("📥 [Lyxal_System] Loading configuration from DB...");
    
    const tenants = await selectAll<Tenant>("tenant", SYSTEM_CTX);
    const domains = await selectAll<TenantDomain>("tenant_domain", SYSTEM_CTX);
    const modules = await selectAll<TenantModule>("tenant_module", SYSTEM_CTX);

    const activeTenants = tenants.filter((t) => t.status === "active");

    console.log(
      `📊 Found ${tenants.length} tenants (${activeTenants.length} active), ${domains.length} domains, ${modules.length} module configs.`
    );

    // 3. Configurer le routeur (In-Memory)
    
    // A. Mapping Domaines
    for (const dom of domains) {
      // Trouver le tenant parent pour avoir le NS/DB par défaut si pas surchargé
      const parentTenant = activeTenants.find((t) => t.id === dom.tenant);
      
      if (parentTenant) {
        registerDomainRoute(dom.domain, {
          namespace: dom.target_namespace || parentTenant.target_namespace,
          database: dom.target_database || parentTenant.target_database,
          tenantId: parentTenant.id,
          label: `${dom.domain} -> ${parentTenant.target_database}`,
        });
      }
    }

    // B. Mapping Modules SaaS
    for (const ten of activeTenants) {
      const tenantMods = modules
        .filter((m) => m.tenant === ten.id && m.status === "active")
        .map((m) => m.module_id);

      setSaaSModules({
        tenantId: ten.id,
        modules: tenantMods,
      });
      
      // On pourrait aussi enregistrer une route workspace par défaut ici
      // registerWorkspaceRoute(...)
    }

    // 4. Warmup des connexions critiques
    // On pré-connecte tous les tenants ACTIFS pour éviter la latence à la première requête
    console.log("🔥 [Lyxal_System] Warming up active tenant connections...");
    
    const contextsToWarmup = activeTenants.map((t) => ({
      namespace: t.target_namespace,
      database: t.target_database,
      tenantId: t.id,
      label: `warmup:${t.id}`
    }));

    // On convertit en SurrealContext valides via le helper
    const surrealContexts = contextsToWarmup
      .map((c) => getSurrealContextFor({ explicitContext: c }))
      .filter((c): c is NonNullable<typeof c> => !!c);

    await warmupSurrealConnections(surrealContexts);

    console.log("✅ [Lyxal_System] System Ready. Routing table loaded.");
    
  } catch (err) {
    console.error("❌ [Lyxal_System] Critical Failure during bootstrap:", err);
    throw err; // On laisse planter le serveur si le système ne peut pas charger
  }
}

