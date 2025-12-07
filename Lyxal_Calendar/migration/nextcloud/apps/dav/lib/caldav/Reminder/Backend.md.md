# Analyse du Fichier `Reminder/Backend.php`

Ce document décompose le contenu de la classe `Reminder\Backend.php`. Il s'agit d'une classe de la couche d'accès aux données (similaire à un "Data Mapper") qui gère la persistance des rappels d'événements planifiés.

---

## 1. Rôle et Responsabilités

La classe `Backend` est responsable de **toutes les opérations de base de données (CRUD)** sur la table `calendar_reminders`. Cette table ne contient pas les définitions d'alarmes (`VALARM`), mais plutôt les **notifications pré-calculées et planifiées** qui en découlent.

Lorsqu'un événement avec des alarmes est créé, un service de plus haut niveau calcule les moments précis où les notifications doivent être envoyées et utilise ce `Backend` pour insérer des enregistrements dans la table. Le rôle de ce backend est donc de fournir une API pour stocker, récupérer et gérer ces rappels planifiés.

---

## 2. Logique Principale

Chaque méthode publique correspond à une opération spécifique sur la base de données.

- **`getRemindersToProcess(): array`**:
  - **Rôle**: C'est la méthode la plus critique du backend. Elle est conçue pour être appelée par une tâche de fond (`cron job`) à intervalles réguliers.
  - **Action**: Elle exécute une requête `SELECT` qui recherche dans la table `calendar_reminders` toutes les entrées dont la colonne `notification_date` est antérieure ou égale à l'heure actuelle. En d'autres termes, elle récupère **tous les rappels qui sont "dus"** et qui doivent être envoyés.
  - Elle effectue également des jointures (`JOIN`) avec les tables `calendarobjects` et `calendars` pour enrichir les résultats avec les données complètes de l'événement et les informations du calendrier, afin que le service de notification ait tout le contexte nécessaire.

- **`insertReminder(...)`**:
  - **Rôle**: Créer un nouvel enregistrement de rappel planifié.
  - **Action**: Exécute une requête `INSERT` dans la table `calendar_reminders` avec tous les détails du rappel : à quel événement il appartient, sa date de notification, son type, etc.

- **`updateReminder(...)`**:
  - **Rôle**: Mettre à jour un rappel existant.
  - **Action**: Exécute une requête `UPDATE` pour modifier la `notification_date` d'un rappel. Ceci est probablement utilisé pour reprogrammer les rappels répétitifs.

- **`removeReminder(...)`, `cleanRemindersForEvent(...)`, `cleanRemindersForCalendar(...)`**:
  - **Rôle**: Gérer la suppression des rappels.
  - **Action**: Fournit différentes méthodes pour exécuter des requêtes `DELETE` afin de nettoyer la table lorsqu'un rappel est traité, ou lorsqu'un événement ou un calendrier entier est modifié ou supprimé.

---

## Conclusion

`Reminder\Backend` est la fondation sur laquelle repose le système de notifications de rappel asynchrone et fiable de Nextcloud. En décentralisant l'état des rappels dans une table dédiée, il permet de décorréler le calcul des dates de notification de leur envoi effectif. Ce backend fournit l'interface de bas niveau indispensable pour que les services de plus haut niveau puissent planifier, interroger et nettoyer les rappels, et pour que les tâches de fond puissent efficacement déterminer quelles notifications envoyer à un instant T.
