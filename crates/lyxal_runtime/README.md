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
  (`RUNTIME_MIGRATION_CHECKSUM_MISMATCH`).
* **Migration interrompue jamais rejouée d'office** : une migration restée `Applying` après une
  coupure arrête l'installation du module (`RUNTIME_MIGRATION_INTERRUPTED`) jusqu'à la décision
  d'un exploitant, prise sous bail d'installation et tracée (§4.1).
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
| `runtime_migration` | Migrations (`[module_id, migration_id]`) : empreinte, statut, script, nœud qui a écrit le dernier état, début de la dernière exécution, dernière décision de reprise (`resolution`). |
| `runtime_lease` | Baux distribués (`[kind, key]`, nature `migration`, `installation` ou `leader`) : détenteur, génération, échéances. |
| `runtime_health` | Dernier état de santé par nœud et module. |
| `runtime_worker` | État des workers par nœud. |
| `runtime_event_journal` | Journal des événements techniques du runtime. |

Toutes en `TYPE NORMAL SCHEMAFULL PERMISSIONS NONE` : seules les fonctions du module y accèdent.

---

## 4. Fonctions SurrealQL (`functions/`)

Fonctions internes du runtime, appelées par `call_fn`. Toutes prennent un objet unique
`$params`, acceptent `language` (défaut `fr`), renvoient `{ ok, data, error }` et valident leurs
entrées par les primitives de `lyxal_core` (décision CTO) ; les deux fonctions de reprise le font
par le moteur `fn::validation_object_execute` (clé inconnue refusée). Une entrée invalide renvoie
`RUNTIME_INVALID_PARAMETERS` avec le détail par champ.

| Domaine | Fonctions |
| :--- | :--- |
| Modules | `fn::runtime_module_upsert`, `_get`, `_list` |
| Releases | `fn::runtime_release_register`, `_get`, `_list`, `_status_update` (`RUNTIME_RELEASE_NOT_FOUND`) |
| Migrations | `fn::runtime_migration_record` (garde de bail : `lease_key`, `node_id`, `generation`), `_get`, `_list` ; reprise : `fn::runtime_migration_interrupted_list`, `fn::runtime_migration_resolve` (§4.1) |
| Baux | `fn::runtime_lease_acquire` (`acquired`, `recovered`, `already_owned`, `held_by_other`), `_renew`, `_release`, `_get` |
| Santé | `fn::runtime_health_record`, `_list` |
| Workers | `fn::runtime_worker_upsert`, `_get`, `_list` |
| Journal | `fn::runtime_event_append`, `fn::runtime_event_list` |

`fn::runtime_migration_record` écrit d'abord sur le bail pour se protéger ; un bail perdu lève
`RUNTIME_LEASE_FENCED` par `THROW` afin d'annuler toute la transaction (exception documentée,
comme dans `lyxal_event`). Côté Rust, ce code devient `RuntimeError::LeaseFenced`.

### 4.1. Reprise d'une migration interrompue

