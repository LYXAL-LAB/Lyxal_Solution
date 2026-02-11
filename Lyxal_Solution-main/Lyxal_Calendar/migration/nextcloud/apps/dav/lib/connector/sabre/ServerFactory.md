# Analyse du Fichier `ServerFactory.php` de Nextcloud

## Description

`ServerFactory` est une usine (Factory pattern) chargée d'instancier et de configurer l'objet `Server` WebDAV avec tous ses plugins et dépendances. C'est ici que l'assemblage final du serveur WebDAV Nextcloud a lieu.

## Rôle et Responsabilités

### 1. Création du Serveur (`createServer`)
-   Initialise l'arbre de fichiers (`ObjectTree` pour les utilisateurs, `SimpleCollection` pour les partages publics).
-   Instancie `OCA\DAV\Connector\Sabre\Server`.

### 2. Enregistrement des Plugins
-   Ajoute tous les plugins essentiels :
    -   **Auth** : `AuthPlugin`, `AnonymousOptionsPlugin`.
    -   **Sécurité** : `BlockLegacyClientPlugin`, `MaintenancePlugin`.
    -   **Fonctionnalités** : `FilesPlugin`, `QuotaPlugin`, `ChecksumUpdatePlugin`, `TagsPlugin`, `SharesPlugin`, `CommentPropertiesPlugin`.
    -   **Compatibilité** : `FakeLockerPlugin`, `BrowserErrorPagePlugin`.
    -   **Debug/Logs** : `ExceptionLoggerPlugin`, `RequestIdHeaderPlugin`, `PropFindMonitorPlugin`.
-   Charge également les plugins WebDAV fournis par d'autres applications Nextcloud via `PluginManager`.

### 3. Configuration Contextuelle
-   Configure différemment le serveur selon qu'il s'agit d'un accès utilisateur standard ou d'un partage public (`$isPublicShare`).
-   Pour les partages publics, monte des collections racines spécifiques (`RootCollection`) pour limiter l'accès aux seuls fichiers partagés.

## Dépendances Clés
-   `OCA\DAV\Connector\Sabre\Server` : Le serveur à créer.
-   `OCA\DAV\AppInfo\PluginManager` : Gestionnaire de plugins externes.
-   Quasiment tous les services Nextcloud (`IConfig`, `IUserSession`, `IDBConnection`, etc.) sont injectés ici.
