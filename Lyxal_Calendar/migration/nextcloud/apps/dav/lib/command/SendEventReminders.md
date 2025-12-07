# Analyse de `OCA\DAV\Command\SendEventReminders`

## Description

`SendEventReminders` est une commande qui force l'envoi immédiat des rappels d'événements (par email ou notification push). Elle est conçue pour être utilisée lorsque le traitement des rappels n'est pas géré par le système de tâches de fond (Cron) habituel.

## Rôle et Responsabilités

-   **Nom de la commande** : `dav:send-event-reminders`
-   **Description** : "Sends event reminders" (Envoie les rappels d'événements).

### Fonctionnement

1.  **Vérifications de Configuration** :
    *   **Activation** : Vérifie si la fonctionnalité est activée (`dav` -> `sendEventReminders` doit être à 'yes'). Sinon, elle échoue avec un message explicatif.
    *   **Mode d'Exécution** : Vérifie si le mode d'envoi est configuré sur 'occ' (`dav` -> `sendEventRemindersMode`). Si le mode est réglé sur 'backgroundjob' (la valeur par défaut), la commande refuse de s'exécuter pour éviter les conflits ou les doubles envois.

2.  **Exécution** :
    *   Si les conditions sont réunies, elle délègue le travail à `ReminderService->processReminders()`.

### Cas d'Usage

-   **Débogage** : Pour tester l'envoi de mails de rappel sans attendre le cron.
-   **Architectures Spécifiques** : Pour les installations où l'administrateur préfère déclencher les rappels via un script externe ou une tâche planifiée système spécifique plutôt que par le cron interne de Nextcloud.

## Dépendances Clés

-   `OCP\IConfig`: Pour lire la configuration de l'application.
-   `OCA\DAV\CalDAV\Reminder\ReminderService`: Le service qui contient la logique d'envoi des rappels.
