# Plan d'implémentation — Alignement du SDK Rust `surrealdb` sur SurrealDB 3.3.4

> **Statut** : VALIDÉ PAR LE CTO (2026-11-01) — exécution en cours : **Lots 1 et 2 terminés**.
> **Décisions CTO** : Q1 → SDK et serveur en 3.3.x (dernier patch) ; Q2 → `lyxal_error` dépend de `surrealdb-types` ; Q3 → requêtes directes de `lyxal_pipeline_ingestion` portées telles quelles, remplacées à la reprise du module.
> **Module porteur** : `lyxal_surreal` (transport unique, §11.1).
> **Impact** : transverse — tous les crates du workspace qui parlent à SurrealDB.
> **Régime** : pré-production « Zéro Dette » (`.agents/AGENTS.md` §0) — ruptures de contrat autorisées si tous les appelants sont mis à jour dans le même chantier.

---

## 1. Objectif

Passer le workspace de `surrealdb = "2.2"` (résolu en **2.6.5** dans `Cargo.lock`) à **`surrealdb` 3.3.x**, pour que :

1. le SDK parle le même protocole que le serveur cible **3.3.4** ;
2. les tests embarqués (`mem://`) s'exécutent sur le **moteur 3.3** et non plus sur le moteur 2.6 ;
3. le code ne contienne plus aucune construction propre à 2.x.

## 2. Constats (vérifiés le 2026-11-01)

