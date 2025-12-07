# Analyse du Fichier `AvatarNode.php` de Nextcloud

## Description

`AvatarNode` représente un fichier avatar individuel dans l'arborescence WebDAV. Étend `Sabre\DAV\File`.

## Rôle et Responsabilités

### 1. Représentation d'un Avatar
-   Nom : `{taille}.{extension}` (ex: `96.jpeg`)
-   Taille configurable (en pixels)
-   Format : PNG ou JPEG

### 2. Récupération du Contenu
-   `get()` : Génère l'image à la volée avec GD (`imagepng`, `imagejpeg`)
-   Utilise `ob_start()`/`ob_get_clean()` pour capturer la sortie

### 3. Métadonnées
-   `getContentType()` : Retourne `image/png` ou `image/jpeg`
-   `getETag()`, `getLastModified()` : Délègue au fichier avatar stocké

## Dépendances Clés
-   `IAvatar` : Interface Nextcloud pour les avatars
-   `Sabre\DAV\File` : Classe parente Sabre
