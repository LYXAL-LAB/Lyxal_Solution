# Guide : Comment Ajouter une Built-in Function dans Lyxal

> **Objectif :** Ce guide explique **exactement** comment ajouter une nouvelle fonction appelable depuis SurrealQL (ex: `bridge::call()`, `monmodule::mafn()`) dans le fork Lyxal de SurrealDB.  
> **Date :** 2026-03-30  
> **Racine du projet :** `lyxal_solution_backend/lyxal/core/src/`

---

## Table des Matières

1. [Vue d'ensemble — Les 4 fichiers à toucher](#1-vue-densemble)
2. [Étape 1 — Parser (table PATHS)](#étape-1)
3. [Étape 2 — Routeur sync/async](#étape-2)
4. [Étape 3 — Logique métier (function/)](#étape-3)
5. [Étape 4 — Streaming Executor (exec/function/builtin/)](#étape-4)
6. [Checklist récapitulative](#checklist)
7. [Exemple complet : ajout de `bridge::call()`](#exemple-complet)
8. [FAQ](#faq)

---

## 1. Vue d'ensemble

Pour qu'une fonction soit appelable en SurrealQL comme :

```sql
LET $result = bridge::call("slack", "send_message", { channel: "general" });
```

Il faut intervenir sur **4 points de câblage** dans le code :

```
lyxal/core/src/
├── db/syn/parser/builtin.rs          ← [1] Le parser doit CONNAÎTRE le nom
├── function/mod.rs                   ← [2] Le routeur doit DISPATCHER (sync ou async)
├── function/bridge.rs                ← [3] La logique métier EXISTE ici (NOUVEAU)
└── db/exec/function/builtin/
    ├── mod.rs                        ← [4a] Enregistrement dans le registry
    └── bridge.rs                     ← [4b] Définition pour le streaming executor (NOUVEAU)
```

### Pourquoi 4 fichiers ?

| Fichier | Rôle | Analogie |
|:---|:---|:---|
| `builtin.rs` (parser) | Le parser valide que `bridge::call` est un nom de fonction connu | Annuaire téléphonique |
| `function/mod.rs` | Décide si la fn est sync ou async, puis dispatche vers le bon module | Standard téléphonique |
| `function/bridge.rs` | Contient le **vrai code** de la fonction | Le correspondant |
| `exec/function/builtin/bridge.rs` | Version pour le streaming executor (nouveau moteur d'exécution) | Même correspondant, autre ligne |

---

## Étape 1 — Parser (table PATHS) {#étape-1}

### Fichier

```
db/syn/parser/builtin.rs
```

### Quoi faire

Ajouter chaque fonction dans la `phf_map!` statique `PATHS` (ligne ~22). C'est une **table de lookup** compilée à la compilation. Le parser consulte cette table pour valider qu'un identifiant comme `bridge::call` est bien une built-in function.

### Où exactement

La map est triée alphabétiquement par namespace. Chercher la section correspondante ou en créer une nouvelle :

```rust
pub(crate) static PATHS: phf::Map<
    UniCase<&'static str>,
    (PathKind, Option<UniCase<&'static str>>),
> = phf_map! {
    // ... api::* (lignes 26-32)
    // ... array::* (lignes 34-95)
    // ... bytes::* (ligne 97)
    // ...
    // ← INSÉRER ICI (ordre alphabétique, après "array::" et avant "bytes::")
    //    ou après la section qui correspond alphabétiquement
    // ...
};
```

### Syntaxe

```rust
// Fonction normale (nouveau nom)
UniCase::ascii("bridge::call") => (PathKind::Function, None),

// Fonction renommée (l'ancien nom redirige vers le nouveau)
UniCase::ascii("connector::call") => (PathKind::Function, Some(UniCase::ascii("bridge::call"))),

// Constante (pas une fonction, une valeur fixe)
UniCase::ascii("math::PI") => (PathKind::Constant(Constant::MathPi), None),
```

### Paramètres

| Champ | Valeur | Signification |
|:---|:---|:---|
| `PathKind::Function` | C'est une fonction appelable avec `()` | Utilisé pour 99% des cas |
| `PathKind::Constant(...)` | C'est une constante (pas de parenthèses) | Uniquement pour des valeurs comme `math::PI` |
| `None` (2ème param) | Pas de renommage | Nom définitif |
| `Some(UniCase::ascii("nouveau::nom"))` | Ancien nom → nouveau nom | Migration de noms de fonctions |

### ⚠️ Attention — MAX_FUNCTION_NAME_LEN

En bas du fichier (ligne ~513), il y a une constante :

```rust
const MAX_FUNCTION_NAME_LEN: usize = 48;
```

Un test unitaire vérifie que cette constante correspond au nom de fonction le plus long dans `PATHS`. **Si tu ajoutes un nom plus long que 48 caractères**, il faut mettre à jour cette constante. Le test `function_name_constant_up_to_date` échouera sinon.

---

## Étape 2 — Routeur sync/async {#étape-2}

### Fichier

```
function/mod.rs
```

### Quoi faire — Partie A : Déclarer le module

En haut du fichier (lignes 13-43), ajouter le `pub mod` :

```rust
pub mod api;
pub mod args;
pub mod array;
pub mod bridge;  // ← AJOUTER ICI (ordre alphabétique)
pub mod bytes;
// ...
```

### Quoi faire — Partie B : Classifier sync ou async

La fonction `run()` (ligne ~46) décide si une fonction est **synchrone** ou **asynchrone** :

```rust
pub(crate) async fn run(...) -> Result<Value> {
    if name.eq("sleep")
        || name.eq("array::all")
        // ...
        || name.starts_with("api")
        || name.starts_with("http")
        || name.starts_with("bridge")    // ← AJOUTER ICI
        || name.starts_with("search")
        // ...
    {
        stk.run(|stk| asynchronous(stk, ctx, opt, doc, name, args)).await
    } else {
        synchronous(ctx, doc, name, args)
    }
}
```

### Règle de décision : sync ou async ?

| Ta fonction fait... | → | Classification |
|:---|:---|:---|
| Du HTTP (reqwest, réseau) | → | **async** (ajouter dans le `if`) |
| De l'I/O fichier | → | **async** |
| De la crypto lourde | → | **async** (avec `cpu_intensive`) |
| Du calcul pur (math, string...) | → | **sync** (ne rien ajouter) |
| Un accès à la DB (SELECT, etc.) | → | **async** |

### Quoi faire — Partie C : Dispatch async

Si ta fonction est **async**, l'ajouter dans la fonction `asynchronous()` (ligne ~541) avec la macro `dispatch!` :

```rust
pub(crate) async fn asynchronous(...) -> Result<Value> {
    dispatch!(
        ctx, name, args, "no such builtin function found",
        // ...
        // Après les http::* (ligne ~619)
        //
        "bridge::call" => bridge::call((stk, ctx, opt, doc)).await,
        "bridge::list" => bridge::list((stk, ctx, opt, doc)).await,
        "bridge::info" => bridge::info((stk, ctx, opt, doc)).await,
        "bridge::health" => bridge::health(ctx).await,
        "bridge::batch" => bridge::batch((stk, ctx, opt, doc)).await,
        // ...
    )
}
```

### Quoi faire — Partie C (alternative) : Dispatch sync

Si ta fonction est **sync**, l'ajouter dans `synchronous()` (ligne ~148) :

```rust
pub(crate) fn synchronous(...) -> Result<Value> {
    dispatch!(
        ctx, name, args, "no such builtin function found",
        // ...
        "monfn::calcul" => monfn::calcul,
        // ...
    )
}
```

### Syntaxe de la macro dispatch!

```rust
// Fonction sync simple
"math::abs" => math::abs,

// Fonction async simple
"http::get" => http::get(ctx).await,

// Fonction async avec contexte complet (stk, ctx, opt, doc)
"bridge::call" => bridge::call((stk, ctx, opt, doc)).await,

// Fonction CPU-intensive (exécutée sur un thread séparé)
"crypto::argon2::compare" => (cpu_intensive) crypto::argon2::cmp.await,

// Fonction avec feature gate expérimentale
exp(Files) "file::put" => file::put((stk, ctx, opt, doc)).await,
```

### Arguments du contexte

| Argument | Type | Quand le passer |
|:---|:---|:---|
| `ctx` | `&FrozenContext` | Toujours disponible — accès au contexte de la session |
| `stk` | `&mut Stk` | Nécessaire si ta fn doit évaluer des sous-expressions |
| `opt` | `&Options` | Nécessaire si ta fn accède aux options de la requête |
| `doc` | `Option<&CursorDoc>` | Nécessaire si ta fn accède au document courant |

---

## Étape 3 — Logique Métier {#étape-3}

### Fichier

```
function/bridge.rs    (NOUVEAU)
```

### Quoi faire

Créer le fichier qui contient la **vraie implémentation** de tes fonctions. C'est le code métier.

### Template

```rust
//! Bridge functions for outbound API calls.
//!
//! These functions provide the Lyxal Bridge functionality,
//! allowing SurrealQL to call external APIs dynamically.

use anyhow::Result;
use reblessive::tree::Stk;

use crate::db::ctx::FrozenContext;
use crate::db::dbs::Options;
use crate::db::doc::CursorDoc;
use crate::db::val::Value;

/// bridge::call(provider, operation, params) → Value
///
/// Appelle une opération sur un provider externe.
///
/// # Exemple SurrealQL
/// ```sql
/// LET $result = bridge::call("airtable", "list_records", { baseId: "appXYZ" });
/// ```
pub(crate) async fn call(
    (stk, ctx, opt, doc): (
        &mut Stk,
        &FrozenContext,
        &Options,
        Option<&CursorDoc>,
    ),
    args: Vec<Value>,
) -> Result<Value> {
    // Extraire les arguments
    let provider_name = match args.get(0) {
        Some(Value::String(s)) => s.clone(),
        _ => return Err(anyhow::anyhow!("bridge::call expects a provider name as first argument")),
    };

    let operation_name = match args.get(1) {
        Some(Value::String(s)) => s.clone(),
        _ => return Err(anyhow::anyhow!("bridge::call expects an operation name as second argument")),
    };

    let params = args.get(2).cloned().unwrap_or(Value::None);

    // TODO: Implémenter la logique bridge_call()
    // 1. Résoudre provider + opération depuis les tables bridge_*
    // 2. Construire la requête HTTP
    // 3. Exécuter avec résilience
    // 4. Retourner le résultat

    Ok(Value::None)
}

/// bridge::list() → Array
///
/// Liste tous les providers actifs.
pub async fn list(
    ctx: &FrozenContext,
    _args: Vec<Value>,
) -> Result<Value> {
    // TODO: SELECT identity.name, affichage.display_name FROM bridge_providers
    // WHERE status.status = bridge_status:active
    Ok(Value::None)
}

/// bridge::info(provider) → Object
///
/// Retourne les détails d'un provider et ses opérations.
pub async fn info(
    ctx: &FrozenContext,
    args: Vec<Value>,
) -> Result<Value> {
    // TODO: SELECT * FROM bridge_providers WHERE identity.name = $name
    // + SELECT * FROM bridge_operations WHERE relations.provider_id = $pid
    Ok(Value::None)
}

/// bridge::health(provider) → Object
///
/// Vérifie la connectivité avec l'URL de base du provider.
pub async fn health(
    ctx: &FrozenContext,
    args: Vec<Value>,
) -> Result<Value> {
    // TODO: HEAD request sur provider.configuration.endpoint_base_url
    Ok(Value::None)
}

/// bridge::batch(calls) → Array
///
/// Exécute plusieurs appels bridge en parallèle.
pub async fn batch(
    (stk, ctx, opt, doc): (
        &mut Stk,
        &FrozenContext,
        &Options,
        Option<&CursorDoc>,
    ),
    args: Vec<Value>,
) -> Result<Value> {
    // TODO: Paralléliser plusieurs bridge::call()
    Ok(Value::None)
}
```

### Conventions

- Les fonctions reçoivent `args: Vec<Value>` ou un tuple déstructuré `(arg1, arg2): (Type1, Type2)`
- Les types sont des `Value` Lyxal (pas des types Rust natifs)
- Utiliser `anyhow::Result` pour la gestion d'erreurs
- Nommer les fonctions Rust exactement comme le dernier segment du nom SurrealQL (`bridge::call` → `pub fn call`)

---

## Étape 4 — Streaming Executor {#étape-4}

Le streaming executor est le **nouveau moteur d'exécution** (parallèle à l'ancien). Il utilise un système de `FunctionRegistry` avec des macros.

### Fichier 4a — `builtin/mod.rs` (enregistrement)

```
db/exec/function/builtin/mod.rs
```

Ajouter le module et l'enregistrement :

```rust
// Ligne ~17 — Déclaration du module
mod bridge;  // ← AJOUTER

// Ligne ~52 dans register_all() — Enregistrement
pub fn register_all(registry: &mut FunctionRegistry) {
    // ...
    bridge::register(registry);  // ← AJOUTER (ordre alphabétique)
    // ...
}
```

### Fichier 4b — `builtin/bridge.rs` (NOUVEAU)

```
db/exec/function/builtin/bridge.rs
```

Ce fichier définit les mêmes fonctions mais pour le streaming executor, en utilisant les macros `define_async_function!` et `register_functions!`.

### Template

```rust
//! Bridge functions for the streaming executor.
//!
//! These provide Bridge functionality (outbound API calls).

use anyhow::Result;

use crate::db::exec::function::FunctionRegistry;
use crate::db::exec::physical_expr::EvalContext;
use crate::db::val::Value;
use crate::{define_async_function, register_functions};

// =========================================================================
// bridge::call
// =========================================================================

async fn bridge_call_impl(ctx: &EvalContext<'_>, args: Vec<Value>) -> Result<Value> {
    let provider = match args.get(0) {
        Some(Value::String(s)) => s.clone(),
        _ => return Err(anyhow::anyhow!("bridge::call: missing provider name")),
    };
    let operation = match args.get(1) {
        Some(Value::String(s)) => s.clone(),
        _ => return Err(anyhow::anyhow!("bridge::call: missing operation name")),
    };
    let params = args.get(2).cloned().unwrap_or(Value::None);

    // TODO: Implémenter la logique
    Ok(Value::None)
}

// =========================================================================
// bridge::list
// =========================================================================

async fn bridge_list_impl(ctx: &EvalContext<'_>, args: Vec<Value>) -> Result<Value> {
    // TODO
    Ok(Value::None)
}

// =========================================================================
// bridge::info
// =========================================================================

async fn bridge_info_impl(ctx: &EvalContext<'_>, args: Vec<Value>) -> Result<Value> {
    // TODO
    Ok(Value::None)
}

// =========================================================================
// bridge::health
// =========================================================================

async fn bridge_health_impl(ctx: &EvalContext<'_>, args: Vec<Value>) -> Result<Value> {
    // TODO
    Ok(Value::None)
}

// =========================================================================
// bridge::batch
// =========================================================================

async fn bridge_batch_impl(ctx: &EvalContext<'_>, args: Vec<Value>) -> Result<Value> {
    // TODO
    Ok(Value::None)
}

// =========================================================================
// Function definitions using the macro
// =========================================================================

// Syntaxe : define_async_function!(NomStruct, "namespace::fn", (arg: Type, ?opt_arg: Type) -> ReturnType, impl_fn);
//
// ?arg = argument optionnel
// Types disponibles : String, Int, Float, Bool, Object, Array, Any
// ReturnType : Any, String, Int, etc.

define_async_function!(BridgeCall, "bridge::call",
    (provider: String, operation: String, ?params: Object) -> Any,
    bridge_call_impl);

define_async_function!(BridgeList, "bridge::list",
    () -> Any,
    bridge_list_impl);

define_async_function!(BridgeInfo, "bridge::info",
    (provider: String) -> Any,
    bridge_info_impl);

define_async_function!(BridgeHealth, "bridge::health",
    (provider: String) -> Any,
    bridge_health_impl);

define_async_function!(BridgeBatch, "bridge::batch",
    (calls: Array) -> Any,
    bridge_batch_impl);

// =========================================================================
// Registration
// =========================================================================

pub fn register(registry: &mut FunctionRegistry) {
    register_functions!(registry, BridgeCall, BridgeList, BridgeInfo, BridgeHealth, BridgeBatch,);
}
```

### Syntaxe de `define_async_function!`

```rust
define_async_function!(
    NomDuStruct,           // Nom unique du struct (PascalCase)
    "namespace::function", // Nom SurrealQL exact
    (                      // Signature des arguments
        arg1: String,      //   argument requis de type String
        arg2: Int,         //   argument requis de type Int
        ?opt_arg: Object,  //   argument optionnel (préfixé par ?)
    ) -> Any,              // Type de retour
    ma_fn_impl             // Référence vers la fn async d'implémentation
);
```

### Types disponibles pour les arguments

| Type macro | Type Rust correspondant | Exemple SurrealQL |
|:---|:---|:---|
| `String` | `Value::String(s)` | `"hello"` |
| `Int` | `Value::Number(n)` | `42` |
| `Float` | `Value::Number(n)` | `3.14` |
| `Bool` | `Value::Bool(b)` | `true` |
| `Object` | `Value::Object(o)` | `{ key: "val" }` |
| `Array` | `Value::Array(a)` | `[1, 2, 3]` |
| `Any` | `Value` (n'importe quoi) | `*` |

---

## Checklist Récapitulative {#checklist}

Pour ajouter une nouvelle built-in function `monns::mafn()` :

```
[ ] 1. db/syn/parser/builtin.rs
       → Ajouter UniCase::ascii("monns::mafn") => (PathKind::Function, None)
       → Vérifier MAX_FUNCTION_NAME_LEN si nom > 48 chars

[ ] 2. function/mod.rs
       → Ajouter pub mod monns;
       → Si async : ajouter || name.starts_with("monns") dans run()
       → Si async : ajouter "monns::mafn" => monns::mafn(...).await dans asynchronous()
       → Si sync  : ajouter "monns::mafn" => monns::mafn dans synchronous()

[ ] 3. function/monns.rs (NOUVEAU)
       → Créer le fichier avec pub async fn mafn(...) -> Result<Value>

[ ] 4. db/exec/function/builtin/mod.rs
       → Ajouter mod monns;
       → Ajouter monns::register(registry); dans register_all()

[ ] 5. db/exec/function/builtin/monns.rs (NOUVEAU)
       → define_async_function!(MonnsMafn, "monns::mafn", ...)
       → pub fn register(registry)
```

---

## Exemple Complet : Ajout de `bridge::call()` {#exemple-complet}

### Récapitulatif des modifications exactes

#### Fichier 1 : `db/syn/parser/builtin.rs`

```diff
  // Après la section "array::*" et avant "bytes::*" (ou après "api::*")
  //
+ UniCase::ascii("bridge::call") => (PathKind::Function, None),
+ UniCase::ascii("bridge::list") => (PathKind::Function, None),
+ UniCase::ascii("bridge::info") => (PathKind::Function, None),
+ UniCase::ascii("bridge::health") => (PathKind::Function, None),
+ UniCase::ascii("bridge::batch") => (PathKind::Function, None),
+ //
  UniCase::ascii("bytes::len") => (PathKind::Function, None),
```

#### Fichier 2 : `function/mod.rs`

```diff
  pub mod api;
  pub mod args;
  pub mod array;
+ pub mod bridge;
  pub mod bytes;
```

```diff
      || name.starts_with("api")
+     || name.starts_with("bridge")
      || name.starts_with("http")
```

```diff
      "http::delete" => http::delete(ctx).await,
      //
+     "bridge::call" => bridge::call((stk, ctx, opt, doc)).await,
+     "bridge::list" => bridge::list(ctx).await,
+     "bridge::info" => bridge::info(ctx).await,
+     "bridge::health" => bridge::health(ctx).await,
+     "bridge::batch" => bridge::batch((stk, ctx, opt, doc)).await,
+     //
      "crate::function::record::exists" => ...
```

#### Fichier 3 : `function/bridge.rs` — NOUVEAU

→ Voir le template complet dans la section [Étape 3](#étape-3)

#### Fichier 4a : `db/exec/function/builtin/mod.rs`

```diff
+ mod bridge;
  mod bytes;
```

```diff
  pub fn register_all(registry: &mut FunctionRegistry) {
      api::register(registry);
      array::register(registry);
+     bridge::register(registry);
      bytes::register(registry);
```

#### Fichier 4b : `db/exec/function/builtin/bridge.rs` — NOUVEAU

→ Voir le template complet dans la section [Étape 4](#étape-4)

---

## FAQ {#faq}

### Q: Pourquoi il y a deux systèmes (function/ ET exec/function/builtin/) ?

**R:** Le système `function/mod.rs` est **l'ancien exécuteur** (tree-walking). Le système `exec/function/builtin/` est le **nouveau streaming executor** (plus performant). Les deux coexistent pour la compatibilité. À terme, seul le streaming executor restera, mais pour l'instant il faut câbler les deux.

### Q: Est-ce que je dois toucher au lexer ou au token parser ?

**R:** **Non.** Le parser de `builtin.rs` utilise une `phf_map` statique. Il n'y a pas de token spécial à ajouter dans le lexer. Le parser reconnaît le pattern `identifiant::identifiant(args)` de manière générique, puis vérifie dans la map `PATHS` si c'est un nom connu.

### Q: Comment faire passer mes fonctions en read-only ou read-write ?

**R:** Par défaut les fonctions sont considérées comme pures. Si ta fonction a des **effets de bord** (HTTP, écriture DB, etc.), vérifie dans `db/expr/expression.rs` que le check `read_only()` la marque correctement. Les fonctions `http::*` sont déjà gérées par un `name.starts_with("http")`. Tu devras ajouter `name.starts_with("bridge")` au même endroit.

### Q: Ma fonction a besoin d'accéder à la DB depuis l'intérieur ?

**R:** Le `FrozenContext` (`ctx`) donne accès à tout le contexte de la session. Pour accéder à la DB, tu peux utiliser le pattern :

```rust
let txn = ctx.tx();  // Transaction courante
// Ou accéder aux capabilities, session, etc.
```

### Q: Puis-je ajouter un feature gate ?

**R:** Oui, utilise le préfixe `exp(NomFeature)` dans le dispatch. Exemple :

```rust
exp(Bridge) "bridge::call" => bridge::call((stk, ctx, opt, doc)).await,
```

Cela nécessite que la capability `Bridge` soit activée (à ajouter dans `dbs/capabilities.rs`).

### Q: Combien de fonctions puis-je ajouter dans un namespace ?

**R:** Autant que tu veux. Le namespace est juste une convention de nommage (`bridge::call`, `bridge::list`, etc.). Il n'y a pas de limite technique.

---

*Ce guide fait partie de la documentation technique de Lyxal Solution.*