| # | Constat | Preuve |
| :- | :--- | :--- |
| C1 | Le workspace compile et ses tests passent, mais **uniquement sur le moteur 2.6 embarqué** : la quasi-totalité des tests utilise `mem://`. Aucun test du workspace ne prouve aujourd'hui le fonctionnement sur 3.x. | `grep mem:// crates/*/tests` |
| C2 | **Les verrous de `lyxal_runtime` sont incompatibles avec un serveur 3.x** : 10 requêtes utilisent `type::thing(...)`, supprimée en 3.x (`Invalid function/constant path`, vérifié sur le binaire 3.3.4). | `lock/installation.rs` (7), `lock/surreal.rs` (3) |
| C3 | En SDK 3.x, l'échange de données avec la base ne passe plus par `serde` mais par le trait **`SurrealValue`** (`surrealdb::types`). `.bind(...)` et `.take(...)` exigent `SurrealValue`. | Essai de compilation sur une copie jetable : `call.rs` → `the trait SurrealValue is not implemented` |
| C4 | `surrealdb::RecordId`, `surrealdb::Datetime` et `surrealdb::sql::Thing` n'existent plus à ces chemins. Les types sont dans `surrealdb::types::{RecordId, Datetime, …}`. | Essai : `cannot find RecordId in surrealdb` |
| C5 | `signin(Root { … })` prend désormais des `String` (et non des `&str`). | Essai : `client.rs:95-96` |
| C6 | Le SDK fournit une passerelle `SerdeWrapper<T>`, mais sa documentation précise qu'elle **n'a pas la parité** avec `SurrealValue` (variantes d'enum, types natifs comme `RecordId` non préservés) et recommande `SurrealValue` « directement chaque fois que possible ». | `surrealdb-types/src/traits/surreal_value.rs` |
| C7 | Le derive `SurrealValue` gère `default`, `rename`, `rename_all`, `tag`, `content`, `untagged`, `flatten`, `skip_content_if`. Il ne gère **pas** `alias` ni `with`. | `surrealdb-types-derive` |

### Volume concerné (crates du workspace)

| Crate | Structs `serde` | `call_fn` | `.query(` directs | Lignes `src/` |
| :--- | ---: | ---: | ---: | ---: |
| `lyxal_error` | 17 | – | – | 468 |
| `lyxal_surreal` | 3 | 2 | 1 | 442 |
| `lyxal_event` | 42 | 21 | 3 | 7 126 |
| `lyxal_runtime` | 93 | – | 40 | 15 016 |
| `lyxal_pipeline_ingestion` | 69 | 27 | 12 | 7 992 |
| `apps/lyxal-server` | 20 | – | 5 | – |
| `lyxal_crypto` | 0 | – | – | non concerné |

Tests : ~22 000 lignes dans `crates/*/tests` et `apps/*/tests`.

## 3. Choix technique

| Option | Description | Décision |
| :--- | :--- | :--- |
| A. Passerelle `SerdeWrapper` | Garder tous les DTO `serde`, envelopper dans `call_fn`. Changement minimal. | **Rejetée** : perte de typage natif (`RecordId`, `Datetime`, enums), dette assumée dès le départ (C6). |
| B. Passer par `serde_json::Value` | Convertir chaque DTO en JSON avant `bind`. | **Rejetée** : même perte de types natifs, double conversion, logique de transport dupliquée. |
| **C. `SurrealValue` natif** | Chaque type qui traverse la frontière Rust ↔ SurrealDB dérive `SurrealValue`. | **Retenue** : conforme à la recommandation du SDK, zéro passerelle, types natifs préservés. |

`Serialize` / `Deserialize` ne restent **que** sur les types qui servent aussi à autre chose que la base (API HTTP JSON d'`apps/lyxal-server`, fichiers `manifest.toml`, configuration). Un type peut dériver les deux.

## 4. Contrats Rust modifiés

### 4.1. `lyxal_surreal` (contrat public central)

```rust
// Avant
async fn call_fn<T, P>(&self, function_name: &'static str, params: P) -> Result<T, LyxalSurrealError>
where T: DeserializeOwned + Send, P: Serialize + Send + 'static;

// Après
async fn call_fn<T, P>(&self, function_name: &'static str, params: P) -> Result<T, LyxalSurrealError>
where T: SurrealValue + Send, P: SurrealValue + Send + 'static;
```

* `create_surreal_client` : signature inchangée ; seul l'appel interne `signin(Root { username: String, password: String })` change.
* Ré-export depuis `lyxal_surreal` des types du SDK utilisés par les modules : `pub use surrealdb::types::{SurrealValue, RecordId, Datetime, Value};`. Les modules continuent de définir leurs alias dans `models/types.rs` (§12.2) à partir de ces types.
* `LyxalSurrealError::Database(surrealdb::Error)` : conservé ; vérifier la conversion `From` avec le nouveau type d'erreur.

### 4.2. `lyxal_error`

* `LyxalResult<T>` et `LyxalCallError`/structures d'erreur désérialisées depuis SurrealQL : dérivent `SurrealValue` (en plus de `Serialize`, car renvoyées aussi en JSON par l'API HTTP).
* `lyxal_error` ajoute la dépendance `surrealdb-types` (types uniquement, sans moteur) — **point à valider** (§8, Q2).

### 4.3. Modules consommateurs

* Tous les `XxxParams` / `XxxResult` et modèles lus en base : `#[derive(SurrealValue)]`.
* Attributs `serde` convertis vers leurs équivalents `SurrealValue` (`skip_serializing_if` → `skip_content_if`, etc.).
* `#[serde(alias = …)]` (10 occurrences) : **supprimés** — ce sont des compatibilités avec d'anciens noms de champs, interdites par le §0.
* `#[serde(with = …)]` (3 occurrences) : remplacés par le type natif (`Datetime`, `Duration`) ou une implémentation manuelle de `SurrealValue`.
* `surrealdb::sql::Thing as RecordId` → `lyxal_surreal::RecordId`.

## 5. Changements SurrealQL dans le Rust

* `type::thing('table', $key_id)` → `type::record('table', $key_id)` (10 occurrences dans `lyxal_runtime/src/lock/`).
* Revue de chaque requête `.query(...)` directe (61 au total) contre les règles du skill `lyxal-surrealdb` §2.5 (fonctions supprimées, signatures 3.x).
* **Correction (Lot 1)** : contrairement à ce qu'annonçait la première version de ce plan, 9 fichiers `.surql` sur 167 (hors `lyxal_core`) ne passent pas `surreal validate` en 3.3.4. Ils sont corrigés dans le lot de leur crate :

| Crate | Fichiers | Cause | Lot |
| :--- | :--- | :--- | :- |
| `lyxal_error` | 7 fichiers de `functions/` | `type::is::*` → `type::is_*` | 1 (corrigé) |
| `lyxal_event` | `tests/concurrency/lot3a_queries.surql` | fichier supprimé avec le dossier `tests/concurrency/` (décision CTO, Lot 2) | 2 (clos) |
| `lyxal_runtime` | `schema/fields.surql` | à analyser | 3 |

## 6. Fonctions Core, erreurs et crypto

* **Fonctions `lyxal_core` réutilisées** : aucune nouvelle ; aucune fonction Core manquante identifiée.
* **Nouvelles fonctions SurrealQL** : aucune.
* **Codes d'erreur master data** : aucun nouveau.
* **Besoin crypto** : aucun (`lyxal_crypto` n'utilise pas SurrealDB).

## 7. Lots d'exécution (un commit par lot)

> **Correction** : le workspace complet ne peut pas compiler entre les lots 1 et 5, car le changement de `call_fn` casse les crates appelants jusqu'à leur propre lot. À chaque lot, les crates **déjà migrés** compilent et leurs tests passent ; le workspace complet recompile au Lot 5. Rien n'est fusionné sur `main` avant la fin du Lot 6.

| Lot | Contenu | Vérification |
| :- | :--- | :--- |
| 1 ✅ | `Cargo.toml` racine : `surrealdb = { version = "3.3", features = ["protocol-ws", "protocol-http", "kv-mem"] }`. `lyxal_error` + `lyxal_surreal` : `SurrealValue`, `call_fn`, `signin`, ré-exports. | `cargo test -p lyxal_error -p lyxal_surreal` |
| 2 ✅ | `lyxal_event` : modèles, DTO, `event_store`, moteur, tests. | `cargo test -p lyxal_event` |
| 3 | `lyxal_runtime` : stores, verrous (`type::record`), migrations, santé, workers, tests. | `cargo test -p lyxal_runtime` |
| 4 | `lyxal_pipeline_ingestion` : stockage, publisher, tests. | `cargo test -p lyxal_pipeline_ingestion` |
| 5 | `apps/lyxal-server` : connexion, runtime, tests HTTP. | `cargo test -p lyxal-server` |
| 6 | Preuve 3.3.4 : `cargo clippy --workspace --all-targets -D warnings` ; suite complète ; tests serveur (`ws://`) contre un `surreal start` 3.3.4 local ; `surreal validate` sur tous les `.surql` du workspace. Mise à jour des skills qui citent `surrealdb = "2.2"`. | Rapport de tests joint |

Les écarts de comportement du moteur 3.3 révélés par les tests (C1) sont corrigés dans le lot du crate concerné et listés dans le rapport final.

## 8. Questions au CTO

* **Q1 — Version exacte** : le SDK `=3.3.4` tire ses sous-crates en `^3.3.4`, aujourd'hui résolues en **3.3.5**. Proposition : contrainte `"3.3"` dans `Cargo.toml` (moteur embarqué en 3.3.x le plus récent) et binaire serveur 3.3.x de même patch ; ou figer tout en 3.3.4 via `Cargo.lock`.
* **Q2 — `lyxal_error` et `surrealdb-types`** : `lyxal_error` est sous `lyxal_surreal` dans la hiérarchie et ne dépend pas de SurrealDB aujourd'hui. Pour que `LyxalResult<T>` dérive `SurrealValue`, il doit dépendre de `surrealdb-types` (types seuls, pas de moteur). Alternative : `lyxal_surreal` désérialise une structure interne puis la convertit en `LyxalResult<T>`. Recommandation : dépendance à `surrealdb-types` (plus simple, pas de duplication).
* **Q3 — Requêtes directes dans `lyxal_pipeline_ingestion`** : ce module métier fait 12 `.query(...)` directs, contraire au §11.5 (`raw_query` réservé au runtime, aux migrations et aux tests). Proposition : les **porter tels quels** dans ce chantier (changement de SDK uniquement), et les remplacer par des fonctions `fn::ingestion_*` lors de la reprise du module.

## 9. Hors périmètre

* `lyxal_booking/engine` (SDK 2.2) et `lyxal_scheduler/engine` (SDK 3) : hors workspace, traités à la reprise de chaque module.
* Toute refonte fonctionnelle des crates : seul le changement de SDK et ce qu'il impose est fait ici.

## 10. Checklist §13 (extraits pertinents)

* [x] Responsabilité dans le bon crate (`lyxal_surreal` reste le seul porteur de `call_fn`).
* [x] Aucune primitive Core dupliquée ; aucune nouvelle primitive Core ou crypto.
* [x] Aucune dépendance circulaire (Q2 ajoute une dépendance vers un crate externe de types, pas vers un crate Lyxal supérieur).
* [ ] Zéro dette : `alias` supprimés, aucune passerelle `serde` résiduelle — vérifié au Lot 6.
* [ ] Validation explicite du CTO.

---

## 11. Journal d'exécution

### Lot 1 — `lyxal_error` + `lyxal_surreal` (terminé)

* SDK résolu : `surrealdb` **3.3.5** (moteur embarqué des tests en 3.3.5) ; serveur de test : binaire **3.3.4**.
* `lyxal_error` : `LyxalResult<T: SurrealValue>` et `LyxalError` dérivent `SurrealValue` **et** `serde` (relus depuis SurrealDB et renvoyés en JSON par l'API) ; les 15 `XxxParams` ne dérivent plus que `SurrealValue`. 5 attributs `#[serde(alias)]` supprimés (§0). `into_result` : un succès sans donnée n'est accepté que si `T` accepte `NONE` (`()` ou `Option<_>`).
* `lyxal_surreal` : `call_fn<T: SurrealValue, P: SurrealValue>` ; `signin(Root { String, String })` ; ré-export `Datetime`, `RecordId`, `SurrealValue`, `Value` ; dépendance `serde` retirée.
* SurrealQL : 7 fichiers de `lyxal_error/functions/` corrigés (`type::is::*` → `type::is_*`).
* Tests d'intégration `lyxal_error` : chemin Windows en dur (`c:\Users\HP\...\surreal.exe`) remplacé par `LYXAL_SURREAL_BIN`, à défaut `surreal` dans le `PATH`. Ils ne pouvaient s'exécuter que sur un poste ; ils passent désormais sur 3.3.4.
* Nouveau test `test_remote_ws_root_signin_and_call_fn` (ignoré par défaut, lancé avec `LYXAL_SURREAL_WS_URL`) : connexion `ws://` + Root + `call_fn` réels.
* Point d'attention pour les lots suivants : un `Option<_>` n'accepte que `NONE`, pas `NULL`. Les contrats `fn::result_ok` / `fn::error_result` renvoient bien `NONE`.
* Résultats : `cargo test -p lyxal_error -p lyxal_surreal --all-features` → 39 tests OK (dont 6 sur serveur 3.3.4) + test distant OK ; `cargo clippy … -D warnings` OK ; `cargo fmt` appliqué aux deux crates.

### Lot 2 — `lyxal_event` (terminé)

* **Modèles publics** (`LyxalEventEnvelope`, `EventContext`, `EventDelivery`, `EventSubscription`, `EventDeadLetter`) : `SurrealValue` + `serde` (JSON des payloads et de l'API). **DTO internes** (`engine/dto.rs`, paramètres privés de `event_store.rs`) : `SurrealValue` seul.
* **Identifiants typés** : `LyxalEventEnvelope.event_id` / `correlation_id` / `causation_id` passent de `uuid::Uuid` aux types existants `EventId` / `CorrelationId` / `CausationId`, qui implémentent `SurrealValue` sous forme de chaîne (conforme à `TYPE string` du schéma). Les modules `uuid_serde` / `opt_uuid_serde` (lecture tolérante de plusieurs anciens formats) sont supprimés (§0). `with_correlation_id` / `with_causation_id` prennent désormais les types typés. `PendingDeliveryItem` est typé (`EventContext`, `EventId`…) au lieu de chaînes et de JSON décodés avec repli silencieux.
* **`RecordId` en 3.x** : plus de `Display` ni de `FromStr`. Remplacés par `to_sql()` (trait `ToSql`, ajouté aux ré-exports de `lyxal_surreal`) et `RecordId::parse_simple` / `RecordId::new`.
* **Énumérations unitaires** : par défaut le derive encode `Pending` en `{pending: {}}`. `DeliveryStatus` utilise `#[surreal(untagged, rename_all = "snake_case")]` pour être lu et écrit en chaîne (`'pending'`), comme en base.
* **SurrealQL** : `fn::event_publish` convertit `event_id` / `correlation_id` / `causation_id` en chaîne (`<string>`). En 3.x, `rand::uuid::v7()` renvoie un `uuid` natif ; sans cette conversion, l'exemple officiel de `DEFINE EVENT` (§5.6.1) échouait sur `TYPE string`. Le test `integration_define_event` couvre ce cas.
* **Tests** : dossier `tests/concurrency/` supprimé (≈ 3 600 lignes de bancs d'essai des lots 3A/3B, tous ignorés, chemins Windows en dur, scripts PowerShell — décision CTO). Fixture de `integration_dto_contracts` corrigée (champs `published` / `published_at` absents du schéma : ignorés en 2.x, refusés en 3.3).
* **Résultats** : `cargo test -p lyxal_event` → 80 tests OK + test de charge ignoré `integration_concurrency_1000` lancé à part (1 000 événements, OK) ; `cargo clippy -p lyxal_event --all-targets -D warnings` OK ; `cargo fmt` appliqué ; 27/27 `.surql` valides en 3.3.4. Les trois crates migrés : 117 tests OK.

#### Défauts existants relevés (hors périmètre, à traiter à la reprise de `lyxal_event`)

1. **Classification des erreurs par texte** : `EventStore::claim_batch` (et les autres méthodes au même schéma) réessaie dès que le message d'erreur contient « conflict » ou « retry ». Une erreur de désérialisation citant le champ `next_retry_at` a ainsi été réessayée ; le premier essai ayant déjà réclamé la livraison, le second renvoyait une liste vide — erreur masquée (§11.4). Il faut tester le type d'erreur, pas son texte.
2. **Replis silencieux dans `EventWorker::fetch_and_enqueue_pending`** : un `event_id` absent est remplacé par un identifiant neuf, un contexte absent par le contexte par défaut.
3. **Test `integration_concurrency_1000`** : marqué « Legacy … superseded by unified streaming architecture » ; à supprimer ou réécrire selon §0.
4. **En-têtes de licence ASF** dans `engine/*.rs` (licence Apache Software Foundation), incohérents avec la licence du workspace.

