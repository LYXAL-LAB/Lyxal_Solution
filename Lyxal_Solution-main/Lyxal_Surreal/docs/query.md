📘 Documentation Officielle — Lyxal_Surreal / Query (Version PRO)

Version prête à mettre dans ton dossier docs/ ou dans le README du module.

Elle couvre :

query.ts — rawQuery PRO

select.ts — lecture PRO

write.ts — écriture PRO

transaction.ts — transactions PRO

health.ts — healthcheck PRO

Elle est claire, structurée, professionnelle, et alignée 100 % sur ton architecture.

📚 LYXAL SURREAL ENGINE — MODULE QUERY (VERSION PRO)

Le module query/ fournit une couche d’accès SurrealDB professionnelle, harmonisée et sécurisée, utilisée par tous les modules SaaS (CRM, Auth, ERP, Travel, AI, etc.).

Cette couche s’appuie sur :

le client Surreal PRO (surrealClient)

les utils PRO (logger, errors, retry, types)

le multi-contexte NS/DB (surrealContext)

Elle garantit :

✔ Sécurité (Isolation Thread-Safe)
✔ Reconnexion intelligente
✔ Logs JSON structurés
✔ Erreurs normalisées
✔ Retry intelligent (backoff exponentiel + jitter)
✔ Multi-SaaS
✔ Extensibilité par module

⚡ NOTE PERFORMANCE
Toutes ces fonctions exploitent automatiquement le nouveau Pool de Connexions "Enterprise-Grade".
- Pas besoin de gérer la connexion manuellement.
- Le contexte passé en argument (ctx) détermine quelle connexion du pool est utilisée.
- Zéro latence de switching (context-switch O(1)).

📁 Structure du dossier query/
query/
   query.ts
   select.ts
   write.ts
   transaction.ts
   health.ts


Chaque fichier répond à un besoin précis.

1️⃣ query.ts — rawQuery PRO
🎯 Rôle

Fournir l'accès brut à SurrealQL, avec :

retry automatique

logs PRO

erreurs PRO (SurrealError)

exécution dans un namespace/database donné

compatibilité multi-tenant

C’est la fonction la plus flexible et la plus bas niveau.

🧩 API
rawQuery<T = JsonValue>(
  surql: string,
  vars?: Record<string, unknown>,
  ctx?: SurrealContext | null,
  options?: RawQueryOptions
): Promise<T[]>

⚙ Options

useRetry : active/désactive le retry

attempts : nb de tentatives

delayMs : délai initial

label : identifiant pour les logs

🧪 Exemple
const rows = await rawQuery(
  "SELECT * FROM company WHERE active = true",
  {},
  CRM_CTX,
  { label: "crm:list_active_companies" }
);

2️⃣ select.ts — lecture PRO
🎯 Rôle

Centraliser toutes les opérations de lecture :

selectAll(table)

selectById(table, id)

Avec :

logs PRO

erreurs PRO

execution contextuelle (NS/DB)

🧪 Exemple
const customers = await selectAll("customer", CRM_CTX);

const order = await selectById("order", "abc123", CRM_CTX);

3️⃣ write.ts — écriture PRO
🎯 Rôle

Opérations CRUD typées :

createRecord()

updateRecord()

mergeRecord()

deleteRecord()

Avec :

DeepPartial<T>

SurrealRecord<T>

logs PRO

retry via surrealClient

gestion des erreurs Surreal

🧪 Exemple : créer un record
const company = await createRecord("company", {
  name: "Lyxal Corp",
  active: true
}, CRM_CTX);

🧪 Exemple : mettre à jour un record
await updateRecord("company:xyz123", {
  name: "Lyxal Corp International"
}, CRM_CTX);

🧪 Exemple : merge
await mergeRecord("company", { active: false }, CRM_CTX, "xyz123");

🧪 Exemple : delete
await deleteRecord("company:xyz123", CRM_CTX);

4️⃣ transaction.ts — transactions PRO
🎯 Rôle

Offrir un système transactionnel robuste via :

BEGIN TRANSACTION

COMMIT TRANSACTION

CANCEL TRANSACTION

Avec :

rollback automatique

logs avancés

erreurs PRO

multi-tenant

🧩 API
transactional(ctx, async (db) => {
  const a = await db.create("user", dataUser);
  const b = await db.create("company", { ...dataCompany, owner: a.id });

  return { a, b };
});

🧪 Exemple
const result = await transactional(CRM_CTX, async (db) => {
  const comp = await db.create("company", { name: "TestCo" });
  const log = await db.create("company_log", { company: comp.id });
  return { comp, log };
});

5️⃣ health.ts — healthcheck PRO
🎯 Rôle

Tester la santé d’un contexte SurrealDB :

Temps de réponse

Validité de la connexion

Logs PRO

🧪 Exemple
const status = await checkHealth(CRM_CTX);

if (!status.ok) console.warn("CRM database is not healthy!");

🧩 Résumé du module Query PRO
Fichier	Description	Usage principal
query.ts	SurrealQL brut + retry + logs	Flexibilité totale
select.ts	Lecture typée	Liste, détails
write.ts	Création / Update / Merge / Delete	CRUD métier
transaction.ts	Transactions robustes	Opérations atomiques
health.ts	Vérification de santé	Monitoring / tests
⭐ Exemple global (CRM)
import {
  createContext,
  selectAll,
  createRecord,
  transactional,
  rawQuery,
} from "@lyxal/surreal";

const CRM_CTX = createContext("Lyxal_CRM", "Customer");

// Lire
const customers = await selectAll("customer", CRM_CTX);

// Écrire
await createRecord("customer", { name: "Alice" }, CRM_CTX);

// Transaction
await transactional(CRM_CTX, async (db) => {
  const a = await db.create("customer", { name: "Bob" });
  const l = await db.create("customer_log", { customer: a.id });
});
