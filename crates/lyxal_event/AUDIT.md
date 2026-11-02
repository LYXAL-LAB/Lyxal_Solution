# Audit de reprise — `lyxal_event`

Audit en lecture seule (skill `lyxal-audit`), état de `main` au 2026-11-02, après la reprise de
`lyxal_crypto` (#38). Supprimé à la clôture de la reprise (`AGENTS.md` §0.3.4).

## 1. Périmètre et position dans le graphe

* Crate et module `lyxal_event` : Cargo `0.1.0` (workspace), **`manifest.toml` en `1.0.0`**.
  Noyau technique (§5.2, §6) : au-dessus de `lyxal_error` et `lyxal_surreal`, sous
  `lyxal_runtime`, qui l'utilise (`EventStore`, `EventWorker`, `GarbageCollector`,
  `EventPublisher`). Comme `lyxal_runtime` en dépend, `LyxalWorker` et `LyxalModule` ne
  peuvent pas être exigés ici (Contrôle 2).
* Ressources : 6 schémas, 20 fonctions SurrealQL, 15 définitions d'erreurs. Le manifeste
  correspond exactement aux fichiers sur disque. Environ 7 200 lignes de Rust (`src/`) et
  9 fichiers de tests d'intégration.
* Fichiers inspectés : manifeste, `Cargo.toml`, tous les `.surql` (analyse statique scriptée
  et lecture ciblée), `src/store/event_store.rs`, `src/worker/worker.rs`,
  `src/engine/{feeder,lease}.rs`, `src/engine/dto.rs`, `src/lib.rs`, la liste des tests,
  `CHANGELOG.md`, `ROADMAP.md`, `docs/*.md`.

## 2. Synthèse et verdict

**NON CONFORME** : 3 écarts P0, 8 écarts P1, 6 écarts P2 (dont 4 découverts au lot 2 en éprouvant le chemin de production : V-14 à V-17).

Le cœur du moteur est solide :
* tous les appels passent par `call_fn` ;
* le fencing par bail à génération est présent dans les fonctions d'avancement ;
* l'invariant de contiguïté du curseur est contrôlé en base ;
* les définitions d'erreurs sont idempotentes ;
* aucun `unwrap`, `expect` ni `panic!` hors tests.

Les écarts majeurs :
* entrées SurrealQL validées à la main, sans `lyxal_core` ;
* deux chemins de livraison coexistent, et la plupart des tests d'intégration éprouvent
  l'ancien, pas celui de production ;
* erreurs masquées dans le worker ;
* identifiants transmis en chaînes ;
* liste d'installation dupliquée en Rust.

## 3. Écarts constatés

