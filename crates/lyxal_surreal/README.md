# `lyxal_surreal` — transport SurrealDB de Lyxal OS

Fondation technique (`.agents/AGENTS.md` §5.2, §6) : seul crate qui encapsule le client
`Surreal<Any>` et l'appel des fonctions SurrealQL. Il dépend de `lyxal_error` et ne contient
aucune logique métier ni SurrealQL.

Version `0.1.0` (régime pré-production). SDK `surrealdb` 3.3, serveur cible SurrealDB 3.3.4.

---

## 1. Connexion : `create_surreal_client`

```rust
use lyxal_surreal::{create_surreal_client, RootCredentials};

let db = create_surreal_client("mem://", None).await?;
let db = create_surreal_client("ws://127.0.0.1:8000", Some(RootCredentials::new("root", "…"))).await?;
```

Règles appliquées (`.agents/rules/lyxal_standards_and_checklist.md` §11.2) :

* seuls `ws://`, `wss://`, `mem://` et `memory` sont acceptés (`UnsupportedEndpoint` sinon) ;
* `ws://` et `wss://` exigent des identifiants Root non vides (`MissingCredentials` sinon) ;
* `mem://` et `memory` ne tentent jamais d'authentification ;
* un `/` final ou un suffixe `/rpc` est retiré de l'URL.

## 2. Appel de fonction : `LyxalSurrealCall::call_fn`

Un store métier enveloppe un `Surreal<Any>` et implémente le trait ; chaque opération est un
appel d'une ligne :

```rust
#[async_trait]
impl LyxalSurrealCall for BookingStore {
    fn surreal_client(&self) -> &Surreal<Any> { &self.db }
}

pub async fn booking_create(store: &BookingStore, params: BookingCreateParams)
    -> Result<Booking, LyxalSurrealError> {
    store.call_fn("booking_create", params).await
}
```

`call_fn` :

* refuse un nom de fonction hors `^[a-z0-9_]+$` (`InvalidFunctionName`), avant toute requête ;
* exécute `RETURN fn::<nom>($params);` en liant les paramètres par `SurrealValue` (types natifs
  `RecordId`, `Datetime`, sans passage par JSON) ;
* lit le contrat `{ ok, data, error }` et renvoie `T`, `Call(Business(LyxalError))` ou
  `Call(InvalidContract)` (réponse vide ou incohérente).

Le crate réexporte `LyxalCallError`, `LyxalError`, `LyxalResult` et les types du SDK
`Datetime`, `RecordId`, `SurrealValue`, `ToSql`, `Value`.

## 3. Erreurs : `LyxalSurrealError`

| Variante | Cause |
| :- | :- |
| `Call(LyxalCallError)` | erreur métier ou contrat non respecté (`lyxal_error`) |
| `Database(surrealdb::Error)` | erreur du SDK : réseau, requête, authentification |
| `InvalidFunctionName { function }` | nom de fonction refusé |
| `UnsupportedEndpoint { endpoint }` | schéma d'URL non autorisé |
| `MissingCredentials { endpoint }` | identifiants Root absents en distant |

Avec la fonctionnalité `axum`, `LyxalSurrealError` implémente `IntoResponse` : `Call` est relayé
à `lyxal_error`, les autres variantes répondent `{ ok: false, data: null, error: {…} }`.

## 4. Vérification

```bash
cargo test -p lyxal_surreal --all-features
```

Le test de connexion distante (`ws://` + Root) est ignoré par défaut ; la CI le lance contre un
serveur 3.3.4 (`scripts/ci/test_all.sh`) :

```bash
LYXAL_SURREAL_WS_URL=ws://127.0.0.1:8000 cargo test -p lyxal_surreal -- --ignored
```
