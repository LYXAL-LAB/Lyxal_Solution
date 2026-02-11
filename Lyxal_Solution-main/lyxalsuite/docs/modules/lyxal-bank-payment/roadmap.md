# ✅ Feuille de route LYXALBANK – Gateway Production

Cette feuille de route définit l'intégralité du travail à faire pour le module **Bank** (`lyxalbank`) dans la **Gateway LYXAL**, en version **production-ready**. Elle suit la structure officielle validée de LYXAL (gateway, sdk, ui).

---

## 📦 Objectif général

Créer un **gateway bancaire complet** couvrant tous les aspects de la gestion financière : ordres, relevés, rapprochements, formats, audit. Il permet :

* la gestion des ordres de paiement
* l'import/export de relevés bancaires multi-format (AFB120, SEPA, etc.)
* le rapprochement bancaire automatisé
* l'audit et la journalisation de toutes les opérations
* l'intégration d'un agent IA pour suggestions, anomalies et automatisation

---

## 📂 Module `lyxalbank`

Gestion bancaire centralisée : paiements, relevés, rapprochements, et formats internationaux. Rattaché à `company`, `partner`, `payment_mode`, etc.

---

## ✅ Fonctionnalités couvertes

* Création / validation d'ordres de paiement
* Importation de relevés bancaires
* Rapprochements manuels ou automatiques
* Export de fichiers de paiement
* Gestion des formats de fichiers bancaires par pays
* Journalisation des actions critiques (`bank_audit_log`)
* Intégration IA : rapprochement, suggestions, détection anomalies
* Authentification par Logto + RateLimit + workspace
* Validation stricte des entrées via Zod

---

## 📁 Structure du module

```
lyxalbank/
├──── gateway/
│       ├── index.ts
│       ├── routes/
│       │   ├── bank.order.ts
│       │   ├── bank.statement.ts
│       │   ├── bank.reconciliation.ts
│       │   └── bank.routes.ts
│       ├── controllers/
│       │   └── bankController.ts
│       ├── services/
│       │   └── bankService.ts
│       ├── validators/
│       │   └── bankSchemas.ts
│       ├── middlewares/
│       │   ├── requireAuth.ts
│       │   ├── rateLimit.ts
│       │   └── requireCompanyRole.ts
├──── sdk/
│      ├── backend/
│      │      └── bankClient.ts
│      ├── frontend/
│      │      └── bankClient.ts
│      └── agent/
│            └── bankAgent.ts
├──── model/
│        ├── bank_structure.surql
│        ├── bank_index.surql
│        ├── referenceBankData.surql
│        ├── bank_triggers.surql
│        └── testBankFlow.surql
└───── docs/
         └── lyxalbank.md
```

---

## 🚡 Sécurité & Conformité

* 🔐 Auth Logto obligatoire (via `requireAuth()`)
* ❌ Aucune route exposée sans protection
* 📊 Logs automatiques : création, modification, suppression (events SurrealDB)
* ⏱️ Ratelimit : 10 requêtes/min/IP
* 🌐 Filtrage par workspace : aucune fuite de données inter-tenant

---

## 🧰 Routes disponibles (`/bank`)

| Méthode | URL                        | Description                       |
| ------- | -------------------------- | --------------------------------- |
| POST    | `/order`                   | Créer un ordre de paiement        |
| GET     | `/order/:id`               | Lire un ordre bancaire            |
| PUT     | `/order/:id`               | Modifier un ordre bancaire        |
| GET     | `/statement`               | Lister les relevés bancaires      |
| POST    | `/statement/upload`        | Importer un fichier relevé        |
| GET     | `/reconciliation/:id`      | Voir un rapprochement             |
| POST    | `/reconciliation/:id/sync` | Lancer un rapprochement auto      |
| GET     | `/formats`                 | Lister formats supportés          |
| GET     | `/logs`                    | Lister les logs bancaires (admin) |

---

## ✅ Table SurrealDB à ajouter : `bank_audit_log`

```sql
DEFINE TABLE bank_audit_log SCHEMAFULL;
DEFINE FIELD event      ON bank_audit_log TYPE string;
DEFINE FIELD user       ON bank_audit_log TYPE string;
DEFINE FIELD workspace  ON bank_audit_log TYPE string;
DEFINE FIELD payload    ON bank_audit_log TYPE object;
DEFINE FIELD timestamp  ON bank_audit_log TYPE datetime;
```

---

## 💪 Statut

✅ Base technique OK (schema, index, triggers, testFlow)
✅ Préparation des routes REST en cours
✅ Audit / logs en place via events Surreal
✅ Support IA spécifique prêt à intégration

**Cible** : 🔹 Production certifiée LYXAL Cloud (multi-tenant, isolé, sécurisé)

---

*Ce module est prévu pour fonctionner dans une instance SurrealDB indépendante par workspace, avec audit et IA activables.*
