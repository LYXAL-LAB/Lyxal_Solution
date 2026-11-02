# Audit de reprise — `lyxal_surreal`

Audit en lecture seule (skill `lyxal-audit`), état de `main` au 2026-11-02, après la reprise de
`lyxal_error` (#31 à #34). Supprimé à la clôture de la reprise (`AGENTS.md` §0.3.4).

## 1. Périmètre et position dans le graphe

* Crate `lyxal_surreal` `0.1.0`, **fondation technique** (§5.2, §6) : au-dessus de `lyxal_error`,
  au même niveau que `lyxal_crypto`, sous `lyxal_event`, `lyxal_runtime` et les modules métiers.
* Dépendances : `surrealdb`, `serde_json`, `async-trait`, `thiserror`, `lyxal_error`, `axum`
  (optionnel). Dépendants : `lyxal_event`, `lyxal_runtime`, `lyxal_pipeline_ingestion`.
  Aucun cycle.
* Fichiers inspectés intégralement : `Cargo.toml`, `src/lib.rs`, `src/call.rs`, `src/client.rs`,
  `src/error.rs`, `tests/it/main.rs`, `tests/it/call_tests.rs`, `README.md`,
  `LYXAL_SURREAL_IMPLEMENTATION_REPORT.md`. Recoupement :
  `apps/lyxal-server/src/database.rs`, `apps/lyxal-server/src/config.rs`,
  `crates/lyxal_crypto/src/secret.rs`, `scripts/ci/test_all.sh`, `scripts/ci/clippy.sh`.
* Pas de SurrealQL, pas de `manifest.toml` (crate Rust pur).

## 2. Synthèse et verdict

**NON CONFORME** : 1 écart P0, 2 écarts P1, 4 écarts P2.

Le cœur du crate est sain : `call_fn` est l'unique exécuteur `RETURN fn::<nom>($params)`, sans
`panic!` ni erreur masquée, avec un nom de fonction filtré et un contrat `{ ok, data, error }`
strictement vérifié. Les règles §11.2 (schémas d'URL, Root obligatoire en distant, jamais en
mémoire) sont bien codées dans `create_surreal_client` et prouvées contre un serveur 3.3.4.

Les écarts portent sur :
* un mot de passe visible dans `Debug` ;
* une fabrique de connexion que personne n'utilise, `lyxal-server` se connectant lui-même sans ses
  contrôles ;
* les codes d'erreur HTTP, au préfixe d'un autre module et sans définition.

## 3. Écarts constatés

| ID | Sév. | Règle | Fichier | Preuve | Correction recommandée |
| :- | :- | :- | :- | :- | :- |
| S-01 | P0 | §12.3 (redaction `Debug`), §11.3.6 (types sensibles) | `src/client.rs:77-81` | `RootCredentials` dérive `Debug` avec `password: String` : `{:?}` affiche le mot de passe Root en clair (journaux, traces d'erreur). | `Debug` manuel avec `[REDACTED]`, ou mot de passe en `lyxal_crypto::SecretString` (décision Q1). |
| S-02 | P1 | §5.1 (une responsabilité, un endroit), §11.1, §11.2 | `src/client.rs:137-172` ; `apps/lyxal-server/src/database.rs:18-46` | `create_surreal_client` n'a **aucun appelant** dans le dépôt. `lyxal-server` réécrit la connexion avec `any::connect` + `signin`. Par rapport aux règles : aucun contrôle du schéma d'URL ; un `ws://` sans identifiants est accepté ; un `mem://` avec identifiants tente un `signin` Root. | Compléter la fabrique avec ce dont l'hôte a besoin (délai de connexion, sélection namespace/base) et la faire utiliser par `lyxal-server` dans le même changement (décision Q2). |
| S-03 | P1 | §5.5, §7 (préfixe du module propriétaire, master data) | `src/error.rs:49, 67, 85, 103` | `IntoResponse` émet `CORE_DATABASE_ERROR`, `CORE_INVALID_FUNCTION_NAME`, `CORE_UNSUPPORTED_ENDPOINT`, `CORE_MISSING_CREDENTIALS`. Ce sont les seuls codes `CORE_*` émis en Rust dans le dépôt. Le préfixe est celui de `lyxal_core`, et aucun de ces codes n'a de définition (`error/core/core_definitions.surql` n'en contient que 3, tous de `lyxal_core`). | Préfixe `SURREAL_*` et définitions master data (emplacement : décision Q3). |
| S-04 | P2 | Cohérence du référentiel `lyxal_error` | `src/error.rs:55, 106` et statuts HTTP | `category: "security"` n'existe pas dans les catégories de `error_definition` (le schéma la refuserait en master data). `Database` est toujours `retryable: true`, alors qu'il couvre aussi les erreurs de requête (fonction inconnue, `THROW`, permissions). `UnsupportedEndpoint` (400) et `MissingCredentials` (401) sont des erreurs de configuration du serveur, pas de la requête du client. | Catégories et statuts du référentiel (décision Q4). |
| S-05 | P2 | §0.2 (documents historiques) | `LYXAL_SURREAL_IMPLEMENTATION_REPORT.md` | Rapport de clôture d'une « v0.2.0 » jamais livrée, citant SurrealDB 3.2.0, le SDK 2.6.5 et un chemin Windows local. | Supprimer. |
| S-06 | P2 | §0.3.4 (documentation de l'état actuel) | `README.md` | Badges « Production-Ready » et « Tests Passed » ; renvoi vers `../.agents/...` cassé (le bon chemin est `../../.agents/...`) ; codes `CORE_*`. | Réécrire à l'état actuel. |
| S-07 | P2 | Couverture | `src/error.rs:147-175` | Le test `axum` ne vérifie que les statuts HTTP, pas les codes ni le corps `{ ok, data, error }`. Le cas `Call(...)` n'y figure pas. | Vérifier code, statut et forme du corps pour chaque variante. |

## 4. Correspondance DTO ↔ SurrealQL

Sans objet : le crate ne définit aucune fonction SurrealQL ni `*Params`. Il transporte ceux des
modules : `call_fn<T, P: SurrealValue>` lie `P` à `$params` sans conversion JSON intermédiaire
(`src/call.rs:41-49`). Un test (`src/lib.rs:45-68`) vérifie que `RecordId` et `Datetime`
traversent en types natifs.

## 5. Preuves d'exécution et points non vérifiés

Exécuté (2026-11-02, binaire `surreal` 3.3.4) :

| Commande | Résultat |
| :- | :- |
| `cargo test -p lyxal_surreal --features axum` | 10 tests unitaires et 8 tests d'intégration réussis, 1 ignoré (le test distant, lancé ci-dessous). |
| `LYXAL_SURREAL_WS_URL=ws://127.0.0.1:18777 cargo test -p lyxal_surreal --features axum -- --ignored`, contre `surreal start … memory` 3.3.4 | `test_remote_ws_root_signin_and_call_fn` réussi : connexion `ws://`, `signin` Root, `call_fn`. |
| `cargo clippy -p lyxal_surreal --all-targets --features axum -- -D warnings` | Aucune remarque. |

La CI rejoue le test distant (`scripts/ci/test_all.sh:48`).

Non vérifié : `wss://` (TLS), aucun serveur TLS n'étant disponible dans la CI.

## 6. Éléments conformes

* **Transport unique** : `Surreal<Any>` uniquement, sans `enum` Ws/Mem local (§11.1) ;
  `call_fn` est le seul exécuteur (`src/call.rs:28-57`).
* **Filtrage du nom de fonction** : `^[a-z0-9_]+$` avant toute requête (`src/call.rs:10-15`,
  `:36-40`) ; tentative d'injection testée (`tests/it/call_tests.rs`).
* **Contrat vérifié** : `NONE` donne `InvalidContract` ; un état incohérent est rejeté par
  `LyxalResult::into_result` (`src/call.rs:51-55`).
* **Zéro `panic!` et erreurs propagées** : aucun `unwrap`, `expect` ni `panic!` hors tests ;
  les erreurs SDK sont propagées par `?` dans `Database` (§11.4).
* **Règles §11.2 codées et testées** : `src/client.rs:115-172`.
* **Pas de `raw_query()`** dans le crate (§11.5 sans objet).
* **Cryptographie et versions** : aucune dépendance cryptographique (§11.3) ; version `0.1.0`.

## 7. Plan correctif

Voir `implementation_plan.md` (soumis au CTO).
