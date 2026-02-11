# 🆔 Lyxal Identity (Module)

**Le Pilier de la Sécurité et de l'Identité Unifiée.**

## 🎯 Vision
`Lyxal_Identity` n'est pas juste un système de login. C'est un **Identity Provider (IdP)** complet et souverain.
Contrairement aux systèmes classiques où un user appartient à une app, ici **l'User est au centre**. Il possède son identité et "visite" des Apps/Tenants.

## 🏗 Architecture
Ce module est construit pour être "Headless" mais fournit aussi les composants UI (Login Box) via des SDKs.

### Composants Clés
1.  **Core Engine (API)** : Gère l'inscription, le login, le MFA, les sessions, et les tokens JWT.
2.  **Universal Login Box** : Une interface de connexion unique pour tout l'écosystème Lyxal.
3.  **Tenant Linker** : Le composant qui fait le pont entre "Qui je suis" (User) et "Où je vais" (Tenant/Workspace).

## 📚 Inspirations & Références
Nous ne réinventons pas la cryptographie. Nous nous inspirons des meilleurs standards :
*   **Auth0** : Pour l'architecture "Universal Login" et la gestion des règles (Actions).
*   **Clerk** : Pour l'expérience développeur (DX) et la facilité d'intégration Frontend.
*   **Ory Kratos** : Pour la robustesse des flux (Self-service flows) et la sécurité Open Source.

## 🛠 Stack Technique
*   **Langage** : TypeScript (Bun).
*   **Database** : SurrealDB (Namespace `LYXAL_IDENTITY`).
*   **Protocole** : OAuth 2.1 / OIDC.

