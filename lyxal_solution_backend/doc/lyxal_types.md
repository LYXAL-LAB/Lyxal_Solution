# lyxal_types

## Rôle
Workspace de **types partagés** pour Lyxal Solution.  
Regroupe tous les crates de définition de types utilisés par les différents composants du backend.

## Sous-crates

### lyxal-types
**Types primitifs de la base de données.**

Contient les structures Rust (`LyxalValue`, `Array`, `RecordId`, `Regex`, etc.) utilisées par le parseur et l'évaluateur SQL du moteur Lyxal DB. C'est le fork des types originaux Lyxal, entièrement rebrandé.

- **Chemin** : `lyxal_types/lyxal-types/`
- **Destiné à** : Le moteur DB (`lyxal_db`), le futur crate `lyxal_function`
- **Dépendances clés** : `serde`, `chrono`, `rust_decimal`, `uuid`, `geo`, `lyxal-protocol` (feature flatbuffers)

### lyxal-types_derive
**Macros procédurales pour lyxal-types.**

Fournit les `#[derive(...)]` macros pour générer automatiquement des implémentations de traits sur les types DB.

- **Chemin** : `lyxal_types/lyxal-types/derive/`
- **Destiné à** : Utilisé uniquement par `lyxal-types`
- **Dépendances clés** : `syn`, `quote`, `proc-macro2`

### lyxal_types_proxy
**Types IPC pour la communication avec Lyxal Proxy.**

Contient les structures Rust générées depuis le Protobuf de Lyxal Proxy (`command.proto`). Définit les commandes réseau : `Request`, `Response`, `WorkerRequest`, `AddBackend`, `RequestHttpFrontend`, `SocketAddress`, `Cluster`, etc.

- **Chemin** : `lyxal_types/lyxal_types_proxy/`
- **Destiné à** : Le futur crate `lyxal_function` (pour forger des commandes), `lyxal_proxy` (pour les recevoir)
- **Dépendances clés** : `prost`, `serde`
- **Fichier clé** : `src/command.rs` — Code statique généré depuis `lyxal_proxy/command/src/command.proto`

### lyxal_types_lism
**Marshalling des arguments de fonction pour Lyxal DB.**

Anciennement "Lyxal_lism", ce crate gère le transfert et l'interprétation des arguments (marshalling) pour l'exécution des fonctions externes. Il permet d'éviter l'implémentation du trait `Serializable` sur chaque type individuel de la DB.

- **Chemin** : `lyxal_types/lyxal_types_lism/`
- **Destiné à** : L'évaluateur de fonctions du moteur (`lyxal_db`) et les plugins/fonctions WASM ou natives (`lyxal_function`).
- **Dépendances clés** : `lyxal-protocol` (pour la sérialisation des arguments via FlatBuffers).

### lyxal_macros_lism
**Macros pour lyxal_types_lism.**

Fournit les macros procédurales utilisées par le crate LISM pour simplifier la déclaration des arguments de fonction.

- **Chemin** : `lyxal_macros/lyxal_macros_lism/`
- **Destiné à** : Utilisé uniquement par `lyxal_types_lism`.


## Architecture des dépendances

```
lyxal-types ──────► lyxal-protocol (flatbuffers)
lyxal_types_proxy ───► lyxal_proxy (command.proto)

         ┌─────────────────┐
         │ lyxal_function   │  (futur)
         │  (Le Pont)       │
         └──┬──────────┬───┘
            │          │
            ▼          ▼
   lyxal-types   lyxal_types_proxy
```
