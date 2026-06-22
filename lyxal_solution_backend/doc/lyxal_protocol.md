# lyxal-protocol

## Rôle
Crate interne de **sérialisation** pour Lyxal Solution.  
Définit le format binaire (Protobuf, FlatBuffers) et les services gRPC utilisés pour la communication entre les composants internes du backend.

## Ce qu'il contient
- **Schemas Protobuf** (`lyxal/protocol/v1/*.proto`) — Définitions des types `Value`, `Expression`, `RecordId`, etc.
- **Schemas FlatBuffers** (`lyxal/protocol/v1/*.fbs`) — Sérialisation zero-copy haute performance
- **Service gRPC** (`lyxal/protocol/rpc/v1/rpc.proto`) — Interface RPC pour les requêtes DB (Query, Authenticate, LiveQuery, etc.)
- **Code Rust généré** (`gen/rust/`) — Structures Rust compilées depuis les schemas
- **Code Rust source** (`rust/`) — Conversions, méthodes utilitaires et traits (`TryFromValue`, `TryIntoValue`)

## Destiné à
Consommé **uniquement** par les autres crates internes du backend Lyxal :
- `lyxal-types` — qui importe les types FlatBuffers pour la sérialisation des valeurs
- Le futur moteur DB — qui utilisera le service gRPC pour les appels réseau internes

> **Ce n'est PAS un SDK client.** Ce crate n'est pas publié ni destiné à des développeurs externes.

## Dépendances clés
| Dépendance | Usage |
|------------|-------|
| `prost` | Sérialisation/désérialisation Protobuf |
| `prost-types` | Types standards Protobuf (Timestamp, Duration) |
| `flatbuffers` | Sérialisation zero-copy |
| `tonic` | Framework gRPC (feature `rpc`) |
| `serde` | Sérialisation JSON des types proto |

## Régénération du code
Si les schemas `.proto` ou `.fbs` sont modifiés, voir les instructions dans le `README.md` du crate.
Outils requis : `protoc`, `flatc`.
