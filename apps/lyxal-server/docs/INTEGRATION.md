# Intégration dans le workspace Lyxal OS

## 1. Copier le dossier

```text
lyxal-os/
└── apps/
    └── lyxal-server/
```

## 2. Déclarer le membre

Dans le `Cargo.toml` racine :

```toml
[workspace]
resolver = "3"
members = [
    "apps/lyxal-server",
    "crates/*",
]
```

## 3. Dépendances minimales du workspace

```toml
[workspace.package]
version = "0.1.0"
edition = "2024"
license = "AGPL-3.0-or-later"
rust-version = "1.85"

[workspace.dependencies]
anyhow = "1"
async-trait = "0.1"
axum = "0.8"
chrono = { version = "0.4", features = ["serde"] }
config = "0.15"
http = "1"
serde = { version = "1", features = ["derive"] }
serde_json = "1"
surrealdb = { version = "3.2", default-features = false }
thiserror = "2"
tokio = { version = "1", features = ["full"] }
tower = { version = "0.5", features = ["limit", "util"] }
tower-http = { version = "0.7", features = [
    "catch-panic",
    "cors",
    "limit",
    "timeout",
    "trace",
] }
tracing = "0.1"
tracing-subscriber = { version = "0.3", features = ["env-filter", "json"] }
uuid = { version = "1", features = ["serde", "v4"] }
tempfile = "3"
```

## 4. Raccordement au futur lyxal-runtime

Le trait temporaire `src/modules/contract.rs` est volontairement isolé. Quand
`lyxal-runtime` exposera le contrat définitif :

1. déplacer `ModuleId`, `ModuleDescriptor`, `ModuleState`, `ModuleContext`,
   `ModuleMigration` et `LyxalModule` dans `lyxal-runtime` ;
2. remplacer les imports dans `lyxal-server` ;
3. supprimer le contrat local ;
4. conserver l'orchestration et les handlers.

## 5. Ajouter un module

Dans `src/modules/mod.rs`, enregistrer une instance compilée :

```rust
#[cfg(feature = "module-timezone")]
modules.push(Arc::new(lyxal_timezone::TimezoneModule::new()));
```

Puis ajouter la dépendance optionnelle au `Cargo.toml`.
