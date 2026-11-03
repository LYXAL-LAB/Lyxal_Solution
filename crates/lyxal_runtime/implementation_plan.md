# Plan d'implémentation — reprise de `lyxal_runtime`

> **Statut : ✅ validé par le CTO** (recommandations Q1 à Q3 acceptées). Constats : `AUDIT.md` (R-01 à R-18). Les deux documents seront
> supprimés à la clôture (§0.3.4).

## 1. Décisions demandées

| # | Question | Recommandation |
| :- | :--- | :--- |
| Q1 | **Manifeste et installation des ressources (R-04)** : le runtime doit-il lire `[resources]` et installer les fichiers déclarés ? | **Oui.** `ModuleManifest` reçoit `resources` (`schemas`, `functions`, `events`, `error_definitions`, `migrations`, `seeds`) avec `deny_unknown_fields`. L'installation exécute ces fichiers dans l'ordre du manifeste, phase par phase, et la découverte par noms fixes dans `schema/` est supprimée. Le runtime reçoit son propre `manifest.toml`. `lyxal_event` abandonne alors `EventStore::install` au profit de l'installation par le runtime : c'est l'alternative laissée ouverte à sa reprise (Q3). Les installateurs de test de `lyxal_error`, `lyxal_surreal` et `lyxal_event` restent tels quels : un crate placé sous le runtime ne peut pas en dépendre, même en test, sans dupliquer ses types. |
| Q2 | **Persistance du runtime (R-01, R-05, R-06, R-07, R-13)** | **Fonctions SurrealQL `fn::runtime_*($params: object)`**, appelées par `call_fn`, entrées validées par les primitives de `lyxal_core` (chemin interne, comme les fonctions internes de `lyxal_event`). Un seul schéma dans `schema/`, tables renommées `runtime_*` en `TYPE NORMAL SCHEMAFULL PERMISSIONS NONE`. Les baux de migration et d'installation passent dans ces fonctions et prennent l'heure de la base (`time::now()`), ce qui corrige R-07. *Alternative moins coûteuse* : garder les requêtes en Rust, mais installer le schéma depuis `schema/` (une seule source), ajouter les permissions et passer l'heure de la base dans les requêtes. Elle laisse la logique de persistance hors de SurrealQL (§10). |
| Q3 | **Bus d'événements interne et journal (`RuntimeEventBus`, `system_runtime_event`)** : est-ce un doublon de `lyxal_event` ? | **Non, à garder.** Ce sont des événements techniques du runtime (cycle de vie, migrations, workers), diffusés localement et journalisés pour audit. Ils ne traversent pas les modules et n'ont pas besoin de la livraison garantie de l'outbox. La table devient `runtime_event_journal`, sa tâche de journalisation est rattachée au runtime, et les abandons sont journalisés (R-12, R-17). *Alternative* : publier ces événements dans `lyxal_event` sous `runtime.*`, au prix d'un coût de livraison garantie inutile pour de la télémétrie. |

**Hors périmètre, à signaler** : `apps/lyxal-server` n'instancie pas le runtime (§5.8.5). Ce
branchement appartient à la reprise de `lyxal-server`.

## 2. Contrat cible

### SurrealQL (si Q2 est validée)

`manifest.toml` du runtime : dépendances `lyxal_core` et `lyxal_error` ; ressources `schema/*`,
`functions/*`, `error/runtime.surql`.

**Tables** (`TYPE NORMAL SCHEMAFULL PERMISSIONS NONE`) : `runtime_module`, `runtime_release`,
`runtime_migration`, `runtime_lease`, `runtime_health`, `runtime_worker`,
`runtime_event_journal`. Les deux tables de baux actuelles (`system_migration_lock`,
`system_installation_lock`), identiques champ pour champ, deviennent une seule table
`runtime_lease` (identifiant `runtime_lease:[kind, key]`). Toutes les dates sont des `datetime`
écrites par la base.

**Fonctions** : toutes internes, de signature `DEFINE FUNCTION OVERWRITE fn::<nom>($params: object)`,
avec `PERMISSIONS FULL` et un `COMMENT`. Elles renvoient `fn::result_ok` ou
`fn::error_result("RUNTIME_…")`. Entrées validées par les primitives de `lyxal_core`
(`fn::validation_required_string`, `fn::validation_integer`, `fn::validation_object`,
`fn::validation_language_code`) ; une entrée invalide donne `RUNTIME_INVALID_PARAMETERS` avec
`details.fields`. Chacune accepte `language` (défaut `fr`).

