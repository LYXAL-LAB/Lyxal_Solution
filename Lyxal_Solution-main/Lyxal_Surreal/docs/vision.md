📘 Lyxal_Surreal — Documentation Officielle
🏛️ 1. Introduction

Lyxal_Surreal est le moteur SurrealDB unifié de l’écosystème LYXAL.

Il fournit :

un client SurrealDB unique (singleton)

une gestion native du multi-namespace / multi-database

des helpers de requêtes (ORM minimal)

un système robuste de retry, logs, validation, Wrappers d’erreur

la fondation pour :

Lyxal Auth

Lyxal CRM

Lyxal Marketing

Lyxal Studio

Lyxal OS

Les modules des SaaS clients

Ce module constitue le point d’entrée unique pour toutes les interactions avec SurrealDB dans l’écosystème LYXAL.

📁 2. Structure du module
Lyxal_Surreal/
│
├─ src/
│   ├─ client/
│   │   surrealConfig.ts
│   │   surrealEnvironment.ts
│   │   surrealContext.ts
│   │   surrealClient.ts
│   │
│   ├─ query/
│   │   query.ts
│   │   select.ts
│   │   write.ts
│   │   transaction.ts
│   │   health.ts
│   │
│   ├─ utils/
│   │   types.ts
│   │   errors.ts
│   │   logger.ts
│   │   retry.ts
│   │
│   ├─ scripts/
│   │   functions/
│   │   events/
│   │   tables/
│   │   seed/
│   │
│   ├─ admin_ui/     (réservé, pas utilisé pour le moment)
│   │
│   └─ index.ts
│
└─ .env

🔧 3. Configuration .env
LYXAL_SURREAL_URL=wss://xxx.surreal.cloud/rpc
LYXAL_SURREAL_USER=admin
LYXAL_SURREAL_PASS=admin
LYXAL_SURREAL_NAMESPACE=Lyxal_Solution
LYXAL_SURREAL_DATABASE=Developpement


Ces valeurs définissent le contexte par défaut.

Chaque module peut ensuite créer son propre contexte pour travailler dans une autre base / namespace.

🧠 4. Architecture multi-tenant

Le module gère nativement :

un contexte par défaut

des contextes spécifiques (par SaaS, workspace, tenant…)

👉 Définition d’un contexte :
createContext(namespace: string, database: string)

Exemple :
const CRM_CTX = createContext("Lyxal_CRM", "Customer");

🔌 5. Le client Surreal (singleton)

Ce module utilise un client unique initialisé une seule fois :

connexion wss

signin

sélection du namespace/database

retry

logs

Import :
import { getSurrealClient } from "@lyxal/surreal";

📚 6. ORM minimal — Helpers de requêtes

Le module fournit les helpers suivants :

✔ rawQuery(surql, vars?, ctx?)

Pour exécuter n’importe quel SurrealQL.

✔ selectAll(table, ctx)

Pour sélectionner tous les enregistrements.

✔ selectById(tableOrId, id?, ctx)

Sélection par identifiant.

✔ createRecord(table, data, ctx)

Insertion.

✔ updateRecord(tableOrId, data, ctx)

Remplacement complet.

✔ mergeRecord(tableOrId, data, ctx)

Mise à jour partielle.

✔ deleteRecord(tableOrId, ctx)

Suppression.

✔ transactional(ctx, steps)

Bloc transactionnel.

✔ checkHealth()

Ping SurrealDB.

🧪 7. Exemple complet d’utilisation

(celui que tu m’as demandé, présenté proprement)

🎯 Exemple : Module Lyxal CRM
🎛 Définir le contexte CRM
import { createContext } from "@lyxal/surreal";

const CRM_CTX = createContext("Lyxal_CRM", "Customer");

📌 LISTE des entreprises
import { selectAll } from "@lyxal/surreal";

export async function listCompanies() {
  return selectAll("company", CRM_CTX);
}

🏗 CRÉER une entreprise
import { createRecord } from "@lyxal/surreal";

export async function createCompany(data: any) {
  return createRecord("company", data, CRM_CTX);
}

🔍 RÉCUPÉRER une entreprise par ID
import { selectById } from "@lyxal/surreal";

export async function getCompany(id: string) {
  return selectById("company", id, CRM_CTX);
}

🔁 METTRE À JOUR une entreprise
import { mergeRecord } from "@lyxal/surreal";

export async function updateCompany(id: string, data: any) {
  return mergeRecord(`company:${id}`, data, CRM_CTX);
}

🗑 SUPPRIMER une entreprise
import { deleteRecord } from "@lyxal/surreal";

export async function deleteCompany(id: string) {
  return deleteRecord(`company:${id}`, CRM_CTX);
}

🔒 Exemple transactionnel

(Dépend de ton futur module CRM)

import { transactional } from "@lyxal/surreal";

export async function createCompanyWithOwner(company, owner) {
  return transactional(CRM_CTX, async (db) => {
    const c = await db.create("company", company);
    const o = await db.create("owner", { ...owner, company: c.id });
    return { company: c, owner: o };
  });
}

⚙️ 8. Bonnes pratiques LYXAL

Tous les modules doivent utiliser Lyxal_Surreal.

Jamais de client Surreal ailleurs.

Toujours utiliser un context dédié par module.

Logique métier → dans les modules (CRM, Auth, Marketing…)

Logique DB → uniquement dans Lyxal_Surreal.

Scripts (tables, seeds, fn…) → dans src/scripts/.

Admin UI → plus tard dans src/admin_ui/.

🏁 9. Résumé
Lyxal_Surreal est :

un client Surreal centralisé

un ORM minimal

une abstraction multi-SaaS / multi-tenant

une base pour importer tes scripts builder / tables / seeds

une fondation pour l’admin UI interne

un module critique de l’architecture Lyxal Solution

Avec cette documentation, tu peux maintenant :

✔ intégrer Lyxal_Surreal dans tes modules
✔ unifier toute la gestion Surreal
✔ préparer ton futur admin panel unifié
✔ préparer la génération dynamique de bases via builder