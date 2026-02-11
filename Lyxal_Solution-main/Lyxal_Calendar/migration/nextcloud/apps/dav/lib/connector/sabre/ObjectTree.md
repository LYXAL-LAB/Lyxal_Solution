# Analyse du Fichier `ObjectTree.php` de Nextcloud

## Description

`ObjectTree` est une implémentation spécialisée de l'arbre SabreDAV (`Tree`) pour Nextcloud. Elle gère la résolution des chemins WebDAV vers les objets internes de Nextcloud (`Node`, `File`, `Directory`) et supporte les opérations de copie.

## Rôle et Responsabilités

### 1. Résolution de Chemin (`getNodeForPath`)
-   Transforme un chemin WebDAV (ex: `files/mon_dossier/image.jpg`) en un objet `Sabre\DAV\INode`.
-   Utilise la vue de fichiers (`fileView`) pour vérifier l'existence et récupérer les infos (`FileInfo`).
-   Gère le cache via `CachingTree`.
-   **Support des Fichiers Partiels** : Détecte les fichiers `.part` (uploads incomplets) et permet leur lecture directe depuis le stockage, contournant parfois le cache ou les vérifications standard.

### 2. Copie (`copy`)
-   Gère la copie récursive de fichiers ou dossiers.
-   Vérifie les permissions de création dans le dossier de destination.
-   Utilise `fileView->copy` pour effectuer l'opération au niveau du stockage.
-   Invalide le cache (`markDirty`) après l'opération.

## Dépendances Clés
-   `OCA\DAV\Connector\Sabre\CachingTree` : Classe parente.
-   `OC\Files\View` : Accès au système de fichiers.
-   `OCP\Files\Mount\IMountManager` : Gestion des points de montage.
