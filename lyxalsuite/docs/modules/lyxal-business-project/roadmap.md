# ✅ Feuille de route LYXALPROJECT – Gateway Production

Cette feuille de route définit l'intégralité du travail à faire pour le module **Project** (anciennement `business-project`) dans la **Gateway LYXAL**, version **production-ready**. Elle respecte l'architecture officielle LYXAL (gateway, sdk, ui).

---

## 📦 Objectif général

Créer un **backend projet modulaire**, compatible multi-workspace, sécurisé et conforme aux règles LYXAL. Il exposera des routes REST pour :

* la gestion des projets et tâches
* le suivi budgétaire, invoicing et achats
* l’intégration complète avec les ventes, achats, dépenses
* les rapports analytiques et logiques de marge
* la configuration par société

---

# 📦 Module `lyxalproject`

Module de gestion de projets incluant tâches, contrats, facturation, temps, achats, ventes, dépenses, suivi analytique et rentabilité.

---

## ✅ Fonctionnalités couvertes

* CRUD complet pour projets, tâches, dossiers, retenues, manuels
* Intégration directe avec :

  * commandes de vente et d’achat
  * lignes de facture, dépenses, feuilles de temps
  * contrats clients/fournisseurs
* Calculs de marges (estimée, réelle, prévisionnelle, landing)
* Gestion des templates de tâche et modèles de projet
* Support des retenues de garantie (`ProjectHoldBack`)
* Invoicing automatique ou partiel avec `InvoicingProject`
* Suivi analytique (temps, dépenses, achats) par projet
* Groupement multi-fichiers de données : contrats, dossiers, templates
* Configuration multi-société (`BusinessProjectConfig`)
* Protection via `Logto` (auth/session)
* Sécurité et audit intégrés

---

## 📂 Structure du module

```
lyxalproject/
├── gateway/
│   ├── index.ts
│   ├── routes/
│   │   ├── project.routes.ts
│   │   ├── task.routes.ts
│   │   ├── folder.routes.ts
│   │   ├── holdback.routes.ts
│   │   ├── invoicing.routes.ts
│   │   ├── manual.routes.ts
│   ├── controllers/
│   │   └── projectController.ts
│   ├── services/
│   │   └── projectService.ts
│   ├── validators/
│   │   └── projectSchemas.ts
│   ├── utils/
│   │   └── projectUtils.ts
│   └── middlewares/
│       ├── requireAuth.ts
│       ├── errorHandler.ts
│       └── rateLimit.ts
├── sdk/
│   ├── backend/
│   │   └── projectClient.ts
│   ├── frontend/
│   │   └── projectClient.ts
│   └── types/
│       └── types.ts
├── model/
│   ├── project_structure.surql
│   ├── referenceProjectData.surql
│   ├── project_triggers.surql
│   └── project_indexes.surql
└── docs/
    └── lyxalproject.md
```

---

## 🛡️ Sécurité

* 🔐 Auth obligatoire via `requireAuth()` de LyxalAuth
* 📉 Ratelimit (5 req/min/IP)
* 📟 Audit : événements critiques loggués automatiquement
* ❌ Aucun accès public sans middleware sécurisé

---

## 🔀 Relations prises en charge

* `Project ➔ Task`, `InvoiceLine`, `PurchaseOrderLine`, `SaleOrderLine`
* `Project ➔ ProjectHoldBack`, `ManualElement`, `Contract`
* `Task ➔ SaleOrderLine`, `PurchaseOrderLine`, `InvoiceLine`
* `Task ➔ Contract`, `Product`
* `Project ➔ Folder`, `Customer`, `Currency`, `PriceList`
* `InvoicingProject ➔ All entities (Time, Expenses, Sales, Purchases)`

---

## ✅ Tables SurrealDB à créer

```sql
DEFINE TABLE project SCHEMAFULL;
DEFINE TABLE project_task SCHEMAFULL;
DEFINE TABLE project_folder SCHEMAFULL;
DEFINE TABLE project_holdback SCHEMAFULL;
DEFINE TABLE project_holdback_line SCHEMAFULL;
DEFINE TABLE manual_element SCHEMAFULL;
DEFINE TABLE invoicing_project SCHEMAFULL;
DEFINE TABLE business_project_config SCHEMAFULL;
```

---

## 🧪 Routes disponibles (`/project`)

| Méthode | URL                      | Description                          |
| ------- | ------------------------ | ------------------------------------ |
| GET     | `/project`               | Lister tous les projets              |
| POST    | `/project`               | Créer un nouveau projet              |
| GET     | `/project/:id`           | Lire les détails d’un projet         |
| PUT     | `/project/:id`           | Mettre à jour un projet              |
| DELETE  | `/project/:id`           | Supprimer un projet                  |
| GET     | `/project/:id/tasks`     | Récupérer les tâches d’un projet     |
| POST    | `/task`                  | Créer une tâche                      |
| PUT     | `/task/:id`              | Mettre à jour une tâche              |
| GET     | `/invoicing-project/:id` | Lire un projet de facturation        |
| POST    | `/invoicing-project`     | Générer un invoicing (multi-entités) |
| GET     | `/holdback/:id`          | Lire une retenue de garantie         |
| POST    | `/holdback`              | Créer une retenue                    |
| GET     | `/manual/:id`            | Lire un élément manuel               |
| POST    | `/manual`                | Créer une ligne manuelle             |

---

## 📊 Champs calculés et triggers

* `DEFINE EVENT` sur :

  * progression (`% progress`, `% consumption`, `remaining`)
  * `invoicingMargin`, `realCosts`, `soldTime`, `turnover`, etc.
  * fullName/completions (nom projet + code)
  * post-création d’un `holdback` ou `manualElement`

---

## 🛠️ Index à prévoir

* `project.name`, `project.code`, `project.customer`
* `task.status`, `task.customerReferral`, `task.saleOrderLine`
* `invoicing_project.statusSelect`, `project_task.project`

---

## 🏁 Statut

🟢 **Prêt à implémenter** en Gateway LYXAL.

Tu peux maintenant lancer :

* Génération des `.surql`
* Mise en place du backend (`gateway/`)
* Intégration des appels dans le `sdk/`
