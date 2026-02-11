# 🚀 Lyxal Identity - Plan de Développement (Roadmap)

Ce document définit la stratégie et les étapes méthodiques pour transformer la structure actuelle en un Identity Provider (IdP) complet en Rust, inspiré par l'architecture de Logto.

## 📌 Phase 1 : Fondations et Cœur du Système (Core) ✅
**Objectif :** Établir les bases techniques communes et la communication avec la base de données.

- [x] **lyxal_core :**
    - [x] Implémenter le gestionnaire de configuration (chargement via `.env` ou YAML).
    - [x] Finaliser le système de gestion d'erreurs (`CoreError`) avec support Axum.
    - [x] Mettre en place le pool de connexion SQLx (PostgreSQL).
    - [x] Créer les utilitaires de cryptographie (Hashing Argon2, génération de salts).
- [x] **lyxal_schema :**
    - [x] Définir les modèles de données complets (Users, Applications, Organizations, Roles).
    - [x] Créer les migrations SQL initiales.

## 📌 Phase 2 : Gestion des Identités (IAM) ✅
**Objectif :** Créer, lire et gérer les entités fondamentales.

- [x] **lyxal_iam :**
    - [x] Implémenter les "Repositories" (accès SQLx) pour les utilisateurs, applications et tenants.
    - [x] Créer les services CRUD pour la gestion des utilisateurs.
    - [x] Gérer l'enregistrement et la validation des métadonnées des applications (Client ID, Client Secret).

## 📌 Phase 3 : Authentification et Sessions ✅
**Objectif :** Permettre aux utilisateurs de se connecter et maintenir leur état.

- [x] **lyxal_session :**
    - [x] Implémenter le stockage des sessions (PostgreSQL via tower-sessions).
    - [x] Créer le middleware de session pour Axum (Intégration tower-sessions).
- [x] **lyxal_auth :**
    - [x] Implémenter le flux Login/Password (AuthService).
    - [ ] Mettre en place les flux de vérification (Emails, Codes).
    - [x] Créer les endpoints d'authentification de base (Login, Register, Logout).

## 📌 Phase 4 : Autorisation et RBAC ✅
**Objectif :** Contrôler qui peut faire quoi.

- [x] **lyxal_rbac :**
    - [x] Implémenter le moteur de vérification des permissions (Enforcer).
    - [x] Gérer l'attribution des rôles aux utilisateurs et scopes aux applications.
    - [x] Intégrer les contrôles d'accès dans les middlewares de route.

## 📌 Phase 5 : Protocole OAuth2 & OpenID Connect (OIDC) ✅
**Objectif :** Devenir un fournisseur d'identité standardisé.

- [x] **lyxal_oauth :**
    - [x] Implémenter le endpoint de découverte (`.well-known/openid-configuration`).
    - [x] Gérer le flux `Authorization Code` (avec PKCE).
    - [x] Générer et valider les Access Tokens et ID Tokens (JWT).
    - [x] Implémenter les endpoints `JWKS`, `Token`, et `Userinfo`.

## 📌 Phase 6 : Sécurité Avancée (MFA) ✅
**Objectif :** Sécuriser les comptes avec plusieurs facteurs.

- [x] **lyxal_mfa :**
    - [x] Implémenter le support TOTP (Google Authenticator).
    - [x] Gérer les codes de secours (Backup Codes).
    - [x] Intégrer WebAuthn pour le support des Passkeys.

## 📌 Phase 7 : Écosystème et Connecteurs ✅
**Objectif :** Ouvrir le système aux tiers.

- [x] **lyxal_connectors :**
    - [x] Définir les traits Rust pour les connecteurs génériques.
    - [x] Implémenter un connecteur Email (SMTP).
    - [x] Implémenter un connecteur SMS (Twilio/Generic).
    - [x] Implémenter les connecteurs Social Login (GitHub, Google) via OAuth2 Client.

## 📌 Phase 8 : API de Management et Dashboard ✅
**Objectif :** Interface d\'administration.

- [x] Créer une API REST complète pour administrer le serveur.
- [x] Générer la documentation OpenAPI/Swagger.
- [x] Préparer l\'intégration avec un frontend (React/Next.js).

---

## 🛠 Méthodologie de Travail
1.  **Approche "Spec-First" :** Toujours définir les types et les traits dans `lyxal_schema` et `lyxal_core` avant d'implémenter la logique.
2.  **Tests Unitaires :** Chaque nouveau service doit avoir ses tests associés.
3.  **Documentation :** Utiliser `cargo doc` pour maintenir une documentation technique à jour.
4.  **Performance :** Utiliser massivement l'asynchronisme de Rust (`tokio`) pour gérer les fortes charges.