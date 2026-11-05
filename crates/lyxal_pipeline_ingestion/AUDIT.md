# Audit de reprise — `lyxal_pipeline_ingestion`

Audit en lecture seule (skill `lyxal-audit`), réalisé sur `main` après la clôture de
`lyxal_catalogue` (#60 à #64).

## 1. Périmètre et position dans le graphe

* **Module** : `crates/lyxal_pipeline_ingestion`, **hybride Rust + SurrealQL**, version `0.1.0`.
  * SurrealQL : 11 tables (`schema/`), 20 fonctions (`functions/`), 2 `DEFINE EVENT`
    (`events/`), 10 définitions d'erreurs (`error/`), 4 fichiers de seeds, 1 migration
    (environ 3 000 lignes).
  * Rust : 33 fichiers (environ 8 700 lignes) : adaptateurs FAB-DIS / CSV / XML / JSON,
    normalisation, regroupement technique, quarantaine, empreintes, publication, worker,
    `LyxalModule`, sonde de santé.
  * Tests : 8 fichiers d'intégration Rust, 30 tests unitaires ; script PowerShell.
  * Documents : `README.md`, `ROADMAP.md`, `CHANGELOG.md`, `implementation_plan.md`, 6 documents
    `docs/`.
* **Niveau** : module métier (`AGENTS.md` §6). Manifeste : dépend de `lyxal_core`, `lyxal_base`,
  `lyxal_error`, `lyxal_event`. Hébergé par `lyxal-server` (fonctionnalité `module-ingestion`,
  `PipelineIngestionModule`, `IngestionWorker`, `IngestionHealthCheck`).
* **Consommateur visé** : `lyxal_catalogue` (publication des articles qualifiés vers
  `fn::catalogue_item_create` / `_update`), **non déclaré** dans le manifeste.

Lu intégralement ou par extraits ciblés : `manifest.toml`, `Cargo.toml`, `schema/*`,
`functions/**`, `events/*`, `error/*`, `seeds/*`, `migrations/*`, `src/storage/store.rs`,
`src/publisher/controlled_publisher.rs`, `src/worker/ingestion_worker.rs`, `src/module.rs`,
`src/error.rs`, `src/normalization/*`, `src/quarantine/engine.rs`, `tests/it/*` (structure),
documents.

## 2. Synthèse et verdict

**NON CONFORME (P0 et P1 bloquants).**

Le module a une base solide : tables `SCHEMAFULL` avec permissions par rôle, machines à états
gardées par `DEFINE EVENT`, manifestes scellés par BLAKE3, worker supervisé et coopératif, DTO
Rust alignés champ par champ sur les fonctions SurrealQL, empreintes par `lyxal_crypto`, SurrealQL
valide en 3.3.4. Mais :

1. **deux élévations de privilèges** : un appelant choisit lui-même son rôle de Data Steward
   (paramètre `_session_auth`) et n'importe quel appelant approuve un manifeste
   (`approver_role` lu dans les paramètres, `steward_admin` par défaut) ;
2. **la publication vers le catalogue n'existe pas** : hors mode test elle échoue toujours, en
   mode test elle simule l'appel sans toucher au catalogue ; le contrat envoyé est de toute
   façon incompatible ;
3. **les deux événements publiés ne se déclenchent jamais** (statuts attendus inexistants) ;
4. erreurs masquées (résolution d'unité, passage en échec d'un lot, événement d'échec) ;
5. 30 codes d'erreur utilisés sans définition (10 définis sur 40) ;
6. aucune entrée validée par `lyxal_core` ;
7. un second schéma complet, écrit en dur dans le Rust, sert aux tests : ils ne prouvent pas
   le SurrealQL réellement installé.

## 3. Écarts constatés

| ID | Sév. | Règle | Fichier & lignes | Preuve | Correction recommandée |
| :- | :- | :--- | :--- | :--- | :--- |
| I-01 | P0 | §11.4 (sécurité), sessions | [`ingestion_staged_requalify.surql:13-27`](functions/staged/ingestion_staged_requalify.surql), [`ingestion_quarantine_resolve.surql:14-28`](functions/quarantine/ingestion_quarantine_resolve.surql), [`store.rs` `SessionAuthContext`, `_session_auth`](src/storage/store.rs) | Sans `$auth`, le rôle et l'opérateur sont lus dans `$params._session_auth` : `{ role: "steward_admin" }` suffit pour requalifier un article ou résoudre une quarantaine. | Identité lue uniquement dans la session (`$token` / `$auth`) ; `_session_auth` supprimé du contrat SurrealQL et Rust. |
| I-02 | P0 | idem | [`ingestion_manifest_approve.surql:4,23-30,40`](functions/manifest/ingestion_manifest_approve.surql) ; garde [`05_ingestion_publication_manifest.surql:165`](schema/05_ingestion_publication_manifest.surql) | `approver_role` vient des paramètres (`steward_admin` par défaut) ; la fonction écrit elle-même `approver_role = "steward_admin"`, ce qui neutralise la garde. `approved_by` est aussi libre. | Rôle et identité de l'approbateur lus dans la session ; garde fondée sur la session. |
| I-03 | P0 | §11.4 (erreurs masquées) | [`store.rs` `resolve_unit` (`Err(_) => Ok(None)`)](src/storage/store.rs) ; [`ingestion_worker.rs:455-472`](src/worker/ingestion_worker.rs) (`let _ =` sur le passage en `FAILED` et l'événement d'échec) ; `controlled_publisher.rs:300` ; `ingestion_worker.rs:400` | Une panne de base devient « unité non résolue » ; l'échec d'enregistrement de l'état `FAILED` ou de publication de l'événement est perdu. | Propagation (`?`) ou journalisation et remontée explicites. |
| I-04 | P1 | §1 (contrat public), §5.8.1 | [`controlled_publisher.rs:226-243, 316-355`](src/publisher/controlled_publisher.rs) ; [`manifest.toml`](manifest.toml) | Hors `isolated_test_mode`, `execute_catalogue_api` renvoie toujours `Unauthorized` ; en mode test, il exécute `RETURN { function_called, status: 'OK' }` sans appeler le catalogue. Les champs envoyés (`gtin`, `type_item`, `unite`, sans `code`) ne sont pas ceux du contrat (`code`, `type`, `unite_reference`, `code_barre`, `master_id`). Dépendance `lyxal_catalogue` non déclarée. L'appel exige une identité `catalogue_sync_agent` (`iss = lyxal-os`, scope `catalogue:sync:write`) que le module n'a pas. | Q1. |
| I-05 | P1 | §5.6.1 (événements) | [`events/01_events.surql`](events/01_events.surql) | `ingestion.batch.completed` attend `statut = "Completed"` : aucun lot n'a cet état (`RECEIVED` … `PUBLISHED`, `FAILED`). `ingestion.manifest.approved` attend `"Approved"`, la fonction écrit `"APPROVED"`. `DEFINE EVENT IF NOT EXISTS` : une correction ne serait jamais réinstallée. | Statuts réels, `OVERWRITE`, test qui prouve la publication dans `event_outbox`. |
| I-06 | P1 | §5.5 (codes définis) | [`functions/**`](functions), [`schema/*`](schema), [`src/error.rs:60-95`](src/error.rs), [`ingestion_worker.rs:468`](src/worker/ingestion_worker.rs) | 10 définitions pour 40 codes utilisés ; 30 sans définition : 14 émis par les fonctions (`INGESTION_BATCH_NOT_FOUND`, `_MANIFEST_NOT_FOUND`, `_PROOF_*`…), 8 levés par les gardes (`INGESTION_BATCH_ILLEGAL_STATE_TRANSITION`, `_MANIFEST_SEAL_REQUIRED`…), 8 par le Rust (`INGESTION_DB_ERROR`, `_VALIDATION_ERROR`, `_BATCH_FAILED`, `_MISSING_PROOF`…). Le serveur exclut le module de son test (`PENDING_TAKEOVER`). | Définitions par thème (`error/<thème>/`), catalogue Rust aligné, module retiré de `PENDING_TAKEOVER`. |
| I-07 | P1 | §5.7.8 | 20 fonctions (`functions/**`) | Aucun appel `fn::validation_*` / `fn::sanitize_*` ; nettoyage et défauts recopiés champ par champ (`string::trim`, `string::uppercase`, `<int>` qui lève une erreur brute). | Q2 : moteur `fn::validation_object_execute` / `fn::sanitize_object_execute`, `INGESTION_INVALID_PARAMETERS`. |
| I-08 | P1 | §5.1, §5.8.1, tests | [`store.rs:385-1396` `init_schema`](src/storage/store.rs) ; `create_in_memory` (20 usages dans les tests) | Second schéma complet en dur dans le Rust : 11 tables (dont une copie de `base_unite`), 117 champs, 22 fonctions, en `IF NOT EXISTS`, avec seeds en `UPSERT`. Les tests l'utilisent au lieu des fichiers installés par le manifeste. Seul `integration_manifest_install.rs` installe le vrai module. | Suppression ; tests sur le module installé depuis son manifeste (Q4). |
| I-09 | P1 | §5.4, §11.5 | [`store.rs`](src/storage/store.rs) : 11 `.query(...)` métier (`get_batch`, `find_batch_by_hash`, `save_raw_records_chunk`, `get_staged_items_by_batch`, `get_quarantine_by_batch`, `get_manifest`, `update_manifest_execution_item`, `load_family_rules`, `load_specifications`, `load_substitution_rules`) | Lectures et écritures métier écrites en Rust au lieu de fonctions `fn::ingestion_*` appelées par `call_fn`. | Fonctions SurrealQL publiques et wrappers une ligne. |
| I-10 | P1 | §5.1, §5.7.6 | [`src/normalization/gtin.rs`](src/normalization/gtin.rs) | Clé GS1 modulo 10 réimplémentée en Rust ; `lyxal_core` fournit `fn::validation_gtin` et la règle `gtin`. | Q3. |
| I-11 | P1 | Zéro `panic!` (§11.1) | [`quarantine/engine.rs:58-176`](src/quarantine/engine.rs) (8 `RwLock::…().unwrap()`), [`gtin.rs:57,60`](src/normalization/gtin.rs), [`normalization/mod.rs:326`](src/normalization/mod.rs), [`ingestion_worker.rs:81`](src/worker/ingestion_worker.rs) | `unwrap()` et `panic!` sur des chemins d'exécution. | Erreurs typées ; verrou empoisonné signalé. |
| I-12 | P1 | §11.4 | [`normalization/mod.rs:235-238`](src/normalization/mod.rs), [`adapters/json.rs:129`](src/adapters/json.rs), [`ingestion_worker.rs:259,278`](src/worker/ingestion_worker.rs) | `serde_json::to_string(...).unwrap_or_default()` : un échec de sérialisation produit l'empreinte BLAKE3 d'une chaîne vide (empreintes canoniques identiques). | Propagation de l'erreur. |
| I-13 | P1 | §11.4, §5.3 | `functions/**` (écritures) ; [`ingestion_batch_create.surql:15`](functions/batch/ingestion_batch_create.surql) | Aucune écriture vérifiée (une écriture refusée par les permissions est annoncée comme un succès) ; `statut` par défaut `"Staged"`, refusé par l'`ASSERT` du schéma (majuscules). | Contrôle `<MODULE>_WRITE_FORBIDDEN` ; défauts conformes au schéma. |
| I-14 | P1 | Sécurité (secret dans le dépôt) | [`tests/it/integration_staging_live_server.rs:43-48`](tests/it/integration_staging_live_server.rs) | Mot de passe de staging en dur en repli de `LYXAL_STAGING_PASS`. Le fichier, nommé « serveur réel », n'utilise ce serveur que dans un test sur six ; les autres passent par `create_in_memory` (I-08). | Aucun secret par défaut ; tests serveur réels regroupés et alimentés par `test_all.sh`. |
| I-15 | P1 | §5.1 (une responsabilité) | [`schema/00_core_primitives.surql`](schema/00_core_primitives.surql) (non déclaré) | Redéfinit `fn::result_ok` et `fn::error_result` (version dégradée, `message = code`). Installé, il écraserait celles de `lyxal_error`. | Suppression. |
| I-16 | P2 | §0.2, §0.3 | `CHANGELOG.md`, `implementation_plan.md` (plan exécuté), `docs/PHASE_5_*`, `docs/STAGING_*`, `docs/V1_CLOSURE_REPORT.md`, `tests/run_ingestion_phase1_tests.ps1` ; `migrations/0001_initial_schema.surql` (un simple `RETURN`) | Documents historiques ; migration sans contenu. `ROADMAP.md` (à conserver) et `README.md` contiennent des parties périmées (SurrealDB 3.2.0, « 22 fonctions », liens `file:///c:/…`). `docs/ARCHITECTURE_DESIGN.md` est à confronter au code. | Suppression ; roadmap et README à l'état actuel. |
| I-17 | P2 | Q5 | [`seeds/04_carrelage_demo.surql`](seeds/04_carrelage_demo.surql) | Données de démonstration installées partout. | Q5. |
| I-18 | P2 | Charte SurrealQL | `schema/*` | Tables sans `TYPE NORMAL` explicite. | `TYPE NORMAL SCHEMAFULL`. |

## 4. Correspondance DTO Rust ↔ `$params`

20 fonctions, chacune appelée par `store.call_fn` avec une structure `SurrealValue`.

| Fonction | Struct Rust | Conformes | Absents côté Rust | En trop côté Rust | Incompatibles |
| :--- | :--- | :-: | :--- | :--- | :--- |
| `ingestion_batch_create` | `BatchCreateParams` | 16 | — | — | défaut `statut` (I-13) |
| `ingestion_batch_checkpoint` | `BatchCheckpointParams` | 6 | — | — | — |
| `ingestion_batch_transition` | `BatchTransitionParams` | 3 | — | — | — |
| `ingestion_staged_save` | `StagedSaveParams` | 21 | — | — | — |
| `ingestion_quarantine_log` | `QuarantineLogParams` | 7 | — | — | — |
| `ingestion_manifest_save` | `ManifestSaveParams` | 16 | — | — | — |
| `ingestion_manifest_approve` | `ManifestApproveParams` | 3 | — | — | `approver_role` (I-02) |
| `ingestion_manifest_record_exec` | `ManifestRecordExecParams` | 5 | — | — | — |
| `ingestion_resolve_unit` / `_manufacturer` | `ResolveUnitParams` / `ResolveManufacturerParams` | 2 / 2 | — | — | — |
| `ingestion_rule_family_add` / `_spec_add` / `_substitution_add` | `FamilyRuleAddParams` / `SpecAddParams` / `SubstitutionRuleAddParams` | 4 / 9 / 11 | — | — | — |
| `ingestion_dashboard_metrics` | `DashboardMetricsParams` | 1 | — | — | — |
| `ingestion_staged_list` / `_quarantine_list` / `_manifest_list` | `StagedListFilter` / `QuarantineListFilter` / `ManifestListFilter` | 5 / 5 / 4 | — | — | — |
| `ingestion_staged_requalify` | `StagedRequalifyParams` | 6 | — | — | `_session_auth` (I-01) |
| `ingestion_quarantine_resolve` | `QuarantineResolveParams` | 6 | — | — | `_session_auth` (I-01) |
| `ingestion_manifest_get_detail` | `ManifestGetDetailParams` | 2 | — | — | — |

Appel sortant vers le catalogue (`controlled_publisher.rs`) : voir I-04 et le contrat de
`fn::catalogue_item_create` dans `crates/lyxal_catalogue/README.md`.

| Champ du catalogue | Ingestion envoie | Statut |
| :--- | :--- | :--- |
| `code` (requis) | — | **absent** |
| `type` (`catalogue_type:<CODE>`, requis) | `type_item` (texte) | **incompatible** |
| `unite_reference` (`base_unite:<CODE>`, requis) | `unite` (code canonique d'alias) | **incompatible** |
| `code_barre` | `gtin` | **incompatible** |
| `nature_reference` | — (défaut `GENERIQUE`, alors qu'un article fabricant est `COMMERCIALE`) | **incompatible** |
| `master_id` (article maître) | — | **absent** |
| `tenant_id` | `null` | refusé (`null` n'est pas un texte) |
| `reference_fabricant`, `fabricant`, `marque`, `libelle`, `conditionnement` | idem | conformes |

## 5. Preuves d'exécution et points non vérifiés

* **Exécuté** :
  * `surreal version` : 3.3.4 ; `surreal validate` sur les 39 fichiers `.surql` : tous valides ;
    aucune construction 2.x (`type::thing`, `type::is::`, `array::contains`, `option<any>`…) ;
  * `cargo test -p lyxal_pipeline_ingestion` (local, sans serveur de recette) : 30 tests
    unitaires et 39 tests d'intégration réussis, 1 échec attendu
    (`test_staging_live_connection_and_reconnection` exige le serveur `127.0.0.1:8001` démarré par
    `scripts/ci/test_all.sh`) ; `scripts/ci/ci_local.sh` complet réussi au lot 4 du catalogue,
    sans changement du module depuis.
* **Contrôles statiques** : manifeste contre fichiers, signatures, `COMMENT`, longueur des
  fonctions (toutes < 120 lignes), codes émis contre définis, idempotence des seeds (protégés),
  imports crypto (aucun direct ; BLAKE3 par `lyxal_crypto`), `tokio::spawn` (aucun), `unwrap`,
  requêtes Rust, croisement DTO.
* **Non vérifié** :
  * comportement des permissions et des gardes sous une vraie identité (aucun test sous
    jeton ; les tests passent par une session root sur le schéma recopié, I-08) ;
  * publication réelle vers le catalogue (inexistante, I-04) ;
  * déclenchement des événements (impossible en l'état, I-05) ;
  * cohérence de `docs/ARCHITECTURE_DESIGN.md` avec le code.

## 6. Éléments conformes

* 20 fonctions en `$params: object`, retour `fn::result_ok` / `fn::error_result`, `COMMENT`
  présent, aucune `fn::result_error`.
* Tables `SCHEMAFULL` avec permissions par rôle (`$token` / `$auth`) ; gardes des machines à
  états (lots, qualification, manifestes).
* `LyxalModule`, `LyxalWorker` (boucle coopérative, `CancellationToken`, reprise par point de
  contrôle), `ModuleHealthCheck` ; aucun `tokio::spawn`.
* Cryptographie par `lyxal_crypto` uniquement ; aucune crate crypto importée.
* Seeds de référence protégés par `record::exists` ; DTO alignés sur les fonctions.
* SurrealQL valide en 3.3.4.

## 7. Plan correctif

Voir `implementation_plan.md` : décisions Q1 à Q5, puis les lots.
