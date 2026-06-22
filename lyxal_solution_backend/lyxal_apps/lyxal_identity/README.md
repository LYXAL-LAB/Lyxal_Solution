# Lyxal Identity

IdP (Identity Provider) modulaire haute performance écrit en Rust, offrant une parité fonctionnelle 1:1 avec le backend de **Logto**.

## 🚀 État du Projet
- **Backend Core** : ✅ 100% Terminé
- **Protocoles OIDC/OAuth2** : ✅ 100% Terminé
- **Sécurité (MFA/Passkeys)** : ✅ 100% Terminé
- **Connecteurs** : ✅ 100% Opérationnels (Sans Mocks)

## 🏗 Architecture
Workspace Cargo composé de crates spécialisées :
- `lyxal_core`: Noyau, Database (SQLx/PostgreSQL), Crypto.
- `lyxal_auth`: Logique d'authentification.
- `lyxal_oauth`: Implémentation standard OIDC.
- `lyxal_iam`: Gestion des identités et des organisations (B2B).
- `lyxal_connectors`: Écosystème d'intégrations tierces.

## 📄 Documentation
- [Rapport de Conformité Logto](./AUDIT_CONFORMITE_LOGTO.md)
- [Feuille de Route](./ROADMAP.md)

## 🛠 Démarrage
1. Configurer le `.env`.
2. `cargo run` (Migrations automatiques incluses).
