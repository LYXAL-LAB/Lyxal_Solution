# Architecture des Données du Module Scheduler

Ce document a pour objectif de schématiser la structure de la base de données pour le module `scheduler`. Il sert de référence unique pour le développement afin d'assurer la cohérence et la compréhension du modèle de données.

---

## 1. Tables Principales (Core Tables)

Ce sont les tables centrales qui définissent le fonctionnement du scheduler.

| Table | Rôle |
| :--- | :--- |
| **`scheduler_job`** | Table maîtresse contenant la configuration de chaque job (fonction à appeler, paramètres, planification, etc.). |
| **`job_run`** | *(À créer)* Table de contrôle pour le pipeline. Chaque enregistrement représente un batch d'exécution (par minute) et suit les jobs à travers les différentes étapes (sélection, exécution, notification, erreur). |
| **`scheduler_notification`** | Stocke les notifications qui doivent être envoyées suite à l'exécution d'un job (succès ou échec). Alimentée par le pipeline, traitée par le `notification.worker.ts`. |
| **`scheduler_folder`** | Permet d'organiser les jobs dans une structure de dossiers hiérarchique pour une meilleure gestion. |

---

## 2. Tables de Configuration des Jobs

Ces tables détaillent la planification et la configuration HTTP des jobs. Elles sont généralement liées à `scheduler_job`.

| Table | Rôle |
| :--- | :--- |
| **`scheduler_job_minutes`** | Définit les minutes spécifiques où un job doit s'exécuter. |
| **`scheduler_job_hours`** | Définit les heures spécifiques où un job doit s'exécuter. |
| **`scheduler_job_mdays`** | Définit les jours du mois spécifiques où un job doit s'exécuter. |
| **`scheduler_job_wdays`** | Définit les jours de la semaine spécifiques où un job doit s'exécuter. |
| **`scheduler_job_months`** | Définit les mois spécifiques où un job doit s'exécuter. |
| **`scheduler_job_header`** | Stocke les en-têtes HTTP pour les jobs de type `http`. |
| **`scheduler_job_body`** | Stocke le corps (payload) pour les jobs de type `http`. |

---

## 3. Tables de Journalisation & d'Audit (Logging & Audit)

Ces tables enregistrent l'activité du système à des fins de suivi, de débogage et de sécurité.

| Table | Rôle |
| :--- | :--- |
| **`scheduler_history`** | Journal d'audit détaillé de chaque exécution de job. Contient le statut final (succès/échec), la durée, les logs de sortie, etc. |
| **`scheduler_apilog`** | Journal de tous les appels externes effectués via les fonctions SurrealDB "publiques". Essentiel pour la sécurité et le traçage. |
| **`scheduler_nodestats`** | *(Héritage de chronos)* Stocke les statistiques de performance des workers/nœuds. Utile pour le monitoring. |
| **`system_log`** | Journal générique pour les événements de bas niveau du système (ex: initialisation d'une table). |

---

## 4. Tables de Relation

Ces tables créent des liens `MANY-TO-MANY` entre d'autres tables.

| Table | Rôle |
| :--- | :--- |
| **`scheduler_job_tag`** | Lie un `scheduler_job` à un ou plusieurs `system_tag`. C'est le mécanisme principal pour gérer le statut d'un job (ex: `pending`, `processing`, `failed`). |

---

## 5. Tables Système (externes mais utilisées)

Tables provenant d'autres modules (comme `system`) mais qui sont essentielles au fonctionnement du `scheduler`.

| Table | Rôle |
| :--- | :--- |
| **`system_tag`** | Contient les définitions des étiquettes (tags) utilisées pour la gestion de statut. C'est une table de référence. |
| **`system_environment`** | Définit les différents environnements d'exécution (ex: `production`, `development`). |

---

## 6. Schéma des Interactions (Simplifié)

- Un **`surrealworker.ts`** appelle `fn::scheduler::chronos::run_minute_tick()` chaque minute.
- Cette fonction crée un enregistrement dans **`job_run`**.
- Elle sélectionne les **`scheduler_job`** pertinents (en se basant sur leur statut dans **`scheduler_job_tag`**) et remplit le champ `job_select` du **`job_run`**.
- Le pipeline traite les jobs et met à jour leur statut via **`scheduler_job_tag`**.
- Chaque exécution est enregistrée dans **`scheduler_history`**.
- Si une notification est requise, un enregistrement est créé dans **`scheduler_notification`**.
- Le **`notification.worker.ts`** écoute les changements sur **`scheduler_notification`** pour envoyer les alertes.
- Les appels externes (ex: depuis un frontend) sont tracés dans **`scheduler_apilog`**.
