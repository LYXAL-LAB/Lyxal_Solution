# Documentation du Module Projet – Lyxal Gateway

## Introduction

Le module **Projet** de Lyxal Gateway (`lyxalproject`) permet de gérer l’ensemble du cycle de vie d’un projet métier. Il s’appuie sur les modèles d’Axelor BusinessProject enrichis, convertis pour SurrealDB, et adaptés à l’écosystème LYXAL.

Il convient aux sociétés de service, chantiers, ingénierie, agences et toute organisation pilotée par des projets, avec une logique compatible IA et multi-workspaces.

---

## Fonctionnalités principales

* Création et structuration de projets (client, société, contrat, dates, marges)
* Gestion des tâches avec progression, durée, produit associé
* Saisie d’éléments manuels (revenu/dépense) pour ajuster marge réelle
* Intégration native avec la vente, l’achat, la facturation et les contrats
* Gestion de la facturation globale (`invoicing_project`)
* Retenues de garantie (`project_holdback`)
* Suivi des documents, annonces, modèles de tâche
* Configuration métier personnalisée par société (`business_project_config`)

---

## Architecture du module

Le module `lyxalproject` est intégré nativement dans l’architecture modulaire LYXAL :

* **Gateway** : routes REST sécurisées (auth, ratelimit, audit)
* **SDK Backend / Frontend** : accès typé aux projets, tâches, lignes, marges
* **SurrealDB** : tables `project`, `task`, `manual_element`, `holdback`, avec triggers auto
* **UI Kit** : composants `ProjectBoard`, `ProjectDetails`, `MarginWidget`, etc.
* **Agents IA** : déclenchement de création, mise à jour, facturation automatisée

---

## Exemple d’utilisation (Backend)

```ts
import { ProjectClient } from 'lyxalproject/sdk/backend';

const project = await ProjectClient.createProject({
  name: 'Nouveau projet',
  customer: 'partner:1',
  company: 'company:1',
  startDate: '2025-06-01',
});
```

---

## Exemple d’utilisation (Frontend React)

```tsx
import { useCreateProject } from 'lyxalproject/sdk/frontend/hooks';

function CreateProjectButton() {
  const { createProject } = useCreateProject();
  return <button onClick={() => createProject({ name: 'Projet React' })}>Créer</button>;
}
```

---

## Exemple d’intégration Agent IA

```ts
import { createProjectAgent } from 'lyxalproject/sdk/agent';

const agent = createProjectAgent('https://api.monapp.com');

await agent.createProject({
  name: 'Projet IA',
  client: 'partner:23'
});
```

---

## Modèles SurrealDB

* `project` : entité centrale
* `project_task` : gestion des tâches et progression
* `manual_element` : revenu/dépense manuel
* `project_holdback` & `project_holdback_line` : retenues de garantie
* `invoicing_project` : préfacturation globale
* `project_folder` : structure documentaire
* `project_announcement` : communication interne liée au projet
* `task_template` : tâches réutilisables
* `business_project_config` : logique par société

---

## Sécurité

* 🔐 Auth via Logto (token/session)
* 📜 Audit sur actions critiques : création, modification, facturation
* 🚦 Ratelimit 5 requêtes/min par IP
* 🔀 Données totalement isolées par `workspace`

---

## Bonnes pratiques

* Toujours rattacher un projet à un client et une société
* Utiliser les tâches pour calculer le progrès du projet
* Alimenter manuellement les revenus non facturés avec `manual_element`
* Centraliser toute logique via `projectService` (backend)
* Automatiser les marges avec `DEFINE EVENT`

---

## Migration et déploiement

```bash
surreal import --conn wss://your.surreal.endpoint --user root --pass pass lyxalproject/model/project_structure.surql
```

---

## Références

* [Documentation SurrealDB](https://surrealdb.com/docs)
* [Documentation Logto](https://docs.logto.io)
* [LYXAL GitHub](https://github.com/lyxal-dev)

---

**Module 100% cloud, IA-ready, conçu pour la rentabilité et la performance projet.**
