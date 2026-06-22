# Plan de Traçabilité du Fork SurrealDB → Lyxal

> **Base du fork** : SurrealDB 3.0.0-beta.2
> **Date de création** : 2026-04-25
> **Objectif** : Suivre manuellement les releases SurrealDB upstream et savoir exactement quels fichiers sont impactés lors d'un merge.

---

## 1. Cartographie du renommage

Le fork a renommé systématiquement les crates et namespaces SurrealDB en Lyxal.

| SurrealDB upstream | Lyxal fork | Type |
|:---|:---|:---|
| `surrealdb/` (racine SDK) | `lyxal/` | Renommé |
| `surrealdb/core/` | `lyxal/core/` | Renommé |
| `surrealdb/server/` | `lyxal/server/` | Renommé |
| `surrealdb/types/` | `lyxal/types/` | Renommé |
| `surrealkv` | `lyxalkv/` | Renommé |
| `surrealml` | `lyxalml/` | Renommé |
| `surrealism` (WASM) | `lyxalism/` | Renommé |
| `surrealdb-protocol` | `lyxal-protocol/` | Renommé |
| `surrealdb-revision` | `lyxal-revision/` | Renommé |
| N/A | `lyxal_apps/` | **AJOUTÉ** (100% Lyxal) |
| N/A | `lyxal-crates/` | **AJOUTÉ** (100% Lyxal) |
| N/A | `lyxal_rmcp/` | **AJOUTÉ** (100% Lyxal) |
| N/A | `lyxal_types/` (proxy) | **AJOUTÉ** (100% Lyxal) |
| `surrealdb-rocksdb` (dep ext) | `surrealdb-rocksdb` | **Non renommé** (dep externe) |
| `surrealdb-tikv-client` (dep ext) | `surrealdb-tikv-client` | **Non renommé** (dep externe) |

---

## 2. Classification des fichiers

### 🟢 Catégorie A — Fichiers 100% AJOUTÉS par Lyxal (pas dans upstream)

Ces fichiers n'existent **pas** dans SurrealDB. Aucun risque de conflit lors d'un merge.

#### `lyxal_apps/` (crates applicatifs Lyxal)
```
lyxal_apps/
  lyxal-bridge/          ← Moteur de connecteurs API
  lyxal_broker/          ← Message broker
  lyxal_captcha/         ← Service captcha
  lyxal_identity/        ← Gestion identité
  lyxal_proxy/           ← Proxy Sozu
  lyxal_studio/          ← Studio/IDE
  lyxal_utility/         ← Utilitaires
```

#### `lyxal-crates/` (crates internes Lyxal)
```
lyxal-crates/
  lyxal_crates_socket/   ← Communication socket
```

#### `lyxal_types/` (proxy types)
```
lyxal_types/
  lyxal_types_proxy/     ← Proxy de types
```

#### `lyxal_rmcp/` (MCP protocol)
```
lyxal_rmcp/              ← Remote MCP (vide pour l'instant)
```

#### Fichiers ajoutés dans le core
```
lyxal/core/src/function/bridge.rs       ← Fonctions bridge::* natives
lyxal/core/src/function/list.rs         ← Fonctions list::dedupe, aggregate, split_out, diff
lyxal/core/src/lyxalism/                ← Module lyxalism (cache.rs, host.rs)
lyxal/core/src/kvs/lyxalkv/             ← Intégration LyxalKV dans le KVS (cnf.rs, mod.rs, sync.rs)
```

---

### 🟡 Catégorie B — Fichiers MODIFIÉS par rapport à upstream

Ces fichiers existent dans SurrealDB upstream et ont été modifiés. **Ce sont ceux à surveiller lors d'un merge.**

#### `cargo.toml` (workspace root) — ⚡ CRITIQUE
- **Risque de conflit** : ÉLEVÉ (chaque release upstream modifie les dépendances)
- **Modifications Lyxal** :
  - Ajout des workspace members : `lyxal_apps/*`, `lyxalkv`, `lyxalism/*`, `lyxalml/*`, `lyxalmx`, `lyxal-protocol`, `lyxal-revision`
  - Ajout des dépendances internes : `lyxal-bridge`, `lyxalism-*`, `lyxalkv`, etc.
  - Renommage des auteurs/metadata en Lyxal