| ID | Sév. | Règle | Fichier | Preuve | Correction recommandée |
| :- | :- | :- | :- | :- | :- |
| V-01 | P0 | Contrôle 3.3 (`PERMISSIONS`) | `schema/*.surql` (6 tables) | Aucune table ne déclare `TYPE NORMAL` ni `PERMISSIONS`. L'effet par défaut de SurrealDB est `NONE` pour les utilisateurs d'enregistrement, donc le risque effectif est faible. Mais la règle exige une déclaration explicite, comme `error_definition` (`PERMISSIONS NONE`). | `TYPE NORMAL SCHEMAFULL PERMISSIONS NONE` sur les 6 tables. |
| V-02 | P1 | §5.7.8 (entrées par `lyxal_core`) | `functions/*.surql` (20 fonctions) | Aucune fonction n'utilise `lyxal_core`, bien que le manifeste le déclare en dépendance. La validation est écrite à la main (`IF $params.x == NONE OR … == NULL`), puis suivie de conversions forcées non validées (`<number> $params.ttl_seconds`, `<string>`, `<record<…>>`). Rapport d'erreur libre (`{ field, message }`), sans `details.fields`. | `fn::validation_object_execute` en tête de chaque fonction ; `EVENT_INVALID_PARAMETERS` avec `details.fields` ; `unknown_keys: "reject"`. |
| V-03 | P1 | §5.3 (contrat), §11.4 | `functions/*.surql` | Langue codée en dur (`"fr"`, 10 occurrences), sans `$params.language`. `event_delivery_success` répond `result_ok(false)` quand `delivery_id` manque : une entrée invalide devient un succès. `event_claim_batch` invente un `worker_id` (`"worker_default"`) au lieu d'exiger la valeur. | `language` validé (défaut `fr`) ; champs obligatoires réellement obligatoires, `EVENT_INVALID_PARAMETERS` sinon. |
| V-04 | P1 | §0.2 (code mort, chemin hérité), Contrôle 8 | `src/worker/worker.rs:341-463`, `src/store/event_store.rs:266-331`, `functions/event_claim_batch.surql`, `functions/event_delivery_success.surql`, `src/worker/retry.rs` (`compute_lease_duration`) | Deux chemins de livraison coexistent : `EventWorker::run` (streaming : `feeder`, `event_delivery_assign_seq`, `event_flush_batch`), utilisé en production par `lyxal_runtime`, et `EventWorker::poll_cycle` (réclamation par lots `event_claim_batch` puis `event_delivery_success`/`failure`), appelé uniquement par des tests. 7 des 9 fichiers de tests d'intégration éprouvent `poll_cycle`. Le test `integration_concurrency_1000` est marqué « Legacy CAS claim test … superseded by unified streaming architecture » (et lancé par la CI via `--ignored`). | Supprimer le chemin hérité. Réécrire les tests d'intégration sur `EventWorker::run` (décision Q1). |
| V-05 | P1 | §11.4 (zéro erreur silencieuse) | `src/worker/worker.rs:470-521` | `let _ = self.store.recover_pending_fanouts(…)` ignore l'erreur. Une livraison sans métadonnées d'événement est livrée avec des valeurs inventées : `event_id` par défaut (UUID nul), `event_type` `"unknown"`, `version` 1, `created_at` par défaut, `context` vide (`unwrap_or_default`, `unwrap_or_else`). | Propager l'erreur. Traiter une livraison incomplète comme une donnée corrompue (DLQ ou erreur), jamais comme un événement fabriqué. |
| V-06 | P1 | Contrôle 4 (DTO), §11.5 (types natifs) | `src/engine/feeder.rs:301-307` ; `src/engine/dto.rs` | `feeder` construit les paramètres de `event_delivery_failure` par `serde_json::json!` : non typés, en doublon de `DeliveryFailureParams` de `event_store.rs`. Les DTO du moteur (`DeliveryAssignSeqParams`, `FlushBatchParams`, `DeadLetterTransferParams`, `ProgressGetParams`) transportent les identifiants en `String`, reconvertis en SurrealQL par `<record<…>>`. | Un seul `DeliveryFailureParams` typé. Identifiants en `RecordId`. |
| V-07 | P1 | §5.1 (un seul endroit), §11.5 | `src/store/event_store.rs:122-203` | `EventStore::init_schema` (`pub`) recopie à la main les 27 ressources du manifeste (`include_str!`) et exécute le DDL par `.query()`. Toute ressource ajoutée doit l'être à deux endroits. Il est appelé par `lyxal_runtime` (`auto_init_schema`) et par tous les tests. | Décision Q3. |
| V-08 | P2 | §5.3 (retour unique) | `functions/event_flush_batch.surql`, `event_delivery_assign_seq.surql`, `event_dead_letter_transfer.surql` | 8 `THROW` (fencing, monotonie, invariant de contiguïté). Ils sont nécessaires quand l'échec survient après des écritures : dans `event_flush_batch`, les contrôles des lignes 104 et 119 suivent les mises à jour des lignes 65 à 84, et seul le `THROW` annule l'ensemble. Côté Rust, l'erreur est reconnue par recherche de texte (`err_str.contains("EVENT_STALE_LEADER_FENCED")`). | Décision Q2. |
| V-09 | P2 | §5.8.3 (tâches supervisées) | `src/worker/worker.rs:101, 154, 208` ; `src/engine/lease.rs:240` | Quatre tâches `tokio::spawn`. Elles coopèrent avec le `CancellationToken`, mais deux poignées ne sont jamais attendues : la reprise des fan-outs et la liaison des annulations. Une panique ou une erreur y passerait inaperçue. | Conserver et attendre toutes les poignées à l'arrêt. |
| V-10 | P2 | §0.2 (code mort) | `error/events.surql` | 7 codes définis et jamais émis : `EVENT_CLAIM_FAILED`, `EVENT_HANDLER_TIMEOUT`, `EVENT_LEASE_ACQUIRE_FAILED`, `EVENT_LEASE_LOST`, `EVENT_NOT_FOUND`, `EVENT_PROGRESS_NOT_FOUND`, `EVENT_SUBSCRIPTION_NOT_FOUND`. | Supprimer ceux que le contrat cible n'utilise pas. |
| V-11 | P2 | §0.3.3, §0.3.4 | `manifest.toml`, `CHANGELOG.md`, `ROADMAP.md`, `docs/*.md`, `readme.md`, `tests/it/integration_lot3b3_bridge.rs` | Manifeste en `1.0.0`. Changelog et roadmap avant toute livraison. Documents citant SurrealDB 3.2.0. `readme.md` en minuscules. Nom de test hérité d'un ancien lot. | `0.1.0`, suppression, documents à l'état actuel. |
| V-12 | P2 | Cohérence (`lyxal_error`) | `functions/*.surql` | Aucune fonction ne déclare `PERMISSIONS` : `FULL` par défaut. | `PERMISSIONS FULL` explicite, comme `lyxal_error`. |
| V-13 | P2 | Couverture | `tests/it/` | Le chemin de production n'est éprouvé de bout en bout que par `integration_lot3b3_bridge` et des tests unitaires du moteur. | Couvert par Q1. |
| V-14 | P0 | §5.6.4 (un flux ordonné par abonnement) | `src/worker/worker.rs`, `src/engine/feeder.rs:208` | **Découvert au lot 2.** Le worker utilise une seule file pour tous les abonnements, rangée par numéro de séquence, alors que chaque abonnement numérote ses livraisons à partir de 1. Dès que deux abonnements reçoivent le même événement, la seconde livraison porte le même numéro : elle est ignorée et reste en `processing`. `lyxal_runtime` crée un seul worker pour tous les abonnements, donc la production est touchée. | Une file par abonnement dans le worker (décision CTO). |
| V-15 | P0 | §5.6.4 (barrière DLQ) | `src/worker/worker.rs` (`dead_letter_topic`) | **Découvert au lot 2.** La politique `DeadLetter` exige un topic, absent par défaut de `EventWorkerConfig` comme de `lyxal_runtime`. Une livraison dont les tentatives sont épuisées n'est jamais transférée en DLQ (« Dead letter topic must be configured ») et reste bloquée. | Topic par défaut propre à l'abonnement. |
| V-16 | P1 | §5.8.3 (tâches supervisées) | `src/worker/worker.rs` (heartbeat) | **Découvert au lot 2** (aggrave V-09). Si la tâche d'un worker est interrompue, sa tâche de renouvellement du bail, lancée à part, continue seule : elle garde le bail indéfiniment, aucun autre worker ne prend le relais. | Tâches de fond liées à la vie du worker (`AbortOnDropHandle`). |
| V-17 | P1 | §5.6.3 (at-least-once), §11.4 | `src/engine/progress.rs`, `src/engine/feeder.rs` | **Découvert au lot 2** (≈ 1 exécution sur 5 du test de concurrence). Un conflit d'écriture transitoire sur `event_flush_batch` n'est pas rejoué. Le flush n'étant relancé qu'au prochain acquittement, la dernière livraison d'un abonnement reste verrouillée et le curseur bloqué. | Rejeu borné des conflits transitoires ; rattrapage du flush en attente à chaque tour du worker. |

