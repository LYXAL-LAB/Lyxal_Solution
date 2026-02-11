# Authentification "Cloud" et SSO dans Lyxal Portal

## 1. Vue d'ensemble
Le bouton "Sign in" (Connexion) situé en haut à droite de l'interface Surrealist est initialement conçu pour se connecter au SaaS "Surreal Cloud". Dans le cadre de **Lyxal Portal**, ce mécanisme sera détourné pour authentifier les utilisateurs sur le système d'identité interne (SSO) de l'entreprise (ex: Keycloak, Auth0 personnalisé, etc.).

## 2. Fichiers Clés de l'Authentification

La logique d'authentification OAuth est concentrée dans le dossier `src/cloud/api/`.

### A. Les Points de Terminaison (Endpoints)
- **Fichier :** `src/cloud/api/endpoints.tsx`
- **Rôle :** Définit les URLs de base vers lesquelles l'application redirige pour la connexion (`authBase`) et l'API (`apiBase`).
- **Modification requise :** Remplacer les URLs par celles de votre serveur d'authentification.
  ```typescript
  // Exemple de modification
  const CLOUD_ENDPOINT = "https://api.lyxal-solution.com";
  const AUTH_ENDPOINT = "https://auth.lyxal-solution.com";
  ```

### B. Le Flux OAuth (Auth Flow)
- **Fichier :** `src/cloud/api/auth.tsx`
- **Rôle :** Gère le cycle de vie OAuth : génération du PKCE, redirection vers la page de login, échange du code contre un token.
- **Paramètres à adapter :**
  - `CLIENT_ID` : L'identifiant de l'application Lyxal Portal déclaré sur votre serveur OAuth.
  - `audience` : (Ligne ~87) L'identifiant de l'API cible.
  - `scope` : Les permissions demandées (ex: `openid profile email`).

## 3. Configuration via Variables d'Environnement

Plutôt que de modifier le code en dur, il est recommandé d'utiliser les variables d'environnement (fichier `.env`).

- `VITE_CLOUD_ENDPOINT` : URL de votre API Backend (si vous imitez l'API Cloud Surreal).
- `VITE_CLOUD_CLIENT_ID` : Votre Client ID OAuth.

## 4. Stratégie d'Implémentation Lyxal

1.  **Backend d'Authentification :** Monter un serveur OAuth2/OIDC (ex: Keycloak).
2.  **Configuration Frontend :**
    - Modifier `endpoints.tsx` pour pointer vers ce serveur.
    - Modifier `auth.tsx` pour correspondre aux paramètres attendus par votre serveur (scopes, audience).
3.  **Expérience Utilisateur :**
    - Le bouton "Sign in" redirigera vers votre page de login Lyxal.
    - Une fois connecté, le token JWT récupéré sera stocké localement par Surrealist.
    - Ce token pourra ensuite être utilisé pour authentifier automatiquement la connexion à la base de données SurrealDB (si configurée pour accepter ce JWT).

## 5. Note sur la Désactivation
Si l'authentification centralisée n'est pas prête, il est possible de désactiver totalement ce bouton et les fonctionnalités liées en forçant le hook `useIsCloudEnabled` à retourner `false` dans `src/hooks/cloud.tsx`.

