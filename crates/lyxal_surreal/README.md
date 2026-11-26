# `lyxal_surreal` — transport SurrealDB de Lyxal OS

Fondation technique (`.agents/AGENTS.md` §5.2, §6) : seul crate qui encapsule le client
`Surreal<Any>`, le pool de connexions d'une session et l'appel des fonctions SurrealQL. Il dépend
de `lyxal_error` et de `lyxal_crypto` (même niveau) et ne contient aucune logique métier ni
fonction SurrealQL ; il ne porte que les définitions de ses codes d'erreur.

Version `0.1.0` (régime pré-production). SDK `surrealdb` 3.3, serveur cible SurrealDB 3.3.4.

Évolutions prévues : [`ROADMAP.md`](ROADMAP.md).

---

## 1. Connexion : `create_surreal_client`

```rust
use lyxal_surreal::{create_surreal_client, RootCredentials, SecretString, SurrealConnectOptions};

let options = SurrealConnectOptions {
    endpoint: "ws://127.0.0.1:8000".into(),
    credentials: Some(RootCredentials::new("root", SecretString::new(password)?)),
    namespace: "lyxal".into(),
    database: "booking".into(),
    connect_timeout: Duration::from_secs(10),
};
let db = create_surreal_client(&options).await?;
```

C'est la seule façon de se connecter dans le dépôt : les hôtes l'utilisent à travers
`SurrealPool::connect` (§2). Les options sont empruntées : elles servent à ouvrir chaque
connexion d'un pool. Règles appliquées (`.agents/rules/lyxal_standards_and_checklist.md` §11.2) :

* seuls `ws://`, `wss://`, `mem://` et `memory` sont acceptés (`UnsupportedEndpoint` sinon) ;
* `ws://` et `wss://` exigent des identifiants Root non vides (`MissingCredentials` sinon) ;
* `mem://` et `memory` ne tentent jamais d'authentification, même avec des identifiants ;
* connexion, authentification et sélection namespace/base tiennent dans `connect_timeout`
  (`ConnectTimeout` sinon) ;
* un `/` final ou un suffixe `/rpc` est retiré de l'URL.

Le mot de passe est un `lyxal_crypto::SecretString` (réexporté) : masqué dans `Debug`, effacé de
la mémoire à la libération, lu à chaque `signin`. `is_embedded_endpoint` dit si une URL désigne
une base embarquée (`mem://…`, `memory`).

## 2. Pool de connexions : `SurrealPool`

Un serveur SurrealDB ne répartit pas sur ses cœurs les requêtes d'une même connexion : le débit
d'un store qui n'a qu'un client reste celui d'une connexion, quel que soit le nombre d'appels
simultanés (banc de `lyxal_mail`, serveur 3.3.4 à 4 cœurs : 11,7 remises par seconde avec une
connexion, 25,8 avec huit). `SurrealPool` tient plusieurs clients `Surreal<Any>` ouverts sous la
même session et les distribue à tour de rôle ; les appels simultanés passent alors par plusieurs
connexions, chacun dans sa transaction.

```rust
use lyxal_surreal::SurrealPool;
use std::num::NonZeroUsize;

let pool = SurrealPool::connect(&options, NonZeroUsize::new(8).expect("non nul")).await?;
let store = BookingStore::new(pool.clone());     // chaque appel prend le client du tour suivant
let fixed = pool.fixed();                        // toujours la même connexion
```

