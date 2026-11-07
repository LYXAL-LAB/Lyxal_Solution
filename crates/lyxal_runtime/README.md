# Module `lyxal_runtime` — Moteur d'exécution de Lyxal OS

`lyxal_runtime` installe les modules de Lyxal OS depuis leur manifeste, applique leurs
migrations, pilote leur cycle de vie (installation, démarrage, arrêt), supervise leurs workers,
agrège leur santé et fait converger le nœud vers un état désiré. Les modules métiers ne dépendent
que de ses traits ; le binaire hôte instancie le runtime (`AGENTS.md` §5.8.5).

Version `0.1.0` (régime pré-production, `.agents/AGENTS.md` §0). Cible : SurrealDB 3.3.4,
SDK `surrealdb` 3.3. Dépend de `lyxal_core` (validation des entrées), `lyxal_error` (contrat de
résultat, définitions d'erreurs), `lyxal_surreal` (transport), `lyxal_crypto` (empreintes) et
`lyxal_event` (moteur d'événements intégré).

Évolutions prévues : [`ROADMAP.md`](ROADMAP.md).

---

## 1. Garanties

* **Installation depuis le manifeste** : seuls les fichiers déclarés dans `[resources]` sont
  installés, dans l'ordre des phases (schémas, fonctions, définitions d'erreurs, événements,
  seeds, migrations) puis dans l'ordre déclaré. Une clé inconnue du manifeste est refusée.
* **Une migration n'est exécutée qu'une fois**, même avec plusieurs nœuds : elle s'exécute sous
  un bail distribué, renouvelé tant qu'elle dure, et son résultat n'est enregistré que si le
  nœud détient encore le bail dans la même génération (sinon `RUNTIME_LEASE_FENCED`).
* **Baux à l'heure de la base** : les échéances sont calculées par SurrealDB, jamais par
  l'horloge d'un nœud. Chaque reprise incrémente la génération ; un ancien détenteur ne peut
  plus renouveler, libérer ni écrire.
* **Dérive détectée** : une migration appliquée dont le contenu a changé arrête l'installation
  (`RUNTIME_MIGRATION_CHECKSUM_MISMATCH`) ; une migration restée `Applying` exige une reprise
  explicite (`MigrationRecoveryPolicy`).
* **Aucune erreur masquée** : un échec de persistance, de worker ou de journal est propagé, ou
  journalisé et compté quand l'appelant ne peut pas échouer.

---

## 2. Manifeste d'un module (`manifest.toml`)

```toml
manifest_version = 1
id = "lyxal_booking"
name = "Lyxal Booking"
version = "0.1.0"
capabilities = ["booking"]

[runtime]
min_version = ">=0.1.0"

[[dependencies]]
id = "lyxal_core"
version = ">=0.1.0"

[resources]
schemas = ["schema/tables.surql", "schema/fields.surql", "schema/indexes.surql"]
functions = ["functions/booking.surql"]
error_definitions = ["error/booking.surql"]
events = ["events/booking.surql"]
seeds = []
migrations = ["migrations/0001_initial.surql"]
```

Migrations : en pré-production, une seule par module, `migrations/0001_initial.surql`,
réécrite en place (`AGENTS.md` §0.3.2). Le format de nom est `NNNN_description.surql`.

---

## 3. Tables (`schema/`)

| Table | Rôle |
| :--- | :--- |
| `runtime_module` | Modules connus. |
| `runtime_release` | Releases installées (`[module_id, version]`), statut et phase d'installation. |
| `runtime_migration` | Migrations appliquées (`[module_id, migration_id]`), empreinte, statut. |
| `runtime_lease` | Baux distribués (`[kind, key]`, nature `migration` ou `installation`) : détenteur, génération, échéances. |
| `runtime_health` | Dernier état de santé par nœud et module. |
| `runtime_worker` | État des workers par nœud. |
| `runtime_event_journal` | Journal des événements techniques du runtime. |

Toutes en `TYPE NORMAL SCHEMAFULL PERMISSIONS NONE` : seules les fonctions du module y accèdent.

---

## 4. Fonctions SurrealQL (`functions/`)

Fonctions internes du runtime, appelées par `call_fn`. Toutes prennent un objet unique
`$params`, acceptent `language` (défaut `fr`), renvoient `{ ok, data, error }` et valident leurs
entrées par les primitives de `lyxal_core` (décision CTO). Une entrée invalide renvoie
`RUNTIME_INVALID_PARAMETERS` avec le détail par champ.

| Domaine | Fonctions |
| :--- | :--- |
| Modules | `fn::runtime_module_upsert`, `_get`, `_list` |
| Releases | `fn::runtime_release_register`, `_get`, `_list`, `_status_update` (`RUNTIME_RELEASE_NOT_FOUND`) |
| Migrations | `fn::runtime_migration_record` (garde de bail : `lease_key`, `node_id`, `generation`), `_get`, `_list` |
| Baux | `fn::runtime_lease_acquire` (`acquired`, `recovered`, `already_owned`, `held_by_other`), `_renew`, `_release`, `_get` |
| Santé | `fn::runtime_health_record`, `_list` |
| Workers | `fn::runtime_worker_upsert`, `_get`, `_list` |
| Journal | `fn::runtime_event_append`, `fn::runtime_event_list` |

`fn::runtime_migration_record` écrit d'abord sur le bail pour se protéger ; un bail perdu lève
`RUNTIME_LEASE_FENCED` par `THROW` afin d'annuler toute la transaction (exception documentée,
comme dans `lyxal_event`). Côté Rust, ce code devient `RuntimeError::LeaseFenced`.

