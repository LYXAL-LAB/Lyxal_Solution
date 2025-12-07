# Analyse du Fichier `CommentPropertiesPlugin.php` de Nextcloud

## Description

`CommentPropertiesPlugin` injecte des informations sur les commentaires (nombre total, nombre non lu, lien) dans les propriétés WebDAV des fichiers et dossiers.

## Rôle et Responsabilités

### 1. Propriétés Personnalisées (`handleGetProperties`)
-   Injecte trois propriétés lors d'un `PROPFIND` :
    -   `{http://owncloud.org/ns}comments-count` : Nombre total de commentaires.
    -   `{http://owncloud.org/ns}comments-unread` : Nombre de commentaires non lus par l'utilisateur courant.
    -   `{http://owncloud.org/ns}comments-href` : Lien vers l'interface web pour voir les commentaires.

### 2. Optimisation / Préchargement (`preloadCollection`)
-   Pour éviter de faire N requêtes SQL lors du listage d'un dossier contenant N fichiers, le plugin utilise `preloadCollection`.
-   Il récupère en une seule fois les compteurs de commentaires pour tous les enfants du dossier (`commentsManager->getNumberOfCommentsForObjects`).
-   Ces données sont mises en cache localement (`$cachedCount`, `$cachedUnreadCount`) pour être servies rapidement par `handleGetProperties`.

## Dépendances Clés
-   `OCP\Comments\ICommentsManager` : Service de gestion des commentaires.
-   `OCP\IUserSession` : Pour identifier l'utilisateur (lecture des non-lus).
