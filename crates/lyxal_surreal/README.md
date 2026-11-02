# `lyxal_surreal` — transport SurrealDB de Lyxal OS

Fondation technique (`.agents/AGENTS.md` §5.2, §6) : seul crate qui encapsule le client
`Surreal<Any>` et l'appel des fonctions SurrealQL. Il dépend de `lyxal_error` et de `lyxal_crypto` (même niveau) et ne contient
aucune logique métier ni fonction SurrealQL ; il ne porte que les définitions de ses codes d'erreur.

Version `0.1.0` (régime pré-production). SDK `surrealdb` 3.3, serveur cible SurrealDB 3.3.4.

---

## 1. Connexion : `create_surreal_client`

```rust
use lyxal_surreal::{create_surreal_client, RootCredentials, SecretString, SurrealConnectOptions};

let db = create_surreal_client(SurrealConnectOptions {
    endpoint: "ws://127.0.0.1:8000".into(),
    credentials: Some(RootCredentials::new("root", SecretString::new(password)?)),
    namespace: "lyxal".into(),
    database: "booking".into(),
    connect_timeout: Duration::from_secs(10),
})
.await?;
```

C'est la seule façon de se connecter dans le dépôt : `lyxal-server` l'utilise. Règles
appliquées (`.agents/rules/lyxal_standards_and_checklist.md` §11.2) :

* seuls `ws://`, `wss://`, `mem://` et `memory` sont acceptés (`UnsupportedEndpoint` sinon) ;
* `ws://` et `wss://` exigent des identifiants Root non vides (`MissingCredentials` sinon) ;
* `mem://` et `memory` ne tentent jamais d'authentification, même avec des identifiants ;
* connexion, authentification et sélection namespace/base tiennent dans `connect_timeout`
  (`ConnectTimeout` sinon) ;
* un `/` final ou un suffixe `/rpc` est retiré de l'URL.

Le mot de passe est un `lyxal_crypto::SecretString` (réexporté) : masqué dans `Debug`, effacé de
la mémoire à la libération, lu une seule fois au `signin`.

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
`Datetime`, `RecordId`, `SurrealValue`, `ToSql`, `Value`, ainsi que `SecretString`.

## 3. Erreurs : `LyxalSurrealError`

| Variante | Cause | Code | HTTP |
| :- | :- | :- | :- |
| `Call(LyxalCallError)` | erreur métier ou contrat non respecté | code de `lyxal_error` | celui du code |
| `Database(surrealdb::Error)` | erreur du SDK : réseau, requête, authentification | `SURREAL_DATABASE_ERROR` | 500 |
| `InvalidFunctionName { function }` | nom de fonction refusé | `SURREAL_INVALID_FUNCTION_NAME` | 500 |
| `UnsupportedEndpoint { endpoint }` | schéma d'URL non autorisé | `SURREAL_UNSUPPORTED_ENDPOINT` | 500 |
| `MissingCredentials { endpoint }` | identifiants Root absents en distant | `SURREAL_MISSING_CREDENTIALS` | 500 |
| `ConnectTimeout { endpoint }` | délai de connexion dépassé | `SURREAL_CONNECT_TIMEOUT` | 503, réessayable |

Les erreurs de transport sont des erreurs du serveur (catégorie `internal`, ou `timeout` pour le
délai). `transport_info()` donne leur code, leur catégorie, leur statut et leurs libellés.
Avec la fonctionnalité `axum`, `LyxalSurrealError` implémente `IntoResponse` :

* `Call` est relayé à `lyxal_error` ;
* les autres variantes répondent `{ ok: false, data: null, error: {…} }`, sans l'adresse de la
  base ni le détail SurrealDB, qui restent dans les journaux du serveur.

Les définitions de ces codes (traductions fr/en) sont dans `error/error_definitions.surql`,
déclaré dans `manifest.toml` (dépendance `lyxal_error`, dont elles alimentent la table
`error_definition`). Un test vérifie que chaque code émis y figure avec les mêmes attributs.

## 4. Vérification

```bash
cargo test -p lyxal_surreal --all-features
```

Le test de connexion distante (`ws://` + Root) est ignoré par défaut ; la CI le lance contre un
serveur 3.3.4 (`scripts/ci/test_all.sh`) :

```bash
LYXAL_SURREAL_WS_URL=ws://127.0.0.1:8000 cargo test -p lyxal_surreal -- --ignored
```