Le moteur écrit l'état `Applying` avant d'exécuter le script d'une migration, puis `Applied` ou
`Failed`. Si le nœud s'arrête entre les deux, la migration reste `Applying` : le script a pu
s'exécuter en entier, en partie ou pas du tout. Elle est **interrompue** dès que son bail de
migration est libéré ou échu (30 s après l'arrêt du nœud, par défaut) ; avant, elle est
considérée en cours. Le runtime ne la rejoue jamais de lui-même : l'installation du module
échoue (`RUNTIME_MIGRATION_INTERRUPTED`) jusqu'à la décision d'un exploitant.

| Fonction | Rôle |
| :--- | :--- |
| `fn::runtime_migration_interrupted_list({ module })` | Migrations interrompues (`state: "interrupted"`) ou abandonnées et non rejouées (`state: "abandoned"`), de tous les modules ou d'un seul : `{ module, migration, version, script, node, state, started_at, resolution }`. `node` est le nœud qui exécutait la migration, `started_at` le début de cette exécution (heure de la base), `resolution` la dernière décision (`{ action, actor, reason, node_id, at }`). |
| `fn::runtime_migration_resolve({ module, migration, action, reason, actor, node_id, generation })` | Décision sur une migration interrompue. `action: "retry"` la marque `RetryRequested` : elle est rejouée à la prochaine installation du module. `action: "abandon"` la marque `Abandoned` : rien n'est rejoué et l'installation du module reste refusée (`RUNTIME_MIGRATION_RECOVERY_REQUIRED`). Une migration abandonnée n'accepte plus qu'une décision `retry`, qui la remet à rejouer. `reason` (obligatoire, 1 000 caractères au plus) et `actor` (identifiant de l'auteur, 256 au plus) sont gardés dans `resolution`. Rend `{ module, migration, version, action, status, previous_status, resolved_at }`. |

Refus de `fn::runtime_migration_resolve` :

| Code | Cas |
| :--- | :--- |
| `RUNTIME_MIGRATION_NOT_INTERRUPTED` (409) | Migration inconnue (`status: "unknown"`), encore en cours (`"running"`), ou dans un autre état (appliquée, en échec, déjà à rejouer, déjà abandonnée pour un `abandon`) : le détail `status` le dit. |
| `RUNTIME_LEASE_FENCED` (412) | Le bail d'installation de la release (`runtime_lease:["installation", "<module>:<version>"]`) n'est pas détenu par `node_id` dans la génération `generation`, non expiré à l'heure de la base. |
| `RUNTIME_INVALID_PARAMETERS` (400) | Paramètre absent, mal formé ou inconnu. |

La décision se prend **sous le bail d'installation** de la release, celui que prend
l'installation du module pour rejouer ses migrations : une décision et une installation ne
peuvent pas se croiser. `LyxalRuntime::resolve_migration(MigrationResolveParams { module,
migration, action, reason, actor })` enchaîne : prise du bail (sans attente : s'il est détenu par
un autre nœud vivant, ou par une installation en cours sur ce nœud, `RuntimeError::LeaseFenced`),
appel de la fonction, libération du bail, puis **trace au journal du runtime**
(`runtime_event_journal`, événement `migration` / `resolved` : migration, version, action,
auteur, motif, état précédent ; le nœud et la date sont ceux de l'événement), écrite avant de
rendre la main. `LyxalRuntime::interrupted_migrations` lit la liste. Le runtime ne contrôle aucun
droit (il est sous `lyxal_auth`) : l'appelant vérifie celui de l'auteur avant d'appeler ; l'hôte
`lyxal-server` le fait pour ses routes `/api/v1/system/migrations/*`.

L'hôte `lyxal-server` offre ces deux opérations de deux façons (`apps/lyxal-server/README.md`) :

| Situation | Moyen | Auteur tracé |
| :--- | :--- | :--- |
| **Serveur arrêté** — cas d'un serveur seul : la migration interrompue fait échouer l'installation du module, donc le démarrage, et aucune route n'est servie | Ligne de commande de l'hôte : `lyxal-server runtime migrations list [--module <module>]` et `lyxal-server runtime migrations resolve --module <module> --migration <id> --action retry\|abandon --reason <texte>`. La commande réinstalle le socle (rejouable), n'installe aucun module, et appelle les mêmes opérations du runtime. | `cli:<application.instance_id>` (pas d'appelant authentifié ; accès : qui peut lancer le binaire avec la configuration du serveur et les identifiants de la base) |
| **Un autre nœud de l'installation est démarré** | Routes `GET /api/v1/system/migrations/interrupted` et `POST /api/v1/system/migrations/resolve` de ce nœud, réservées au droit `server.installation.manage`. | Identité ou application de l'appelant |

Procédure pour l'exploitant :

1. lire la liste : module, migration, script, nœud et date de l'exécution interrompue ;
2. **vérifier l'état de la base** au regard du script (tables, champs, index, fonctions et
   données qu'il crée). Les migrations de Lyxal OS sont écrites pour être rejouables
   (`DEFINE … OVERWRITE`, seeds protégés par `record::exists`), mais `retry` réexécute un script
   peut-être déjà appliqué en partie : la décision appartient à celui qui a vérifié ;
3. décider : `retry` si le script peut être rejoué tel quel (ou corrigé dans le package : une
   migration à rejouer l'est avec le script du package installé, même s'il a changé depuis
   l'interruption, puisqu'elle n'a jamais été appliquée) ; `abandon` pour consigner que l'état
   doit être réparé avant tout rejeu, puis `retry` une fois la base réparée ;
4. relancer l'installation du module (démarrage du serveur arrêté, ou redémarrage du nœud) : la
   migration est rejouée et enregistrée `Applied`.

Une décision est refusée (`RUNTIME_LEASE_FENCED`) tant que le bail d'installation de la release
est détenu : après l'arrêt brutal d'un nœud en cours d'installation, attendre l'échéance de son
bail avant de décider.

Le motif est conservé et journalisé : il ne contient ni secret ni donnée personnelle. Si la
trace ne peut pas être écrite au journal, l'opération rend l'erreur (`RUNTIME_STORE_FAILED`)
alors que la décision est prise ; elle reste lisible dans `resolution`.

---

## 5. Codes d'erreur (`error/runtime.surql`)

57 définitions, une par code `RUNTIME_*`. Elles sont générées depuis le catalogue Rust
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
  durée du bail, intervalle de renouvellement, attente). États `MigrationStatus` : `Pending`,
  `Applying`, `Applied`, `Failed`, `RolledBack`, `Skipped` (écrits par le moteur),
  `RetryRequested` et `Abandoned` (écrits par la seule décision de reprise). Le plan rejoue une
  migration `RetryRequested` et refuse une migration `Applying` ou `Abandoned`. Reprise (§4.1) :
  `MigrationRecovery`, `MigrationInterruptedParams`, `InterruptedMigration`,
  `MigrationResolveParams`, `MigrationResolveAction`, `MigrationResolved`.
* **Baux** : `MigrationLeaseManager`, `InstallationLeaseManager` ; implémentations SurrealDB
  (`fn::runtime_lease_*`) et mémoire (tests, processus unique). `SurrealLeaderLeaseManager`
  (nature `leader`) élit un seul nœud pour un rôle (`acquire`, `renew` qui rend `None` quand le
  bail est perdu, `release`, `inspect`) : le planificateur de `lyxal_scheduler` (clé `scheduler`)
  s'en sert, et ses fonctions SurrealQL vérifient le bail par `fn::runtime_lease_get` (garde de
  génération) ; la déclaration d'une tâche lit les modules installés par `fn::runtime_module_list`
  et `fn::runtime_release_list`.
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

* La santé, le démarrage et l'arrêt des modules sont locaux au nœud ; seuls les installations,
  les migrations et les rôles élus (bail `leader`) sont coordonnés entre nœuds.
* La cible `Absent` arrête un module sans supprimer ses données ; les rétrogradations sont
  bloquées.
* Une migration interrompue au milieu d'un script non transactionnel peut laisser un état
  partiel : le runtime le signale et attend une décision (§4.1), il ne répare pas la base.

---

## 8. Vérification

```bash
cargo test -p lyxal_runtime
```

Les tests d'intégration installent `lyxal_core`, `lyxal_error` et le schéma du runtime dans une
base embarquée : manifeste et installation par phases, migrations (dérive, reprise, migration
plus longue que le bail exécutée une seule fois ; migration interrompue listée, remise à rejouer
puis rejouée, abandonnée puis installation refusée jusqu'au `retry`, refus quand elle n'est pas
interrompue ou sans bail d'installation, trace au journal), baux (concurrence, heure de la base, écriture
refusée après reprise, élection d'un seul nœud par le bail `leader`), workers, santé, réconciliation, intégration de `lyxal_event`.
`scripts/ci/ci_local.sh` rejoue la CI complète, dont la validation du SurrealQL par un binaire
SurrealDB 3.3.4.
