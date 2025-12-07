# Analyse du Fichier `SharesPlugin.php` de Nextcloud

## Description

`SharesPlugin` enrichit les réponses WebDAV avec des informations sur les partages. Il permet aux clients de savoir si un fichier est partagé, comment, et avec qui.

## Rôle et Responsabilités

### 1. Injection de Propriétés (`handleGetProperties`)
-   Ajoute deux propriétés WebDAV personnalisées :
    -   `{http://owncloud.org/ns}share-types` : Liste des types de partage (via `ShareTypeList`).
    -   `{http://nextcloud.org/ns}sharees` : Détails sur les bénéficiaires (via `ShareeList`).
-   Récupère ces informations via `ShareManager`.

### 2. Optimisation / Mise en Cache (`preloadCollection`)
-   Pour éviter de faire une requête SQL par fichier lors du listing d'un dossier (`PROPFIND` sur une collection), ce plugin précharge tous les partages du dossier en une seule fois (`getSharesInFolder`) et les met en cache (`$cachedShares`).

### 3. Validation de Déplacement/Copie (`validateMoveOrCopy`)
-   Empêche de déplacer un fichier non partageable dans un partage.
-   Empêche de déplacer un fichier d'un partage vers un autre partage différent (sauf si l'utilisateur a les droits adéquats).

## Dépendances Clés
-   `Sabre\DAV\ServerPlugin` : Classe de base.
-   `OCP\Share\IManager` : Gestionnaire de partages.
