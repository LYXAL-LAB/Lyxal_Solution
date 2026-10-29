# 🌐 Module `lyxal_surreal` — Transport Universel & Façade `Surreal<Any>`

[![Status](https://img.shields.io/badge/Status-Production--Ready-success.svg)](#)
[![Charte](https://img.shields.io/badge/Conformit%C3%A9-AGENTS.md%20%C2%A711-blue.svg)](#)
[![Tests](https://img.shields.io/badge/Tests-Passed-brightgreen.svg)](#)

Le crate **`lyxal_surreal`** constitue la fondation technique officielle de Couche 1 pour l'ensemble des interactions avec SurrealDB dans l'écosystème **Lyxal OS**.

Il encapsule le client générique `Surreal<Any>` et fournit le trait unifié `LyxalSurrealCall` permettant à tous les stores métiers d'exécuter des fonctions SurrealQL typées en 1 ligne (`store.call_fn(...)`).

---

## 🏛️ 1. Rôle Architectural & Règles Inviolables (§11)

Conformément à la Charte d'Architecture Lyxal OS ([`.agents/rules/lyxal_standards_and_checklist.md`](../.agents/rules/lyxal_standards_and_checklist.md) §11) :

1. **Store Unifié `Surreal<Any>`** :
   Tout store de persistance d'un module métier enveloppe une structure `Surreal<Any>` issue de `surrealdb::engine::any::Any`. Interdiction formelle de définir des `enum (Ws/Mem)` locaux.
2. **Centralisation de `call_fn()`** :
   La méthode d'exécution universelle existe à un seul endroit : `lyxal_surreal`. Aucun module métier ne doit surcharger ou dupliquer cette logique.
3. **Zéro `panic!`** :
   Les appels au client transport ne doivent jamais générer de `panic!` ou d'erreur non capturée.
4. **Authentification des Moteurs Distants vs Embarqués (§11.2)** :
   - **Connexions distantes (`ws://`, `wss://`)** : requièrent obligatoirement une authentification `Root` (`signin`).
   - **Connexions embarquées (`mem://`, `memory`)** : ne doivent **JAMAIS** tenter d'authentification `Root`.
   - **Schémas autorisés** : strictement restreints à `ws://`, `wss://`, `mem://`, `memory`.

---

## 🔌 2. Factory de Connexion Centralisée (`client.rs`)

`lyxal_surreal` expose la méthode officielle de création et de connexion du client :

```rust
use lyxal_surreal::{create_surreal_client, RootCredentials};

// Connexion en mémoire (développement, tests d'intégration, workers isolés)
let db = create_surreal_client("mem://", None).await?;
db.use_ns("lyxal").use_db("booking").await?;

// Connexion distante (production, staging)
let creds = RootCredentials::new("root", "root_password");
let db = create_surreal_client("ws://127.0.0.1:8000", Some(creds)).await?;
db.use_ns("lyxal").use_db("booking").await?;
```

---

## ⚙️ 3. Trait `LyxalSurrealCall` & Wrappers 1-Ligne (`call.rs`)

Les stores des modules métiers implémentent `LyxalSurrealCall` en exposant simplement leur référence `&Surreal<Any>` :

```rust
use async_trait::async_trait;
use lyxal_surreal::{LyxalSurrealCall, LyxalSurrealError};
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

pub struct BookingStore {
    db: Surreal<Any>,
}

#[async_trait]
impl LyxalSurrealCall for BookingStore {
    fn surreal_client(&self) -> &Surreal<Any> {
        &self.db
    }
}

// Wrapper 1-ligne typé
pub async fn booking_create(
    store: &BookingStore,
    params: BookingCreateParams,
) -> Result<BookingResult, LyxalSurrealError> {
    store.call_fn("booking_create", params).await
}
```

### Garanties de `call_fn` :
- **Sécurisation SQL Injection** : `validate_function_name` vérifie que le nom est strictement composé de minuscules alphanumériques et de tirets bas (`^[a-z0-9_]+$`).
- **Contrat universel** : Formate `RETURN fn::<name>($params);` et désérialise `LyxalResult<T>`, converti de manière déterministe par `.into_result(function_name)` :
  - `{ ok: true, data: Some(...) }` $\rightarrow$ `Ok(T)`
  - `{ ok: false, error: Some(...) }` $\rightarrow$ `Err(LyxalSurrealError::Call(LyxalCallError::Business(...)))`
  - Violation de contrat (état incohérent ou réponse vide) $\rightarrow$ `Err(LyxalSurrealError::Call(LyxalCallError::InvalidContract { ... }))`

---

## 🚨 4. Gestion d'Erreurs (`error.rs`)

L'énumération `LyxalSurrealError` fédère les erreurs du socle de données :

```rust
pub enum LyxalSurrealError {
    Call(LyxalCallError),
    Database(surrealdb::Error),
    InvalidFunctionName { function: &'static str },
    UnsupportedEndpoint { endpoint: String },
    MissingCredentials { endpoint: String },
}
```

### Intégration Axum HTTP (`feature = "axum"`)
Lorsqu'elle est activée, `LyxalSurrealError` implémente `axum::response::IntoResponse` avec un mapping HTTP strict :
- `Call(call_err)` : relayé vers le statut HTTP résolu par l'erreur métier de `lyxal_error` (ex: 400, 404, 422).
- `UnsupportedEndpoint` : `HTTP 400 Bad Request` (`CORE_UNSUPPORTED_ENDPOINT`).
- `InvalidFunctionName` : `HTTP 400 Bad Request` (`CORE_INVALID_FUNCTION_NAME`).
- `MissingCredentials` : `HTTP 401 Unauthorized` (`CORE_MISSING_CREDENTIALS`).
- `Database` : `HTTP 500 Internal Server Error` (`CORE_DATABASE_ERROR`).

---

## 🧪 5. Validation Qualité

```bash
# Vérification des types (toutes features)
cargo check -p lyxal_surreal --all-features

# Linter statique
cargo clippy -p lyxal_surreal --all-targets --all-features

# Suite de tests
cargo test -p lyxal_surreal --all-features
```
