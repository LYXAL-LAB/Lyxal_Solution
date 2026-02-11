# Plan d'Action pour l'Architecture du Pipeline de Traitement

Ce document décrit l'architecture d'un pipeline de traitement des jobs, entièrement géré au sein de SurrealDB.

Le principe est de piloter le flux via une table de contrôle `job_run`. Un enregistrement unique est créé dans cette table pour chaque "batch" de minute. Cet enregistrement contient des champs qui agissent comme des files d'attente pour les différentes étapes du traitement (`job_select`, `job_execute`, `job_notification`, `job_error`), offrant un contrôle total et une grande observabilité.

---

### Étape 0 : Déclenchement (Externe)

-   **Action :** Le `surrealworker.ts` appelle une fonction maîtresse une fois par minute.
-   **Où :** `surrealworker.ts` -> `fn::scheduler::chronos::run_minute_tick`

---

### Étape 1 : Initialisation du Pipeline

-   **Action :** 
    1.  Créer un nouvel enregistrement unique dans la table `job_run` pour le batch en cours.
    2.  Identifier les jobs éligibles et stocker leurs IDs dans le champ `job_select`.
    3.  Initialiser les champs de métriques sur l'enregistrement `job_run` (ex: `total_jobs`, `start_time`, `success_count = 0`, `failure_count = 0`).
-   **Où :** Dans la fonction `fn::scheduler::chronos::run_minute_tick`.

---

### Étape 2 : Traitement du Pipeline

-   **Action :** Une fonction de traitement en boucle va opérer sur l'enregistrement `job_run` :
    1.  Prendre un job depuis la file `job_select`.
    2.  Le verrouiller et l'exécuter.
    3.  Mettre à jour les métriques : incrémenter `success_count` ou `failure_count` et ajouter la durée d'exécution à un tableau `execution_durations`.
    4.  En fonction du résultat, déplacer l'ID du job de `job_select` vers la file appropriée : `job_notification` ou `job_error`, ou simplement le retirer si le traitement est terminé.
-   **Où :** Logique principale dans `fn::scheduler::chronos::run_minute_tick` ou des sous-fonctions.

---

### Étape 3 : Traitement des Files Secondaires

-   **Rôle :** Des workers ou fonctions dédiés surveillent les files de l'enregistrement `job_run`.
-   **Action :**
    -   Le `notification.worker.ts` traite les jobs listés dans `job_notification`.
    -   Une fonction d'administration permet de retraiter les jobs listés dans `job_error`.

---

### Étape 4 : Clôture du Pipeline

-   **Action :** Une fois toutes les files de l'enregistrement `job_run` vides :
    1.  Calculer les métriques finales (durée totale, temps min/max/avg à partir de `execution_durations`).
    2.  Marquer l'enregistrement `job_run` comme `completed`.
-   **Où :** Logique de nettoyage à la fin de `fn::scheduler::chronos::run_minute_tick` ou via une tâche séparée.
