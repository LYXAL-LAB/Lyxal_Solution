# Analyse du Fichier `LegacyPublicAuth.php` de Nextcloud

## Description

`LegacyPublicAuth` gère l'authentification pour les anciens liens publics WebDAV (probablement ceux utilisant `public.php/webdav` avec le token comme nom d'utilisateur).

## Rôle et Responsabilités

### 1. Authentification (`validateUserPass`)
-   Utilise le nom d'utilisateur fourni comme **Token de Partage**.
-   Vérifie si le partage existe.
-   Si le partage est protégé par mot de passe, valide le mot de passe fourni.
-   Gère la session (`DAV_AUTHENTICATED`) pour éviter les ré-authentifications.

### 2. Différence avec `PublicAuth`
-   `PublicAuth` (plus récent) extrait le token directement de l'URL (`/public.php/webdav/{token}`).
-   `LegacyPublicAuth` s'attend à ce que le token soit passé dans le champ "Username" de l'authentification Basic.

## Dépendances Clés
-   `Sabre\DAV\Auth\Backend\AbstractBasic` : Classe de base.
-   `OCP\Share\IManager` : Gestion des partages.
