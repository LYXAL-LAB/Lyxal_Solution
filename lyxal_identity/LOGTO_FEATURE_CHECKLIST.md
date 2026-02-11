# 📋 Logto Feature Checklist (Exhaustive) - Lyxal Identity Tracking

Ce document sert de référence absolue pour aligner les fonctionnalités de **Lyxal Identity (Rust)** sur celles de **Logto (TypeScript/Node.js)**. 

---

## 📌 1. Authentification (AuthN)
*Méthodes et flux de connexion des utilisateurs.*

- [x] **Email & Mot de passe** : Inscription et connexion classiques.
- [ ] **Username Login** : Support de l'identifiant textuel unique.
- [ ] **Phone Login** : Connexion via numéro de téléphone.
- [ ] **Passwordless (OTP)** : Envoi de codes par Email ou SMS.
- [ ] **Social Login (OAuth2/OIDC)** : 
    - [x] Moteur de base (Phase 7).
    - [ ] Intégration Google, GitHub, Apple, Microsoft, Discord, Slack.
- [ ] **Enterprise SSO** : 
    - [ ] SAML 2.0.
    - [ ] OpenID Connect (OIDC) Enterprise.
- [ ] **Liaison de comptes (Account Linking)** : Fusionner plusieurs identités (ex: Google + GitHub) sous un même profil.
- [ ] **Récupération de compte** : Flux complet "Mot de passe oublié".

---

## 📌 2. Sécurité & MFA
*Protection des accès et gestion des menaces.*

- [x] **TOTP (Authenticator App)** : Support Google Authenticator, Authy, etc.
- [x] **Backup Codes** : Génération de codes de secours à usage unique.
- [x] **WebAuthn (Passkeys)** : Support de FaceID, TouchID, YubiKey.
- [ ] **MFA Policies** : Configurer le MFA en "Désactivé", "Optionnel" ou "Obligatoire".
- [x] **Gestion des Sessions** :
    - [x] Création et persistance (PostgreSQL).
    - [ ] Liste des sessions actives par utilisateur.
    - [ ] Révocation de session à distance (Sign out from all devices).
- [ ] **Rate Limiting** : Protection contre le brute-force par IP et par compte.
- [ ] **Audit Logs** : Historique complet des événements de sécurité.

---

## 📌 3. Autorisation & IAM
*Gestion des permissions et contrôle d'accès.*

- [x] **Système de Rôles (RBAC)** : Création et gestion des rôles globaux.
- [x] **Permissions (Scopes)** : Définition granulaire des actions.
- [ ] **API Resources** : Enregistrement et protection d'APIs tierces.
- [ ] **JWT Custom Claims** : Injecter des données personnalisées dans les tokens.
- [ ] **Machine-to-Machine (M2M)** : Authentification entre serveurs (Client Credentials).

---

## 📌 4. Organizations (B2B Multi-tenancy)
*Gestion des clients entreprises et isolation des données.*

- [x] **Gestion des Organisations** : CRUD des tenants/organisations.
- [ ] **Organization RBAC** : Rôles spécifiques à une organisation.
- [ ] **Invitation System** : Inviter des membres par email avec rôles prédéfinis.
- [ ] **Organization SSO** : Isoler les méthodes de connexion par organisation.

---

## 📌 5. Expérience Utilisateur (UX)
*Interfaces et personnalisation.*

- [ ] **Hosted Experience** : Pages de login/register par défaut.
- [ ] **Custom Branding** :
    - [ ] Logo & Favicon.
    - [ ] Couleurs primaires/secondaires.
    - [ ] CSS personnalisé.
- [ ] **I18n (Internationalisation)** : Support multi-langue des interfaces.
- [ ] **Custom Domains** : Utiliser `auth.votre-domaine.com`.
- [ ] **User Self-Service** : Dashboard permettant à l'utilisateur de gérer son profil.

---

## 📌 6. Connecteurs & Écosystème
*Intégrations avec les services tiers.*

- [x] **Connecteurs Email** :
    - [x] SMTP (Générique).
    - [ ] AWS SES, SendGrid, Mailgun.
- [x] **Connecteurs SMS** :
    - [x] Twilio.
    - [ ] Vonage, MessageBird.
- [ ] **Webhooks** : Notifications en temps réel (`user.created`, `login.success`).

---

## 📌 7. Administration & Développeurs
*Outils de gestion du système.*

- [ ] **Management Console** : Interface graphique d'administration (Dashboard).
- [x] **Management API** :
    - [x] Endpoints CRUD (Users, Apps, Tenants).
    - [x] Documentation OpenAPI/Swagger intégrée.
- [ ] **CLI (Command Line Interface)** : Outil pour automatiser les tâches.
- [ ] **SDKs Clients** : Bibliothèques pour React, Vue, Next.js, Node.js, Go, Python.

---

## 📊 État d'avancement Global
- **Cœur Rust (Performance/Sécurité)** : 🟢 90%
- **Protocoles (OIDC/OAuth2)** : 🟢 85%
- **Logiciel de Gestion (IAM/RBAC)** : 🟡 60%
- **Interfaces (UI/Dashboard)** : 🔴 0%
```markdown
