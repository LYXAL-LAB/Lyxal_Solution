# lyxal_types_proxy

Types partagés pour la communication IPC entre **Lyxal DB** et **Lyxal Proxy**.

Ce crate contient les structures Rust générées à partir du fichier Protobuf `command.proto` du proxy Lyxal. Il sert de contrat d'interface entre la base de données et le proxy.

## Structure

```
src/
├── lib.rs        # Point d'entrée, exporte le module command
└── command.rs    # Structures Protobuf générées (Request, Response, etc.)
```

## Types principaux

| Type | Description |
|------|-------------|
| `Request` | Message envoyé au proxy (ajout frontend, backend, certificat, etc.) |
| `Response` | Réponse du proxy (statut, contenu) |
| `WorkerRequest` | Requête interne entre processus proxy |
| `WorkerResponse` | Réponse interne entre processus proxy |
| `RequestHttpFrontend` | Définition d'un frontend HTTP/HTTPS |
| `AddBackend` | Ajout d'un backend à un cluster |
| `Cluster` | Configuration d'un cluster de routage |
| `SocketAddress` | Adresse réseau (IP + port) |

## Régénérer les types (si le protocole change)

Le fichier `src/command.rs` est un **fichier statique** généré depuis le Protobuf. Si le protocole du proxy Lyxal est modifié (`lyxal_proxy/command/src/command.proto`), il faut régénérer ce fichier.

### Prérequis

1. Installer le compilateur Protobuf (`protoc`) :
   - Télécharger depuis https://github.com/protocolbuffers/protobuf/releases
   - Ajouter le dossier `bin/` au PATH système, ou définir la variable `PROTOC`

### Étapes de régénération

1. Ajouter temporairement `prost-build` dans `Cargo.toml` :
   ```toml
   [build-dependencies]
   prost-build = "0.13.3"
   ```

2. Créer un fichier `build.rs` à la racine du crate :
   ```rust
   fn main() {
       let mut config = prost_build::Config::new();
       config.out_dir("src/");
       config.type_attribute(".", "#[derive(serde::Serialize, serde::Deserialize)]");
       config.compile_protos(
           &["../../lyxal_proxy/command/src/command.proto"],
           &["../../lyxal_proxy/command/src/"],
       ).expect("Failed to compile Protobuf definitions");
   }
   ```

3. Compiler le crate :
   ```powershell
   $env:PROTOC="C:\chemin\vers\protoc.exe"
   cargo build
   ```

4. Vérifier que `src/command.rs` a été mis à jour.

5. **Supprimer** le fichier `build.rs` et retirer `prost-build` du `Cargo.toml`.

6. Commit le nouveau `src/command.rs`.
