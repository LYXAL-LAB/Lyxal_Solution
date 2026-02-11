# D10 — Mapping SurrealDB & Native DAV

Ce document accompagne l'implémentation du code natif DAV (crates/core/src/fnc/dav).
Il liste les points d'intégration et les limitations actuelles.

## 1. Code Implémenté (D10.1 - D10.3)
Le code suivant a été intégré dans le core SurrealDB :

- **`crates/core/src/fnc/dav/`** : Module contenant les signatures natives.
- **Types** (`types.rs`) : `DavResource`, `DavPrincipal`, `DavShare`, `DavLock`.
- **Context** (`context.rs`) : `DavExecutionContext`.
- **Fonctions** :
  - `dav::get(path)`
  - `dav::put(path, content, headers)`
  - `dav::delete(path)`
  - `dav::list(path, depth)`
  - `dav::move(src, dst, overwrite)`
  - `dav::copy(src, dst, overwrite)`
  - `dav::lock(path, ...)`
  - `dav::unlock(path, token)`
  - `dav::sync(path, token, limit)`

## 2. Intégration dans le Moteur
Les fonctions sont enregistrées dans `crates/core/src/fnc/mod.rs` via le mécanisme de dispatch natif.
Elles sont accessibles via SurrealQL comme `dav::get("/dav/tenant/path")`.

## 3. Mapping Surreal & Limitations (D10.4)

### Points de Blocage Actuels
1.  **Accès Transactionnel** :
    Les fonctions natives actuelles reçoivent `&Context`, mais l'accès direct aux KVS (Key-Value Store) pour une transaction en cours n'est pas trivialement exposé aux fonctions `fnc`.
    *Solution future* : Passer un `Transaction` handle via le `Context` ou utiliser les méthodes internes `ctx.tx()`.

2.  **Blob Storage** :
    Les contenus de fichiers (`content`) sont passés en `Value::Bytes` ou `Value::String`. Pour les gros fichiers, cela charge tout en mémoire.
    *Besoin* : Un type `Value::Blob` streamable ou une gestion optimisée des `Bytes`.

3.  **Hooks Synchrones** :
    Pour `dav::put` et `dav::delete`, nous devons garantir que l'insertion dans `_changes` (pour le sync-token) est atomique avec la modification de la ressource.
    *Status* : Possible via transaction SurrealDB standard, mais l'implémentation native Rust doit orchestrer ces multiples écritures.

### Mapping Tables (Proposé)
- `dav_resources` : Table générique stockant `DavResource`.
- `dav_changes` : Table append-only pour `dav::sync`.
- `dav_locks` : Table avec TTL pour `dav::lock`.

## 4. Prochaines Étapes
1.  **Implémenter le corps des fonctions** : Connecter `dav::get` etc. au KVS interne de SurrealDB.
2.  **Exposer en JS** : Si nécessaire, ajouter le mapping dans `script/modules/surrealdb`.
3.  **Tests d'Intégration** : Créer des tests Rust appelant `dav::*` via l'engine SQL.

