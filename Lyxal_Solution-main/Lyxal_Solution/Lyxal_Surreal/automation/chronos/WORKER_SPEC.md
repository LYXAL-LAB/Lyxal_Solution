# Spécifications du Worker TypeScript pour le Scheduler

## 1. Vue d'ensemble

Le Worker est une application TypeScript/Node.js autonome et long-running. Son rôle principal est d'exécuter des fonctions SurrealDB planifiées (jobs). Il remplace la logique du démon C++ `chronos` par une approche moderne et intégrée à l'écosystème SurrealDB.

Le Worker **n'exécute pas de requêtes HTTP lui-même**. Il agit comme un **orchestrateur d'appels de fonctions** au sein de la base de données.

## 2. Cycle de vie et Comportement Principal

1.  **Initialisation :**
    -   Au démarrage, le worker établit une connexion persistante (WebSocket) à la base de données SurrealDB.
    -   Il s'authentifie avec des identifiants de service dédiés (par exemple, un `SCOPE` utilisateur système).
    -   Il charge en mémoire sa configuration (par exemple, le nombre de jobs à exécuter en parallèle).

2.  **Boucle Principale (Scheduler Tick) :**
    -   Le worker contient une boucle principale qui s'exécute **toutes les minutes**, alignée sur le début de la minute (ex: 14:32:00, 14:33:00).
    -   À chaque "tick", le worker appelle la fonction SurrealDB `fn::scheduler::chronos::get_jobs_for_minute()` pour obtenir la liste de tous les jobs planifiés pour cette minute exacte.

3.  **File d'Attente et Exécution :**
    -   Les jobs récupérés sont placés dans une file d'attente interne.
    -   Le worker traite cette file d'attente en respectant une limite d'exécutions parallèles (configurable).
    -   Pour chaque job, le worker exécute la logique décrite dans la section "Traitement d'un Job".

## 3. Traitement d'un Job

Pour chaque enregistrement de job reçu de `get_jobs_for_minute`, le worker effectue les étapes suivantes :

1.  **Démarrage :**
    -   Enregistre le timestamp de début d'exécution.

2.  **Exécution de la Fonction :**
    -   Lit les champs `function_name` et `function_params` du job.
    -   Exécute la fonction dans SurrealDB via une requête `PERFORM`, en passant les paramètres.
    -   **Exemple :** `PERFORM fn::user::send_daily_report WITH { user_id: 'user:123', level: 'summary' };`
    -   Encadre l'appel dans un `try...catch` pour capturer à la fois les succès et les échecs.

3.  **Capture du Résultat :**
    -   Crée un objet `JobResult` qui contient :
        -   `job_id` : L'ID du job exécuté.
        -   `execution_status` : 'success' ou 'failure'.
        -   `return_value` : La valeur retournée par la fonction en cas de succès, ou l'erreur `THROW` en cas d'échec.
        -   `start_time` : Timestamp du début.
        -   `end_time` : Timestamp de la fin.
        -   `duration_ms` : Durée totale de l'exécution en millisecondes.

4.  **Traitement Post-Exécution :**
    -   Passe l'objet `JobResult` à la fonction SurrealDB `fn::scheduler::chronos::process_job_result(...)`. Cette fonction est responsable de mettre à jour la base de données (historique, statistiques, etc.) et de gérer la notification de désactivation (`onDisable`).
    -   Récupère les informations du job pour vérifier si une notification est requise (`notification_on_success`, `notification_on_failure`).
    -   Si le job a réussi et `notification_on_success` est vrai, le worker appelle `fn::scheduler::chronos::create_notification(job_id, history_id, 'onSuccess')`.
    -   Si le job a échoué et `notification_on_failure` est vrai, le worker appelle `fn::scheduler::chronos::create_notification(job_id, history_id, 'onFailure')`.
    -   **Note :** Pour obtenir le `history_id`, la fonction `process_job_result` devra être modifiée pour le retourner.

## 4. Gestion des Erreurs et Robustesse

-   Le worker doit être capable de gérer les déconnexions de SurrealDB et tenter de se reconnecter automatiquement.
-   Toutes les opérations (sélection, exécution, traitement) doivent être journalisées (logs) de manière claire pour faciliter le débogage.
-   Si le worker est arrêté, il doit tenter de terminer proprement les jobs en cours d'exécution.

## 5. Communication avec la Base de Données

-   L'interaction principale se fait via des appels de fonctions (`PERFORM` ou `SELECT VALUE fn::...`).
-   Le worker doit utiliser des transactions lorsque cela est pertinent (même si la plupart de la logique transactionnelle sera dans les fonctions SurrealDB elles-mêmes).
