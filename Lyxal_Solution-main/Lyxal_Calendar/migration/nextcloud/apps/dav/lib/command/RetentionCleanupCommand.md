# Analyse de `OCA\DAV\Command\RetentionCleanupCommand`

## Description

`RetentionCleanupCommand` est une commande console simple qui déclenche le processus de nettoyage automatique des événements expirés, basé sur les règles de rétention définies.

## Rôle et Responsabilités

-   **Nom de la commande** : `dav:retention:clean-up`
-   **Description** : Déclenche le nettoyage de la rétention.

### Fonctionnement

1.  **Délégation** :
    *   La commande est un simple point d'entrée (wrapper).
    *   Elle ne contient aucune logique métier propre.
    *   Elle appelle directement la méthode `cleanUp()` du service `RetentionService`.

2.  **Action du Service** :
    *   Le `RetentionService` (analysé par ailleurs) est responsable de parcourir les calendriers et de supprimer les événements qui ont dépassé leur date limite de conservation (si une telle politique est configurée).

### Cas d'Usage

-   **Tâche Planifiée (Cron)** : Cette commande est probablement destinée à être exécutée régulièrement par le système de tâches de fond (cron) de Nextcloud pour assurer que les anciennes données sont purgées automatiquement.
-   **Maintenance Manuelle** : Un administrateur peut l'exécuter manuellement pour forcer un nettoyage immédiat sans attendre le prochain cycle cron.

## Dépendances Clés

-   `OCA\DAV\CalDAV\RetentionService`: Le service qui contient la logique réelle de nettoyage.
