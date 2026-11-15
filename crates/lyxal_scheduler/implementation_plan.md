# Plan d'implémentation — `lyxal_scheduler`, lot 1 : socle SurrealQL

Premier lot du programme `lyxal_scheduler` (`implementation_plan.md` à la racine, décisions S1 à
S8 validées par le CTO le 15 novembre 2026). Il crée le module et tout ce qui vit dans SurrealDB :
réglages, tâches déclarées par les modules, files, calendriers, planifications, exécutions et
leurs états, réservation sous bail, nouvelles tentatives, chevauchement, droits par
organisation, journal, événements. Il supprime l'ancien dossier `lyxal_scheduler/` et ses écrans
Surrealist (S1). Le calcul des dates (cron, fuseaux, calendriers) arrive au lot 2 et la boucle du
moteur au lot 3 : ici, les tests fournissent eux-mêmes les dates. Aucune ligne de code avant la
validation du CTO (`.agents/AGENTS.md` §3).

## 1. Questions soumises au CTO

| N° | Question | Proposition |
| :- | :--- | :--- |
| **T1** | Déclaration d'une tâche | Par le **seed du module propriétaire**, comme les permissions dans `lyxal_auth` : `IF !record::exists(scheduler_task:⟨notification.digest⟩) THEN (CREATE …) END;`. Nom `<module>.<action>` en minuscules ; une personne ne crée, ne modifie ni ne supprime jamais une tâche ; la session système peut seulement l'activer ou la désactiver. |
| **T2** | Droits à l'exécution | La permission propre de la tâche est contrôlée **à la création et à chaque modification** d'une planification ou d'une exécution différée. L'exécution se fait ensuite au nom du système, pour l'organisation de la planification (modèle Temporal, Oban) ; la fonction ou le handler du module reste responsable de ne toucher que cette organisation. Une planification dont l'auteur a perdu le droit continue ; un gestionnaire peut la mettre en pause ou la supprimer. |
| **T3** | Équité entre organisations | Deux limites tenues par **compteurs** (une écriture conditionnelle, donc pas de dépassement entre deux nœuds) : places de la file (`scheduler_queue.running < concurrency`), et places par organisation dans la file (`scheduler_slot`, 10 par défaut). Une organisation pleine laisse passer les autres. |
| **T4** | Journal | Journal **simple en ajout seul** (`scheduler_audit`), sans chaînage : il trace les actions des personnes (création, pause, rejeu, annulation, réglages), pas chaque exécution, déjà suivie par `scheduler_run`. |
| **T5** | Limites par défaut | Arguments 16 Kio ; résultat court 4 Kio ; message d'erreur 1 000 caractères ; 1 000 planifications et 10 000 exécutions en attente par organisation ; réglables. |

## 2. Module

Structure canonique (§4) : `manifest.toml` (dépendances `lyxal_core`, `lyxal_error`,
`lyxal_event`, `lyxal_auth`), `schema/`, `functions/`, `events/`, `error/`, `seeds/`, `tests/`,
`README.md`, `ROADMAP.md`. Aucun dossier `migrations/` : le schéma cible complet est déclaré dans
`schema/` (`DEFINE … OVERWRITE`, rejouable), comme dans tous les modules du dépôt ; le §0.3
limite un module à une migration au plus, il n'en exige pas, et une `0001_initial.surql` recopiant
`schema/` dupliquerait le schéma (§5.1). Version `0.1.0`. Aucun code
Rust dans ce lot : l'hôte porte le module par un `ManifestModule` (`build.rs`).
`RECHERCHE_SOURCES.md` reste jusqu'à la clôture (lot 5).

## 3. Schéma (`TYPE NORMAL SCHEMAFULL`)

`tenant` : organisation (`option<record<auth_organization>>`, `REFERENCE ON DELETE CASCADE`) ;
`NONE` = installation. `scope_key` = identifiant de l'organisation ou `installation`, pour les
index et les compteurs.