| Élément | Rôle |
| :- | :- |
| `SurrealPool::connect(&options, connections)` | Ouvre `connections` clients par `create_surreal_client`, l'un après l'autre ; la première ouverture en échec rend son erreur et ferme les clients déjà ouverts. Base embarquée (`mem://`, `memory`) : **un seul client** quel que soit `connections` (le moteur embarqué n'a pas de connexion, et chaque ouverture y créerait une base distincte) |
| `SurrealPool::from(client)` | Pool d'un seul client : la forme d'un store posé sur un client unique (session d'un utilisateur, tests) |
| `client()` | Client du tour suivant ; deux appels successifs rendent deux clients différents dès que le pool en a plusieurs |
| `fixed()` | Connexion fixe : toujours le premier client. Pour ce qui tient à une connexion (requête `LIVE` et sa vérification, session d'un utilisateur clonée puis authentifiée) ou n'a pas à être réparti (installation, moteur du runtime) |
| `clients()`, `size()` | Tous les clients (la connexion fixe en premier) et leur nombre, 1 au moins |
| `probe(within)` → `PoolProbe` | Sonde : chaque client doit répondre à une requête triviale en moins de `within` ; clients sondés en même temps. `PoolProbe { clients, responding, error }`, `reachable()` (un client au moins répond), `complete()` (tous répondent) |

Règles :

* **Même état de session sur tous les clients.** Un client rendu par le pool ne reçoit jamais
  `authenticate`, `invalidate`, `signin`, `use_ns`, `use_db` ni `set` : il n'est pas possible de
  savoir sur quel client la requête suivante passera. Une session d'utilisateur se prend sur une
  copie de la connexion fixe (`pool.fixed().clone()` ouvre une session à part sur la même
  connexion), authentifiée par son jeton, puis remise à un store (`Store::new(session)`).
* **Une copie du pool partage ses clients et son tour** (`Clone`) : elle n'ouvre aucune session.
* **Rien n'est rejoué.** Un appel en échec rend son erreur. Deux appels simultanés d'un même
  processus peuvent se heurter dans la base (conflit de transaction,
  `LyxalSurrealError::is_transient_conflict`), comme ceux de deux nœuds ; le rejeu appartient
  au module. C'était déjà vrai sur une seule connexion, dont les requêtes s'entrelacent
  (mesuré : deux transactions simultanées d'une même connexion se heurtent) : aucun ordre
  n'était garanti entre des appels simultanés.
* **Connexion coupée** : seuls les appels en cours sur cette connexion échouent (`Database`,
  « Connection reset ») ; le SDK rouvre la connexion et rétablit sa session, les appels suivants
  aboutissent. Les autres connexions ne sont pas touchées. L'appelant d'un appel coupé ne sait
  pas si sa transaction a été validée (essai sur un serveur 3.3.4 : transaction abandonnée) : il
  ne rejoue qu'une opération idempotente.
* **Lecture après écriture** : chaque appel est une transaction validée avant sa réponse ; un
  appel attendu puis un second, sur deux connexions, se suivent (le second lit ce que le premier
  a écrit).

## 3. Appel de fonction : `LyxalSurrealCall::call_fn`

Un store métier enveloppe un `SurrealPool` (ou, pour une session fixe, un `Surreal<Any>`) et
implémente le trait ; chaque opération est un appel d'une ligne :

```rust
#[derive(Clone)]
pub struct BookingStore { db: SurrealPool }

impl BookingStore {
    /// Client déjà connecté, ou pool de clients de la même session.
    pub fn new(db: impl Into<SurrealPool>) -> Self { Self { db: db.into() } }
}

#[async_trait]
impl LyxalSurrealCall for BookingStore {
    fn surreal_client(&self) -> &Surreal<Any> { self.db.client() }
}

pub async fn booking_create(store: &BookingStore, params: BookingCreateParams)
    -> Result<Booking, LyxalSurrealError> {
    store.call_fn("booking_create", params).await
}
```

`call_fn` reste défini à un seul endroit, ce trait : il demande au store le client de l'appel
(`surreal_client`), sans savoir s'il vient d'un pool. Une copie d'un store partage la session de
l'original. `call_fn` :

* prend le nom de la fonction en `&str` : un nom fixe (`"booking_create"`) ou lu à l'exécution
  (cible d'une tâche du planificateur) ;
* refuse un nom de fonction hors `^[a-z0-9_]+$` (`InvalidFunctionName { function }`, nom refusé
  en `String`), avant toute requête ;
* exécute `RETURN fn::<nom>($params);` en liant les paramètres par `SurrealValue` (types natifs
  `RecordId`, `Datetime`, sans passage par JSON) ;
* lit le contrat `{ ok, data, error }` et renvoie `T`, `Call(Business(LyxalError))` ou
  `Call(InvalidContract)` (réponse vide ou incohérente) ;
* reconnaît un code de module levé par `THROW "<CODE>"` ou `THROW "<CODE>: texte"` (annulation
  d'une écriture multiple, garde `DEFINE EVENT`) : `<CODE>` en majuscules avec au moins un `_`
  (`AUTH_WRITE_FORBIDDEN`). Le code est résolu par `fn::error_result` (master data de
  `lyxal_error`, langue par défaut) et renvoyé en `Call(Business(LyxalError))` ; un code sans
  définition donne l'erreur métier interne de `lyxal_error` portant ce code. Un texte libre levé,
  une erreur réseau ou une résolution impossible restent `Database`. La reconnaissance
  (`thrown_code`) s'appuie sur le marqueur de `THROW` de SurrealDB : erreur marquée levée, ou
  message `Error while processing event <nom>: An error occurred: <CODE>…` pour une garde.

Le crate réexporte `LyxalCallError`, `LyxalError`, `LyxalResult` et les types du SDK
`Datetime`, `RecordId`, `SurrealValue`, `ToSql`, `Value`, ainsi que `SecretString`.

## 4. Erreurs : `LyxalSurrealError`

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

## 5. Vérification

```bash
cargo test -p lyxal_surreal --all-features
```

Les essais du pool (`tests/it/pool_tests.rs`) lancent un serveur SurrealDB 3.3.4 réel
(`LYXAL_SURREAL_BIN`, à défaut `surreal` dans le `PATH`) et le joignent à travers un relais TCP
local qui compte les appels de chaque connexion, coupe une connexion ou la rend muette :
pool de un (une seule connexion, par laquelle passent tous les appels, comme pour un store posé
sur un client seul) ; pool de quatre (même session sur chaque client, appels successifs et
simultanés répartis à tour de rôle, écriture lue aussitôt par une autre connexion) ; connexion
coupée (seuls ses appels en cours échouent, elle est rouverte et sa session rétablie) ; sonde
(connexions muettes comptées) ; requête `LIVE` sur la connexion fixe, qui reçoit les écritures
des autres connexions.

Le test de connexion distante (`ws://` + Root) est ignoré par défaut ; la CI le lance contre un
serveur 3.3.4 (`scripts/ci/test_all.sh`) :

```bash
LYXAL_SURREAL_WS_URL=ws://127.0.0.1:8000 cargo test -p lyxal_surreal -- --ignored
```
