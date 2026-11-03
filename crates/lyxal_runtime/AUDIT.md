# Audit de reprise — `lyxal_runtime`

Audit en lecture seule (skill `lyxal-audit`), réalisé sur `main` après la clôture de
`lyxal_event` (#44).

## 1. Périmètre et position dans le graphe

* **Crate** : `crates/lyxal_runtime`, version `0.1.0` (workspace). Environ 15 100 lignes de Rust
  dans 102 fichiers `src/`, 3 fichiers `schema/*.surql`, 34 fichiers de tests d'intégration.
* **Niveau** : noyau technique (`AGENTS.md` §6), au même niveau que `lyxal_event`. Dépendances :
  `lyxal_error`, `lyxal_surreal`, `lyxal_event`, `lyxal_crypto`. Aucune dépendance circulaire.
* **Consommateurs** : `lyxal_pipeline_ingestion` (types `ModuleId`, `LyxalModule`,
  `ModulePackage`, `ResourceProvider`…). **`apps/lyxal-server` ne dépend pas de
  `lyxal_runtime`** : le runtime n'est instancié par aucun hôte (§5.8.5).
* **Pas de `manifest.toml`**, pas de `functions/`, pas de `error/`.

Fichiers lus intégralement ou par extraits ciblés : `Cargo.toml`, `schema/*.surql`,
`src/manifest/*`, `src/resource/discovery.rs`, `src/store/surreal.rs`, `src/lock/*`,
`src/migration/{discovery,runner}.rs`, `src/runtime.rs`, `src/controller/controller.rs`,
`src/reconciler/reconciler.rs`, `src/worker/{supervisor,report,handle}.rs`,
`src/health/{engine,store}.rs`, `src/event/{bus,store,id}.rs`, `src/error.rs`,
`src/event_engine/*`.

## 2. Synthèse et verdict

**NON CONFORME (P0 et P1 bloquants).**

Le runtime est riche (cycle de vie, DAG, réconciliation, workers supervisés, santé, baux) et ses
189 tests passent. Mais :

1. son contrat central, le manifeste, n'est pas implémenté : `[resources]` est ignoré ;
2. sa persistance est écrite en SurrealQL inline dans le Rust, sans fonctions, sans permissions
   et avec un schéma recopié en quatre endroits ;
3. les baux de migration et d'installation reposent sur l'horloge locale de chaque nœud et sur un
   identifiant de nœud fabriqué maison, et les migrations ne renouvellent pas leur bail ;
4. de nombreuses erreurs de persistance et d'enregistrement sont jetées sans trace ;
5. aucun de ses quelque 100 codes d'erreur n'a de définition en master data, et une quarantaine
   ne portent pas le préfixe `RUNTIME_`.

## 3. Écarts constatés

| ID | Sév. | Règle | Fichier & lignes | Preuve | Correction recommandée |
| :- | :- | :--- | :--- | :--- | :--- |
| R-01 | P0 | Contrôle 3.3 (`PERMISSIONS`) | `schema/tables.surql:5-27` ; `src/store/surreal.rs:85+`, `src/health/store.rs:97+`, `src/worker/store.rs:173+`, `src/event/store.rs:42+` | Les 8 tables `system_*` sont `SCHEMAFULL` sans `TYPE NORMAL` ni `PERMISSIONS`. | `TYPE NORMAL SCHEMAFULL PERMISSIONS NONE`, comme les autres modules du noyau. |
| R-02 | P0 | §11.4 (zéro erreur silencieuse) | `src/runtime.rs:370,381` (enregistrement des workers du moteur d'événements) ; `src/runtime.rs:485,498` (enregistrement des modules d'un package) ; `src/reconciler/reconciler.rs:275` (statut `Inactive`) ; `src/controller/controller.rs:333` (instantané de santé) ; `src/worker/supervisor.rs:615` (état d'un worker) ; `src/reconciler/reconciler.rs:97,103` (`to_descriptor().ok()`) ; `src/health/engine.rs:225,232` (sémaphore, panique d'une sonde) | Résultats jetés par `let _ =` ou `.ok()`. Exemples : un worker du moteur d'événements non enregistré n'est jamais signalé ; une écriture de statut ou de santé qui échoue disparaît ; une sonde qui panique sort du rapport de santé sans trace. Un seul `tracing::` dans tout le crate. | Propager l'erreur, ou la journaliser avec son contexte et la compter quand l'appelant ne peut pas échouer. |
| R-03 | P0 | §11.4 | `src/runtime.rs:583,601,644,652` ; `src/worker/report.rs:29` | `start_module_workers` renvoie un `WorkerBatchReport` dont `failed` liste les workers qui n'ont pas démarré. Le rapport est jeté (`let _ = …?`) : un module démarre « avec succès » sans ses workers. | Lire `failed` et le remonter (erreur typée ou état dégradé observable). |
| R-04 | P1 | §5.8.1 (contrat de manifeste) | `src/manifest/model.rs:50-75` ; `src/resource/discovery.rs:10-40` | `ModuleManifest` n'a pas de champ `resources` ni `workers`, et n'utilise pas `deny_unknown_fields`. La section `[resources]` de `lyxal_core`, `lyxal_error` et `lyxal_event` est ignorée sans erreur. Le runtime découvre à la place des noms fixes dans `schema/` (`tables.surql`, `fields.surql`…), qui ne correspondent à aucun module réel (`functions/`, `error/`). Chaque crate du noyau relit donc `[resources]` lui-même dans ses tests (`lyxal_error`, `lyxal_event`, `lyxal_surreal`) et `lyxal_event` garde son propre `EventStore::install`. | Le manifeste décrit `[resources]` (`schemas`, `functions`, `events`, `error_definitions`, `migrations`, `seeds`) et le runtime installe exactement ces fichiers, dans l'ordre déclaré ; clés inconnues refusées. |
| R-05 | P1 | §5.4, §10, §11.5 (logique dans SurrealQL, `call_fn`) | `src/store/surreal.rs` (11 requêtes), `src/lock/surreal.rs` (8), `src/lock/installation.rs` (8), `src/worker/store.rs` (4), `src/event/store.rs` (4), `src/health/store.rs` (3), `src/migration/runner.rs`, `src/schema/importer.rs` | Toute la persistance (releases, migrations, baux, santé, workers, journal) est du SurrealQL écrit en dur dans le Rust ; aucune fonction `fn::runtime_*`, aucun `call_fn` (0 occurrence). | Fonctions `fn::runtime_*($params: object)` dans `functions/`, appelées par `call_fn` ; entrées validées par les primitives de `lyxal_core`. |
| R-06 | P1 | §5.1 (un seul endroit) | `schema/*.surql` et les 4 `bootstrap` Rust cités en R-01 | Le schéma des 8 tables existe deux fois : dans `schema/*.surql` (qu'aucun code ne lit, seule la CI le valide) et recopié dans quatre `bootstrap` Rust (80 champs identiques aujourd'hui). | Un seul schéma, dans `schema/`, installé depuis le manifeste du runtime. |
| R-07 | P1 | §5.6.4 (fencing), sûreté des baux | `src/lock/surreal.rs:205-245`, `src/lock/installation.rs:119-135,275-322` | L'expiration des baux de migration et d'installation est calculée avec `SystemTime::now()` du nœud, transmise en paramètre (`$now_secs`). Un écart d'horloge entre nœuds permet deux détenteurs simultanés. `lyxal_event` utilise l'heure de la base. | Expiration et comparaison avec `time::now()` côté base, dans les fonctions SurrealQL des baux. |
| R-08 | P1 | Sûreté des baux | `src/lock/node_id.rs:18-31` ; `Cargo.toml:23` | `NodeId::generate` hache PID et nanosecondes, tronqués à 8 caractères hexadécimaux (32 bits). En conteneur, le PID vaut souvent 1. Deux nœuds au même identifiant se croient tous deux propriétaires d'un bail. `uuid` est en dépendance mais jamais utilisé. | Identifiant aléatoire UUID v7 (`uuid`), comme `lyxal_event`. |
| R-09 | P1 | Sûreté des migrations | `src/migration/runner.rs:236-260,397-494` | Le bail de migration n'est jamais renouvelé pendant l'exécution, et `record_migration` n'est pas protégé par la génération du bail. Une migration plus longue que le bail peut être exécutée en parallèle par un autre nœud. | Renouvellement pendant l'exécution, et enregistrement conditionné à la génération du bail (garde atomique, comme `lyxal_event`). |
| R-10 | P1 | §5.5 (master data, préfixe) | `src/error.rs` (57 codes `RUNTIME_*`) ; ~40 codes ad hoc `Internal { code }` | Aucune définition d'erreur en master data (pas de `error/`). Codes sans préfixe `RUNTIME_` : `EVENT_JOURNAL_*`, `EVENT_STORE_MISSING`, `EVENT_HANDLER_REGISTRATION_FAILED`… (préfixe de `lyxal_event`), `REGISTRY_LOCK_POISONED`, `CONTROLLER_*`, `HEALTH_*`, `MEMORY_HEALTH_STORE_POISONED`, `PACKAGE_MISSING_DURING_APPLY`, `INVALID_RELEASE_STATUS`. | Variantes typées préfixées `RUNTIME_`, définitions dans `error/`, et un test qui vérifie que chaque code émis y est défini (comme `lyxal_surreal`). |
| R-11 | P1 | §12.5 (pas de tuple dans un contrat public) | `src/worker/report.rs:29`, `src/package/types.rs:165,167`, `src/reconciler/differ.rs:603` | `failed: Vec<(WorkerId, String)>`, `failed: Vec<(ModuleId, RuntimeError)>`, `not_attempted: Vec<(ModuleId, ModuleId)>`. | Structures nommées. |
| R-12 | P1 | §5.8.3 (tâches supervisées) | `src/event/bus.rs:72-80` ; `src/health/engine.rs:215,224` | La tâche de journalisation du bus est lancée par `tokio::spawn` sans poignée ni arrêt, et ses échecs ne sont que comptés. Le moteur de santé lance une tâche par sonde, y compris pour renvoyer une valeur déjà calculée (l. 215). | Tâches rattachées à leur propriétaire (`JoinSet`, `AbortOnDropHandle`), échecs journalisés. |
| R-13 | P2 | §7 (nommage) | `schema/tables.surql` | Tables préfixées `system_` au lieu du préfixe du module (`runtime_`). | Renommage `runtime_*` (rupture libre en pré-production). |
| R-14 | P2 | §0.2, §0.3.3, §0.3.4 | `readme.md`, `RUNTIME_V1_CLOSURE_AUDIT.md`, `LYXAL_EVENT_RUNTIME_INTEGRATION_REPORT.md`, `Cargo.lock` du crate ; commentaires « V1.4 », « V1.5 », « V1.6 », « V1.7 », « contrat CTO V1.6 » | Deux rapports historiques, `readme.md` en minuscules, un `Cargo.lock` propre au crate (le workspace a le sien), versions jamais livrées citées dans le code. | Suppression ; `README.md` à l'état actuel. |
| R-15 | P2 | §0.2 (code mort) | `Cargo.toml:23,25` | Dépendances `uuid` et `fastrand` jamais utilisées. | `uuid` utilisé par R-08 ; `fastrand` supprimé. |
| R-16 | P2 | Cohérence | `src/migration/discovery.rs:13-35` | La convention documentée est `NNN_description.surql` (3 chiffres) ; `AGENTS.md` §0.3.2 impose `0001_initial.surql`. Le code accepte tout entier, seule la documentation diverge. | Documentation alignée sur `0001_initial.surql`. |
| R-17 | P2 | §11.4 | `src/event/bus.rs:118-130` | Le journal d'audit abandonne les événements quand sa file est pleine : c'est compté (`journal_dropped`), jamais journalisé. | Journaliser l'abandon. |
| R-18 | P2 | §5.3 (`expect`) | `src/package/installer.rs:691`, `src/config.rs:22`, `src/event_engine/worker_adapter.rs:30`, `src/event_engine/gc_adapter.rs:24` | Quatre `expect` hors tests, sur des invariants locaux (valeurs constantes, clé insérée juste avant). | Constantes vérifiées par test, ou erreur typée. |

## 4. Correspondance DTO ↔ SurrealQL

Sans objet : le runtime n'a **aucune fonction SurrealQL** (`$params: object`). Ses requêtes sont
écrites en dur dans le Rust et reçoivent leurs valeurs par `.bind(...)` (R-05). La
correspondance sera établie pour les fonctions `fn::runtime_*` créées par le plan.

## 5. Preuves d'exécution et points non vérifiés

* **Exécuté et réussi** :
  * `cargo test -p lyxal_runtime` : 189 tests d'intégration réussis, 0 test unitaire dans `src/`, 0 `#[ignore]` ;
  * `surreal version` : `3.3.4 for linux on x86_64` ;
  * `surreal validate` sur `schema/*.surql` : OK ;
  * `scripts/ci/ci_local.sh` (clippy et formatage du crate compris) : passé lors de la clôture de `lyxal_event`, sur le même code du runtime.
* **Contrôles statiques** : lecture des fichiers listés au §1 ; recherches systématiques de `.query(`, `call_fn`, `tokio::spawn`, `unwrap`, `expect`, `let _ =`, `.ok()`, `unwrap_or_default`, codes d'erreur, dépendances, imports crypto.
* **Non vérifié** :
  * les tests du runtime n'utilisent que `mem://` : les chemins `ws://` (authentification `Root`) et la concurrence réelle entre processus ne sont pas éprouvés contre un serveur 3.3.4 ;
  * le comportement des baux sous écart d'horloge (R-07) et sous collision d'identifiant de nœud (R-08) est déduit du code, sans test ;
  * le dépassement de bail pendant une migration (R-09) est déduit du code, sans test.

## 6. Éléments conformes

* **Graphe** : dépendances conformes au §6, aucune dépendance circulaire.
* **Cryptographie** : uniquement par `lyxal_crypto` (`Sha256Hasher`, `sha256_hex`) ; aucun import de `sha2`, `blake3`, `hmac`, `argon2`, `aes-gcm` ou `hkdf` ; aucun `thread_rng`.
* **Workers** : `LyxalWorker`, `WorkerSupervisor` (seul `tokio::spawn` légitime, `src/worker/supervisor.rs:156`), `CancellationToken`, stratégie de redémarrage.
* **Contrats publics** : `LyxalModule`, `ModuleHealthCheck`, `EventConsumerModule`, présents et utilisés par les tests.
* **Baux** : écriture conditionnelle par génération (`WHERE generation = $expected_gen`) ; une seule réussite possible pour un même état lu.
* **Erreurs** : chaque variante de `RuntimeError` a un code stable `RUNTIME_*` (`src/error.rs`).
* **Qualité** : `clippy -D warnings` sans remarque ; schéma valide sous SurrealDB 3.3.4.

## 7. Plan correctif

Voir `implementation_plan.md` : trois décisions à prendre, puis cinq lots ordonnés P0 → P1 → P2.
