# `lyxal_scheduler` — tâches différées et périodiques

Module du Noyau Technique de Lyxal OS : planifie et exécute les tâches différées et périodiques
de tous les modules (purges, recalculs, envois, publications différées). Les recherches et les
modèles (Temporal, Oban, Quartz, Hatchet) sont dans [`RECHERCHE_SOURCES.md`](RECHERCHE_SOURCES.md),
les évolutions dans [`ROADMAP.md`](ROADMAP.md).

## État actuel

Le **socle SurrealQL** est en place : réglages, tâches déclarées par les modules, files,
calendriers d'exceptions, planifications, exécutions et leurs états, réservation sous bail,
nouvelles tentatives, chevauchement, rattrapage, rejeu de période, droits par organisation,
journal des actions et événements. Le **crate Rust** fournit le calcul des dates (cron,
intervalles, date unique, fuseaux et changements d'heure, exclusions, calendriers, bornes,
décalage aléatoire, prévision), le contrôle des planifications avant écriture et les appels
typés de chaque fonction publique (voir « Partie Rust »). La **boucle du moteur** (planificateur
et exécuteurs) n'est pas encore écrite : aucune exécution n'est lancée tant qu'elle n'existe
pas.

Manifeste : `lyxal_scheduler` 0.1.0, dépendances `lyxal_core`, `lyxal_error`, `lyxal_event`,
`lyxal_auth`. Le crate n'a pas encore de `LyxalModule` : l'hôte `lyxal-server` porte le module
par un `ManifestModule`.

## Les trois objets

```text
Tâche (scheduler_task)              ce qu'un module sait exécuter ; déclarée par le seed du module
   ▼                                 ex. notification.digest, automation.workflow_run
Planification (scheduler_schedule)  quand, avec quels arguments ; créée par une personne ou un module
   ▼
Exécution (scheduler_run)           une fois : créée à l'échéance, réservée, exécutée, retentée, terminée
```

Une exécution peut aussi naître sans planification : exécution **différée** (`run_at`, `delay`)
ou **immédiate** (`fn::scheduler_run_enqueue`).

## Tâches

Une tâche est déclarée par le seed de son module propriétaire, en session système, comme une
permission `lyxal_auth` :

```surql
IF !record::exists(scheduler_task:⟨notification.digest⟩) THEN (
    CREATE scheduler_task:⟨notification.digest⟩ CONTENT {
        module: "lyxal_notification", executor: "handler", target: "notification.digest",
        permission: "notification.digest.schedule",
        args_schema: { fields: { channel: { pipeline: [{ rule: "slug" }], required: true } }, unknown_keys: "reject" },
        queue: scheduler_queue:default, priority: 5, timeout: 5m, unique_for: 1h, scope: "organization",
        retry: { max_attempts: 3, strategy: "exponential", initial_delay: 30s, max_delay: 1h },
        description: { fr: "Résumé quotidien", en: "Daily digest" }
    }
) END;
```