| Fonction | `$params` (requis en gras) | Donnée renvoyée | Erreurs |
| :--- | :--- | :--- | :--- |
| `fn::runtime_module_upsert` | **module_id**, **name**, description | module | — |
| `fn::runtime_module_get` | **module_id** | module ou `NONE` | — |
| `fn::runtime_module_list` | — | modules | — |
| `fn::runtime_release_register` | **module_id**, **version**, **manifest_version**, **status**, description, checksum | release | `RUNTIME_RELEASE_ALREADY_EXISTS` |
| `fn::runtime_release_get` | **module_id**, **version** | release ou `NONE` | — |
| `fn::runtime_release_list` | **module_id** | releases | — |
| `fn::runtime_release_status_update` | **module_id**, **version**, **status** (`Discovered`, `Installing`, `Installed`, `Active`, `Inactive`, `Failed`), phase | release | `RUNTIME_RELEASE_NOT_FOUND` |
| `fn::runtime_migration_record` | **module_id**, **migration_id**, **module_version**, **order**, **checksum**, **status**, **duration_ms**, error, **lease_key**, **node_id**, **generation** | migration | `RUNTIME_LEASE_FENCED` (`THROW`) |
| `fn::runtime_migration_get` | **module_id**, **migration_id** | migration ou `NONE` | — |
| `fn::runtime_migration_list` | **module_id** | migrations | — |
| `fn::runtime_lease_acquire` | **kind** (`migration`, `installation`), **key**, **node_id**, **ttl_seconds** | `{ outcome, lease }`, `outcome` ∈ `acquired`, `already_owned`, `recovered`, `held_by_other` | — |
| `fn::runtime_lease_renew` | **kind**, **key**, **node_id**, **generation**, **ttl_seconds** | `{ renewed, lease }` | — |
| `fn::runtime_lease_release` | **kind**, **key**, **node_id**, **generation** | `{ released }` | — |
| `fn::runtime_lease_get` | **kind**, **key** | bail ou `NONE` | — |
| `fn::runtime_health_record` | **node_id**, **module_id**, **status**, latency_ms, message | santé | — |
| `fn::runtime_health_list` | **node_id** | santé du nœud | — |
| `fn::runtime_worker_upsert` | **node_id**, **worker_id**, **module_id**, **state**, **criticality**, **metrics** | worker | — |
| `fn::runtime_worker_get` | **node_id**, **worker_id** | worker ou `NONE` | — |
| `fn::runtime_worker_list` | **node_id** | workers du nœud | — |
| `fn::runtime_event_append` | **event_id**, **sequence**, **node_id**, **kind**, module_id, correlation_id, causation_id, **payload** | événement | — |
| `fn::runtime_event_list` | **limit**, module_id | événements récents | — |

Un bail est actif si `is_released = false` et `expires_at > time::now()`. La prise est une
écriture conditionnelle sur la génération lue, qui incrémente `generation`.
`fn::runtime_migration_record` commence par une écriture de garde sur le bail (même nœud, même
génération, bail actif) ; un échec lève `RUNTIME_LEASE_FENCED` par `THROW` pour annuler la
transaction, exception documentée comme dans `lyxal_event`.

### Types Rust (`src/store/dto.rs`)

Un `*Params` par fonction, champ pour champ identique au SurrealQL, dérivant `SurrealValue`. Les
identifiants sont des `ModuleId`, `MigrationId` et `NodeId` sérialisés en chaîne ; les dates sont
des `Datetime`. Un champ `None` vaut « non fourni ».

