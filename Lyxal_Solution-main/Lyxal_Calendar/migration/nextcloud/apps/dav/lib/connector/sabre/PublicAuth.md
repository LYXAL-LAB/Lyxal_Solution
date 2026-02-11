# Analyse du Fichier `PublicAuth.php` de Nextcloud

## Description

`PublicAuth` gère l'authentification pour les partages publics (liens publics) via WebDAV. Il permet d'accéder aux fichiers partagés par lien, avec ou sans mot de passe.

## Rôle et Responsabilités

### 1. Authentification par Token (`checkToken`)
-   Extrait le token de partage de l'URL (ex: `/public.php/webdav/{token}`).
-   Vérifie si le partage existe via `ShareManager`.
-   Si le partage est protégé par mot de passe, vérifie si l'utilisateur est déjà authentifié pour ce partage (session) ou si les identifiants fournis sont corrects.

### 2. Validation Utilisateur/Mot de Passe (`validateUserPass`)
-   Si un mot de passe est requis, valide le mot de passe fourni via l'authentification Basic HTTP.
-   En cas de succès, ajoute le partage à la session de l'utilisateur (`addShareToSession`) pour éviter de redemander le mot de passe.

### 3. Protection
-   Utilise `IThrottler` pour limiter les tentatives de force brute sur les mots de passe de partage.
-   Gère le mode "Incognito" (`OC_User::setIncognitoMode`) pour ces sessions publiques.

## Dépendances Clés
-   `Sabre\DAV\Auth\Backend\AbstractBasic` : Classe de base.
-   `OCP\Share\IManager` : Gestion des partages.
-   `OCP\Security\Bruteforce\IThrottler` : Sécurité.
