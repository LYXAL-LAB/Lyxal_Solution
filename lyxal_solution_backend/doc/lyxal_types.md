# lyxal_types

## Rôle
Workspace de **types partagés** pour Lyxal Solution.  
Regroupe tous les crates de définition de types utilisés par les différents composants du backend.

## Sous-crates

### lyxal_types_db
**Types primitifs de la base de données.**

Contient les structures Rust (`LyxalValue`, `Array`, `RecordId`, `Regex`, etc.) utilisées par le parseur et l'évaluateur SQL du moteur Lyxal DB. C'est le fork des types originaux SurrealDB, entièrement rebrandé.

- **Chemin** : `lyxal_types/lyxal_types_db/`
- **Destiné à** : Le moteur DB (`lyxal_db`), le futur crate `lyxal_function`
- **Dépendances clés** : `serde`, `chrono`, `rust_decimal`, `uuid`, `geo`, `lyxal_protocol` (feature flatbuffers)

### lyxal_types_db_derive
**Macros procédurales pour lyxal_types_db.**

Fournit les `#[derive(...)]` macros pour générer automatiquement des implémentations de traits sur les types DB.

- **Chemin** : `lyxal_types/lyxal_types_db/derive/`
- **Destiné à** : Utilisé uniquement par `lyxal_types_db`
- **Dépendances clés** : `syn`, `quote`, `proc-macro2`

### lyxal_types_proxy
**Types IPC pour la communication avec Lyxal Proxy.**

Contient les structures Rust générées depuis le Protobuf de Lyxal Proxy (`command.proto`). Définit les commandes réseau : `Request`, `Response`, `WorkerRequest`, `AddBackend`, `RequestHttpFrontend`, `SocketAddress`, `Cluster`, etc.

- **Chemin** : `lyxal_types/lyxal_types_proxy/`
- **Destiné à** : Le futur crate `lyxal_function` (pour forger des commandes), `lyxal_proxy` (pour les recevoir)
- **Dépendances clés** : `prost`, `serde`
- **Fichier clé** : `src/command.rs` — Code statique généré depuis `lyxal_proxy/command/src/command.proto`

## Architecture des dépendances

```
lyxal_types_db ──────► lyxal_protocol (flatbuffers)
lyxal_types_proxy ───► lyxal_proxy (command.proto)

         ┌─────────────────┐
         │ lyxal_function   │  (futur)
         │  (Le Pont)       │
         └──┬──────────┬───┘
            │          │
            ▼          ▼
   lyxal_types_db   lyxal_types_proxy
```