## 4. Correspondance DTO ↔ SurrealQL

Comparaison champ par champ entre les `*Params` sérialisés par `SurrealValue` et les
`$params.<champ>` lus en SurrealQL :

| Fonction | Struct Rust | Conformes | Absents | En trop | Incompatibles |
| :- | :- | :- | :- | :- | :- |
| `event_publish` | `PublishParams` | les 11 champs | — | — | — |
| `event_fanout` | `FanoutParams` | `outbox_id` (`RecordId`) | — | — | — |
| `event_recover_pending_fanouts` | `RecoverFanoutParams` | `limit` | — | — | — |
| `event_claim_batch` | `ClaimParams` | `limit`, `lease_seconds`, `worker_id`, `instance_id` | — | — | — (chemin hérité, V-04) |
| `event_delivery_success` | `DeliverySuccessParams` | `delivery_id` | — | — | — (chemin hérité) |
| `event_delivery_failure` | `DeliveryFailureParams` ; `json!` dans `feeder` | `delivery_id`, `error`, `retry_delay_seconds` | — | — | appel non typé dans `feeder` (V-06) |
| `event_dead_letter_replay` | `DeadLetterReplayParams` | `dead_letter_id` | — | — | — |
| `event_purge_garbage` | `PurgeGarbageParams` | `retention_days` | — | — | — |
| `event_subscription_register` | `SubscriptionRegisterParams` | les 6 champs | — | — | — |
| `event_outbox_get`, `event_delivery_get` | `OutboxGetParams`, `DeliveryGetParams` | `id` | — | — | — |
| `event_dead_letter_list` | `DeadLetterListParams` | `limit`, `delivery` | — | — | — |
| `event_delivery_fetch_pending` | `DeliveryFetchPendingParams` | `limit`, `instance_id`, `subscription` | — | — | `subscription` en `String` |
| `event_progress_get` | `ProgressGetParams` | `subscription` | — | — | `String` converti en `record` (V-06) |
| `event_delivery_assign_seq` | `DeliveryAssignSeqParams` | les 7 champs | — | — | `outbox_event`, `subscription` en `String` |
| `event_flush_batch` | `FlushBatchParams` | les 8 champs | — | — | `subscription` et identifiants (`Vec<String>`) en chaînes |
| `event_dead_letter_transfer` | `DeadLetterTransferParams` | les 4 champs | — | — | `delivery_id` en `String` |
| `event_lease_acquire`, `event_lease_renew`, `event_lease_release` | `Lease*Params` | tous | — | — | — |