| Fonction | Paramètres | Résultat |
| :--- | :--- | :--- |
| `runtime_module_*` | `ModuleUpsertParams`, `ModuleGetParams` | `StoredModule` |
| `runtime_release_*` | `ReleaseRegisterParams`, `ReleaseGetParams`, `ReleaseListParams`, `ReleaseStatusUpdateParams` | `StoredModuleRelease` (`status: ModuleReleaseStatus`, dates `Datetime`) |
| `runtime_migration_*` | `MigrationRecordParams`, `MigrationGetParams`, `MigrationListParams` | `MigrationRecord` (`applied_at: Datetime`) |
| `runtime_lease_*` | `LeaseAcquireParams`, `LeaseRenewParams`, `LeaseReleaseParams`, `LeaseGetParams` | `LeaseAcquireResult { outcome: LeaseOutcome, lease: Lease }`, `LeaseRenewResult`, `LeaseReleaseResult`, `Lease` |
| `runtime_health_*` | `HealthRecordParams`, `HealthListParams` | `StoredHealth` |
| `runtime_worker_*` | `WorkerUpsertParams`, `WorkerGetParams`, `WorkerListParams` | `StoredWorker` |
| `runtime_event_*` | `EventAppendParams`, `EventListParams` | `StoredRuntimeEvent` |

`MigrationLease` et `InstallationLease` deviennent un seul `Lease { kind, key, owner, generation,
acquired_at, renewed_at, expires_at }` (dates `Datetime`) ; `AcquireLeaseResult` devient
`LeaseOutcome` et garde les variantes actuelles. Les traits `RuntimeStore`,
`MigrationLeaseManager` et `InstallationLeaseManager` sont conservés pour les implémentations en
mémoire des tests ; leurs implémentations SurrealDB appellent `call_fn`.

### Codes d'erreur (`error/runtime.surql`)

* **Émis par les fonctions SurrealQL** : `RUNTIME_INVALID_PARAMETERS` (validation, 400),
  `RUNTIME_RELEASE_ALREADY_EXISTS` (conflict, 409), `RUNTIME_RELEASE_NOT_FOUND` (not_found, 404),
  `RUNTIME_LEASE_FENCED` (conflict, 412).
* **Émis par le Rust** : les 57 codes actuels de `RuntimeError`, chacun avec sa définition et sa
  catégorie, vérifiés par un test qui compare `RuntimeError::code()` à `error/runtime.surql`
  (modèle `lyxal_surreal`).
* **Codes ad hoc remplacés** par des variantes typées :
  * `*_LOCK_POISONED` (`REGISTRY_`, `CONTROLLER_`, `HEALTH_REGISTRY_`, `MEMORY_HEALTH_STORE_`) → `RUNTIME_LOCK_POISONED { resource }` ;
  * `RUNTIME_STORE_QUERY_FAILED`, `RUNTIME_STORE_DATA_INVALID`, `RUNTIME_*_PERSISTENCE_FAILED`, `RUNTIME_*_BOOTSTRAP_FAILED`, `EVENT_JOURNAL_*`, `EVENT_DESERIALIZATION_FAILED`, `EVENT_SERIALIZATION_FAILED` → `RUNTIME_STORE_FAILED { operation }` ;
  * `EVENT_STORE_MISSING`, `RUNTIME_STORE_MISSING`, `RUNTIME_CLIENT_MISSING` → `RUNTIME_STORE_MISSING` ;
  * `EVENT_HANDLER_REGISTRATION_FAILED`, `EVENT_WORKER_EXECUTION_FAILED`, `EVENT_GC_EXECUTION_FAILED` → `RUNTIME_EVENT_ENGINE_ERROR` (variante existante) ;
  * `PACKAGE_MISSING_DURING_APPLY`, `INVALID_RELEASE_STATUS`, `CONTROLLER_PASS_ALREADY_RUNNING`, `HEALTH_CHECKER_ALREADY_REGISTERED`, `RUNTIME_CONFIG_INVALID`, `RUNTIME_WORKER_INVALID_ID`, `RUNTIME_MIGRATION_LOCK_RELEASE_FAILED`, `RUNTIME_INSTALLATION_LEASE_RELEASE_FAILED`, `RUNTIME_MIGRATION_FAILED`, `RUNTIME_INSTALL_HOOK_FAILED`, `RUNTIME_RESOURCE_READ_FAILED`, `RUNTIME_RESOURCE_READ_DIR_FAILED`, `RUNTIME_HEALTH_QUERY_FAILED`, `RUNTIME_HEALTH_DATA_INVALID` → une variante typée chacune, préfixée `RUNTIME_` (les doublons de variantes existantes y sont rattachés).

`RuntimeError::Internal { code: &'static str }` est supprimée : tout code émis est une variante
connue.

