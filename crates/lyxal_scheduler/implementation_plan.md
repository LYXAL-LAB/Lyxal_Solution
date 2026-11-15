# Plan d'implémentation — `lyxal_scheduler`, lot 2 : calcul des dates (Rust)

Deuxième lot du programme `lyxal_scheduler` (`implementation_plan.md` à la racine). Il crée le
crate Rust du module et tout le calcul des dates que SurrealDB ne sait pas faire : expressions
cron, intervalles, date unique, fuseaux horaires et changements d'heure, exclusions, calendriers
d'exceptions, bornes, décalage aléatoire, prévision. Il fournit aussi les contrats Rust
(`XxxParams` / `XxxResult`) et les wrappers `store.call_fn` de toutes les fonctions du lot 1. La
boucle du moteur (bail, échéances, exécution) reste au lot 3. Aucune ligne de code avant la
validation du CTO (`.agents/AGENTS.md` §3).

## 1. Questions soumises au CTO

| N° | Question | Proposition |
| :- | :--- | :--- |
| **U1** | Précision | Expressions cron de 5 à 7 champs (secondes et année facultatives) ; **au moins 1 minute entre deux échéances** d'une même planification (un rythme plus rapide relève d'un worker, pas d'une planification). Une expression qui tomberait plus souvent est refusée (`SCHEDULER_SPEC_INVALID`). |
| **U2** | Jour du mois et jour de la semaine tous deux renseignés (`0 9 1 * MON`) | Règle de cron classique (Vixie, POSIX) : l'un **ou** l'autre, comme `croner` par défaut. Quartz exige `?` ; on l'accepte aussi. |
| **U3** | Point de départ d'un intervalle (`every: [6h]`) | Compté depuis `start_at` s'il est donné, sinon depuis la **création de la planification** ; un intervalle n'est pas soumis au changement d'heure (durée réelle, modèle Temporal). |
| **U4** | Calendrier qui exclut toutes les dates | Recherche limitée à 5 ans et 10 000 essais ; au-delà, la planification passe à `invalid` (`no_future_fire`) au lieu de bloquer le moteur. |
| **U5** | Décalage aléatoire (`jitter`) | Tiré à chaque échéance entre 0 et `jitter` ; borné à 1 h et à la moitié du plus petit écart entre deux échéances ; la date prévue (`scheduled_for`) reste l'identité de l'exécution, seul `available_at` est décalé. |

Rappel des décisions déjà prises : changement d'heure selon la règle d'Oban et `croner` (S5) ;
fuseau par planification, UTC par défaut ; bibliothèque `croner` (MIT) avec `jiff` (S3).

## 2. Crate

`crates/lyxal_scheduler/Cargo.toml` dans le workspace : `lyxal_surreal`, `lyxal_runtime` (types
d'erreur seulement dans ce lot), `surrealdb`, `serde`, `thiserror`, `tracing`, `jiff` (même
version et base des fuseaux intégrée que `lyxal_i18n`), **`croner`** (MIT,
`default-features = false`, fonction `jiff`), `rand_core` (`OsRng`, pour le décalage). Aucune
dépendance de chiffrement.

```text
src/
├── lib.rs
├── error.rs        SchedulerError (codes SCHEDULER_*, aucune erreur masquée)
├── store.rs        SchedulerStore (Surreal<Any>, LyxalSurrealCall) et wrappers 1-ligne
├── models/         XxxParams / XxxResult de chaque fonction du lot 1 (SurrealValue)
├── spec/
│   ├── mod.rs      Spec : lecture et contrôle d'une planification (cron, every, at, bornes…)
│   ├── cron.rs     expressions cron (croner), règle de changement d'heure
│   ├── calendar.rs règles d'un calendrier (dates, annuel, jours de semaine, jours du mois, plage horaire)
│   └── next.rs     prochaine date, dates manquées entre deux instants, prévision
└── service.rs      SchedulerService : contrôle des planifications avant écriture, prévision
```

## 3. Calcul

