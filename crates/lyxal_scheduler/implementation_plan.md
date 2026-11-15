# Plan d'implémentation — `lyxal_scheduler`, lot 3 : moteur

Troisième lot du programme `lyxal_scheduler` (`implementation_plan.md` à la racine). Il met le
planificateur en marche : un seul nœud transforme les échéances en exécutions, tous les nœuds
exécutent les tâches, les modules inscrivent leurs handlers, et l'hôte héberge le tout. Il
s'appuie sur le socle SurrealQL (lot 1) et le calcul des dates (lot 2). Aucune ligne de code avant
la validation du CTO (`.agents/AGENTS.md` §3).

## 1. Questions soumises au CTO

| N° | Question | Proposition |
| :- | :--- | :--- |
| **W1** | Bail du planificateur (décision S4) | Nouvelle valeur `leader` pour `runtime_lease.kind` dans `lyxal_runtime` (fonctions `fn::runtime_lease_acquire`, `_renew`, `_release` inchangées par ailleurs) ; clé `scheduler` ; durée 30 s, renouvelé toutes les 10 s. Un nœud qui perd le bail s'arrête de planifier au tour suivant ; les doublons restent impossibles (identifiant `[planification, date]`). |
| **W2** | Rythme | Planificateur : un tour par seconde. Exécuteurs : interrogation de chaque file chaque seconde quand elle est vide, aussitôt après chaque fin sinon. Reprise des baux expirés toutes les 30 s ; élagage toutes les heures. |
| **W3** | Places par nœud | Chaque nœud exécute au plus `LYXAL__SCHEDULER__WORKERS` tâches à la fois par file (4 par défaut, de 1 à 64) ; la limite globale de la file (`concurrency`) et celle de chaque organisation (lot 1) restent les seules garanties communes. |
| **W4** | Délai maximal dépassé | Le handler Rust reçoit l'annulation et l'exécution est terminée en échec `SCHEDULER_RUN_TIMEOUT` (retentable). Une fonction SurrealQL déjà partie ne peut pas être arrêtée par le client : le moteur cesse de l'attendre, enregistre le même échec, et la tâche doit rester idempotente (S7). |
| **W5** | Contenu d'une publication différée (exécuteur `event`) | Charge de l'événement = arguments de l'exécution ; `source` = l'exécution ; métadonnées `{ scheduled_for, attempt, tenant }`. Publication et fin de l'exécution dans **la même transaction** (fonction SurrealQL du module) : jamais d'événement sans exécution terminée, ni l'inverse. |

## 2. Changements SurrealQL (rupture coordonnée, §0.3)