#### `lyxal/core/src/function/mod.rs` — ⚡ CRITIQUE
- **Risque de conflit** : ÉLEVÉ (chaque ajout de fonction upstream touche ce fichier)
- **Modifications Lyxal** :
  - `pub mod bridge;` (ligne 16) — ajout du module bridge
  - `pub mod list;` (ligne 25) — ajout du module list
  - Dispatch sync : ajout `list::dedupe`, `list::aggregate`, `list::split_out`, `list::diff` (lignes 243-246)
  - Dispatch async : ajout `bridge::call`, `bridge::list`, `bridge::info`, `bridge::health`, `bridge::batch` (lignes 640-644)
  - Fonction `run()` : ajout `name.starts_with("bridge")` dans la liste des fonctions async (ligne 96)

#### `lyxal/core/src/kvs/mod.rs` — ⚠️ MOYEN
- **Risque de conflit** : MOYEN
- **Modifications Lyxal** :
  - Ajout `mod lyxalkv;` (ligne 37) — déclaration du module LyxalKV

#### `lyxal/core/src/lib.rs` — ⚠️ MOYEN
- **Risque de conflit** : MOYEN
- **Modifications Lyxal** :
  - Renommage de `SurrealComposer` en `LyxalComposer`
  - Ajout `pub mod lyxalism;` sous feature flag
  - Renommage des doc URLs vers lyxal

#### `lyxal/Cargo.toml` (SDK) — ⚠️ MOYEN
- **Risque de conflit** : MOYEN
- **Modifications Lyxal** :
  - Renommage du package `surrealdb` → `lyxal`
  - Ajout feature `kv-lyxalkv`
  - Ajout dépendance `lyxal-bridge`

#### `lyxal/core/Cargo.toml` — ⚠️ MOYEN
- **Risque de conflit** : MOYEN
- **Modifications Lyxal** :
  - Renommage du package `surrealdb-core` → `lyxal-core`
  - Ajout feature `kv-lyxalkv`
  - Ajout dépendances `lyxal-bridge`, `lyxalkv`

#### `build.rs` (racine) — ⚠️ FAIBLE
- **Modifications** : Probablement renommage des références

---

### 🔵 Catégorie C — Fichiers RENOMMÉS uniquement

Ces crates sont des copies renommées des crates SurrealDB upstream. Le code interne peut être identique ou quasi-identique.

| Crate upstream | Crate Lyxal | Stratégie merge |
|:---|:---|:---|
| `surrealkv/` | `lyxalkv/` | Diff avec upstream `surrealkv`, appliquer les patches |
| `surrealml/` | `lyxalml/` | Diff avec upstream `surrealml` |
| `surrealism/` | `lyxalism/` | Diff avec upstream `surrealism` |
| `surrealdb-protocol/` | `lyxal-protocol/` | Diff avec upstream |
| `surrealdb-revision/` | `lyxal-revision/` | Diff avec upstream |
| `surrealdb/types/` | `lyxal/types/` | Diff avec upstream |

---

## 3. Procédure de merge d'une nouvelle release SurrealDB

### Étape 1 : Identifier les changements upstream

```bash
# Télécharger la nouvelle release
# Comparer avec la version de base (3.0.0-beta.2)
# Lister les fichiers modifiés dans upstream
```

### Étape 2 : Trier par risque

| Priorité | Fichiers | Action |
|:---:|:---|:---|
| 🔴 1 | `cargo.toml` (workspace) | Merge manuel des dépendances |
| 🔴 2 | `core/src/function/mod.rs` | Merge manuel du dispatch (garder nos ajouts bridge/list) |
| 🟡 3 | `core/src/kvs/mod.rs` | Vérifier que `mod lyxalkv` reste compatible |
| 🟡 4 | `core/src/lib.rs` | Vérifier les nouveaux modules upstream |
| 🟡 5 | `Cargo.toml` (lyxal, lyxal-core) | Merger les nouvelles deps/features |
| 🔵 6 | Crates renommés (lyxalkv, lyxalml, etc.) | Diff et patch |
| ✅ 7 | Fichiers Catégorie A (lyxal_apps, etc.) | Aucun conflit possible |

