# lyxal-protocol

Protocole réseau de **Lyxal DB** — définitions Protobuf, FlatBuffers et gRPC utilisées pour la communication client-serveur.

## Vue d'ensemble

Ce crate fournit les structures de sérialisation partagées entre le serveur Lyxal DB et ses clients. Il supporte trois formats de transport :

| Format | Feature Cargo | Usage |
|--------|--------------|-------|
| **Protobuf** | `proto` | Sérialisation des valeurs et expressions |
| **FlatBuffers** | `flatbuffers` | Sérialisation binaire haute performance (zero-copy) |
| **gRPC (tonic)** | `rpc` | Service RPC pour les requêtes client-serveur |

## Structure

```
lyxal-protocol/
├── Cargo.toml
├── rust/                          # Code source Rust
│   ├── lib.rs                     # Point d'entrée du crate
│   ├── convert.rs                 # Conversions TryFromValue / TryIntoValue
│   ├── methods.rs                 # Méthodes du protocole
│   └── rpc_methods.rs             # Méthodes RPC (feature "rpc")
├── lyxal/protocol/                # Définitions source des schemas
│   ├── v1/
│   │   ├── value.proto            # Types de valeurs (Protobuf)
│   │   ├── expr.proto             # Expressions (Protobuf)
│   │   ├── value.fbs              # Types de valeurs (FlatBuffers)
│   │   └── lyxalism.fbs           # Extensions FlatBuffers
│   └── rpc/v1/
│       └── rpc.proto              # Service gRPC
└── gen/rust/                      # Code Rust généré
    ├── proto/                     # Généré depuis les .proto (prost)
    └── fb/                        # Généré depuis les .fbs (flatc)
```

## Utilisation

Dans votre `Cargo.toml` :

```toml
[dependencies]
lyxal-protocol = { path = "../lyxal-protocol" }
# Ou avec des features spécifiques :
lyxal-protocol = { path = "../lyxal-protocol", features = ["flatbuffers"] }
```

## Features

- **`default`** : active `proto`, `flatbuffers` et `rpc`
- **`proto`** : active le support Protobuf (prost)
- **`flatbuffers`** : active le support FlatBuffers (zero-copy)
- **`rpc`** : active le service gRPC (tonic) — requiert `proto`

## Régénérer le code

Si les fichiers `.proto` ou `.fbs` sont modifiés dans `lyxal/protocol/`, il faut régénérer le code dans `gen/rust/`.

### Protobuf (prost)

```bash
# Installer protoc si nécessaire
# https://github.com/protocolbuffers/protobuf/releases

# Utiliser prost-build dans un script de build temporaire
```

### FlatBuffers (flatc)

```bash
# Installer flatc si nécessaire
# https://github.com/google/flatbuffers/releases

flatc --rust -o gen/rust/fb/ lyxal/protocol/v1/value.fbs
```