* Identifiant `⟨module.action⟩` en minuscules ; `module` = `lyxal_<module>`.
* Exécuteur : `handler` (code Rust inscrit, cible `<module>.<action>`), `function` (fonction
  SurrealQL `<module>_<action>` du même module) ou `event` (publication différée d'un type
  d'événement préfixé par le module).
* `permission` : permission `lyxal_auth` existante exigée pour planifier la tâche (contrôlée à la
  création et à chaque modification d'une planification ou d'une exécution différée).
* `args_schema` : schéma de `fn::validation_object_execute` ; sans schéma, aucun argument.
* `retry` : normalisé par `fn::validation_retry_policy` (10 tentatives, 24 h au plus).
* `timeout` : 1 s à 24 h ; `unique_for` : unicité des exécutions différées.
* Une tâche n'est jamais créée, modifiée ni supprimée par une personne ; la session système peut
  seulement l'activer ou la désactiver (`fn::scheduler_task_set_state`). Une tâche désactivée ne
  reçoit ni planification ni exécution, et ses exécutions en attente ne sont pas réservées.

Les personnes créent librement leurs planifications d'une tâche active. Un module
d'automatisation déclarera par exemple `automation.workflow_run`, avec l'identifiant du flux en
argument : l'exécution de logique saisie par une personne relève de ce module, jamais du
scheduler.

## Planifications

* `spec` : `{ cron: [..], every: [..], at, exclude_cron: [..], timezone (UTC par défaut),
  start_at, end_at, jitter (1 h au plus) }`, au moins une règle `cron`, `every` ou `at`. La forme
  est contrôlée ici ; la syntaxe cron, le fuseau et les écarts le sont par le calcul des dates en
  Rust (`SchedulerService` avant l'écriture ; le moteur déclare `invalid` une planification
  écrite sans passer par Rust, par `fn::scheduler_schedule_next_set`).
* `calendars` : calendriers d'exceptions de la même portée (10 au plus).
* `next_fire_at` : écrit par le moteur seulement ; toute modification de `spec`, `calendars` ou
  de la pause le remet à `NONE` (date à recalculer).
* États : `active`, `completed` (plus d'échéance ou `remaining` épuisé), `invalid` (règles
  refusées ; corriger les règles la rend de nouveau active).
* Pause, reprise et suppression n'exigent que `scheduler.schedule.write` : un gestionnaire arrête
  une planification dont l'auteur a perdu le droit. La suppression annule les exécutions en
  attente, demande l'annulation de celle en cours et garde l'historique.
* `pause_on_failure` : une exécution `dead` met la planification en pause (motif `failure`).
* `fn::scheduler_schedule_trigger` : exécution immédiate (même en pause) ;
  `fn::scheduler_schedule_backfill` : rejeu d'une période passée (un an au plus, un seul en cours).

### Rattrapage et chevauchement

Le moteur passe à `fn::scheduler_schedule_fire` les échéances manquées calculées par Rust :

| `catchup` | Exécutions créées |
| :--- | :--- |
| `last` (défaut) | la plus récente de la fenêtre de rattrapage (`catchup_window`, réglage 1 h par défaut) |
| `all` | toutes celles de la fenêtre |
| `none` | la plus récente seulement si elle a moins d'une minute de retard |

Une échéance crée `scheduler_run:[planification, date prévue]` : une même date ne crée jamais deux
exécutions (deux nœuds, deux appels). Avant la création, la politique de chevauchement s'applique
(exécutions actives : `waiting`, `queued`, `running`, `retrying`) :

| `overlap` | Nouvelle exécution |
| :--- | :--- |
| `skip` (défaut) | `skipped` si une exécution est active |
| `buffer_one` | `waiting` ; `skipped` s'il y en a déjà une en attente |
| `buffer_all` | `waiting`, libérées une à une dans l'ordre des dates |
| `cancel_other` | les autres sont annulées (celle qui tourne reçoit une demande d'annulation) ; la nouvelle attend sa fin |
| `allow_all` | `queued` sans attendre |

## Exécutions

```text
waiting ──(précédente terminée)──► queued ──(réservation)──► running ──► completed
                                     ▲                          │
                                     └──── retrying ◄───(échec, tentatives restantes)
                                                                ├──► dead (dernière tentative)
waiting / queued / retrying ──(annulation)──► cancelled ; running ──(annulation acquittée)──► cancelled
                       (chevauchement skip) ──► skipped
```

* **Réservation** (`fn::scheduler_run_claim`) : par priorité (0 la plus haute) puis date, dans
  deux limites tenues par compteurs à écriture conditionnelle : places de la file
  (`scheduler_queue.running < concurrency`) et places de l'organisation dans la file
  (`scheduler_slot`, réglage `tenant_concurrency`). Les organisations déjà pleines sont écartées
  avant la sélection : leurs exécutions en attente ne masquent jamais celles des autres. Chaque réservation pose un **bail** : jeton nouveau (lisible par le moteur seulement),
  nœud, échéance = maintenant + délai de la tâche + 1 min.
* **Battement** (`fn::scheduler_run_heartbeat`) : prolonge le bail et indique si l'annulation est
  demandée. **Fin** (`fn::scheduler_run_complete`, `fn::scheduler_run_fail`) : exige le jeton du bail
  en cours (`SCHEDULER_LEASE_LOST` sinon). Un échec retentable avec des tentatives restantes passe à
  `retrying` après un délai (fixe, linéaire ou exponentiel, plafonné par `max_delay`, gigue
  complète) ; sinon `dead`. Une exécution dont l'annulation est demandée finit `cancelled`.
* **Reprise** (`fn::scheduler_run_rescue`) : une exécution dont le bail a expiré repasse à
  `retrying` (ou `dead`, ou `cancelled`), places rendues, erreur `SCHEDULER_LEASE_LOST` ; puis les
  compteurs de places sont recalés sur les exécutions réellement en cours (une organisation
  supprimée emporte ses exécutions en cours sans passer par leur fin).
* **Unicité** : une tâche avec `unique_for` renvoie l'exécution non terminée de même clé (fournie,
  sinon empreinte des arguments) créée depuis moins de `unique_for` (`duplicate: true`).
* **Élagage** (`fn::scheduler_run_prune`) : exécutions terminées plus vieilles que
  `run_retention` (30 jours), en gardant toujours les `keep_last_runs` (10) dernières de chaque
  planification ; l'éligibilité est évaluée avant la limite du lot, pour qu'un lot d'exécutions
  gardées ne bloque jamais l'élagage des suivantes.
* Des gardes `DEFINE EVENT` refusent toute transition non listée, toute modification de la
  planification, de la tâche, des arguments, de la file, de l'origine ou de la date prévue, toute
  réservation sans bail nouveau et toute fin sans bail rendu, y compris pour une écriture directe.

## Réglages

`fn::scheduler_settings_get` / `_set`, par organisation, sinon installation, sinon défauts :

| Réglage | Défaut |
| :--- | :--- |
| `catchup_window` | 1 h |
| `run_retention` | 30 jours |
| `keep_last_runs` | 10 |
| `tenant_concurrency` | 10 par file |
| `max_schedules` | 1 000 |
| `max_pending_runs` | 10 000 |
| `max_args_bytes` | 16 Kio |

Limites fixes : résultat court 4 Kio, message d'erreur 1 000 caractères (tronqué).

## Droits

| Permission | Portée | Donne |
| :--- | :--- | :--- |
| `scheduler.schedule.read` | organisation | lire tâches, files, calendriers, planifications, exécutions, journal |
| `scheduler.schedule.write` | organisation | planifications ; déclencher, rejouer, différer (avec la permission propre de la tâche) |
| `scheduler.run.manage` | organisation | annuler une exécution, relancer une exécution `dead` ou `cancelled` |
| `scheduler.calendar.write` | organisation | calendriers |
| `scheduler.settings.manage` | organisation | réglages de l'organisation |
| `scheduler.installation.manage` | installation | planifications, calendriers et réglages de l'installation ; pause des files |
| `scheduler.worker` | installation | compte de service du moteur (aucun rôle) |

`organization_admin` reçoit les permissions d'organisation, `platform_admin`
`scheduler.installation.manage`. Contrôle unique : `fn::scheduler_can({ action, tenant, task })`,
utilisé par les `PERMISSIONS` des tables, les gardes et les fonctions. L'exécution se fait au nom
du système, pour l'organisation de la planification ; la fonction ou le handler du module ne
touche que cette organisation. Une écriture filtrée par les permissions renvoie
`SCHEDULER_WRITE_FORBIDDEN`. Une organisation supprimée emporte ses réglages, calendriers,
planifications, exécutions et journal (`REFERENCE ON DELETE CASCADE`).

## Fonctions publiques

| Domaine | Fonctions (`fn::scheduler_*($params: object)`) |
| :--- | :--- |
| Réglages, files | `settings_get`, `settings_set` ; `queue_list`, `queue_pause`, `queue_resume` |
| Tâches | `task_list`, `task_get`, `task_set_state` (session système) |
| Calendriers | `calendar_create`, `calendar_update`, `calendar_get`, `calendar_list`, `calendar_delete` |
| Planifications | `schedule_create`, `schedule_update`, `schedule_get`, `schedule_list`, `schedule_pause`, `schedule_resume`, `schedule_trigger`, `schedule_backfill`, `schedule_delete` |
| Exécutions | `run_enqueue`, `run_get`, `run_list`, `run_cancel`, `run_retry` |
| Journal | `audit_list` |
| Moteur | `due_list`, `schedule_fire`, `schedule_next_set`, `backfill_fire`, `run_claim`, `run_heartbeat`, `run_complete`, `run_fail`, `run_rescue`, `run_prune` |

Toutes valident leurs entrées par `fn::validation_object_execute` et renvoient
`fn::result_ok` ou `fn::error_result`. Un identifiant d'enregistrement se passe en chaîne
(`"scheduler_schedule:…"`) ou en identifiant natif (exécutions `scheduler_run:[planification,
date]`) ; une tâche par son nom (`"notification.digest"`), une file par son nom.

## Erreurs (`error/<thème>/`)

| Thème | Codes |
| :--- | :--- |
| `parametres` | `SCHEDULER_INVALID_PARAMETERS`, `SCHEDULER_ARGS_INVALID`, `SCHEDULER_LIMIT_REACHED` |
| `permissions` | `SCHEDULER_PERMISSION_DENIED`, `SCHEDULER_WRITE_FORBIDDEN` |
| `taches` | `SCHEDULER_TASK_NOT_FOUND`, `SCHEDULER_TASK_DISABLED`, `SCHEDULER_QUEUE_NOT_FOUND` |
| `planifications` | `SCHEDULER_SCHEDULE_NOT_FOUND`, `SCHEDULER_SCHEDULE_EXISTS`, `SCHEDULER_SCHEDULE_STATE_INVALID`, `SCHEDULER_SPEC_INVALID`, `SCHEDULER_BACKFILL_RUNNING`, `SCHEDULER_CALENDAR_NOT_FOUND`, `SCHEDULER_CALENDAR_EXISTS`, `SCHEDULER_CALENDAR_IN_USE` |
| `executions` | `SCHEDULER_RUN_NOT_FOUND`, `SCHEDULER_RUN_STATE_INVALID`, `SCHEDULER_LEASE_LOST` |

## Événements

Bus `lyxal_event` (`fn::event_publish`, résultat vérifié, jamais d'arguments ni de résultat) :
`scheduler.schedule.created`, `.updated`, `.paused`, `.resumed`, `.deleted`, `.completed`,
`.invalid` ; `scheduler.run.completed`, `.failed` (tentative ratée, nouvelle tentative prévue),
`.dead`, `.cancelled`, `.skipped` ; `scheduler.queue.paused`, `.resumed`. Charge : organisation,
planification, tâche, exécution, origine, date prévue, tentative, code d'erreur.

Journal `scheduler_audit` (ajout seul, écrit par `DEFINE EVENT`) : actions des personnes —
réglages, tâches activées ou désactivées, files, calendriers, planifications créées, modifiées,
mises en pause, reprises, supprimées, rejeux, déclenchements, exécutions différées, annulations,
relances ; auteur, type de session, adresse. Les échéances traitées par le moteur ne sont pas
journalisées (suivies par `scheduler_run`).

## Partie Rust

### Calcul des dates (`spec/`)

`Spec::parse(spec, created_at, calendars)` lit les règles ; fonctions pures, l'instant de
référence est toujours un paramètre :

* `next_after(t)` : prochaine échéance strictement après `t`, ou `None` s'il n'y en a plus ;
* `fire_times_between(from, to, limit)` : échéances de `]from, to]`, 1000 au plus par appel,
  avec `truncated` pour reprendre après la dernière (dates manquées, rejeu de période) ;
* `forecast(t, n)` : les `n` prochaines échéances (100 au plus) avec leur heure locale ;
* `validate(now)`, `max_jitter(t)`, `draw_jitter(max)`.

Règles :

* **Cron** (`croner`, MIT) : 5 à 7 champs (`[secondes] minutes heures jour mois jour-de-semaine
  [année]` ; l'année exige les 7 champs), alias `@hourly`…`@yearly`, noms `JAN`-`DEC` et
  `SUN`-`SAT`, `L`, `5L`, `15W`, `LW`, `6#3`, `?` (Quartz) ; jours de la semaine de 0 à 7 (0 et 7 :
  dimanche, numérotation Vixie et non Quartz). Jour du mois **ou** jour de la semaine quand les
  deux sont restreints (U2) ; le préfixe `+` de `croner` (les deux à la fois) est refusé.
* **Fuseau** : nom IANA par planification, UTC par défaut ; base des fuseaux embarquée.
* **Changement d'heure** (S5, règle d'Oban et de `croner`, conforme à OCPS) : une heure fixe
  absente au printemps s'exécute au premier instant qui suit le saut (2 h 30 → 3 h 00) ; une
  heure fixe répétée à l'automne s'exécute une fois (premier passage) ; un joker ou un pas
  (`*/15`, `0 * * * *`) s'exécute à chaque passage réel. `croner` applique déjà cette règle ;
  aucun traitement n'a été ajouté.
* **Intervalles** (`every`, U3) : durée réelle, insensible au changement d'heure ; première
  échéance à `start_at`, sinon un intervalle après la création de la planification.
* **Date unique** `at` ; **bornes** `start_at` et `end_at` incluses ; rien après `end_at`.
* **Exclusions** `exclude_cron` : une date qui correspond est écartée (à la minute pour une
  expression sans secondes).
* **Calendriers** : pour chaque calendrier, toutes les règles d'inclusion et aucune règle
  d'exclusion, sur l'heure locale du fuseau (`dates` `AAAA-MM-JJ`, `annual` `MM-JJ`,
  `weekdays` 1 à 7, `monthdays` 1 à 31, `time_range` `HH:MM-HH:MM` à fin exclue, qui passe minuit
  si la fin précède le début).
* **Écart minimal** (U1) : une seule valeur de secondes par expression, intervalles d'une minute
  au moins, et au moins une minute entre deux échéances consécutives des 200 premières.
* **Recherche bornée** (U4) : 5 ans et 10 000 dates écartées au plus, sinon erreur
  `no_future_fire` (le moteur passe la planification à `invalid`).
* **Décalage aléatoire** (U5) : tiré par `OsRng` entre 0 et `jitter`, borné à 1 h et à la moitié
  du plus petit écart entre deux échéances ; `scheduled_for` reste l'identité de l'exécution.

### Contrats (`models/`, `store.rs`)

`SchedulerStore` (`Surreal<Any>`, `LyxalSurrealCall`) : un wrapper d'une ligne
`store.call_fn("scheduler_…", params)` pour chacune des 38 fonctions publiques. Chaque
`XxxParams` porte exactement les champs lus par sa fonction (un champ `None` est omis et prend la
valeur par défaut de SurrealQL) ; chaque résultat est une structure nommée (`SurrealValue`).
Le jeton de bail (`LeaseToken`) est opaque et masqué dans `Debug`.

### Service (`service.rs`)

`SchedulerService` : `schedule_create` et `schedule_update` contrôlent les règles (syntaxe,
fuseau, au moins une échéance future, U1, U5, règles des calendriers lus avec les droits de
l'appelant) avant d'appeler le wrapper ; erreur `SCHEDULER_SPEC_INVALID` avec la règle fautive
et la raison (`cron_syntax`, `timezone`, `min_interval`, `jitter`, `calendar_rule`, `range`,
`no_future_fire`, `out_of_range`). `validate_spec` contrôle sans écrire ; `forecast` lit une
planification et rend ses prochaines échéances.

### Tests Rust

`cargo test -p lyxal_scheduler` : 46 tests — expressions cron (jeux de cas de `croner`, Quartz
et Croniq), changement d'heure à Paris et New York, calendriers, intervalles, bornes,
exclusions, décalage, dates manquées, prévision ; et en base embarquée (`mem://`) chacune des
38 fonctions appelée par son wrapper, avec décodage sans perte de chaque résultat. Ils ne
remplacent pas le banc SurrealQL.

## Fichiers

| Dossier | Contenu |
| :--- | :--- |
| `schema/` | `scheduler_settings`, `scheduler_task`, `scheduler_queue` et `scheduler_slot`, `scheduler_calendar`, `scheduler_schedule`, `scheduler_backfill`, `scheduler_run`, `scheduler_audit` |
| `functions/` | droits et outils (`access`), réglages, tâches, files, calendriers, planifications, exécutions, chevauchement, moteur (échéances, puis réservation et fin), journal |
| `events/` | gardes, journal, bus |
| `error/` | 19 définitions d'erreurs |
| `seeds/` | permissions et attributions de rôles ; files `default` (10) et `maintenance` (2) |
| `src/` | crate Rust : `spec/` (calcul des dates), `models/` (contrats), `store.rs` (wrappers), `service.rs`, `error.rs` |
| `tests/it/` | tests Rust (calcul des dates, contrats en base embarquée) |
| `tests/` | banc SurrealQL (`scripts/ci/test_lyxal_modules.py`) : droits, tâches et files, calendriers, planifications, échéances, chevauchement, exécutions, réservation et fin, places et élagage, journal, fonctions internes |