| Table | Champs | Règles |
| :--- | :--- | :--- |
| `scheduler_settings` | `tenant`, `scope_key`, `catchup_window`, `run_retention`, `keep_last_runs`, `tenant_concurrency`, `max_schedules`, `max_pending_runs`, `max_args_bytes`, `updated_at` | une ligne par portée ; valeurs effectives : organisation, sinon installation, sinon défauts (1 h, 30 jours, 10, 10, 1 000, 10 000, 16 Kio) |
| `scheduler_task` | id `⟨module.action⟩`, `module`, `description`, `executor` (`handler`, `function`, `event`), `target`, `permission`, `args_schema`, `queue`, `priority`, `retry`, `timeout`, `unique_for`, `scope` (`organization`, `installation`), `state` (`active`, `disabled`) | `target` : nom du handler (`module.action`), d'une fonction `<module>_<action>` du **même module**, ou d'un type d'événement préfixé par le module ; `args_schema` : schéma `fn::validation_object_execute` ; `retry` validé par `fn::validation_retry_policy` (10 tentatives, 24 h au plus) ; `timeout` 1 s à 24 h ; seule la session système écrit, et seulement `state` après création |
| `scheduler_queue` | id `⟨nom⟩`, `concurrency`, `running`, `paused`, `paused_reason`, `updated_at` | files `default` et `maintenance` en seed ; `running` jamais négatif ni au-delà de `concurrency`, modifié seulement par la réservation et la fin d'une exécution |
| `scheduler_slot` | `queue`, `scope_key`, `running` | compteur par file et organisation (T3), créé à la première réservation |
| `scheduler_calendar` | `tenant`, `scope_key`, `name`, `description`, `rules`, `created_by`, `created_at`, `updated_at` | (`scope_key`, `name`) unique ; `rules` : liste de `{ mode: include \| exclude, kind: dates \| annual \| weekdays \| monthdays \| time_range, values }`, contrôlée ici, évaluée par Rust au lot 2 ; suppression refusée si une planification l'utilise |
| `scheduler_schedule` | `tenant`, `scope_key`, `name`, `task`, `args`, `spec` (`{ cron: [..], every: [..], at, exclude_cron: [..], timezone, start_at, end_at, jitter }`), `calendars`, `overlap`, `catchup` (`last`, `all`, `none`), `catchup_window`, `remaining`, `paused`, `paused_reason`, `pause_on_failure`, `state` (`active`, `completed`, `invalid`), `invalid_reason`, `next_fire_at`, `last_fire_at`, `last_run`, `last_state`, `created_by`, `created_at`, `updated_at` | (`scope_key`, `name`) unique ; `overlap` parmi `skip` (défaut), `buffer_one`, `buffer_all`, `cancel_other`, `allow_all` (S6) ; `next_fire_at` écrit seulement par le moteur ; toute modification de `spec`, `calendars` ou `paused` remet `next_fire_at` à `NONE` (recalcul) |
| `scheduler_backfill` | `schedule`, `from`, `to`, `overlap`, `state` (`pending`, `running`, `done`, `cancelled`), `requested_by`, `created_at` | un seul rejeu en cours par planification ; `to` passé, `from < to`, 1 an au plus |
| `scheduler_run` | id `[planification, date prévue]` (échéance) ou aléatoire (différée, immédiate, rejeu manuel) ; `tenant`, `scope_key`, `schedule`, `task`, `args`, `queue`, `priority`, `origin` (`schedule`, `backfill`, `trigger`, `enqueue`, `retry`), `scheduled_for`, `available_at`, `state`, `attempt`, `max_attempts`, `unique_key`, `lease`, `lease_node`, `locked_until`, `cancel_requested`, `started_at`, `finished_at`, `duration_ms`, `result`, `error` (`{ code, message, retryable }`), `created_by`, `created_at`, `updated_at` | `scheduled_for` figé à travers les tentatives ; `lease` lisible seulement par la session système et le worker |
| `scheduler_audit` | `tenant`, `scope_key`, `action`, `actor`, `session_kind`, `ip`, `schedule`, `run`, `details`, `created_at` | ajout seul (T4), écrit par des `DEFINE EVENT` ; jamais d'arguments |

**États d'une exécution** (le programme prévoyait aussi `claimed` et `failed` : la réservation
passe directement à `running`, et un échec est `retrying` ou `dead`) :

```text
waiting ──(précédente terminée)──► queued ──(réservation)──► running ──► completed
                                     ▲                          │
                                     └──── retrying ◄───(échec, tentatives restantes)
                                                                ├──► dead (dernière tentative)
queued / waiting / retrying / running ──(annulation)──► cancelled
                       (chevauchement skip) ──► skipped
```

* `waiting` : exécution mise en attente par `buffer_one` / `buffer_all`, libérée quand la
  précédente se termine ;
