# Analyse du Fichier `LockPlugin.php` de Nextcloud

## Description

`LockPlugin` gère le verrouillage des fichiers lors des opérations d'écriture (`PUT`), en utilisant le mécanisme de verrouillage interne de Nextcloud (`ILockingProvider`) plutôt que le verrouillage WebDAV standard.

## Rôle et Responsabilités

### 1. Acquisition du Verrou (`getLock`)
-   Intercepte les requêtes `PUT` (`beforeMethod:PUT`).
-   Acquiert un verrou partagé (`LOCK_SHARED`) sur le nœud concerné via `node->acquireLock()`.
-   **Note** : Ce verrouillage est interne au serveur pour éviter les conflits d'écriture concurrents (ex: deux uploads simultanés sur le même fichier). Il est différent du verrouillage WebDAV explicite (méthode `LOCK`).

### 2. Libération du Verrou (`releaseLock`)
-   Relâche le verrou (`releaseLock`) après la fin de la requête (`afterMethod:PUT`), que l'opération ait réussi ou échoué.

## Dépendances Clés
-   `Sabre\DAV\ServerPlugin` : Classe de base.
-   `OCP\Lock\ILockingProvider` : Interface de verrouillage de Nextcloud.
