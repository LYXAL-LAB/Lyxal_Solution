# ✅ Feuille de route LYXALPRODUCTION – Gateway Production

Cette feuille de route définit l'intégralité du travail à faire pour le module **Production** (`lyxalproduction`) dans la **Gateway LYXAL**, en version **production-ready**. Elle suit la structure officielle validée de LYXAL (gateway, sdk, model, docs).

---

## 📦 Objectif général

Créer un **module de gestion de la production interconnectée**, conçu pour les entreprises industrielles, techniques ou projetées (ex: bâtiment, mobilier, services complexes). Il couvre :

* la gestion des ordres de production
* les opérations de production planifiées
* l’imputation des temps employés
* les rapprochements avec la vente ou la facturation
* le suivi de projet lié à la fabrication

---

## 📂 Module `lyxalproduction`

Regroupe toutes les entités de suivi de fabrication, opérations, RH terrain, commandes clients, tâches projet et ordres de fabrication (OF).

---

## ✅ Fonctionnalités couvertes

* Création, modification, suppression d'ordres de production (`ProductionOrder`)
* Génération automatique des opérations (`OperationOrder`)
* Imputation automatique des temps (`TimesheetLine`)
* Suivi multi-projet (`ProjectTask`, `InvoicingProject`)
* Lien vente/fabrication (`SaleOrderLineDetails`)
* Génération et planification des ordres de fabrication (`ManufOrder`)
* Rattachement ressources et employés (`WorkCenter`, `Employee`)
* Triggers dynamiques : clôture auto, calcul statuts, validation
* Journaux d’audit `production_audit_log`
* Protection par Logto + validation stricte Zod + workspace isolation

---

## 📁 Structure du module

```
lyxalproduction/
├── gateway/
│   ├── routes/
│   │   ├── production.order.ts
│   │   ├── operation.order.ts
│   │   ├── manuf.order.ts
│   │   ├── invoicing.project.ts
│   │   └── production.routes.ts
│   ├── controllers/
│   │   └── productionController.ts
│   ├── services/
│   │   └── productionService.ts
│   ├── validators/
│   │   └── productionSchemas.ts
│   ├── middlewares/
│   │   ├── requireAuth.ts
│   │   ├── rateLimit.ts
│   │   └── requireRole.ts
├── sdk/
│   ├── backend/
│   │   └── productionClient.ts
│   ├── frontend/
│   │   └── productionClient.ts
│   └── agent/
│       └── productionAgent.ts
├── model/
│   ├── production_structure.surql
│   ├── production_index.surql
│   ├── production_triggers.surql
│   ├── referenceProductionData.surql
│   └── testProductionFlow.surql
└── docs/
    └── lyxalproduction.md
```

---

## 🛡️ Sécurité

* 🔐 Auth Logto (token + session)
* ❌ Aucune route ouverte sans middleware
* 📊 Audit auto via `production_audit_log`
* 💾 Workspace isolation complète (données séparées)
* 📉 RateLimit configurable (ex: 10 req/min/IP)

---

## 🧪 Routes REST disponibles (`/production`)

| Méthode | URL                          | Description                             |
| ------- | ---------------------------- | --------------------------------------- |
| POST    | `/order`                     | Créer un ordre de production            |
| GET     | `/order/:id`                 | Lire un ordre                           |
| PUT     | `/order/:id`                 | Modifier un ordre                       |
| POST    | `/operation/:orderId`        | Ajouter une opération                   |
| POST    | `/timesheet/:employeeId`     | Enregistrer un temps passé              |
| GET     | `/project/:projectId/orders` | Voir les ordres liés à un projet        |
| POST    | `/manuf/:orderId`            | Générer un OF                           |
| GET     | `/invoicing/:projectId`      | Voir les éléments facturables           |
| GET     | `/logs`                      | Voir l’historique des actions critiques |

---

## ✅ Table SurrealDB : `production_audit_log`

```sql
DEFINE TABLE production_audit_log SCHEMAFULL;
DEFINE FIELD event      ON production_audit_log TYPE string;
DEFINE FIELD user       ON production_audit_log TYPE string;
DEFINE FIELD workspace  ON production_audit_log TYPE string;
DEFINE FIELD payload    ON production_audit_log TYPE object;
DEFINE FIELD timestamp  ON production_audit_log TYPE datetime;
```

---

## ✅ Statut

✅ Fichiers XML convertis → entités validées
✅ Analyse fonctionnelle complète terminée
✅ Routes à implémenter selon schéma ci-dessus
✅ Compatible IA et Surreal Events

🎯 Objectif : **Production-ready en multi-tenant cloud, avec IA activable sur déclenchement opérationnel.**

---

*Ce module pourra être enrichi par des extensions RH, planning, logistique ou mobile selon les besoins secteur (ex: BTP, industriel, service).*
