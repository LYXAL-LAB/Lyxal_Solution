# Analyse du Fichier `ExceptionLoggerPlugin.php` de Nextcloud

## Description

`ExceptionLoggerPlugin` est responsable de l'enregistrement (logging) des exceptions survenant lors du traitement des requêtes WebDAV.

## Rôle et Responsabilités

### 1. Filtrage des Exceptions (`logException`)
-   S'abonne à l'événement `exception` du serveur.
-   Distingue les exceptions "fatales" (erreurs serveur, bugs) des exceptions "normales" ou attendues dans le flux WebDAV.

### 2. Niveaux de Log
-   **DEBUG** : Pour les exceptions listées dans `$nonFatalExceptions` (ex: `NotAuthenticated`, `NotFound`, `PreconditionFailed`, `FileLocked`). Ces erreurs sont courantes et font partie du protocole.
-   **CRITICAL** : Pour toutes les autres exceptions non gérées. Elles indiquent un problème sérieux côté serveur.

## Dépendances Clés
-   `Sabre\DAV\ServerPlugin` : Classe de base.
-   `Psr\Log\LoggerInterface` : Le logger PSR-3 de Nextcloud.
