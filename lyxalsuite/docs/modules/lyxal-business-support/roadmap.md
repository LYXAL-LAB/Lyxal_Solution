# ✅ Feuille de route LYXALBUSINESSSUPPORT – Gateway Production

Cette feuille de route définit l'intégralité du travail à faire pour le module **Business Support** dans la **Gateway LYXAL**, version **production-ready**. Elle respecte l'architecture officielle LYXAL (gateway, sdk, ui).

---

## 📦 Objectif général

Créer un **backend modulaire d’assistance projet**, compatible multi-workspace, sécurisé et intégrable au module `lyxalproject`. Il exposera des routes REST pour :

* la gestion des annonces liées aux projets (`ProjectAnnouncement`)
* l’association des applications à leur société prestataire (`AppBusinessSupport`)
* le support des logiques d’affectation client/fournisseur sur les tâches (`assignment`)
* la duplication de tâches via modèles (`TaskTemplate`)

---

# 📦 Module `lyxalbusinesssupport`

Ce module complète la gestion de projet avec des **fonctionnalités de support, communication et structuration métier**, destinées à des environnements prestataires (B2B).

---

## ✅ Fonctionnalités couvertes

* CRUD complet pour :

  * `ProjectAnnouncement`
  * `AppBusinessSupport`
  * `TaskTemplate`
* Gestion du champ `assignment` sur les tâches (`customer` / `provider`)
* Support des annonces publiques ou privées par projet
* Lien direct entre une app métier (`App`) et sa société prestataire (`Company`)
* Modèles de tâche réutilisables dans les projets
* Sécurité par token (Logto)
* Audit automatique sur champs critiques

---

## 📂 Structure du module

```
lyxalbusinesssupport/
├── gateway/
│   ├── routes/
│   │   ├── announcement.routes.ts
│   │   ├── appSupport.routes.ts
│   │   └── taskTemplate.routes.ts
│   ├── controllers/
│   │   └── announcementController.ts
│   ├── services/
│   │   └── announcementService.ts
│   ├── validators/
│   │   └── announcementSchemas.ts
│   └── middlewares/
│       └── requireAuth.ts
├── sdk/
│   ├── backend/
│   │   └── announcementClient.ts
│   ├── frontend/
│   │   └── announcementClient.ts
│   └── types/
│       └── businessSupport.types.ts
├── model/
│   ├── business_support_structure.surql
│   ├── business_support_reference.surql
│   ├── business_support_triggers.surql
│   └── business_support_indexes.surql
└── docs/
    └── lyxalbusinesssupport.md
```

---

## 🛡️ Sécurité

* 🔐 Authentification obligatoire via `requireAuth()` (Logto)
* 📊 Audit activé sur :

  * `ProjectAnnouncement.title`
  * `ProjectAnnouncement.date`
  * `AppBusinessSupport.providerCompany`
* ❌ Aucun accès non-authentifié

---

## 🔀 Relations prises en charge

* `App ➔ AppBusinessSupport ➔ Company`
* `Project ➔ ProjectAnnouncement`
* `ProjectTask.assignment` avec sélection `customer` / `provider`

---

## ✅ Tables SurrealDB à créer

```sql
DEFINE TABLE project_announcement SCHEMAFULL;
DEFINE TABLE app_business_support SCHEMAFULL;
DEFINE TABLE task_template SCHEMAFULL;
```

---

## 🧰 Routes disponibles (`/business-support`)

| Méthode | URL                  | Description                          |
| ------- | -------------------- | ------------------------------------ |
| GET     | `/announcement`      | Lister les annonces                  |
| POST    | `/announcement`      | Créer une annonce                    |
| GET     | `/announcement/:id`  | Lire une annonce                     |
| PUT     | `/announcement/:id`  | Modifier une annonce                 |
| DELETE  | `/announcement/:id`  | Supprimer une annonce                |
| GET     | `/app-support`       | Lire l'association App/Company       |
| POST    | `/app-support`       | Créer ou mettre à jour l’association |
| GET     | `/task-template`     | Lister les templates de tâche        |
| POST    | `/task-template`     | Créer un template                    |
| GET     | `/task-template/:id` | Lire un template                     |
| PUT     | `/task-template/:id` | Modifier un template                 |
| DELETE  | `/task-template/:id` | Supprimer un template                |

---

## 🧠 Triggers à prévoir

* `project_announcement_fullname` : concaténation titre + date
* `track_provider_company` : log modification `providerCompany`
* Optionnel : validation assignment dans `project_task`

---

## 🛠️ Index à créer

```sql
DEFINE INDEX announcement_date_idx ON project_announcement FIELDS date;
DEFINE INDEX announcement_project_idx ON project_announcement FIELDS project;
DEFINE INDEX app_support_company_idx ON app_business_support FIELDS providerCompany;
DEFINE INDEX task_template_idx ON task_template FIELDS internalDescription;
```

---

## 🏁 Statut

🟢 **Prêt à implémenter** dans la Gateway.

Tu peux maintenant :

* Générer les `.surql`
* Déployer les routes REST
* Intégrer les appels dans le `sdk/`
