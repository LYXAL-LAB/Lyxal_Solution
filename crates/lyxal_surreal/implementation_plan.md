# Plan d'implémentation — reprise de `lyxal_surreal`

> **Statut : soumis au CTO.** Aucune modification de code avant validation explicite (§3).
> Constats : `AUDIT.md` (S-01 à S-07). Supprimé avec `AUDIT.md` à la clôture (§0.3.4).

## 1. Décisions demandées

| # | Question | Recommandation |
| :- | :--- | :--- |
| Q1 | **Mot de passe Root (S-01)** : comment le protéger ? | **`lyxal_crypto::SecretString`** pour `RootCredentials::password` (§11.3.6 : tout secret en mémoire est un type sensible, effacé à la libération, `Debug` masqué). `lyxal_surreal` ajoute alors une dépendance vers `lyxal_crypto`. Les deux crates sont au même niveau, et `lyxal_crypto` ne dépend d'aucun crate Lyxal : pas de cycle. Le texte est lu une seule fois, au `signin` (`expose_secret()`). `RootCredentials` perd `Clone` et `PartialEq`, qu'aucun appelant n'utilise. *Alternative* : garder `String` avec un `Debug` manuel `[REDACTED]`, sans nouvelle dépendance mais sans effacement mémoire. |
| Q2 | **Fabrique de connexion (S-02)** : `lyxal-server` doit-il l'utiliser ? | **Oui, dans le même changement.** `create_surreal_client` reçoit ce dont l'hôte a besoin : délai de connexion, namespace et base sélectionnés. `apps/lyxal-server/src/database.rs` l'appelle au lieu de `any::connect` + `signin` ; sa sonde `RETURN { ok: true }` reste dans le serveur. Conséquences pour l'hôte : URL contrôlée ; `ws://`/`wss://` sans identifiants refusé au démarrage ; aucun `signin` en `mem://`. `DatabaseConfig::password` (même fuite `Debug` que S-01) devient un `SecretString` à la lecture de la configuration. |
| Q3 | **Définitions des codes d'erreur (S-03)** : où les placer ? | **Dans `lyxal_surreal`** : un `manifest.toml` (dépendance `lyxal_error`) et `error/error_definitions.surql`, sur le modèle de `lyxal_error`. Le propriétaire du code porte sa définition (§5.5). *Alternative* : un fichier `error/surreal/surreal_definitions.surql` dans `lyxal_error`, comme les codes `CORE_*`. Ce précédent existe parce que `lyxal_core` est sous `lyxal_error` et ne peut pas dépendre de sa table ; `lyxal_surreal`, au-dessus, le peut. |
| Q4 | **Catégories et statuts (S-04)** | Ce sont des erreurs du serveur, pas de la requête du client. Toutes en catégorie `internal`, statut 500, `retryable: false`, sauf `SURREAL_CONNECT_TIMEOUT` en `timeout`, 503, `retryable: true`. `SURREAL_DATABASE_ERROR` passe à `retryable: false` : la variante ne distingue pas une coupure réseau d'une requête invalide, et annoncer « réessayable » sur une requête invalide est faux. |

## 2. Contrat cible

### Codes d'erreur (préfixe `SURREAL_`, master data selon Q3)

| Code | Variante | Catégorie | HTTP | Retryable |
| :- | :- | :- | :- | :- |
| `SURREAL_DATABASE_ERROR` | `Database` | `internal` | 500 | non |
| `SURREAL_INVALID_FUNCTION_NAME` | `InvalidFunctionName` | `internal` | 500 | non |
| `SURREAL_UNSUPPORTED_ENDPOINT` | `UnsupportedEndpoint` | `internal` | 500 | non |
| `SURREAL_MISSING_CREDENTIALS` | `MissingCredentials` | `internal` | 500 | non |
| `SURREAL_CONNECT_TIMEOUT` | `ConnectTimeout` (nouvelle) | `timeout` | 503 | oui |

