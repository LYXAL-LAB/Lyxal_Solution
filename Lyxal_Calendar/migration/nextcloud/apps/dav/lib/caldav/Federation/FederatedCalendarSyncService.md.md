# Analyse du Fichier `Federation/FederatedCalendarSyncService.php`

Ce document décompose le contenu de la classe `Federation\FederatedCalendarSyncService.php`. Il s'agit du service qui contient la logique métier de la synchronisation d'un calendrier fédéré.

---

## 1. Rôle et Responsabilités

La classe `FederatedCalendarSyncService` est le **moteur de la synchronisation**. Sa responsabilité est de prendre un enregistrement de calendrier fédéré, de contacter le serveur distant, de télécharger les modifications (événements ajoutés, modifiés, supprimés) et de mettre à jour l'état local du calendrier (nouveau `sync-token` et date de dernière synchronisation).

Ce service est conçu pour être appelé de manière asynchrone, typiquement par une tâche de fond (`BackgroundJob`), pour ne pas impacter les performances de l'interface utilisateur.

---

## 2. Logique Principale (`syncOne` method)

La méthode `syncOne` orchestre le processus de synchronisation pour un unique calendrier.

- **Étapes d'exécution**:
  1.  **Préparation des Données**:
      -   Elle extrait toutes les informations nécessaires de l'objet `FederatedCalendarEntity` fourni : l'URL du serveur distant, le `sync-token` de la dernière synchronisation réussie, et le token secret pour l'authentification.
      -   Elle prépare également l'identifiant de l'utilisateur local qui sera utilisé comme "nom d'utilisateur" pour l'authentification `Basic` auprès du serveur distant.

  2.  **Délégation de la Communication CalDAV**:
      -   Le cœur du travail de communication réseau est **délégué** à un autre service plus générique, le `CalDavSyncService`.
      -   Ce `CalDavSyncService` est responsable de la construction et de l'envoi de la requête `REPORT` `sync-collection`, qui est la méthode standard en CalDAV pour récupérer uniquement les changements survenus depuis le dernier `sync-token`.
      -   Elle lui transmet l'URL, les identifiants (`calDavUser` et le token secret), et le `sync-token` actuel.

  3.  **Traitement de la Réponse**:
      -   Une fois que le `syncService` a terminé, il retourne une réponse contenant les événements modifiés (qui sont directement insérés dans la base de données par le `syncService`) et, surtout, le **nouveau `sync-token`** fourni par le serveur distant.

  4.  **Mise à Jour de l'État Local**:
      -   Le service parse ce nouveau `sync-token` pour s'assurer de sa validité.
      -   Il utilise ensuite le `FederatedCalendarMapper` pour mettre à jour l'enregistrement dans la base de données locale.
      -   Si le `sync-token` a changé, il stocke le nouveau token et met à jour l'heure de la synchronisation.
      -   Si le `sync-token` est identique (aucune modification sur le serveur distant), il se contente de mettre à jour l'heure de la synchronisation pour indiquer qu'une vérification a bien eu lieu.

---

## Conclusion

`FederatedCalendarSyncService` est un service d'orchestration qui suit le principe de séparation des responsabilités. Il ne gère pas lui-même les détails du protocole CalDAV ou l'accès direct à la base de données. Au lieu de cela, il utilise des services spécialisés pour ces tâches (`CalDavSyncService` et `FederatedCalendarMapper`). Son rôle est de coordonner ces services pour exécuter le processus de synchronisation de haut niveau : préparer les données, déclencher la synchronisation, et mettre à jour l'état local en fonction du résultat.
