# Analyse du Répertoire `Exception` de Nextcloud DAV

Ce répertoire contient les exceptions spécifiques à l'app DAV (niveau applicatif, pas WebDAV).

---

## `ServerMaintenanceMode.php`
-   **Fonction** : Indique que le serveur est en mode maintenance
-   **Usage** : Levée par `MaintenancePlugin` pour bloquer les requêtes

## `ExampleEventException.php`
-   **Fonction** : Exception d'exemple/placeholder
-   **Usage** : Probablement pour tests

## `UnsupportedLimitOnInitialSyncException.php`
-   **Fonction** : Le client a demandé une limite sur une synchronisation initiale
-   **Usage** : CalDAV/CardDAV sync ne supporte pas `limit` sans sync-token