* **Prochaine date** après un instant `t` : plus petite date parmi les règles `cron` (dans le
  fuseau de la planification) et `every` (depuis l'ancre, U3), et `at` ; moins les dates de
  `exclude_cron` ; puis passage des calendriers (toutes les inclusions et aucune exclusion,
  modèle Croniq) ; dans `[start_at, end_at]`. Rien après `end_at` : `None`.
* **Dates manquées** entre la dernière échéance traitée et maintenant : liste bornée (1 000), que le
  lot 1 filtre ensuite selon le rattrapage (`last`, `all`, `none`) et sa fenêtre.
* **Changement d'heure** (S5) : heure inexistante → juste après le saut ; heure répétée → une
  seule exécution pour une heure fixe, les deux pour un joker ou un pas (`*/5`).
* **Prévision** : N prochaines dates (100 au plus) avec leur heure locale, pour l'affichage.
* **Contrôle** à l'écriture (`SchedulerService::schedule_create` / `_update`) : syntaxe de chaque
  expression, nom de fuseau IANA, au moins une échéance future, écart minimal (U1), `jitter`
  (U5), règles des calendriers. Erreur `SCHEDULER_SPEC_INVALID` avec la règle fautive. Une
  planification écrite directement en SurrealQL sans passer par Rust est contrôlée par le moteur
  (lot 3), qui la passe à `invalid`.

## 4. Contrats Rust

### 4.1. Conventions

* Chaque fonction publique du lot 1 a **une structure `XxxParams`** dont les champs portent
  exactement les noms lus dans `$params` (`#[surreal(rename_all = "snake_case")]` inutile : noms
  identiques), et **un type de résultat** décodé depuis `data` du contrat `{ ok, data, error }`.
  Dérivation `SurrealValue` (SDK 3.3), aucun `serde_json::to_value`, aucun tuple.
* Un champ facultatif est un `Option<T>` **omis** quand il vaut `None`
  (`#[surreal(default)]` à la lecture) : il prend alors la valeur par défaut de SurrealQL
  (`language` = `"fr"`, `limit`, `start`…). Aucune valeur par défaut recopiée en Rust (§5.1).
* Correspondance des types :

| SurrealQL (règle du lot 1) | Rust |
| :--- | :--- |
| référence (`auth_organization`, `scheduler_schedule`, `scheduler_calendar`, `scheduler_run`, `scheduler_backfill`) | `RecordId` (alias `SchedulerRecordId`, `models/types.rs`) |
| `datetime`, `future_datetime`, `past_datetime` | `Datetime` (alias `SchedulerDatetime`) |
| `duration` | `surrealdb::types::Duration` (alias `SchedulerDuration`) |
| `integer` | `i64` (`limit`, `start`, `priority`, `remaining`, compteurs) |
| `boolean` | `bool` |
| `slug`, `optional_string`, `required_string`, `language_code` | `String` |
| `lyxal_event_name` (nom de tâche `module.action`) | `String` |
| `enum` | `enum` Rust en minuscules (`Overlap`, `Catchup`, `RunState`, `ScheduleState`, `TaskState`, `Executor`, `RunOrigin`) |
| `is_object` (`args`, `result`), `rules` de calendrier | `Value` (objet) pour `args` et `result`, dont le schéma dépend de la tâche ; `CalendarRule` typée pour les règles |
| `spec` | `ScheduleSpec` typée (§4.2) |

### 4.2. Types partagés

| Type | Champs |
| :--- | :--- |
| `ScheduleSpec` | `cron: Vec<String>`, `every: Vec<Duration>`, `at: Option<Datetime>`, `exclude_cron: Vec<String>`, `timezone: String`, `start_at`, `end_at: Option<Datetime>`, `jitter: Option<Duration>` |
| `CalendarRule` | `mode: RuleMode` (`include`, `exclude`), `kind: RuleKind` (`dates`, `annual`, `weekdays`, `monthdays`, `time_range`), `values: Vec<Value>` |
| `RetryPolicy` | `max_attempts: i64`, `strategy: RetryStrategy` (`fixed`, `linear`, `exponential`), `initial_delay`, `max_delay: Duration` |
| `RunError` | `code: String`, `message: Option<String>`, `retryable: bool` |
| `Page<T>` | `items: Vec<T>`, `total: i64` |
| `Deleted` | `deleted: String` |

### 4.3. Paramètres (`XxxParams`) — champs obligatoires en **gras**, tous les autres `Option`

| Fonction | Champs |
| :--- | :--- |
| `settings_get` | `tenant` |
| `settings_set` | `tenant`, `catchup_window`, `run_retention`, `keep_last_runs`, `tenant_concurrency`, `max_schedules`, `max_pending_runs`, `max_args_bytes`, `clear: Vec<String>` |
| `task_list` | `module`, `state: TaskState`, `limit`, `start` |
| `task_get` | **`task`** |
| `task_set_state` | **`task`**, **`state: TaskState`** |
| `queue_list` | — |
| `queue_pause` / `queue_resume` | **`queue`**, `reason` (pause) |
| `calendar_create` | **`name`**, **`rules: Vec<CalendarRule>`**, `tenant`, `description` |
| `calendar_update` | **`calendar`**, `rules`, `description`, `clear` |
| `calendar_get` / `calendar_delete` | **`calendar`** |
| `calendar_list` | `tenant`, `limit`, `start` |
| `schedule_create` | **`name`**, **`task`**, **`spec: ScheduleSpec`**, `tenant`, `args`, `calendars: Vec<RecordId>`, `overlap: Overlap`, `catchup: Catchup`, `catchup_window`, `remaining`, `pause_on_failure`, `paused`, `paused_reason` |
| `schedule_update` | **`schedule`**, `args`, `spec`, `calendars`, `overlap`, `catchup`, `catchup_window`, `remaining`, `pause_on_failure`, `clear` |
| `schedule_get` / `schedule_resume` / `schedule_delete` | **`schedule`** |
| `schedule_pause` | **`schedule`**, `reason` |
| `schedule_list` | `tenant`, `task`, `state: ScheduleState`, `paused`, `limit`, `start` |
| `schedule_trigger` | **`schedule`**, `overlap` |
| `schedule_backfill` | **`schedule`**, **`from`**, **`to`**, `overlap` |
| `run_enqueue` | **`task`**, `tenant`, `args`, `run_at`, `delay`, `priority`, `unique_key` |
| `run_get` / `run_retry` | **`run`** |
| `run_list` | `tenant`, `schedule`, `task`, `state: RunState`, `since`, `limit`, `start` |
| `run_cancel` | **`run`**, `reason` |
| `audit_list` | `tenant`, `schedule`, `action`, `since`, `limit`, `start` |
| `due_list` | `limit` |
| `schedule_fire` | **`schedule`**, **`fire_times: Vec<Datetime>`**, `next_fire_at` |
| `schedule_next_set` | **`schedule`**, `next_fire_at` ou `invalid_reason` (l'un des deux) |
| `backfill_fire` | **`backfill`**, **`fire_times`**, `done` |
| `run_claim` | **`queue`**, **`node`**, `limit` |
| `run_heartbeat` | **`run`**, **`lease`** |
| `run_complete` | **`run`**, **`lease`**, `result` |
| `run_fail` | **`run`**, **`lease`**, **`error: RunError`** |
| `run_rescue` / `run_prune` | `limit` |

Tous les `XxxParams` portent aussi `language: Option<String>`.

### 4.4. Résultats

| Type | Champs | Rendu par |
| :--- | :--- | :--- |
| `Settings` | `catchup_window`, `run_retention`, `keep_last_runs`, `tenant_concurrency`, `max_schedules`, `max_pending_runs`, `max_args_bytes` | dans `SettingsResult { own: Option<Settings>, effective: Settings }` : `settings_get`, `settings_set` |
| `Task` | `id`, `module`, `description`, `executor: Executor`, `target`, `permission`, `args_schema: Value`, `queue`, `priority`, `retry: RetryPolicy`, `timeout`, `unique_for`, `scope`, `state`, `created_at`, `updated_at` | `task_get`, `task_set_state`, `Page<Task>` de `task_list` |
| `Queue` | `id`, `concurrency`, `running`, `paused`, `paused_reason`, `description`, `slots: Vec<Slot { scope_key, running }>` | `queue_list` (`Vec<Queue>`), `queue_pause`, `queue_resume` |
| `Calendar` | `id`, `tenant`, `name`, `description`, `rules: Vec<CalendarRule>`, `created_by`, `created_at`, `updated_at` | `calendar_create`, `_update`, `_get`, `Page<Calendar>` ; `Deleted` pour `_delete` |
| `Schedule` | tous les champs de `scheduler_schedule` (`id`, `tenant`, `name`, `task`, `args`, `spec: ScheduleSpec`, `calendars`, `overlap`, `catchup`, `catchup_window`, `remaining`, `paused`, `paused_reason`, `pause_on_failure`, `state`, `invalid_reason`, `next_fire_at`, `last_fire_at`, `last_run`, `last_state`, `created_by`, `created_at`, `updated_at`) et `recent_runs: Vec<RunSummary>` | `schedule_create`, `_update`, `_get`, `_pause`, `_resume`, `_next_set`, `Page<Schedule>` ; `Deleted` pour `_delete` |
| `RunSummary` | `id`, `state`, `origin`, `scheduled_for`, `attempt`, `finished_at`, `error: Option<RunError>` | dans `Schedule` |
| `Run` | tous les champs de `scheduler_run` sauf le jeton de bail : `id`, `tenant`, `schedule`, `task`, `args`, `queue`, `priority`, `origin`, `scheduled_for`, `available_at`, `state`, `attempt`, `max_attempts`, `unique_key`, `lease_node`, `locked_until`, `cancel_requested`, `cancel_reason`, `started_at`, `finished_at`, `duration_ms`, `result`, `error`, `created_by`, `created_at`, `updated_at` ; plus `duplicate: Option<bool>` (`run_enqueue`) et `retry_of: Option<String>` (`run_retry`) | `run_enqueue`, `_get`, `_cancel`, `_retry`, `_complete`, `_fail`, `schedule_trigger`, `Page<Run>` |
| `Backfill` | `id`, `schedule`, `from`, `to`, `overlap`, `state`, `runs_created`, `requested_by`, `created_at` | `schedule_backfill` |
| `AuditEntry` | `id`, `tenant`, `action`, `actor`, `session_kind`, `ip`, `schedule`, `run`, `details: Value`, `created_at` | `Page<AuditEntry>` |
| `DueList` | `schedules: Vec<Schedule>`, `backfills: Vec<Backfill>` | `due_list` |
| `FireResult` | `runs: Vec<Run>`, `ignored: i64`, `schedule: Schedule` | `schedule_fire` |
| `BackfillFireResult` | `runs: Vec<Run>`, `backfill: Backfill` | `backfill_fire` |
| `ClaimedRun` | `id`, `lease` (jeton, `SecretString` : jamais dans un `Debug`), `lease_node`, `locked_until`, `timeout`, `tenant`, `schedule`, `task`, `args`, `origin`, `scheduled_for`, `attempt`, `max_attempts` | dans `ClaimResult { items: Vec<ClaimedRun>, paused: bool }` : `run_claim` |
| `Heartbeat` | `run`, `locked_until`, `cancel_requested` | `run_heartbeat` |
| `RescueResult` | `rescued: Vec<{ id, state }>`, `reconciled: i64` | `run_rescue` |
| `PruneResult` | `deleted: i64` | `run_prune` |

Un test par fonction vérifie, en base embarquée, que chaque `XxxParams` est accepté tel quel
(aucun champ inconnu : le lot 1 refuse les clés en trop) et que chaque résultat se décode sans
perte.

### 4.5. Services

* `SchedulerStore` : `Surreal<Any>`, `LyxalSurrealCall` ; un wrapper 1-ligne
  `store.call_fn("scheduler_…", params)` par fonction.
* `SchedulerService` : `schedule_create`, `schedule_update` (contrôle de `spec` et des calendriers
  par le §3, puis wrapper), `forecast(schedule, n)` (lecture puis calcul), `validate_spec` (sans
  écriture).
* `Spec::next_after`, `Spec::fire_times_between`, `Spec::forecast` : fonctions pures, testées sans
  base.

## 5. Erreurs

Aucun code nouveau : `SCHEDULER_SPEC_INVALID` (détails : règle, raison) et
`SCHEDULER_CALENDAR_NOT_FOUND` existent depuis le lot 1. Raison `no_future_fire` ajoutée aux
détails (U4).

## 6. Tests

* **Cron** : jeux de cas repris de `croner`, Quartz et Croniq — fin de mois, `L`, `5L`, `15W`, `LW`,
  `6#3`, alias, secondes, années, 29 février, jour du mois **ou** jour de la semaine (U2),
  expressions fausses.
* **Changement d'heure** : Europe/Paris et America/New_York, printemps et automne, heure fixe,
  joker et pas.
* **Intervalles** : ancre `start_at` ou création, indépendance du changement d'heure (U3).
* **Calendriers** : chaque sorte de règle, inclusion et exclusion, calendrier qui exclut tout (U4).
* **Bornes, date unique, exclusions, décalage** (U5), **dates manquées** (limite de 1 000),
  **prévision**.
* **Wrappers** : chaque fonction du lot 1 appelée par son wrapper en base embarquée (`mem://`),
  succès et erreur décodés.
* Contrôle complet : `scripts/ci/ci_local.sh`.

## 7. Documents

`README.md` (partie Rust, règles de calcul), `ROADMAP.md`, `RECHERCHE_SOURCES.md` inchangé
jusqu'à la clôture ; ligne 2 du plan racine passée à « Réalisé ». Ce plan est supprimé dans la
demande de fusion de l'implémentation.

## 8. Checklist (§13)

* Rust : `XxxParams` / `XxxResult`, wrappers `call_fn`, aucun `raw_query` métier, aucun `panic!`
  ni `unwrap` hors tests, aucune erreur masquée.
* Aucune logique métier dupliquée : les règles de rattrapage, de chevauchement et d'état restent
  en SurrealQL (lot 1) ; Rust ne calcule que des dates.
* Crypto : aucune ; `OsRng` pour le décalage aléatoire.
* Zéro dette : `0.1.0`, aucun alias.
