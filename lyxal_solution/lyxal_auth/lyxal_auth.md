# Lyxal Auth : Architecture Unifiée (IAM & Vault)

## 1. Vision et Concept
**Lyxal Auth** est le pilier central de sécurité de la Lyxal Solution. Il fusionne la gestion des identités (**IAM**) et la protection des secrets (**Vault**) pour créer un **Native Identity Provider (IdP)** directement intégré au moteur de base de données. 

L'objectif est de supprimer la dépendance à des services tiers (comme Logto ou Auth0) en offrant une plateforme d'authentification "BaaS" (Backend-as-a-Service) ultra-rapide en Rust, capable de gérer aussi bien la sécurité granulaire des données que l'identité utilisateur complète.

## 2. Structure du Module
L'implémentation est centralisée dans `surrealdb/core/src/lyxal_auth/`.

### A. Lyxal IAM (Identity & Access Management)
Le "Cerveau" qui décide qui peut faire quoi, agissant comme un Logto natif.
- **Identity Provider (IdP)** : Gestion native des flux OAuth2, OIDC et Social Login (Google, GitHub, etc.) via le Lyxal Bridge.
- **User Management** : Inscription (Signup), Connexion (Signin) et MFA (Multi-Factor Authentication) intégrés sans latence réseau.
- **Roles & Permissions** : Définition de rôles granulaires (Admin, Service Account, Bridge Runner, Dav User).
- **Session Management** : Gestion des sessions actives et des cycles de vie des jetons (JWT, Macaroons).
- **Policy Engine** : Moteur de règles permettant de définir des accès conditionnels (ex: "Le Bridge ne peut accéder à l'API Slack que le lundi").

### B. Lyxal Vault (Secrets Management)
Le "Coffre-fort" qui protège les actifs sensibles.
- **Encrypted Storage** : Stockage des secrets (Clés API, mots de passe, certificats) chiffrés au repos via AES-256-GCM.
- **Crypto Engine** : Gestion des clés de chiffrement et intégration possible avec des HSM/KMS externes.
- **Secret Rotation** : Automatisation du renouvellement des identifiants (OAuth2 Refresh, rotation de mots de passe).

## 3. Architecture Technique (Dossiers)
```text
lyxal_auth/
├── mod.rs           # Point d'entrée et orchestration IAM/Vault
├── iam/             # Module Identité
│   ├── mod.rs
│   ├── roles.rs     # Logique des rôles et hiérarchies
│   ├── session.rs   # JWT, Sessions et Tokens
│   └── policy.rs    # Moteur de règles d'accès
└── vault/           # Module Secrets
    ├── mod.rs
    ├── crypto.rs    # Primitives de chiffrement
    └── storage.rs   # Adaptateurs de persistance (Local, Cloud, RAM)
```

## 4. Flux d'Interaction Type
1. **Identification** : Un module (ex: `lyxal_bridge`) s'identifie auprès de `lyxal_auth::iam`.
2. **Autorisation** : L'IAM vérifie la `Policy` associée au module pour l'action demandée.
3. **Accès au Secret** : Si autorisé, l'IAM demande au `lyxal_auth::vault` de déchiffrer le secret nécessaire.
4. **Usage Éphémère** : Le secret est transmis au Bridge pour usage immédiat, puis effacé de la mémoire.

## 5. Capacités Avancées

| Fonctionnalité | Description |
| :--- | :--- |
| **Native Identity** | Remplace Logto/Auth0 par une gestion d'identité "In-Database" (latence < 1ms). |
| **Social Auth** | Intégration native des flux Social Login via le catalogue Lyxal Bridge. |
| **Multi-Tenancy** | Isolation stricte des secrets et des identités par Namespace ou Tenant. |
| **Audit Trail** | Journalisation immuable de chaque demande d'autorisation ou accès à un secret. |
| **Emergency Seal** | Capacité de verrouiller instantanément le Vault en cas de détection d'intrusion. |
| **Dynamic Credentials** | Génération de jetons à usage unique pour des tâches spécifiques du Scheduler. |

## 6. Synergie avec l'Écosystème Lyxal
- **Lyxal Bridge** : Utilise `Auth` pour récupérer les clés API sans jamais les manipuler en clair.
- **Lyxal Scheduler** : Utilise `Auth` pour exécuter des tâches en arrière-plan avec des privilèges restreints.
- **Lyxal Dav** : Utilise `Auth` pour l'authentification des utilisateurs sur le système de fichiers et la connexion aux Clouds tiers.
- **Lyxal SDK** : Fournit les interfaces pour administrer le Vault et l'IAM de manière sécurisée.

---
*Ce document fait partie de la documentation technique de Lyxal Solution.*