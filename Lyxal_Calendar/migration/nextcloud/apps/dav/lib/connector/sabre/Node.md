# Analyse du Fichier `Node.php` de Nextcloud

## Description

`Node` est la classe de base abstraite pour tous les nœuds WebDAV de Nextcloud (`File` et `Directory`). Elle fait le pont entre l'interface `Sabre\DAV\INode` et le système de fichiers interne de Nextcloud (`OC\Files\Node`).

## Rôle et Responsabilités

### 1. Gestion des Métadonnées de Base
-   **Nom** : `getName`, `setName`.
-   **Chemin** : `getPath`.
-   **Dates** : `getLastModified`, `touch`.
-   **ETag** : `getETag`.

### 2. Gestion des Permissions (`getDavPermissions`)
-   Traduit les permissions Nextcloud (`FileInfo::getPermissions`) en chaînes de permissions WebDAV (ex: "DWCK...").
-   Gère les permissions spécifiques aux partages (`getSharePermissions`).

### 3. Gestion des Partages
-   Fournit des méthodes pour récupérer les attributs de partage (`getShareAttributes`) et les notes de partage (`getNoteFromShare`).

### 4. Verrouillage (`acquireLock`, `releaseLock`)
-   Délègue les opérations de verrouillage à la vue de fichiers sous-jacente (`fileView`).

## Dépendances Clés
-   `Sabre\DAV\INode` : Interface SabreDAV.
-   `OC\Files\View` : Vue sur le système de fichiers.
-   `OCP\Files\FileInfo` : Informations sur le fichier/dossier.