---

## 5. Codes d'erreur (`error/runtime.surql`)

60 définitions, une par code `RUNTIME_*`. Elles sont générées depuis le catalogue Rust
`RUNTIME_ERROR_CATALOG` (`src/error/catalog.rs`) : code, catégorie, statut HTTP, caractère
réessayable, message et libellé. `RuntimeError::info()` et `to_lyxal_error()` lisent ce catalogue.
Un test vérifie que chaque entrée est définie à l'identique dans le fichier, sans code en plus ;
un autre vérifie qu'elles s'installent dans `error_definition`.

Exemples : `RUNTIME_LEASE_FENCED` (`conflict`, 412), `RUNTIME_STORE_FAILED` (`dependency`, 503,
réessayable), `RUNTIME_INVALID_MANIFEST` (`validation`, 422).

---

## 6. Contrats Rust (`src/`)

* **Module** : `LyxalModule` (`descriptor`, `install`, `start`, `stop`), `ModuleContext`,
  `ModuleDescriptor`.
* **Workers** : `LyxalWorker` (`run(WorkerContext)`, coopération avec le `CancellationToken`),
  `WorkerSupervisor` (redémarrage, arrêt gracieux), `WorkerStore`.
* **Santé** : `ModuleHealthCheck`, `HealthEngine` (concurrence et délai bornés), `HealthStore`.
* **Installation** : `ModulePackage`, `ModuleInstaller` (lots ordonnés par dépendances, isolement
  des échecs), `schema::install_resources`, `install_embedded`, `install_batch`,
  `install_runtime_schema`.
* **Migrations** : `MigrationDiscovery`, `MigrationPlan`, `MigrationRunner` (`MigrationLockConfig` :
  durée du bail, intervalle de renouvellement, attente).
* **Baux** : `MigrationLeaseManager`, `InstallationLeaseManager` ; implémentations SurrealDB
  (`fn::runtime_lease_*`) et mémoire (tests, processus unique).
* **Persistance** : `RuntimeStore` ; `SurrealRuntimeStore` (`Surreal<Any>`, `LyxalSurrealCall`),
  `MemoryRuntimeStore`.
* **Réconciliation** : `DesiredRuntimeState`, `RuntimeObserver`, `RuntimeDiffer`,
  `RuntimeReconciler`, `ContinuousReconciliationController` (une passe à la fois, repli
  exponentiel borné).
* **Événements** : bus interne `RuntimeEventBus` et journal ; intégration de `lyxal_event` par
  `EventConsumerModule`, `EventWorkerService`, `EventGarbageCollectorService`.
* **Erreurs** : `RuntimeError`, `RuntimeErrorInfo`, `RUNTIME_ERROR_CATALOG`.
* **Hôte** : `LyxalRuntime` assemble ces composants ; il est instancié par le binaire hôte.

---

## 7. Limites

* La santé, le démarrage et l'arrêt des modules sont locaux au nœud ; seuls les installations et
  les migrations sont coordonnés entre nœuds (baux).
* La cible `Absent` arrête un module sans supprimer ses données ; les rétrogradations sont
  bloquées.
* Une migration interrompue au milieu d'un script non transactionnel peut laisser un état
  partiel ; la politique par défaut exige alors une reprise manuelle.

---

## 8. Vérification

```bash
cargo test -p lyxal_runtime
```

Les tests d'intégration installent `lyxal_core`, `lyxal_error` et le schéma du runtime dans une
base embarquée : manifeste et installation par phases, migrations (dérive, reprise, migration
plus longue que le bail exécutée une seule fois), baux (concurrence, heure de la base, écriture
refusée après reprise), workers, santé, réconciliation, intégration de `lyxal_event`.
`scripts/ci/ci_local.sh` rejoue la CI complète, dont la validation du SurrealQL par un binaire
SurrealDB 3.3.4.
