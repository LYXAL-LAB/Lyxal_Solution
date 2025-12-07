# Analyse du Fichier `Federation/FederatedCalendarMapper.php`

Ce document décompose le contenu de la classe `Federation\FederatedCalendarMapper.php`. Il s'agit d'une classe de la couche d'accès aux données, responsable de toutes les interactions avec la table de base de données des calendriers fédérés.

---

## 1. Rôle et Responsabilités

La classe `FederatedCalendarMapper` est un **Data Mapper**. Son unique responsabilité est de faire le pont entre le monde orienté objet de l'application (représenté par la classe `FederatedCalendarEntity`) et le monde relationnel de la base de données (la table `calendars_federated`).

Elle encapsule toute la logique de construction et d'exécution des requêtes SQL, fournissant une API claire et orientée objet aux autres services pour manipuler les données de la fédération.

---

## 2. Logique Principale

La classe hérite de `QBMapper`, ce qui lui fournit une base solide pour construire des requêtes avec le Query Builder de Nextcloud. Chaque méthode publique correspond à une opération de base de données spécifique (CRUD - Create, Read, Update, Delete).

- **Méthodes de Lecture (`find...`)**:
  - `find(int $id)`: Récupère un enregistrement unique par sa clé primaire.
  - `findByPrincipalUri(string $principalUri)`: Récupère tous les calendriers fédérés appartenant à un utilisateur.
  - `findByUri(...)`: Récupère un calendrier spécifique pour un utilisateur par son URI local.
  - `findByRemoteUrl(...)`: Récupère des calendriers en se basant sur leur URL distante, l'utilisateur local et le token, ce qui est probablement utilisé par le `CalendarFederationProvider` pour les notifications de synchronisation.
  - `findUnsyncedSinceBefore(...)`: Une méthode spécialisée pour les tâches de fond, qui récupère les calendriers qui n'ont pas été synchronisés depuis un certain temps.

- **Méthodes de Suppression (`delete...`)**:
  - `deleteById(int $id)`: Supprime un enregistrement par sa clé primaire.
  - `deleteByUri(...)`: Supprime un enregistrement en se basant sur l'utilisateur et l'URI local.

- **Méthodes de Mise à Jour (`update...`)**:
  - `updateSyncTime(int $id)`: Met à jour uniquement l'horodatage de la dernière synchronisation.
  - `updateSyncTokenAndTime(...)`: Met à jour à la fois le `sync-token` et l'horodatage de la synchronisation.

- **Méthode de Création (`insert`)**:
  - La méthode `insert` est héritée de la classe parente `QBMapper`. Elle prend un objet `FederatedCalendarEntity`, le transforme en une requête `INSERT` et l'exécute.

---

## Conclusion

`FederatedCalendarMapper` est une implémentation propre du patron de conception Data Mapper. Elle sépare clairement les responsabilités en isolant toute la logique de la base de données dans une seule classe. Cela rend le reste du code plus propre, car les services n'ont pas à se soucier de la syntaxe SQL, et plus sécurisé, car l'utilisation du Query Builder prévient les injections SQL. C'est la fondation sur laquelle repose la persistance de l'état de la fédération de calendriers.
