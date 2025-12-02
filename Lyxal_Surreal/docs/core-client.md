📘 Rôle des 6 fichiers Core
=========================================

Ce module constitue le cœur de la connectivité SurrealDB pour tout l'écosystème Lyxal.

1. surrealEnvironment.ts
------------------------
Lit et valide les variables d’environnement (URL, user, pass, namespace, database, fallbacks).
👉 C’est la seule couche qui touche `process.env`.

2. surrealContext.ts
--------------------
Gère les définitions de contextes Surreal : namespace, database, plus des métadonnées (label, tenantId).
👉 Permet d’avoir un contexte par module SaaS, par workspace, ou par tenant.

3. surrealConfig.ts
-------------------
Fusionne surrealEnvironment + surrealContext pour produire une config runtime :
- URL principale
- URLs fallback
- Contexte par défaut
- Modes préférés (WS/HTTP)

4. surrealConnection.ts
-----------------------
Fabrique technique d'une connexion SurrealDB :
- Gestion Multi-URL (fallback automatique)
- Gestion Multi-mode (WS/HTTP)
- Retry pattern (tentatives multiples)
- Mesure de latence

5. surrealClient.ts (Moteur Enterprise-Grade)
---------------------------------------------
Gère le cycle de vie des connexions via un **Pool Intelligent** :
- **Multi-Context Pool** : Maintient une connexion WebSocket dédiée par couple `Namespace:Database`.
- **Thread-Safe** : Isolation totale entre les tenants (CRM, Auth, ERP ne partagent pas la même connexion active).
- **Auto-Cleanup (LRU)** : Ferme automatiquement les connexions inutilisées après 10 minutes.
- **Health Throttling** : Vérifie la santé de la base toutes les 30s maximum pour réduire la charge.
- **Reconnexion Automatique** : Gère la perte de lien par contexte individuel.

6. surrealWarmup.ts (Nouveau 🚀)
--------------------------------
Utilitaire de préchauffage pour le démarrage des applications :
- Ouvre proactivement les connexions critiques (Auth, Config).
- Élimine la latence de la première requête utilisateur.

---

🧪 Exemple d’utilisation dans un module
=======================================

```typescript
import {
  createContext,
  selectAll,
  createRecord,
} from "@lyxal/surreal";

// 1. Définir un contexte isolé (aura sa propre connexion dans le pool)
const CRM_CTX = createContext("Lyxal_CRM", "Customer", {
  label: "lyxalcrm:customer",
});

// 2. Les requêtes utilisent automatiquement le pool
export async function listCompanies() {
  // Si la connexion CRM est ouverte, elle est réutilisée.
  // Sinon, elle est créée, mise en cache, et utilisée.
  return selectAll("company", CRM_CTX);
}

export async function createCompany(data: any) {
  return createRecord("company", data, CRM_CTX);
}
```

⚙️ Fonctionnement Interne du Pool
=================================

| État | Action |
| :--- | :--- |
| **Première requête** | Ouvre une connexion WebSocket, l'ajoute au Pool, l'utilise. (Latence ~50-100ms) |
| **Requêtes suivantes** | Réutilise la connexion du Pool. (Latence ~1-5ms) |
| **Inactivité > 10min** | La connexion est fermée et retirée du Pool (Libération RAM). |
| **Erreur réseau** | La connexion est marquée "unhealthy", une reconnexion est tentée automatiquement. |
