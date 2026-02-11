# Pistes techniques à reprendre

Ce document liste les points techniques identifiés lors de la migration de la logique de `cron-job.org` qui ont été mis en attente car ils dépendent d'implémentations futures (notamment les workers TypeScript) ou de services externes.

---

### 1. Récupération des données de séries temporelles (`getTimeSeriesData`)

-   **Contexte :** La fonction qui affiche les pages de statut publiques (`PublicStatusPage`) doit afficher des graphiques basés sur l'historique des exécutions (latence, uptime, etc.). L'implémentation originale récupérait ces données via un appel RPC `getTimeSeriesData` à chaque nœud d'exécution.
-   **État actuel :** La fonction SurrealDB retourne actuellement des tableaux vides pour ces données.
-   **Action requise :** Lorsque les workers (schedulers TypeScript) seront développés, ils devront stocker les résultats de chaque exécution dans une ou plusieurs tables (par exemple, `scheduler_job_history`). La fonction SurrealDB devra alors être mise à jour pour lire ces tables et agréger les données afin de construire les séries temporelles.
-   **Fichier concerné :** `reprise/surreal/scheduler/resources/PublicStatusPage/public_status_page_get_status_page_initialise.surql`

---

### 2. Exécution réelle des tests de jobs

-   **Contexte :** Le système permet de lancer un test d'exécution immédiat pour un job. L'implémentation originale utilisait Redis et un appel RPC pour demander à un nœud d'exécuter la tâche sur-le-champ.
-   **État actuel :** La fonction SurrealDB `fn::scheduler::resources::job::submit_test_run` crée correctement un enregistrement de "test en attente" dans la table `scheduler_job_test_run`, mais ne déclenche pas l'exécution.
-   **Action requise :** Il faudra mettre en place un mécanisme de communication entre la base de données et les workers. Une approche possible serait que les workers écoutent les créations dans la table `scheduler_job_test_run` via une `LIVE QUERY` SurrealDB. Lorsqu'un nouveau test est créé, le worker concerné exécute la tâche, puis met à jour l'enregistrement de test avec le résultat.
-   **Fichier concerné :** `reprise/surreal/scheduler/resources/Job/job_submit_test_run_initialise.surql`

---

### 3. Connexion au service WAF (Web Application Firewall)

-   **Contexte :** Une fonction de sécurité (`validateAgainstWAF`) est appelée avant de créer ou de mettre à jour un job pour le valider auprès d'un service externe.
-   **État actuel :** La fonction `fn::scheduler::utils::validate_against_waf` a été créée mais elle est un "placeholder" : elle ne fait rien et retourne toujours `true`.
-   **Action requise :** Lorsque l'endpoint du service WAF sera disponible, il faudra modifier cette fonction pour qu'elle utilise la commande `FETCH` de SurrealDB afin d'appeler ce service externe. En fonction de la réponse, elle devra soit retourner `true`, soit lancer une erreur (`THROW`) pour bloquer l'opération.
-   **Fichier concerné :** `reprise/surreal/scheduler/utils/utils_validate_against_waf_initialise.surql`

---

### 4. Prédiction des exécutions de jobs (`ExecutionPredictor`)

-   **Contexte :** La page d'historique d'un job affiche les prochaines exécutions planifiées. L'implémentation originale utilisait une librairie complexe (`ExecutionPredictor`) pour calculer ces dates à partir du schedule (cron-like).
-   **État actuel :** **[MISE À JOUR]** Une première version de la logique a été portée dans la fonction `fn::scheduler::utils::predict_next_executions`. Cette fonction est maintenant appelée par `fn::scheduler::resources::history::get_job_history`.
-   **Point en suspens :** La version actuelle a été implémentée en utilisant des dates UTC pour simplifier la logique. Le script PHP original gérait des timezones spécifiques. Une future amélioration consistera à porter fidèlement la logique de gestion des timezones en JavaScript, ce qui est non-trivial.
-   **Fichier concerné :** `reprise/surreal/scheduler/utils/utils_predict_next_executions_initialise.surql`

---

### 5. Propagation des changements de groupe utilisateur (`updateUserGroupId`)

-   **Contexte :** Une tâche de fond (`ProcessUserGroupChanges`) est chargée de propager les changements de groupe d'utilisateurs aux nœuds d'exécution. Chaque nœud doit être notifié pour appliquer les nouvelles permissions et quotas.
-   **État actuel :** La fonction SurrealDB `fn::scheduler::tasks::process_user_group_changes` implémente la logique de file d'attente mais simule la partie communication avec les nœuds. Elle suppose que la propagation réussit toujours.
-   **Action requise :** Lorsque les workers TypeScript seront développés, il faudra définir un mécanisme par lequel la base de données peut leur signaler ce changement. Plutôt qu'un appel RPC sortant depuis SurrealDB (ce qui est complexe), les workers pourraient écouter les changements sur la table `scheduler_user`. Quand le `usergroupid` d'un utilisateur est modifié, le worker mettrait à jour sa configuration interne pour les jobs de cet utilisateur. La tâche de fond actuelle deviendrait alors simplement `UPDATE user SET usergroupid = ...` et la table `scheduler_usergroupchange` pourrait être supprimée au profit d'une action directe.
-   **Fichier concerné :** `reprise/surreal/scheduler/tasks/process_user_group_changes_initialise.surql`