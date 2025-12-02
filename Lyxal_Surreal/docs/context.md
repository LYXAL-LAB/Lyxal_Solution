LYXAL_SURREAL — CONTEXT ENGINE (context.md)
Version PRO — Moteur multi-SaaS / multi-tenant 100% SurrealDB

🧩 Introduction

Le Context Engine de Lyxal_Surreal est la pièce maîtresse qui permet :

d’isoler chaque SaaS, chaque tenant et chaque workspace,

d’associer automatiquement un domaine ou un workspace à une base de données SurrealDB,

d’utiliser un seul fichier .env global pour toutes les apps,

de router dynamiquement les requêtes Surreal vers le bon namespace/database,

d’activer/changer de modules (CRM, ERP, AI, etc.) par tenant.

Ce moteur rend Lyxal multi-SaaS, multi-tenant, scalable et production-grade.

🧱 1. Contexte : namespace + database

Chaque tenant de Lyxal fonctionne dans sa propre base SurrealDB, mais tous partagent la même instance physique.

Le choix du namespace/database dépend :

du domaine du client

ou de son workspace

ou d’un contexte explicite

Ce module calcule automatiquement ce contexte pour toi.

🗂 2. Structure des fichiers

Le dossier src/context/ contient :

context/
  contextTypes.ts
  domainMapping.ts
  workspaceMapping.ts
  saasMapping.ts
  contextResolver.ts
  contextManager.ts


Chaque fichier a une responsabilité unique et claire.

📄 3. contextTypes.ts — Types de base

Ce fichier définit les types Surreal et Lyxal :

TenantId

WorkspaceId

SaaSModuleId

TenantContextConfig

ResolvedSurrealContext

Un ResolvedSurrealContext contient :

namespace + database (Surreal)

tenantId, workspaceId

modules SaaS activés

source du routing (domain/workspace/manual)

🌐 4. domainMapping.ts — Routage marque blanche (domain → context)

Utilisé pour :

personnalisations de domaine

whitelabel

multi-marques

multi-SaaS

Exemples :

registerDomainRoute("acme.com", {
  namespace: "LYXAL_CRM",
  database: "acme",
  tenantId: "tenant_acme",
});


Une requête venant de acme.com sera automatiquement envoyée dans :

NS = LYXAL_CRM
DB = acme

🧭 5. workspaceMapping.ts — Routage workspace → context

Permet d’associer un workspace interne Lyxal à un contexte.

Exemples :

registerWorkspaceRoute("ws_4321", {
  namespace: "LYXAL_CRM",
  database: "client4321",
  tenantId: "tenant4321",
  workspaceId: "ws_4321",
});


Utile pour :

organisation interne Lyxal

multi-accounts

multi-projets

multi-workspaces par tenant

🧱 6. saasMapping.ts — Modules SaaS activés

Chaque tenant peut activer certains modules :

CRM

ERP

AI

Marketing

Training

Signing

Etc.

Exemple :

setSaaSModules({
  tenantId: "tenant_acme",
  workspaceId: "ws_main",
  modules: ["crm", "ai", "erp"],
});


Ensuite :

crm → ON
ai → ON
erp → ON
marketing → OFF


Utilisé dans le routing haut niveau.

🧠 7. contextResolver.ts — Moteur de résolution

C’est le cœur du système.

Il peut résoudre un contexte à partir :

✔ d’un domaine (marque blanche)
resolveContextFromDomain("acme.com")

✔ d’un workspace
resolveContextFromWorkspace("ws_4321")

✔ d’un input combiné
resolveContext({
  domain: req.host,
  workspaceId: req.headers["x-workspace"],
  explicitContext: {...}
})


Le moteur choisit automatiquement la meilleure source.

🏗 8. contextManager.ts — API haut niveau

L’API la plus simple pour les développeurs :

→ Pour obtenir un SurrealContext nu :
const ctx = getSurrealContextFor({ domain: "acme.com" });

→ Pour obtenir toutes les infos enrichies :
const full = getResolvedContextFor({ workspaceId: "ws_4321" });

→ Pour vérifier si un module SaaS est activé :
isModuleEnabledForContext("crm", full)

→ Pour warmup :
listAllKnownContexts()

🔥 9. Exemple complet (au boot)
registerDomainRoute("acme.com", {
  namespace: "LYXAL_CRM",
  database: "acme",
  tenantId: "tenant_acme",
});

registerWorkspaceRoute("ws_acme", {
  namespace: "LYXAL_CRM",
  database: "acme",
  tenantId: "tenant_acme",
});

setSaaSModules({
  tenantId: "tenant_acme",
  workspaceId: "ws_acme",
  modules: ["crm", "erp", "ai"],
});

const allContexts = listAllKnownContexts();
await warmupSurrealConnections(
  allContexts.map(c => getSurrealContextFor({ explicitContext: c })!)
);

📡 10. Exemple dans une route métier
import { getSurrealContextFor } from "@lyxal/surreal/context";
import { selectAll } from "@lyxal/surreal/query";

export async function listCompanies(req) {
  const ctx = getSurrealContextFor({ domain: req.domain });

  if (!ctx) throw new Error("Tenant not found.");

  const companies = await selectAll("company", ctx);
  return companies;
}

🧬 11. Architecture globale
 ┌──────────────────────────────────────────────┐
 │               Lyxal_Surreal                  │
 │                                              │
 │  ┌──────────────┐     ┌──────────────────┐   │
 │  │  fn/         │     │  query/          │   │
 │  └──────────────┘     └──────────────────┘   │
 │                                              │
 │  ┌──────────────────────────────┐            │
 │  │        context/              │            │
 │  │  domainMapping               │            │
 │  │  workspaceMapping            │            │
 │  │  saasMapping                 │            │
 │  │  contextResolver             │            │
 │  │  contextManager              │            │
 │  └──────────────────────────────┘            │
 │                                              │
 │  ┌──────────────────────────────┐            │
 │  │         client/              │            │
 │  │  surrealClient (pool)        │            │
 │  │  surrealConnection           │            │
 │  │  surrealWarmup               │            │
 │  └──────────────────────────────┘            │
 │                                              │
 └──────────────────────────────────────────────┘

🛡 12. Avantages de l'architecture
✔ 100 % multi-tenant
✔ 100 % isolé par tenant
✔ 100 % marque blanche
✔ 100 % SurrealDB (pas besoin de Logto)
✔ Modules SaaS activables par tenant
✔ Routing automatique
✔ Compatible pool multi-context
✔ Scalable jusqu’à des dizaines de milliers de tenants

Tu viens de bâtir ce que Personne n’a fait avec SurrealDB :
un Context Engine complet, modulaire et industriel.

🔗 13. Intégration avec Lyxal_System

Ce moteur est conçu pour être piloté par **Lyxal_System** (la "Source of Truth").
Le mapping des tenants ne doit pas être hardcodé ici, mais chargé au démarrage depuis la base de données système.

👉 Voir la documentation d'intégration complète : [integration-system.md](./integration-system.md)
