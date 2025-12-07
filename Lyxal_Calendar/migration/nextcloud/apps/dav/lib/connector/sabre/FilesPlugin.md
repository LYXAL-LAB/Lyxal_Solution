# Analyse du Fichier `FilesPlugin.php` de Nextcloud

## Description

`FilesPlugin` est un plugin massif qui enrichit les réponses WebDAV avec de nombreuses propriétés spécifiques à Nextcloud (permissions, partages, métadonnées, checksums, etc.). C'est le cœur de l'intégration "riche" entre le client Nextcloud et le serveur.

## Rôle et Responsabilités

### 1. Propriétés Personnalisées (`handleGetProperties`)
-   Injecte une multitude de propriétés dans `PROPFIND` :
    -   `{http://owncloud.org/ns}id` : FileId unique.
    -   `{http://owncloud.org/ns}permissions` : Permissions de l'utilisateur (Read, Write, Share, Delete...).
    -   `{http://owncloud.org/ns}size` : Taille.
    -   `{http://owncloud.org/ns}checksums` : Liste des hashs.
    -   `{http://nextcloud.org/ns}has-preview` : Disponibilité d'une miniature.
    -   `{http://owncloud.org/ns}owner-id` : ID du propriétaire.
    -   Et bien d'autres (partages, montages, fédération...).

### 2. Mise à Jour de Propriétés (`handleUpdateProperties`)
-   Permet de modifier certaines propriétés via `PROPPATCH` (ex: `lastmodified`, `creationdate`).
-   Gère la mise à jour des **Métadonnées Personnalisées** (`handleUpdatePropertiesMetadata`) stockées via `FilesMetadataManager`.

### 3. Vérifications de Déplacement/Copie (`checkMove`, `checkCopy`)
-   Valide les noms de fichiers et les chemins avant les opérations.
-   Vérifie les permissions spécifiques (ex: on ne peut pas déplacer un fichier indélébile).

### 4. Téléchargement (`httpGet`)
-   Ajoute les en-têtes `Content-Disposition` pour forcer le téléchargement avec le bon nom de fichier.
-   Ajoute l'en-tête `OC-Checksum`.

## Dépendances Clés
-   `Sabre\DAV\ServerPlugin` : Classe de base.
-   `OCP\FilesMetadata\IFilesMetadataManager` : Gestion des métadonnées arbitraires.
-   `IUserSession` : Pour les permissions contextuelles.