* une exécution `running` dont `locked_until` est passé est reprise (`scheduler_run_rescue`) :
  `retrying` s'il reste des tentatives, sinon `dead` ;
* délai avant la tentative suivante : stratégie de la tâche (fixe, linéaire, exponentielle),
  plafonnée par `max_delay`, avec gigue complète (`rand::float`), calculé par une fonction
  interne du module.

**Unicité** : une tâche avec `unique_for` refuse une seconde exécution différée de même
`unique_key` (fournie, ou empreinte des arguments) tant qu'une exécution non terminée de moins de
`unique_for` existe ; le résultat renvoie alors l'exécution existante (`duplicate: true`, modèle
Oban).

**Garde de cohérence** : des `DEFINE EVENT` refusent toute transition non listée, toute écriture
de compteur hors réservation et fin, toute modification de `scheduled_for`, `task`, `tenant`,
`origin`, et toute écriture d'une tâche par une session non système.

## 4. Droits

Permissions `lyxal_auth` créées en seed :

| Permission | Portée | Donne |
| :--- | :--- | :--- |
| `scheduler.schedule.read` | organisation | lire tâches, files, calendriers, planifications, exécutions, journal |
| `scheduler.schedule.write` | organisation | créer, modifier, mettre en pause, reprendre, supprimer une planification ; déclencher, rejouer une période ; créer une exécution différée (avec la permission propre de la tâche, T2) |
| `scheduler.run.manage` | organisation | annuler une exécution, relancer une exécution `dead` |
| `scheduler.calendar.write` | organisation | gérer les calendriers |
| `scheduler.settings.manage` | organisation | réglages de l'organisation |
| `scheduler.installation.manage` | installation | planifications, calendriers et réglages de l'installation ; pause des files |
| `scheduler.worker` | installation | compte de service du moteur (lot 3) |

Rôles : `organization_admin` reçoit les permissions d'organisation ; `platform_admin` reçoit
`scheduler.installation.manage` ; `scheduler.worker` n'est donnée à aucun rôle. Contrôle unique :
`fn::scheduler_can({ action, tenant, task })`, utilisé par les `PERMISSIONS` des tables et par
les fonctions.

## 5. Fonctions publiques (`fn::scheduler_*($params: object)`)

Toutes renvoient `fn::result_ok` ou `fn::error_result`. Entrées par
`fn::validation_object_execute` ; règles Core : `record`, `slug`, `enum`, `boolean`, `integer`,
`optional_string`, `array_of_strings`, `datetime`, `future_datetime`, `duration`,
`language_code` ; arguments d'une tâche par son `args_schema` ; politique de tentatives par
`fn::validation_retry_policy`.

| Fonction | Paramètres (**obligatoires**) | Résultat | Droit |
| :--- | :--- | :--- | :--- |
| `scheduler_settings_get` / `_set` | `tenant` ; réglages, `clear` | `{ own, effective }` | lecture / réglages |
| `scheduler_task_list` / `_get` | `module`, `state` / **task** | tâches | lecture |
| `scheduler_task_set_state` | **task**, **state** | tâche | session système |
| `scheduler_queue_list` | — | files, places occupées | lecture |
| `scheduler_queue_pause` / `_resume` | **queue**, `reason` | file | installation |
| `scheduler_calendar_create` / `_update` / `_get` / `_list` / `_delete` | **name**, **rules**, `tenant`, `description` | calendrier | calendriers / lecture |
| `scheduler_schedule_create` | **name**, **task**, **spec**, `tenant`, `args`, `calendars`, `overlap`, `catchup`, `catchup_window`, `remaining`, `pause_on_failure`, `paused` | planification (`next_fire_at` à calculer) | écriture + permission de la tâche |
| `scheduler_schedule_update` | **schedule**, champs modifiables, `clear` | planification | idem |
| `scheduler_schedule_get` / `_list` | **schedule** / `tenant`, `task`, `state`, `paused`, `limit`, `start` | planification et dernières exécutions / `{ items, total }` | lecture |
| `scheduler_schedule_pause` / `_resume` | **schedule**, `reason` | planification | écriture |
| `scheduler_schedule_trigger` | **schedule**, `overlap` | exécution immédiate (`origin: trigger`) | écriture |
| `scheduler_schedule_backfill` | **schedule**, **from**, **to**, `overlap` | demande de rejeu | écriture |
| `scheduler_schedule_delete` | **schedule** | `{ deleted }` ; exécutions en attente annulées, historique gardé | écriture |
| `scheduler_run_enqueue` | **task**, `tenant`, `args`, `run_at` ou `delay`, `priority`, `unique_key` | exécution (`duplicate`) | écriture + permission de la tâche |
| `scheduler_run_get` / `_list` | **run** / `tenant`, `schedule`, `task`, `state`, `since`, `limit`, `start` | exécution / `{ items, total }` | lecture |
| `scheduler_run_cancel` | **run**, `reason` | exécution (`cancelled`, ou `cancel_requested` si en cours) | exécutions |
| `scheduler_run_retry` | **run** | nouvelle exécution (`origin: retry`) d'une exécution `dead` ou `cancelled` | exécutions |
| `scheduler_audit_list` | `tenant`, `schedule`, `action`, `since`, `limit`, `start` | `{ items, total }` | lecture |

