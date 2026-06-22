# lyxal_lism

## Rôle
Crate interne agissant comme **moteur d'exécution d'extensions** et chargeur de modules WASM (WebAssembly) pour Lyxal Solution. 
Il permet d'étendre les capacités de la base de données en exécutant des fonctions personnalisées écrites en Rust (ou d'autres langages compilables en WASM), qui sont packagées sous le format propriétaire `.lyxli`.

## Ce qu'il contient
- **Format `.lyxli`** — Outils pour packager et charger les extensions binaires.
- **Runtime WASM (`runtime/`)** — L'environnement bac à sable (sandbox) basé sur Wasmtime ou Wasmer pour exécuter les fonctions en toute sécurité.
- **Marshalling IPC (`imports.rs`, `args.rs`)** — Système ultra-rapide basé sur FlatBuffers pour transférer les valeurs (`LyxalValue`) de la mémoire Rust hôte vers la mémoire (heap) WASM du plugin et vice-versa sans sérialisation lourde JSON.
- **Demo (`demo/`)** — Exemple de plugin WASM compilable.

## Destiné à
Consommé par le cœur de la base :
- `lyxal_db` — Le moteur base de données utilise `lyxal_lism` pour charger les plugins définis en SQL (`DEFINE MODULE`) et exécuter leurs fonctions (ex: `fn::ma_fonction(1, 2)`).
- `lyxal_function` — Point d'ancrage futur pour les fonctions réseau ou IPC spécifiques qui nécessitent d'être enregistrées dynamiquement.

## Architecture & Découplage
Le renommage de "Lyxal_lism" en "LISM" et son packaging `.lyxli` sécurise la propriété intellectuelle de l'écosystème. L'exécution WASM isole les plugins, empêchant un module d'extension tiers de faire crasher le moteur SQL principal, tout en garantissant des performances quasi-natives grâce aux `MemoryController` spécialisés.

## Dépendances clés
- `wasmtime` / `wasmtime-wasi` — Moteur WASM sous-jacent.
- `lyxal-types`, `lyxal_types_lism` — Partage des définitions mémoire (RecordId, Value).
