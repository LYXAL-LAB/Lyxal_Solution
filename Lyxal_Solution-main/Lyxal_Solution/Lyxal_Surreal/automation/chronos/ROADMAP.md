# Feuille de route pour la migration de la logique `chronos`

**STATUT : [TERMINÉ]**

Ce document décrit les étapes planifiées pour migrer la logique métier du démon d'exécution C++ `chronos` vers un ensemble de fonctions SurrealDB. Ces fonctions serviront de briques de base pour les futurs **workers TypeScript/Node.js** qui orchestreront l'exécution des jobs.

L'approche est incrémentale, partant des actions les plus fondamentales pour remonter vers la logique d'orchestration globale.

---

### Étape 1 : Spécification du Worker et Adaptation du Schéma - [TERMINÉ]

-   **Objectif :** Définir précisément le contrat du nouveau worker, qui exécute des fonctions SurrealDB et non plus des requêtes HTTP.
-   **Actions :**
    1.  **Modifier la table `scheduler_job`** pour inclure les champs `function_name` (string) et `function_params` (object), et clarifier le rôle du champ `url`. **[FAIT]**
    2.  **Rédiger le document `WORKER_SPEC.md`** qui servira de cahier des charges pour le développement du worker TypeScript, en se basant sur la nouvelle logique. **[FAIT]**

---

### Étape 2 : Création de la Fonction de Traitement des Résultats - [TERMINÉ]

-   **Objectif :** Créer une fonction SurrealDB unique qui prend le résultat d'une **exécution de fonction** et met à jour l'état de la base de données.
-   **Action :** Créer le fichier `reprise/surreal/scheduler/chronos/process_job_result_initialise.surql` contenant la fonction `fn::scheduler::chronos::process_job_result(...)`. **[FAIT]**

---

### Étape 3 : Création des Fonctions de Gestion des Notifications - [TERMINÉ]

-   **Objectif :** Isoler la logique de création et de formatage des notifications.
-   **Actions :**
    1.  Créer une fonction `fn::scheduler::chronos::create_notification(...)` qui insère une nouvelle entrée dans la table `scheduler_notification`. **[FAIT]**
    2.  Créer une fonction utilitaire `fn::scheduler::utils::format_notification(...)` pour formater le contenu de la notification. **[FAIT]**

---

### Étape 4 : Création de la Fonction de Sélection des Tâches - [TERMINÉ]

-   **Objectif :** Reproduire le "cerveau" du planificateur, qui identifie les jobs (maintenant des fonctions) à exécuter pour une minute donnée.
-   **Action :** Créer le fichier `reprise/surreal/scheduler/chronos/get_jobs_for_minute_initialise.surql` contenant la fonction `fn::scheduler::chronos::get_jobs_for_minute()`. **[FAIT]**
