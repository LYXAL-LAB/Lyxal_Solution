# Documentation du Composant `system_schedule`

## 1. Objectif Général

Le composant `system_schedule` du module `system` a pour but de gérer l'exécution de tâches planifiées (cron jobs). Il s'appuie sur le service externe [cron-job.org](https://cron-job.org/) pour le déclenchement à heure fixe, mais toute la logique de gestion, de sécurité et de cycle de vie est entièrement contrôlée en interne par SurrealDB.

Ce composant est conçu pour un environnement **entièrement automatisé**. Les tâches sont créées, activées, désactivées et supprimées en cascade en fonction du cycle de vie des "environnements" auxquels elles sont rattachées.

---

## 2. Architecture & Concepts Clés

### 2.1. La Hiérarchie via `system_environment`

Le concept central n'est pas la tâche elle-même, mais l'**environnement** auquel elle appartient. Les tâches planifiées sont toujours des ressources enfants d'un environnement défini dans le composant `system_environment`.

- Chaque environnement (`instance`, `namespace`, ou `database`) possède un et un seul **dossier de planification**.
- La création de ce dossier est **automatisée** et liée à la création de l'environnement.
- C'est le **statut de l'environnement** qui détermine si les tâches qu'il contient peuvent s'exécuter.

### 2.2. Le Dossier (`system_schedule_folder`)

- **Rôle :** C'est le conteneur logique qui regroupe toutes les tâches d'un environnement. Il sert de point d'entrée pour les actions de masse (activer/désactiver tous les jobs).
- **Lien :** Un dossier est lié à un environnement par un lien 1-1.
- **Cycle de vie :** Un dossier est créé automatiquement avec son environnement et est supprimé lorsque son environnement est supprimé (via `fn::system_environment_delete_cascade`).

### 2.3. Le Job (`system_schedule`)

- **Rôle :** C'est l'enregistrement local qui représente une tâche distante sur cron-job.org. Il contient l'ID du job distant (`job_id`) et des métadonnées comme son titre.
- **Lien Immuable :** Un job est **obligatoirement et immuablement lié à un dossier** dès sa création. Il ne peut pas exister sans dossier et ne peut pas être déplacé.

### 2.4. Le Cycle de Vie Automatisé par Événements (`DEFINE EVENT`)

C'est le cœur de l'automatisation. Le module n'agit pas directement sur les jobs, mais réagit aux changements de statut de leurs environnements parents.

- **`WHEN` un environnement passe à `active` :** Un événement (`event_environment_activated`) se déclenche et appelle `fn::system_schedule_folder_enable_jobs`. Toutes les tâches du dossier associé sont activées via l'API de cron-job.org.
- **`WHEN` un environnement passe à `suspended` ou `inactive` :** Un événement (`event_environment_deactivated`) se déclenche et appelle `fn::system_schedule_folder_disable_jobs`. Toutes les tâches sont désactivées.

### 2.5. La Synchronisation

- **Objectif :** Maintenir la cohérence entre les jobs définis sur cron-job.org et les enregistrements locaux dans SurrealDB.
- **Fonction clé :** `fn::system_schedule_sync_all_cronjoborg()`.
- **Logique :**
  - **Jobs supprimés sur cron-job.org :** Sont automatiquement supprimés de la base locale.
  - **Jobs modifiés sur cron-job.org :** Leur statut (`enabled`) et titre sont mis à jour localement.
  - **Jobs inconnus sur cron-job.org :** Sont ignorés (car un job doit être créé via le système pour être valide) et un avertissement est loggué.

---

## 3. Workflow d'Utilisation (pour un développeur ou une IA)

Toute interaction avec ce composant doit se faire via les fonctions d'orchestration de haut niveau.

- **Pour créer une tâche :**
  - Utiliser `fn::system_schedule_create_job(...)`.
  - Le paramètre `$folder_id` est **obligatoire**.

- **Pour suspendre/réactiver toutes les tâches d'un Namespace :**
  - Utiliser `fn::system_environment_set_status_cascade($namespace_id, 'suspended' | 'active')`.
  - La fonction mettra à jour le statut du namespace ET de toutes ses databases enfants. Les événements se chargeront d'activer/désactiver les jobs correspondants.

- **Pour supprimer un Namespace et toutes ses tâches :**
  - Utiliser `fn::system_environment_delete_cascade($namespace_id)`.
  - Cette fonction supprimera en cascade les environnements enfants, les dossiers, et appellera l'API pour supprimer chaque job distant avant de nettoyer la base locale.

- **Pour consulter les tâches :**
  - `fn::system_schedule_folder_list($environment_id)`: Liste le dossier de cet environnement.
  - `fn::system_schedule_folder_list_recursive($environment_id)`: Liste les dossiers de l'environnement ET de tous ses descendants.
  - `fn::system_schedule_folder_get_jobs($folder_id)`: Liste toutes les tâches d'un dossier spécifique.

---

## 4. Déploiement

L'intégralité du composant, y compris ses tables, fonctions et événements, est initialisée en exécutant la fonction principale de déploiement : `fn::system_schedule_deploy()`.
Le script de déploiement est conçu pour être **idempotent** et peut être ré-exécuté sans risque.
