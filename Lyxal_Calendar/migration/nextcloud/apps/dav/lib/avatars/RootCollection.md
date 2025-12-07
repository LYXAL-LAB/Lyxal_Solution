# Analyse du Fichier `RootCollection.php` (Avatars) de Nextcloud

## Description

`RootCollection` est la racine de la collection d'avatars WebDAV (ex: `/avatars/`). Étend `AbstractPrincipalCollection`.

## Rôle et Responsabilités

### 1. Collection Basée sur les Principaux
-   Chaque enfant correspond à un utilisateur (principal)
-   Délègue au backend des principaux pour la liste des utilisateurs

### 2. Création des Enfants
-   `getChildForPrincipal()` : Retourne un `AvatarHome` pour chaque principal
-   Utilise `IAvatarManager` via le container

### 3. Nom de la Collection
-   `getName()` : Retourne `'avatars'`

## Dépendances Clés
-   `AbstractPrincipalCollection` : Classe parente Sabre pour collections par principal
-   `IAvatarManager` : Gestionnaire d'avatars Nextcloud
-   `AvatarHome` : Enfants de la collection