Aucun champ ne manque ni n'est en trop. Les incompatibilités sont des identifiants en chaînes,
convertis en SurrealQL. Ils fonctionnent, mais contournent les types natifs (§11.5).

## 5. Preuves d'exécution et points non vérifiés

| Commande | Résultat |
| :- | :- |
| `cargo test -p lyxal_event` | 50 tests unitaires et 30 tests d'intégration réussis. 1 test ignoré (`integration_concurrency_1000`, chemin hérité), lancé par la CI via `--ignored`. |
| `cargo clippy -p lyxal_event --no-deps --all-targets --all-features -- -D warnings` | Aucune remarque. |
| `surreal validate` (3.3.4) sur les 27 fichiers `.surql` | Tous valides. |

Non vérifié :
* les permissions effectives pour une session d'enregistrement : les tests tournent en `root`
  ou en `mem://` ;
* le chemin streaming sous concurrence réelle avec plusieurs instances : il n'existe de test de
  concurrence que pour le chemin hérité.

## 6. Éléments conformes

* **Transport** : tous les appels SurrealQL passent par `LyxalSurrealCall::call_fn`
  (`EventStore`, `feeder`), sans requête métier directe.
* **Fencing transactionnel** : garde conditionnelle sur `event_stream_lease` dans
  `event_delivery_assign_seq`, `event_flush_batch` et `event_dead_letter_transfer` ;
  `EVENT_STALE_LEADER_FENCED`.
* **Contiguïté** : le curseur n'avance que si toutes les séquences antérieures sont résolues
  (`event_flush_batch`, contrôles `UNRESOLVED_SEQUENCES` et `MISSING_SEQUENCE_HOLE`).
* **Reprise** : `event_delivery_assign_seq` reverrouille une livraison existante sans changer
  sa séquence.
* **Définitions d'erreurs** : préfixe `EVENT_`, forme `IF !record::exists(…) THEN ( CREATE … ) END;`.
* **Code Rust** : aucun `unwrap`, `expect` ni `panic!` hors tests ; aucune dépendance
  cryptographique ; `fastrand` sert uniquement au tirage des délais de retry.
* **Découplage** : les producteurs publient par `fn::event_publish` ou `EventPublisher`, sans
  référence aux consommateurs.

## 7. Plan correctif

Voir `implementation_plan.md` (soumis au CTO).