**Fonctions du moteur** (session système ou `scheduler.worker`, appelées par le lot 3) :

| Fonction | Rôle |
| :--- | :--- |
| `scheduler_due_list` | planifications actives non en pause dont `next_fire_at` est passé ou à calculer ; rejeux en attente |
| `scheduler_schedule_fire` | **schedule**, **fire_times** (dates manquées calculées par Rust), **next_fire_at** : applique le rattrapage (`last` / `all` / `none` dans la fenêtre), crée `scheduler_run:[planification, date]` (un doublon est ignoré), applique le chevauchement, décrémente `remaining`, passe à `completed` à la fin |
| `scheduler_schedule_next_set` | **schedule**, **next_fire_at** ou **invalid_reason** |
| `scheduler_backfill_fire` | **backfill**, **fire_times**, `done` |
| `scheduler_run_claim` | **queue**, **node**, `limit` : réserve les exécutions disponibles par priorité puis date, dans les limites de la file et de chaque organisation (T3) ; jeton de bail nouveau, `locked_until` = maintenant + délai de la tâche + marge |
| `scheduler_run_heartbeat` | **run**, **lease** : prolonge le bail ; renvoie `cancel_requested` |
| `scheduler_run_complete` | **run**, **lease**, `result` : `completed`, libère les places, libère une exécution `waiting` |
| `scheduler_run_fail` | **run**, **lease**, **error**, `retryable` : `retrying` avec délai, ou `dead` ; pause sur échec si demandé |
| `scheduler_run_rescue` | `limit` : exécutions au bail expiré |
| `scheduler_run_prune` | `limit` : exécutions terminées plus vieilles que la conservation, en gardant les N dernières de chaque planification (S7) |

Chaque fin d'exécution (`complete`, `fail`, `cancel`, `rescue`) exige le jeton du bail en cours
(garde de génération, modèle de `lyxal_event`) : un nœud qui a perdu son bail ne peut rien écrire.

Types Rust `XxxParams` / `XxxResult` et wrappers `store.call_fn` : définis au lot 2, avec le
crate Rust.

## 6. Erreurs (`error/<thème>/`, préfixe `SCHEDULER_`)

| Thème | Codes |
| :--- | :--- |
| `parametres` | `SCHEDULER_INVALID_PARAMETERS`, `SCHEDULER_ARGS_INVALID`, `SCHEDULER_LIMIT_REACHED` |
| `permissions` | `SCHEDULER_PERMISSION_DENIED`, `SCHEDULER_WRITE_FORBIDDEN` |
| `taches` | `SCHEDULER_TASK_NOT_FOUND`, `SCHEDULER_TASK_DISABLED`, `SCHEDULER_QUEUE_NOT_FOUND` |
| `planifications` | `SCHEDULER_SCHEDULE_NOT_FOUND`, `SCHEDULER_SCHEDULE_EXISTS`, `SCHEDULER_SCHEDULE_STATE_INVALID`, `SCHEDULER_SPEC_INVALID`, `SCHEDULER_BACKFILL_RUNNING`, `SCHEDULER_CALENDAR_NOT_FOUND`, `SCHEDULER_CALENDAR_EXISTS`, `SCHEDULER_CALENDAR_IN_USE` |
| `executions` | `SCHEDULER_RUN_NOT_FOUND`, `SCHEDULER_RUN_STATE_INVALID`, `SCHEDULER_LEASE_LOST` |

