# Analyse du Fichier `AvatarHome.php` de Nextcloud

## Description

`AvatarHome` représente le répertoire d'avatars d'un utilisateur dans l'arborescence WebDAV (ex: `/avatars/admin/`).

## Rôle et Responsabilités

### 1. Collection WebDAV en Lecture Seule
-   Implémente `Sabre\DAV\ICollection`
-   `createFile()`, `createDirectory()`, `delete()`, `setName()` : Interdits (`Forbidden`)

### 2. Accès aux Avatars
-   `getChild($name)` : Retourne un `AvatarNode` pour un avatar demandé
-   Format du nom : `{taille}.{extension}` (ex: `96.jpeg`, `128.png`)
-   Tailles valides : 1-1024 pixels
-   Extensions valides : `jpeg`, `png`

### 3. Listage
-   `getChildren()` : Retourne un seul avatar par défaut (96.jpeg)
-   `childExists()` : Vérifie si l'avatar existe

## Dépendances Clés
-   `IAvatarManager` : Récupération des avatars
-   `AvatarNode` : Représentation du fichier avatar