### Rust (rupture coordonnée, §0.3.1)

* `ModuleManifest` avec `resources`, clés inconnues refusées.
* `NodeId::generate` en UUID v7 (R-08).
* Migration : bail renouvelé pendant l'exécution, enregistrement refusé si le bail est perdu (R-09).
* Erreurs :
  * aucune erreur de persistance ou d'enregistrement jetée : propagée, ou journalisée et comptée (R-02) ;
  * `WorkerBatchReport.failed` remonté (R-03) ;
  * codes ad hoc remplacés par des variantes typées `RUNTIME_*` (R-10).
* Structures nommées à la place des tuples publics (R-11).
* Tâches du bus et du moteur de santé rattachées à leur propriétaire (R-12).

### Appelants à mettre à jour dans le même changement

* `lyxal_event` : suppression d'`EventStore::install` et de `INSTALL_RESOURCES` si Q1 est validée ;
  `EventEngineConfig::auto_init_schema` installe alors `lyxal_event` depuis son manifeste.
* `lyxal_pipeline_ingestion` : types touchés (`ModuleManifest`, rapports à tuples). Ses appels
  sont mis à jour sans reprendre le module.

### `lyxal_core`

Fonctions réutilisées : `fn::validation_record_id`, `fn::validation_required_string`,
`fn::validation_integer`, `fn::validation_object`, `fn::validation_language_code`. Aucune
fonction du Core à créer.

## 3. Tests

* **Manifeste** : `[resources]` lu ; clé inconnue refusée ; installation de `lyxal_core`,
  `lyxal_error` et `lyxal_event` depuis leurs manifestes, rejouable sans doublon.
* **Baux** : deux nœuds aux horloges décalées ne détiennent jamais le même bail ; identifiants de
  nœud distincts ; migration plus longue que le bail sans double exécution.
* **Erreurs** :
  * un échec de démarrage de worker est remonté ;
  * une écriture de santé, de statut ou de worker qui échoue est journalisée et comptée ;
  * chaque code émis est défini dans `error/`.
* **Permissions** : déclaration des tables vérifiée par `INFO FOR TABLE`.

## 4. Lots

| Lot | Contenu |
| :- | :--- |
| 1 ✅ | **Nettoyage et erreurs silencieuses** : suppression des rapports historiques, du `Cargo.lock` du crate et de `fastrand` ; `README.md` (réécrit au dernier lot) ; R-02, R-03, R-11, R-12, R-17, R-18 ; `NodeId` en UUID v7 (R-08). |
| 2 ✅ | **Manifeste** (Q1, R-04) : `resources`, installation par phases, `manifest.toml` du runtime ; `lyxal_event` installé par le runtime. |
| 3a ✅ | **Schéma unique** (Q2, R-01, R-06, R-13) : tables `runtime_*` en `TYPE NORMAL SCHEMAFULL PERMISSIONS NONE`, installées depuis le manifeste du runtime ; les copies du DDL dans les `bootstrap` Rust sont supprimées. Les deux tables de baux sont fusionnées en `runtime_lease` au lot 4. |
| 3b | **Persistance en SurrealQL** (Q2, R-05) : fonctions `fn::runtime_*`, `call_fn`. |
| 4 | **Baux et migrations sûrs** (R-07, R-09) ; **erreurs en master data** (R-10). |
| 5 | **Clôture** : README à l'état actuel, convention `0001_initial.surql` (R-16), audit de contrôle, suppression de `AUDIT.md` et de ce plan. |

Chaque lot fait l'objet d'une PR, fusionnée quand la CI est verte.

## 5. Checklist §13 (extraits)

* Architecture : aucune dépendance nouvelle hors `uuid` (déjà déclarée) ; DAG inchangé.
* Core : entrées des fonctions `fn::runtime_*` validées par les primitives de `lyxal_core`.
* SurrealQL : `$params: object`, `result_ok` / `error_result`, `COMMENT`, `PERMISSIONS`.
* Rust : aucune erreur masquée, aucun `panic!` ni `expect` hors tests, aucun tuple public.
* Erreurs : codes `RUNTIME_*` définis en master data dans `lyxal_runtime/error/`.
* Zéro dette : rapports historiques et commentaires de versions supprimés, version `0.1.0`.
