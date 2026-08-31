# 📅 Lyxal Booking — Moteur de Réservation & Prise de Rendez-vous

> **Version** : `v1.0.0` (Lyxal OS Native)  
> **Statut** : Architecture Native SurrealDB & Services Rust Typés  
> **Licence** : AGPL-3.0  
> **Philosophie** : Gestion d'agendas, synchronisation CalDAV/Google, réservation d'équipe (Round-Robin), gestion multi-tenant et visio-conférence 100% intégrée à SurrealDB et au frontend Workspace React.

---

## 🏛️ 1. Architecture Finale

Lyxal Booking respecte strictement la séparation tripartite Lyxal OS :

```text
lyxal_booking/
├── access/        👉 Règles de sécurité et permissions SurrealDB (DEFINE ACCESS)
├── api/           👉 Endpoints API natifs SurrealDB (DEFINE API)
├── error/         👉 Master data des erreurs structurées par domaines (DEFINE TABLE error_definition)
├── functions/     👉 Primitives et fonctions métier SurrealQL (209 fichiers .surql)
├── schema/        👉 Schémas stricts des 13 tables SurrealDB (DEFINE TABLE, DEFINE FIELD, DEFINE INDEX)
├── seeds/         👉 Données de démonstration et fixtures d'initialisation
│
├── engine/        👉 Moteur Backend Rust (Axum, Transport SurrealDB WS/Mem, Workers)
│   ├── src/
│   │   ├── auth.rs           👉 Authentification locale & SSO OIDC
│   │   ├── contracts/        👉 DTOs typés sérialisables partagés
│   │   ├── models/           👉 Modèles de domaine typés
│   │   ├── services/         👉 Logique d'orchestration 100% typée via XxxParams
│   │   └── web/              👉 Handlers Axum v1, CSP, Avatars, Middleware
│   └── tests/                👉 Suite de tests d'intégration avec TestHarness SurrealDB
│
└── workspace/     👉 Application Frontend & SDK TypeScript
    ├── sdk/       👉 Client HTTP universel et modules d'API typés
    └── src/       👉 Interface utilisateur React / TailwindCSS
```

---

## 📋 2. Prérequis Système

* **Rust** : `1.78+` (avec `cargo`)
* **Node.js** : `v18+` ou `v20+` (avec `npm`)
* **SurrealDB** : `2.0+` (embarqué via `mem://` pour les tests, ou distant `ws://` / `wss://` en production)

---

## ⚙️ 3. Configuration & Variables d'Environnement

L'ensemble de la configuration est lu via des variables d'environnement standard :

| Variable | Description | Valeur par défaut |
| :--- | :--- | :--- |
| `SURREAL_ENDPOINT` | Endpoint de connexion SurrealDB (`ws://`, `wss://`, `mem://`) | `ws://127.0.0.1:8000` |
| `SURREAL_USER` | Identifiant d'authentification Root SurrealDB | `root` |
| `SURREAL_PASS` | Mot de passe Root SurrealDB | `root` |
| `SURREAL_NS` | Namespace SurrealDB cible | `lyxal` |
| `SURREAL_DB` | Base de données SurrealDB cible | `booking` |
| `LYXAL_BOOKING_PORT` | Port d'écoute du serveur HTTP Axum | `3000` |
| `LYXAL_BOOKING_BASE_URL` | URL de base publique du service | `http://localhost:3000` |
| `LYXAL_CRYPTO_KEY` | Clé maîtresse AES-256-GCM pour le chiffrement des secrets | *(obligatoire en prod)* |
| `LYXAL_BOOKING_ALLOW_PRIVATE_HOSTS`| Autorisation des résolveurs IP privés (tests/dev) | `false` |

---

## 🚀 4. Procédure de Démarrage

### 4.1. Lancement du Serveur Backend (Rust)
```bash
cd engine
cargo run --release
```

### 4.2. Lancement du Frontend Workspace (Dev Server)
```bash
cd workspace
npm install
npm run dev
```

---

## 🔨 5. Procédure de Build & Validation

### 5.1. Build Backend Rust
```bash
cd engine
cargo build --release
```

### 5.2. Build & Typecheck Frontend Workspace
```bash
cd workspace
npm run typecheck
npm run build
```

---

## 🧪 6. Tests & Validation Automatisée

### 6.1. Tests Unitaires Rust
```bash
cd engine
cargo test --lib
```

### 6.2. Validation d'Importation SurrealQL
Valide le parsing et le chargement intégral des 209 fichiers `.surql` :
```bash
cd engine
cargo test --test surreal_import_validation
```

### 6.3. Tests d'Intégration via `TestHarness`
Exécute la suite de tests fonctionnels avec isolation in-memory par test :
```bash
cd engine
cargo test --test harness_sanity_test
cargo test --test auth_integration
cargo test --test event_types_integration
cargo test --test bookings_tokens_integration
cargo test --test availability_integration
cargo test --test resources_integration
cargo test --test teams_admin_integration
```

---

## 🔄 7. Compatibilité Legacy Volontaire

Dans le cadre de la release `v1.0.0`, les mécanismes suivants sont volontairement maintenus :
1. **Redirections HTTP 303** ([engine/src/web/api/v1/compatibility_redirects.rs](file:///c:/Users/HP/Desktop/Lyxal_OS/lyxal_booking/engine/src/web/api/v1/compatibility_redirects.rs)) : Assure la redirection transparente des liens d'invitation et d'annulation contenus dans les e-mails historiques vers les routes React du Workspace.
2. **Support de déchiffrement de transition** (`legacy_secret_key`) : Permet le déchiffrement et la migration à la volée des anciens ciphertexts vers le format scellé `enc:v1:` via `lyxal_crypto`.

---

## 📦 8. Politique de Versionnement & Stabilité

* **Version Actuelle** : `1.0.0`
* **Garantie de non-rupture (SemVer)** :
  * `v1.x` : Rétro-compatibilité stricte de l'ensemble des APIs REST `/api/v1` et des primitives SurrealQL `fn::booking_*`.
  * `v2.0` : Éventuelle dépréciation des redirections legacy 303 après période de grâce.
