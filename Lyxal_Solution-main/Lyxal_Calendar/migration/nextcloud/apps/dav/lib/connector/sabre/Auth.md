# Analyse du Fichier `Auth.php` de Nextcloud

## Description

`Auth` est le backend d'authentification principal pour le serveur SabreDAV de Nextcloud. Il étend l'authentification Basic standard pour y intégrer la logique de session Nextcloud, la protection contre les attaques par force brute et la gestion du 2FA.

## Rôle et Responsabilités

### 1. Authentification Hybride (`validateUserPass`)
-   Vérifie d'abord si une session utilisateur est déjà active (`userSession->isLoggedIn()`) et si elle a été initiée via DAV (`isDavAuthenticated`). Si oui, l'accès est accordé sans revérifier le mot de passe.
-   Sinon, tente une connexion classique (`userSession->logClientIn`).
-   En cas de succès, marque la session comme "authentifiée via DAV".

### 2. Sécurité et Protection
-   **BruteForce** : Utilise `IThrottler` pour ralentir les tentatives échouées.
-   **2FA** : Vérifie si le second facteur est requis (`twoFactorManager->needsSecondFactor`). Si oui, rejette l'authentification (les clients DAV doivent utiliser des mots de passe d'application).
-   **CSRF** : Vérifie les tokens CSRF pour les méthodes non-safe (POST, etc.), sauf pour les clients officiels Nextcloud ou les sessions déjà authentifiées via DAV.

### 3. Gestion des Erreurs
-   Gère les exceptions spécifiques comme `PasswordLoginForbidden` ou `TooManyRequests`.
-   Pour les requêtes AJAX, retourne une erreur 401 avec un header `WWW-Authenticate` factice pour éviter les popups navigateur.

## Dépendances Clés
-   `Sabre\DAV\Auth\Backend\AbstractBasic` : Classe de base.
-   `OC\User\Session` : Gestionnaire de session Nextcloud.
-   `OCP\Security\Bruteforce\IThrottler` : Protection anti-bruteforce.
-   `OC\Authentication\TwoFactorAuth\Manager` : Gestion du 2FA.