### Étape 3 : Tests post-merge

```bash
cargo check --workspace
cargo test -p lyxal-core
cargo test -p lyxal-core --features http
```

---

## 4. Tableau récapitulatif des points de contact

```
                    SurrealDB Upstream
                          │
    ┌─────────────────────┼─────────────────────┐
    │                     │                     │
    ▼                     ▼                     ▼
  Cargo.toml         function/mod.rs        kvs/mod.rs
  (deps/members)     (dispatch sync+async)  (storage engines)
    │                     │                     │
    │  ┌──────────────────┤                     │
    │  │                  │                     │
    ▼  ▼                  ▼                     ▼
  lyxal-bridge       bridge.rs  list.rs     lyxalkv/
  (100% Lyxal)       (100% Lyxal)           (fork surrealkv)
                                               │
                    AUCUN CONFLIT            DIFF + PATCH
```

### Fichiers critiques à surveiller (classés par fréquence de modification upstream)

| Fichier | Fréquence de changement upstream | Impact Lyxal |
|:---|:---|:---|
| `cargo.toml` (workspace) | **Chaque release** | Dépendances à merger |
| `core/src/function/mod.rs` | **Fréquent** (ajout de fonctions) | Dispatch à préserver |
| `core/src/kvs/mod.rs` | **Occasionnel** (nouveau storage) | `mod lyxalkv` à garder |
| `core/src/kvs/ds.rs` | **Fréquent** (90KB, logique datastore) | Vérifier si LyxalKV est impacté |
| `core/src/kvs/tx.rs` | **Fréquent** (90KB, transactions) | Idem |
| `core/src/lib.rs` | **Occasionnel** | Modules à préserver |
| `lyxal/Cargo.toml` | **Chaque release** | Features à merger |
| `core/Cargo.toml` | **Chaque release** | Dependencies à merger |

---

## 5. Checklist de merge (à cocher pour chaque release)

```markdown
## Merge SurrealDB vX.Y.Z → Lyxal

### Préparation
- [ ] Télécharger la release SurrealDB vX.Y.Z
- [ ] Lire le changelog upstream
- [ ] Identifier les fichiers modifiés (git diff)

### Merge critique
- [ ] `cargo.toml` — merger les nouvelles dépendances
- [ ] `core/src/function/mod.rs` — garder bridge::* et list::* dans le dispatch
- [ ] `core/src/kvs/mod.rs` — garder `mod lyxalkv`
- [ ] `core/src/lib.rs` — garder `LyxalComposer` et `pub mod lyxalism`

### Merge crates renommés
- [ ] `lyxalkv/` ← diff avec `surrealkv/` upstream
- [ ] `lyxalml/` ← diff avec `surrealml/` upstream  
- [ ] `lyxalism/` ← diff avec `surrealism/` upstream
- [ ] `lyxal-protocol/` ← diff avec `surrealdb-protocol/`
- [ ] `lyxal-revision/` ← diff avec `surrealdb-revision/`

### Validation
- [ ] `cargo check --workspace`
- [ ] `cargo test -p lyxal-core`
- [ ] `cargo test -p lyxal-core --features http`
- [ ] Test fonctionnel bridge::call
- [ ] Test fonctionnel list::*

### Documentation
- [ ] Mettre à jour la version de base dans ce document
- [ ] Noter les conflits rencontrés et leur résolution
```

---

## 6. Historique des merges

| Date | Version upstream | Version Lyxal | Conflits | Notes |
|:---|:---|:---|:---|:---|
| 2026-XX-XX | SurrealDB 3.0.0-beta.2 | Fork initial | N/A | Base du fork |
| | | | | |
