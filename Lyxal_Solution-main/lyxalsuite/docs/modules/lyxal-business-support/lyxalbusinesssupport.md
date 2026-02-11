# 📘 Documentation LYXALBUSINESSSUPPORT

Ce document décrit le module `lyxalbusinesssupport`, qui complète la gestion de projets dans l'écosystème LYXAL par l'ajout de fonctionnalités de support, d'annonces, et de modèles de tâches.

---

## 🧩 Objectif

Permettre aux workspaces de disposer d'une couche "business support" liée à :

* la publication d'annonces de projet
* l'association d'une application à une société prestataire
* la gestion de modèles de tâches

---

## 🗃️ Tables principales

### `project_announcement`

* `title`: string (obligatoire)
* `project`: record(project)
* `date`: date
* `content`: string

### `app_business_support`

* `app`: record(app) (obligatoire)
* `providerCompany`: record(company)

### `task_template`

* `internalDescription`: string

---

## 🔗 Relations

* `project_announcement.project` → `project`
* `app_business_support.app` → `app`
* `app_business_support.providerCompany` → `company`

---

## 🔐 Sécurité

* Authentification via Logto (`requireAuth`)
* Aucune route publique
* Audit sur `title`, `date`, `providerCompany`

---

## 🧪 Triggers

* `update_project_announcement_fullname`: génère automatiquement un `fullName` concaténé titre/date
* `track_provider_company_update`: trace les changements de société associée à une app

---

## 🗂️ Indexes

* `announcement_date_idx` sur `date`
* `announcement_project_idx` sur `project`
* `app_support_company_idx` sur `providerCompany`
* `task_template_idx` sur `internalDescription`

---

## 🔁 Exemples d’initialisation

```sql
CREATE project_announcement:1 SET
  title = "Kickoff Meeting",
  project = project:1,
  date = time::now(),
  content = "Réunion de lancement du projet avec tous les intervenants.";

CREATE app_business_support:1 SET
  app = app:1,
  providerCompany = company:1;

CREATE task_template:1 SET
  internalDescription = "Étude préliminaire et cadrage du besoin client.";
```

---

## 🧠 À savoir

* Le champ `assignment` dans `project_task` (défini dans `lyxalproject`) est exploité ici côté logique frontend.
* Ce module dépend de la présence des tables `project`, `app`, et `company` importées depuis d’autres modules (ex: `lyxalbase`, `lyxalproject`).

---

## ✅ Statut : Stable

Module prêt à être activé dans tout workspace disposant de `lyxalproject` et `lyxalbase`.
