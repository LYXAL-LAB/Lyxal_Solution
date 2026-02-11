# Architecture Technique - LyxalAck

## 1. Engine Layer (Rust)
Le cœur du système repose sur une extension du fork de SurrealDB v3.0.0-beta.1.

### Modifications du Core
- **Module `crypto::ed25519` :** Ajout de primitives Rust pour `sign` et `verify`.
- **Module `http::async` :** Capacité de streaming hash pour vérifier l'intégrité de documents distants sans stockage temporaire.

## 2. Governance Layer (SurrealQL)
La logique métier est portée par la base de données elle-même (Backendless logic).

### Modèle Graphe
- `user` (Record)
- `document` (Record)
- `signed` (Edge) : `RELATE user->signed->document SET proof = ...`
- `expects` (Edge) : `RELATE document->expects->user`

### Sécurité
- **Scopes :** Authentification via `DEFINE SCOPE ack_signer`.
- **Permissions :** `DEFINE TABLE signed PERMISSIONS FOR create WHERE $auth.id = in`.

## 3. UI Layer (Surrealist-Lite)
L'interface est un fork de Surrealist optimisé pour la consommation.

- **Communication :** WebSocket RPC natif.
- **Sandboxing :** L'utilisateur est restreint par son Scope, rendant l'interface inoffensive et focalisée sur l'acte de signature.

