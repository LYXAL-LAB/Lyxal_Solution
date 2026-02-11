# Analyse du Fichier `SyncService.php` de Nextcloud

Ce document décompose le contenu de la classe `SyncService.php`. Il s'agit d'un service de haut niveau chargé d'orchestrer la synchronisation des calendriers fédérés (partages provenant d'autres instances Nextcloud).

---

## 1. Rôle et Responsabilités

La classe `SyncService` est le **moteur de la synchronisation fédérée**. Sa responsabilité est de maintenir à jour la copie locale d'un calendrier qui a été partagé depuis un autre serveur Nextcloud.

Elle implémente la logique client du protocole `sync-collection` de WebDAV. Elle est conçue pour être appelée périodiquement par une tâche de fond pour chaque calendrier fédéré.

---

## 2. Logique Principale

La logique est entièrement contenue dans la méthode `syncRemoteCalendar`.

- **`syncRemoteCalendar(...)`**:
  - **Rôle**: Exécuter un cycle complet de synchronisation pour un calendrier fédéré.
  - **Paramètres**: Prend en entrée toutes les informations nécessaires : l'URL du calendrier distant, les identifiants, le "secret partagé" pour l'authentification, le dernier `syncToken` connu, et l'entité du calendrier local.
  - **Étapes d'exécution**:
    1.  **Requête de rapport de synchronisation**: Appelle une méthode héritée (`requestSyncReport`) qui envoie une requête `REPORT` de type `sync-collection` au serveur distant. Cette requête demande la liste de toutes les ressources (événements) qui ont changé depuis le dernier `syncToken`.
    2.  **Gestion des erreurs d'authentification**: Si la requête échoue avec un statut "Non autorisé" (401), cela signifie que le partage a été révoqué sur le serveur distant. Le service supprime alors la copie locale du calendrier fédéré.
    3.  **Traitement de la réponse**: La réponse du serveur distant est une liste de ressources (fichiers `.ics`) et de leur statut (modifié ou supprimé).
        -   **Pour les ressources modifiées (statut 200)**:
            a.  Le service télécharge le contenu de l'événement (`.ics`) depuis le serveur distant.
            b.  Il vérifie si l'événement existe déjà localement.
            c.  Il appelle `backend->createCalendarObject(...)` ou `backend->updateCalendarObject(...)` pour créer ou mettre à jour la copie locale. Ces opérations sont encapsulées dans une **transaction atomique** (`$this->atomic(...)`) pour garantir l'intégrité de la base de données.
        -   **Pour les ressources supprimées (autre statut, ex: 404)**:
            a.  Le service appelle `backend->deleteCalendarObject(..., true)` pour supprimer définitivement la copie locale de l'événement.
    4.  **Retour du résultat**: La méthode retourne un objet `SyncServiceResult` qui contient le **nouveau `syncToken`** (fourni par le serveur distant) et le nombre d'événements qui ont été téléchargés. Le nouveau token sera utilisé pour la prochaine exécution de la synchronisation.

---

## 3. Dépendances

- **`IClientService $clientService`**: Le client HTTP pour effectuer les requêtes vers le serveur distant.
- **`CalDavBackend $backend`**: Le service de bas niveau pour manipuler la copie locale des événements dans la base de données.
- **`FederatedCalendarMapper`**: Un service pour gérer les enregistrements des calendriers fédérés eux-mêmes (ex: pour les supprimer en cas d'erreur).
- **`IDBConnection $dbConnection`**: La connexion à la base de données, requise pour la gestion des transactions.

---

## Conclusion

`SyncService` est un composant essentiel de la fonctionnalité de "Cloud Federation" de Nextcloud. Il implémente la logique client robuste et résiliente nécessaire pour maintenir synchronisée une copie locale d'un calendrier distant. En utilisant le protocole `sync-collection`, il assure une synchronisation efficace (en ne téléchargeant que ce qui a changé) et gère correctement le cycle de vie des objets et les cas d'erreur comme la révocation des partages.