| Où | Changement | Raison |
| :--- | :--- | :--- |
| `lyxal_runtime` : `schema/fields.surql`, `functions/runtime_lease.surql` | `kind` accepte `leader` | W1 |
| `fn::scheduler_schedule_fire`, `fn::scheduler_backfill_fire` | `fire_times` devient une liste `{ at, available_at }` : `available_at` = `at` + décalage aléatoire tiré par Rust (U5), jamais avant `at` | point ouvert du lot 2 |
| `fn::scheduler_due_list` | rend aussi `created_at` de chaque planification (ancre d'un intervalle, U3) | point ouvert du lot 2 |
| `fn::scheduler_run_publish` (nouvelle, moteur) | `{ run, lease }` : publie l'événement déclaré par la tâche (`fn::event_publish`, résultat vérifié) puis termine l'exécution, dans la même transaction | W5 |
| erreurs | `SCHEDULER_RUN_TIMEOUT`, `SCHEDULER_HANDLER_NOT_FOUND`, `SCHEDULER_EXECUTOR_FAILED` | W4, §3 |

Tests du banc SurrealQL mis à jour en conséquence ; `fn::scheduler_run_publish` testée (succès,
jeton périmé, tâche qui n'est pas `event`).

## 3. Rust

### 3.1. Contrats publics

```rust
/// Code d'une tâche `handler`, inscrit par son module.
#[async_trait]
pub trait TaskHandler: Send + Sync {
    /// Nom de la tâche déclarée (`notification.digest`).
    fn task(&self) -> &str;
    /// Exécute une tentative ; doit être idempotent (S7).
    async fn run(&self, ctx: RunContext) -> Result<TaskOutput, TaskFailure>;
}

pub struct RunContext {           // rien de secret
    pub run: SchedulerRecordId, pub tenant: Option<SchedulerRecordId>,
    pub schedule: Option<SchedulerRecordId>, pub scheduled_for: SchedulerDatetime,
    pub attempt: i64, pub max_attempts: i64, pub args: SchedulerValue,
    pub cancellation: CancellationToken,   // annulation demandée ou délai maximal
}
pub struct TaskOutput { pub result: Option<SchedulerValue> }          // résultat court (4 Kio)
pub struct TaskFailure { pub code: String, pub message: String, pub retryable: bool }

/// Registre des handlers, rempli par les modules au démarrage de l'hôte.
pub struct HandlerRegistry { /* nom de tâche → handler */ }
impl HandlerRegistry { pub fn register(&mut self, h: Arc<dyn TaskHandler>) -> Result<(), SchedulerError>; }

/// Façade pour les autres modules (planifier, différer, annuler), au nom de l'appelant.
pub struct SchedulerClient { /* SchedulerStore */ }
impl SchedulerClient {
    pub async fn enqueue(&self, p: RunEnqueueParams) -> Result<Run, SchedulerError>;
    pub async fn schedule(&self, p: ScheduleCreateParams) -> Result<Schedule, SchedulerError>; // contrôlée (lot 2)
    pub async fn cancel(&self, p: RunCancelParams) -> Result<Run, SchedulerError>;
}
```

Un deuxième handler pour la même tâche est refusé ; une tâche `handler` sans handler inscrit sur
un nœud n'est pas réservée par ce nœud (elle attend un nœud qui l'a, ou finit `dead` après ses
tentatives avec `SCHEDULER_HANDLER_NOT_FOUND` si aucun nœud ne l'a au bout du délai maximal).

### 3.2. Workers (`LyxalWorker`, annulation coopérative, aucun `tokio::spawn` libre)

| Worker | Rôle |
| :--- | :--- |
| `SchedulerLeaderWorker` | Prend et renouvelle le bail `leader` ; à chaque tour : `due_list`, calcul des dates manquées et de la suivante (lot 2), décalage aléatoire, `schedule_fire` / `backfill_fire`, `schedule_next_set` (ou `invalid`) ; reprise des baux expirés (`run_rescue`) ; élagage (`run_prune`). Sans bail : attend. |
| `SchedulerExecutorWorker` (un par file) | `run_claim` dans la limite W3 ; pour chaque exécution, tâche supervisée par le worker (`JoinSet` arrêté avec lui) : battement à mi-bail, délai maximal, annulation demandée (`cancel_requested`), puis exécuteur : handler Rust, fonction SurrealQL par `store.call_fn(cible, { args, run, tenant, scheduled_for, attempt })`, ou `run_publish` ; fin par `run_complete` / `run_fail`. Une fin refusée pour jeton périmé (`SCHEDULER_LEASE_LOST`) est journalisée, jamais réécrite. |

Toutes les exécutions se font en **session système** (T2). Arrêt du nœud : plus de réservation,
annulation transmise aux tâches en cours, attente bornée (30 s), puis abandon (le bail expire et la
reprise s'en charge).

### 3.3. Module, santé, hôte

* `SchedulerModule` (`LyxalModule`) : descripteur depuis le manifeste ; démarre et arrête les
  workers.
* `SchedulerHealthCheck` (`ModuleHealthCheck`) : dégradé si aucune file n'a d'exécuteur, si des
  exécutions attendent depuis plus de 5 min au-delà de leur date, ou si des tâches `handler`
  actives n'ont aucun handler inscrit ; texte sans donnée d'organisation.
* `apps/lyxal-server/src/modules/scheduler.rs` : module, workers et sonde inscrits ; registre des
  handlers ouvert aux autres modules hébergés ; réglage `LYXAL__SCHEDULER__WORKERS`
  (`apps/lyxal-server/README.md`).

## 4. Erreurs

`SCHEDULER_RUN_TIMEOUT` (délai maximal), `SCHEDULER_HANDLER_NOT_FOUND` (aucun handler inscrit),
`SCHEDULER_EXECUTOR_FAILED` (erreur technique de l'exécuteur : base indisponible, résultat
illisible), en master data dans `error/executions/`.

## 5. Tests

* **Rust, base embarquée** : planification à intervalle qui produit ses exécutions et les exécute
  de bout en bout (handler, fonction SurrealQL d'un module d'essai, publication différée lue dans
  `event_outbox`) ; deux planificateurs simultanés : un seul a le bail, aucune exécution en double ;
  perte du bail ; nœud arrêté pendant une exécution puis reprise par un autre ; délai maximal ;
  annulation demandée ; nouvelles tentatives puis `dead` ; chevauchement `skip` et `buffer_one` vus
  par le moteur ; décalage aléatoire appliqué ; équité entre organisations ; handler absent ;
  arrêt propre des workers ; aucun jeton de bail dans les journaux.
* **Banc SurrealQL** : changements du §2.
* **Hôte** : démarrage avec le module, ses workers et sa sonde.
* Contrôle complet : `scripts/ci/ci_local.sh`.

## 6. Documents

`README.md` (moteur, handlers, réglages), `ROADMAP.md` (lot 3 retiré), `lyxal_runtime/README.md`
(bail `leader`), `apps/lyxal-server/README.md` (réglage, module), `.agents/AGENTS.md` §6 ; ligne 3
du plan racine passée à « Réalisé ». Ce plan est supprimé dans la demande de fusion de
l'implémentation.

## 7. Checklist (§13)

* Runtime : `LyxalModule`, `LyxalWorker` coopérant avec l'annulation, `ModuleHealthCheck`,
  aucun `tokio::spawn` libre (tâches tenues par le worker).
* Rust : wrappers `call_fn`, aucun `raw_query` métier, aucun `panic!` ni `unwrap` hors tests,
  aucune erreur masquée, jeton de bail jamais affiché.
* Événements : publication différée par `fn::event_publish` dans la transaction de fin ; le
  scheduler ne connaît aucun consommateur.
* Zéro dette : rupture coordonnée de `schedule_fire`, `backfill_fire` et `due_list`, appelants mis
  à jour dans le même changement.
