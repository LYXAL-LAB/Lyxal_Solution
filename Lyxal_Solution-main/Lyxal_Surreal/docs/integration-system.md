🔗 Intégration avec Lyxal_System
================================

Ce document explique comment le moteur `Lyxal_Surreal` s'interface avec le module métier `Lyxal_System` pour gérer le multi-tenant dynamique.

1. Le Principe de Séparation
----------------------------

- **Lyxal_Surreal** est le **MOTEUR**.
  Il sait router `domaine → base de données`, mais il ne sait pas *qui* sont les clients. Il démarre "vide" (sans connaissance des tenants).

- **Lyxal_System** est le **CERVEAU**.
  C'est le module qui possède les tables `tenant`, `workspace`, `tenant_domain` dans sa propre base de données. C'est la "Source of Truth".

2. Le Cycle de Démarrage (Boot Sequence)
----------------------------------------

Pour que le système fonctionne, une séquence d'initialisation doit avoir lieu au lancement de l'application (API Gateway ou Microservice).

### Diagramme de Séquence

```
[Boot] 
  │
  ├── 1. Connexion à la DB Lyxal_System (Contexte Admin fixe)
  │
  ├── 2. Lecture de la configuration active
  │    ├── SELECT * FROM tenant WHERE status = 'active'
  │    ├── SELECT * FROM tenant_domain
  │    └── SELECT * FROM tenant_module
  │
  ├── 3. Injection dans Lyxal_Surreal (In-Memory)
  │    ├── registerDomainRoute(...)
  │    ├── registerWorkspaceRoute(...)
  │    └── setSaaSModules(...)
  │
  └── 4. Préchauffage (Warmup)
       └── warmupSurrealConnections(...)
```

3. Exemple de Bootstrapper
--------------------------

Voici à quoi ressemblera le script de démarrage dans votre application principale (ex: `src/main.ts`) :

```typescript
import { 
  createContext, 
  selectAll, 
  registerDomainRoute, 
  registerWorkspaceRoute,
  setSaaSModules,
  warmupSurrealConnections,
  getSurrealContextFor
} from "@lyxal/surreal";

// 1. Définir le contexte système (fixe dans le .env)
const SYSTEM_CTX = createContext(
  process.env.LYXAL_SYSTEM_NS || "LYXAL_SYSTEM",
  process.env.LYXAL_SYSTEM_DB || "core"
);

export async function bootstrapMultiTenancy() {
  console.log("🚀 Bootstrapping Lyxal Multi-Tenant Engine...");

  // 2. Lire la configuration depuis la DB System
  // (Note: On utilise le moteur Surreal pour lire sa propre config !)
  const tenants = await selectAll("tenant", SYSTEM_CTX);
  const domains = await selectAll("tenant_domain", SYSTEM_CTX);
  const modules = await selectAll("tenant_module", SYSTEM_CTX);

  console.log(`📥 Loaded ${tenants.length} tenants, ${domains.length} domains.`);

  // 3. Configurer le routeur (In-Memory)
  for (const dom of domains) {
    registerDomainRoute(dom.domain, {
      namespace: dom.target_namespace,
      database: dom.target_database,
      tenantId: dom.tenant_id,
      label: `${dom.tenant_id}:${dom.target_database}`
    });
  }

  for (const ten of tenants) {
    // Si le tenant a des modules spécifiques
    const tenantMods = modules
      .filter(m => m.tenant_id === ten.id)
      .map(m => m.module_id);

    setSaaSModules({
      tenantId: ten.id,
      modules: tenantMods
    });
  }

  // 4. Warmup des connexions critiques
  console.log("🔥 Warming up active contexts...");
  const allContexts = tenants.map(t => ({
    namespace: t.target_namespace,
    database: t.target_database,
    tenantId: t.id
  }));
  
  await warmupSurrealConnections(
    allContexts.map(c => getSurrealContextFor({ explicitContext: c })!)
  );

  console.log("✅ System Ready.");
}
```

4. Avantages de cette architecture
----------------------------------
1.  **Zéro Latence** : Une fois chargé, le routage se fait en mémoire RAM (via `contextResolver` + Cache LRU). Pas de requête DB pour savoir quelle DB interroger.
2.  **Robustesse** : Si la DB `Lyxal_System` tombe temporairement, les instances déjà lancées continuent de fonctionner car la config est en cache mémoire.
3.  **Découplage** : Vous pouvez changer le schéma de `Lyxal_System` sans toucher une ligne de code de `Lyxal_Surreal`.