`Call(...)` reste relayé tel quel à `lyxal_error` (`ERROR_INVALID_FUNCTION_RESPONSE` ou le code
métier). Les corps HTTP gardent la forme `{ ok: false, data: null, error: { code, message, label,
category, severity, http_status, retryable } }` ; libellés et messages repris des définitions.

### Rust (rupture coordonnée, §0.3.1)

```rust
pub struct RootCredentials { pub username: String, pub password: SecretString } // Q1
pub struct SurrealConnectOptions {
    pub endpoint: String,
    pub credentials: Option<RootCredentials>,
    pub namespace: String,
    pub database: String,
    pub connect_timeout: std::time::Duration,
}
pub async fn create_surreal_client(options: SurrealConnectOptions)
    -> Result<Surreal<Any>, LyxalSurrealError>;
// LyxalSurrealError : + ConnectTimeout { endpoint: String }
```

* **Appelants à mettre à jour** : `apps/lyxal-server/src/database.rs` et `config.rs`, ainsi que
  les tests de `lyxal_surreal`. Aucun autre appelant de `create_surreal_client` ni de
  `RootCredentials`.
* **Hors périmètre** : les connexions `any::connect("mem://")` des tests internes de `lyxal_event`
  et `lyxal_pipeline_ingestion`. Ce sont des tests unitaires ; ils seront revus à la reprise de ces
  modules.

### `lyxal_core`

Aucune fonction utilisée ni requise : le crate ne contient pas de SurrealQL métier. Les
définitions d'erreurs suivent le format standard `IF !record::exists(...) THEN ( CREATE ... ) END;`.

## 3. Tests

* **Erreurs (`axum`)** : chaque variante vérifiée sur son code, son statut et la forme de son
  corps, y compris `Call(Business)` et `Call(InvalidContract)`.
* **Master data** : les codes émis par `IntoResponse` existent dans les définitions (test qui lit
  le fichier).
* **Fabrique** :
  * namespace et base sélectionnés ;
  * délai dépassé → `ConnectTimeout` (port sans écoute) ;
  * `ws://` sans identifiants → `MissingCredentials` ;
  * `mem://` avec identifiants → aucun `signin` ;
  * test distant contre le serveur 3.3.4 de la CI (existant, adapté).
* **Secret** (Q1) : `format!("{:?}", credentials)` ne contient pas le mot de passe.
* **`lyxal-server`** : ses tests existants (`mem://`, configuration) restent verts ; un `ws://`
  sans identifiants échoue au démarrage.

## 4. Lots

| Lot | Contenu |
| :- | :--- |
| 1 | **Nettoyage** : suppression de `LYXAL_SURREAL_IMPLEMENTATION_REPORT.md` ; README à l'état actuel (S-05, S-06). |
| 2 | **Secret et fabrique, avec l'hôte** : `RootCredentials` (Q1) ; `SurrealConnectOptions` et `ConnectTimeout` ; `lyxal-server` passe par la fabrique, `DatabaseConfig::password` protégé (Q2) ; tests (S-01, S-02). |
| 3 | **Codes d'erreur** : `SURREAL_*`, catégories et statuts (Q4), définitions master data et, selon Q3, `manifest.toml` ; tests `axum` complets (S-03, S-04, S-07). |
| 4 | **Clôture** : audit de contrôle, suppression de `AUDIT.md` et de ce plan. |

Chaque lot fait l'objet d'une PR, fusionnée quand la CI est verte.

## 5. Checklist §13 (extraits)

* Architecture : pas de nouveau cycle (`lyxal_surreal` → `lyxal_crypto`, même niveau) ;
  frontière Rust respectée (transport et protocole).
* Rust : aucun `panic!` ; aucun secret exposé ; aucune erreur masquée ; aucun `raw_query()`.
* Erreurs : préfixe du module propriétaire ; master data prévue.
* Cryptographie : uniquement `lyxal_crypto::SecretString` (Q1), aucune primitive nouvelle.
* Zéro dette : aucun alias des anciens codes `CORE_*`, ancienne signature de la fabrique
  supprimée, version `0.1.0`.