## 7. Événements

**Bus `lyxal_event`** (`fn::event_publish`, résultat vérifié, jamais d'arguments) :
`scheduler.schedule.created`, `.updated`, `.paused`, `.resumed`, `.deleted`, `.completed`,
`.invalid` ; `scheduler.run.completed`, `.failed` (tentative ratée), `.dead`, `.cancelled`,
`.skipped` ; `scheduler.queue.paused`, `.resumed`. Charge : organisation, planification, tâche,
exécution, date prévue, tentative, code d'erreur.

**Journal** (`DEFINE EVENT` vers `scheduler_audit`) : créations, modifications, pauses,
reprises, suppressions, déclenchements, rejeux, annulations, relances, réglages, calendriers ;
auteur (`$auth`), type de session, adresse (`$session.ip`).

## 8. Core

Aucune extension : moteur de validation, `fn::validation_retry_policy` et règles existantes.
Le contrôle de la forme de `spec` (listes, longueurs, fuseau non vide) reste dans le module ; la
syntaxe d'une expression cron et le nom d'un fuseau sont contrôlés par Rust (lot 2), qui écrit
`invalid` sur une planification fausse.

## 9. Suppressions (S1)

* dossier `lyxal_scheduler/` à la racine, en entier ;
* écrans Surrealist `src/screens/surrealist/pages/Connection/views/scheduler/` et leur
  inscription (`src/types.tsx`, `src/constants.tsx`, `sidebar.tsx`, `index.tsx`) ;
* toute mention qui y renvoie dans la documentation.

## 10. Hôte

`apps/lyxal-server/build.rs` : `lyxal_scheduler` embarqué ; tests de démarrage mis à jour
(nombre de modules hébergés).

## 11. Documents

`README.md` et `ROADMAP.md` du module ; `.agents/AGENTS.md` §6 et
`docs/14-roadmap/ROADMAP_NOYAU.md` (`lyxal_scheduler` créé) ; `apps/lyxal-server/ROADMAP.md` ;
ligne 1 du plan racine passée à « Réalisé ». Ce plan est supprimé dans la demande de fusion de
l'implémentation.

## 12. Tests (banc SurrealQL)

* réglages : valeurs effectives, bornes ;
* tâches : déclaration par seed rejouable, écriture refusée hors session système, cible d'un
  autre module refusée, désactivation ;
* calendriers : règles valides et fausses, unicité, suppression refusée s'il est utilisé ;
* planifications : création, arguments hors schéma refusés, permission propre de la tâche,
  limite par organisation, unicité du nom, modification qui remet `next_fire_at` à calculer,
  pause, reprise, suppression ;
* échéances : une même date ne crée qu'une exécution (deux appels de `fire`) ; rattrapage
  `last`, `all`, `none` dans et hors de la fenêtre ; `remaining` ; fin de planification ;
* chevauchement : chaque politique (`skip` → `skipped`, `buffer_one`, `buffer_all` → `waiting`
  puis libérée, `cancel_other`, `allow_all`) ;
* exécutions différées : `run_at`, `delay`, unicité (`duplicate`), limite d'attente ;
* réservation : priorité puis date, file en pause, places de la file et de l'organisation
  jamais dépassées, une organisation pleine n'en bloque pas une autre, bail ;
* fin : jeton périmé refusé (`SCHEDULER_LEASE_LOST`), succès, nouvelle tentative avec délai
  croissant et plafonné, `dead`, pause sur échec, annulation demandée pendant l'exécution,
  reprise d'un bail expiré, élagage qui garde les N dernières ;
* transitions interdites refusées ; champs figés ; compteurs protégés ;
* droits : chaque fonction sous une identité sans permission ; organisations isolées ; écriture
  filtrée par les permissions (`SCHEDULER_WRITE_FORBIDDEN`) ;
* journal et événements publiés ; rejeu des seeds ; chaque fonction appelée.
* Contrôle complet : `scripts/ci/ci_local.sh`.

## 13. Checklist (§13)

* Architecture : module du noyau, sans dépendance vers un module métier ; aucun cycle.
* Core : entrées par le moteur ; aucune extension demandée.
* Crypto : aucune opération.
* Zéro dette : `0.1.0`, schéma unique dans `schema/` (aucune migration corrective), ancien dossier et écrans supprimés, aucun alias.
