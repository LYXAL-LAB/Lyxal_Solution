# lyxal_macros

## Rôle
Workspace centralisateur hébergeant toutes les **Macros Procédurales (Proc-Macros)** utilisées à travers Lyxal Solution. 
Ce dossier regroupe les outils de métaprogrammation Rust permettant de générer automatiquement du code à la compilation (les attributs `#[...]` ou les appels `mac!(...)`), ce qui allège considérablement le code source final.

## Sous-crates
### lyxal_macros_lism
**Générateur de signatures pour LISM (.lyxli).**

Fournit la puissante macro `#[lyxal_lism]` qui permet à un développeur de plugin d'écrire une simple fonction Rust :
```rust
#[lyxal_lism]
fn can_drive(age: i64) -> bool { age >= 18 }
```
La macro va automatiquement générer tout le code (le "glue code" WASM) nécessaire pour que les arguments s'interfacent avec les types `LyxalValue` via `lyxal_types_lism` et que la fonction soit exportée au format attendu par le runtime de la DB.

- **Destiné à** : N'importe quel développeur créant un plugin `.lyxli` (utilisé notamment dans `lyxal_lism/demo`).

## Destiné à
Les différents sous-crates de ce répertoire sont importés par les autres crates du backend (comme `lyxal_db`, `lyxal_types`, `lyxal_lism`) selon les besoins en métaprogrammation.

## Architecture
Une limitation technique du langage Rust exige que les macros procédurales soient définies dans des crates dédiés (avec `proc-macro = true` dans leur `Cargo.toml`). 
Au lieu d'éparpiller ces petits crates partout dans l'arborescence, `lyxal_macros` fait office de monorepo structuré et standardisé pour tous ces générateurs de code.

## Dépendances clés typiques
- `syn` — Pour parser le syntax tree (AST) du code Rust hôte.
- `quote` — Pour générer le nouveau code Rust facilement.
- `proc-macro2` — Manipulation sécurisée des tokens Rust.
