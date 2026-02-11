# Analyse de `OCA\DAV\CalDAV\Reminder\ReminderService`

## Description

La classe `ReminderService` est le cœur du système de gestion des rappels pour les événements de calendrier. Elle agit comme un service de haut niveau qui orchestre la création, le traitement, la mise à jour et la suppression des rappels en se basant sur le cycle de vie des objets `VEvent`.

## Rôle et Responsabilités

Les responsabilités principales de `ReminderService` sont :

1.  **Traitement des Rappels Échus (`processReminders`)** :
    *   C'est la méthode principale, généralement appelée par une tâche planifiée (cron job).
    *   Elle récupère les rappels dont la date de notification est passée depuis la base de données via le `Backend`.
    *   Pour chaque rappel, elle valide les données de l'événement, vérifie si l'événement n'a pas été annulé, et s'assure qu'un fournisseur de notification existe pour le type de rappel (Email, Push, etc.).
    *   Elle détermine les destinataires (propriétaire, participants, utilisateurs avec accès en écriture sur un calendrier partagé).
    *   Elle délègue l'envoi effectif de la notification au fournisseur approprié obtenu via le `NotificationProviderManager`.
    *   Enfin, elle nettoie le rappel traité de la base de données ou planifie la prochaine occurrence pour les événements récurrents.

2.  **Gestion du Cycle de Vie des Événements** :
    *   **`onCalendarObjectCreate`** : Lorsqu'un événement est créé, cette méthode analyse ses alarmes (`VALARM`), calcule les dates de déclenchement futures pour chaque occurrence (y compris les exceptions de récurrence), et insère les enregistrements correspondants dans la table de la base de données des rappels. Elle gère la complexité des événements récurrents en utilisant `EventIterator` pour ne planifier que le prochain rappel pertinent.
    *   **`onCalendarObjectEdit`** : Pour la mise à jour d'un événement, l'implémentation actuelle est une approche simple mais robuste : elle supprime tous les anciens rappels associés à l'événement (`onCalendarObjectDelete`) puis en recrée de nouveaux comme s'il s'agissait d'une nouvelle création (`onCalendarObjectCreate`).
    *   **`onCalendarObjectDelete`** : Lors de la suppression d'un événement, cette méthode s'assure de nettoyer tous les rappels en attente associés à cet événement de la base de données.

3.  **Logique de Récurrence et de Fuseau Horaire** :
    *   La classe gère la complexité des événements récurrents. Elle distingue l'événement "maître" des "exceptions de récurrence" pour calculer correctement les dates de rappel.
    *   Elle utilise la librairie `Sabre\VObject` et son `EventIterator` pour parcourir les occurrences futures d'un événement sans toutes les charger en mémoire.
    *   Elle prend en compte le fuseau horaire du calendrier pour s'assurer que les rappels basés sur des heures locales sont déclenchés au bon moment.

4.  **Hashing et Optimisation** :
    *   Elle utilise des fonctions de hachage (`getEventHash`, `getAlarmHash`) pour créer des empreintes uniques des propriétés temporelles d'un événement et de ses alarmes. Ces hashs sont stockés en base de données et permettent de détecter si une mise à jour d'événement nécessite une replanification des rappels.

## Fonctions Publiques Clés

-   `processReminders()`: Traite la file d'attente des rappels à envoyer.
-   `onCalendarObjectCreate(array $objectData)`: Crée des rappels pour un nouvel événement.
-   `onCalendarObjectEdit(array $objectData)`: Met à jour les rappels pour un événement modifié.
-   `onCalendarObjectDelete(array $objectData)`: Supprime les rappels pour un événement supprimé.

## Fonctions Privées Notables

-   `deleteOrProcessNext(array $reminder, VEvent $vevent)`: Logique cruciale qui, après l'envoi d'un rappel pour un événement récurrent, supprime le rappel actuel et planifie le suivant.
-   `getRemindersForVAlarm(...)`: Calcule les données d'un rappel (date de notification, type, etc.) à partir d'un composant `VALARM`.
-   `writeRemindersToDatabase(array $reminders)`: Insère les rappels calculés en base de données.
-   `getVEventByRecurrenceId(...)`: Retrouve une occurrence spécifique d'un événement récurrent à partir de son `RECURRENCE-ID`.
-   `getEventHash(VEvent $vevent)` / `getAlarmHash(VAlarm $valarm)`: Génèrent des hashs pour détecter les changements.

## Dépendances

-   `OCA\DAV\CalDAV\Reminder\Backend`: Pour toutes les interactions avec la table de la base de données `calendar_reminders`.
-   `OCA\DAV\CalDAV\Reminder\NotificationProviderManager`: Pour obtenir le bon fournisseur de notification (`EmailProvider`, `PushProvider`, etc.).
-   `OCA\DAV\CalDAV\CalDavBackend`: Pour récupérer des informations sur les calendriers, comme leur fuseau horaire ou les partages.
-   `OCP\IUserManager` / `OCP\IGroupManager`: Pour résoudre les utilisateurs et les groupes lors de la détermination des destinataires des notifications.
-   `OCP\AppFramework\Utility\ITimeFactory`: Pour obtenir l'heure actuelle de manière testable.
-   `Psr\Log\LoggerInterface`: Pour la journalisation des opérations.
-   `Sabre\VObject`: Utilisation intensive de cette librairie pour parser les données iCalendar (`VCalendar`, `VEvent`, `VAlarm`) et gérer la récurrence.

En résumé, `ReminderService` est le moteur central qui traduit la logique déclarative des alarmes iCalendar (`VALARM`) en actions concrètes (enregistrements en base de données) et qui orchestre leur exécution au moment opportun via différents canaux de notification.
