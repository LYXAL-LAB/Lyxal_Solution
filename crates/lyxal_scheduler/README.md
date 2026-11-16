# `lyxal_scheduler` — tâches différées et périodiques

Module du Noyau Technique de Lyxal OS : planifie et exécute les tâches différées et périodiques
de tous les modules (purges, recalculs, envois, publications différées). Les modèles (Temporal,
Oban, Quartz, Hatchet), les sources et les décisions du CTO sont dans
[`MODELE_SOURCES.md`](MODELE_SOURCES.md), les évolutions dans [`ROADMAP.md`](ROADMAP.md).

## État actuel

Le programme V1 est terminé (lots 1 à 5). Le **socle SurrealQL** est en place : réglages, tâches déclarées par les modules, files,
calendriers d'exceptions, planifications, exécutions et leurs états, réservation sous bail,
nouvelles tentatives, chevauchement, rattrapage, rejeu de période, droits par organisation,
journal des actions et événements. Le **crate Rust** fournit le calcul des dates (cron,
intervalles, date unique, fuseaux et changements d'heure, exclusions, calendriers, bornes,
décalage aléatoire, prévision), le contrôle des planifications avant écriture et les appels
typés de chaque fonction publique (voir « Partie Rust »). Le **moteur** tourne dans l'hôte
`lyxal-server` : un planificateur élu par le bail `leader` du runtime transforme les échéances en
exécutions, un exécuteur par file et par nœud les exécute (handler Rust inscrit par un module,
fonction SurrealQL du module, publication différée d'un événement). Les interfaces y accèdent par
les routes HTTP `/api/v1/scheduler/*` de l'hôte, au nom de l'appelant (voir « Accès par
l'hôte »). Aucun module n'inscrit encore de tâche (S8). L'exploitation est décrite à la fin de ce
document (« Exploitation »).

Manifeste : `lyxal_scheduler` 0.1.0, dépendances `lyxal_core`, `lyxal_error`, `lyxal_event`,
`lyxal_auth`. Le crate fournit `SchedulerModule` (`LyxalModule`), ses workers et sa sonde,
enregistrés par l'hôte (`apps/lyxal-server/src/modules/scheduler.rs`).

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

* Identifiant `⟨module.action⟩` en minuscules ; `module` = `lyxal_<module>`, **installé** : une
  release du runtime `Installing` (seed en cours), `Installed` ou `Active` (Y3, contrats publics
  `fn::runtime_release_list` et `fn::runtime_module_list`).
* Exécuteur : `handler` (code Rust inscrit sous le nom de la tâche : la cible est ce nom même), `function` (fonction
  SurrealQL `<module>_<action>` du même module) ou `event` (publication différée d'un type
  d'événement préfixé par le module). La cible commence par le nom complet du module suivi d'un
  séparateur (`_` ou `.`) ; un module dont le nom est le début du nom d'un autre module connu du
  runtime ne vise jamais les fonctions ou les événements de cet autre module (`lyxal_pipeline`
  ne vise pas `pipeline_ingestion_*`, Y3).
* `permission` : permission `lyxal_auth` existante exigée pour **tout ce qui fait exécuter** la
  tâche (Y1) : création et modification d'une planification, reprise, déclenchement, rejeu de
  période, exécution différée, relance, y compris par écriture directe dans les tables ; pas pour
  ce qui l'arrête (pause, annulation, suppression).
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
  Rust (`SchedulerService` avant l'écriture) ; le moteur les recontrôle à chaque calcul (syntaxe,
  fuseau, écart d'une minute U1, décalage U5) et déclare `invalid` une planification écrite sans
  passer par Rust (`fn::scheduler_schedule_next_set`).
* `calendars` : calendriers d'exceptions de la même portée (10 au plus).
* `next_fire_at` : écrit par le moteur seulement ; toute modification de `spec`, `calendars` ou
  de la pause le remet à `NONE` (date à recalculer).
* États : `active`, `completed` (plus d'échéance ou `remaining` épuisé), `invalid` (règles
  refusées ; seules des règles ou des calendriers nouveaux la rendent de nouveau active, aussi en
  écriture directe).
* Pause et suppression n'exigent que `scheduler.schedule.write` : un gestionnaire arrête une
  planification dont l'auteur a perdu le droit. La reprise exige aussi la permission propre de la
  tâche (Y1). La suppression annule les exécutions en attente, demande l'annulation de celle en
  cours (la garde des exécutions le permet sans `scheduler.run.manage`, la planification n'existant
  plus) et garde l'historique.
* `pause_on_failure` : une exécution `dead` met la planification en pause (motif `failure`).
* `fn::scheduler_schedule_trigger` : exécution immédiate (même en pause) ; avec `cancel_other`, qui
  annule les autres exécutions, `scheduler.run.manage` est aussi exigé.
  `fn::scheduler_schedule_backfill` : rejeu d'une période passée (un an au plus, un seul en cours ;
  permission propre de la tâche, aussi pour une création directe dans `scheduler_backfill`).

### Rattrapage et chevauchement

Le moteur passe à `fn::scheduler_schedule_fire` les échéances manquées calculées par Rust, chacune
`{ at, available_at }` : `at` est la date prévue (identité de l'exécution), `available_at` la date
à partir de laquelle elle peut être réservée, retardée par le décalage aléatoire (U5) et jamais
avant `at` (`SCHEDULER_INVALID_PARAMETERS` sinon) ; de même pour `fn::scheduler_backfill_fire`.

| `catchup` | Exécutions créées |
| :--- | :--- |
| `last` (défaut) | la plus récente de la fenêtre de rattrapage (`catchup_window`, réglage 1 h par défaut) |
| `all` | toutes celles de la fenêtre |
| `none` | la plus récente seulement si elle a moins d'une minute de retard |

Une échéance crée `scheduler_run:[planification, date prévue]` : une même date ne crée jamais deux
exécutions (deux nœuds, deux appels). Les échéances et les rejeux respectent la limite
`max_pending_runs` de la portée : les dates au-delà des places restantes sont ignorées et
comptées (`limited` du résultat, journal du planificateur). Avant la création, la politique de chevauchement s'applique
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

* **Annulation** : réservée à `scheduler.run.manage` et au moteur, aussi en écriture directe
  (`cancelled`, `cancel_requested`) ; seule exception, les exécutions d'une planification
  supprimée.
* **Relance** (`fn::scheduler_run_retry`) : nouvelle exécution `origin: retry` qui porte
  `retry_of` (l'exécution `dead` ou `cancelled` relancée) ; la garde exige que l'exécution
  d'origine existe, soit lisible, terminée en `dead` ou `cancelled`, et ait la même organisation,
  la même tâche et les mêmes arguments. `scheduler.run.manage` et la permission propre de la tâche.

* **Réservation** (`fn::scheduler_run_claim`) : par priorité (0 la plus haute) puis date, dans
  deux limites tenues par compteurs à écriture conditionnelle : places de la file
  (`scheduler_queue.running < concurrency`) et places de l'organisation dans la file
  (`scheduler_slot`, réglage `tenant_concurrency`). Les organisations déjà pleines sont écartées
  avant la sélection : leurs exécutions en attente ne masquent jamais celles des autres. Chaque réservation pose un **bail** : jeton nouveau (lisible par le moteur seulement),
  nœud, échéance = maintenant + délai de la tâche + 1 min. Le nœud passe la liste des tâches
  `handler` dont il a le code (`handlers`) : une autre tâche `handler` lui est laissée tant
  qu'elle n'attend pas depuis plus que son délai maximal ; au-delà, il la réserve et la termine en
  échec `SCHEDULER_HANDLER_NOT_FOUND` (retentable, puis `dead`). Chaque exécution réservée porte
  son exécuteur et sa cible.
* **Publication différée** (`fn::scheduler_run_publish`, tâche `event`, W5) : publie l'événement
  de la tâche (`fn::event_publish` : type = cible, producteur = module de la tâche, source =
  l'exécution, charge = arguments, métadonnées `{ scheduled_for, attempt, tenant }`) et termine
  l'exécution dans la même transaction : une publication refusée annule la fin, un bail perdu ne
  publie rien. Seule la session système publie sur le bus.
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
| `scheduler.schedule.write` | organisation | planifications ; créer, modifier, reprendre, déclencher, rejouer, différer (avec la permission propre de la tâche) ; mettre en pause, supprimer |
| `scheduler.run.manage` | organisation | annuler une exécution ; relancer une exécution `dead` ou `cancelled` (avec la permission propre de la tâche) |
| `scheduler.calendar.write` | organisation | calendriers |
| `scheduler.settings.manage` | organisation | réglages de l'organisation |
| `scheduler.installation.manage` | installation | planifications, calendriers et réglages de l'installation ; pause des files |
| `scheduler.worker` | installation | compte de service du moteur (aucun rôle) : réservation, battement, fin, santé ; les fonctions du planificateur exigent la session système, seule à lire le bail |

`organization_admin` reçoit les permissions d'organisation, `platform_admin`
`scheduler.installation.manage`. Contrôle unique : `fn::scheduler_can({ action, tenant, task })`,
utilisé par les `PERMISSIONS` des tables, les gardes et les fonctions. L'exécution se fait au nom
du système, pour l'organisation de la planification ; la fonction ou le handler du module ne
touche que cette organisation. Les réglages de l'installation sont lisibles avec n'importe quelle
permission `scheduler.*` de l'organisation active (ils s'y appliquent), jamais sans aucune. Une
écriture filtrée par les permissions renvoie
`SCHEDULER_WRITE_FORBIDDEN`. Une organisation supprimée emporte ses réglages, calendriers,
planifications, exécutions et journal (`REFERENCE ON DELETE CASCADE`).

## Fonctions publiques

| Domaine | Fonctions (`fn::scheduler_*($params: object)`) |
| :--- | :--- |
| Réglages, files | `settings_get`, `settings_set` ; `queue_list`, `queue_pause`, `queue_resume` |
| Tâches | `task_list`, `task_get`, `task_set_state` (session système) |
| Calendriers | `calendar_create`, `calendar_update`, `calendar_get`, `calendar_list`, `calendar_delete` |
| Planifications | `schedule_create`, `schedule_update`, `schedule_get`, `schedule_list`, `schedule_pause`, `schedule_resume`, `schedule_trigger`, `schedule_backfill`, `schedule_delete`, `spec_validate` (forme des règles de dates contrôlée sans écriture, droit de lecture) |
| Exécutions | `run_enqueue`, `run_get`, `run_list`, `run_cancel`, `run_retry` ; `run_ref` (forme texte d'un identifiant convertie, sans lecture) |
| Journal | `audit_list` |
| Moteur | planificateur, avec la garde de génération `{ node, generation }` (Y2) : `schedule_fire`, `schedule_next_set`, `backfill_fire`, `run_rescue`, `run_prune` ; lecture `due_list` ; exécuteurs : `run_claim`, `run_heartbeat`, `run_complete`, `run_fail`, `run_publish` ; sonde `health` |

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
| `executions` | `SCHEDULER_RUN_NOT_FOUND`, `SCHEDULER_RUN_STATE_INVALID`, `SCHEDULER_LEASE_LOST`, `SCHEDULER_RUN_TIMEOUT` (délai maximal, retentable), `SCHEDULER_HANDLER_NOT_FOUND` (aucun handler inscrit), `SCHEDULER_EXECUTOR_FAILED` (erreur technique de l'exécuteur), `SCHEDULER_LEADER_FENCED` (bail du planificateur perdu) |

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
* `validate(now)` (contrôle à l'écriture), `check_rhythm(now)` (U1 et U5, aussi par le moteur),
  `max_jitter(t)`, `draw_jitter(max)`.

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
`store.call_fn("scheduler_…", params)` pour chacune des 41 fonctions publiques. Chaque
`XxxParams` porte exactement les champs lus par sa fonction (un champ `None` est omis et prend la
valeur par défaut de SurrealQL) ; chaque résultat est une structure nommée (`SurrealValue`).
Le jeton de bail (`LeaseToken`) est opaque et masqué dans `Debug`. Les appels du moteur, l'annulation
d'une exécution et les écritures d'une personne sur une planification (modification, pause,
reprise, suppression, déclenchement, rejeu) sont rejoués après un conflit d'écriture passager
de SurrealDB (transaction non validée) : le planificateur réécrit les mêmes enregistrements.

### Service (`service.rs`)

`SchedulerService` : `schedule_create` et `schedule_update` contrôlent les règles (syntaxe,
fuseau, au moins une échéance future, U1, U5, règles des calendriers lus avec les droits de
l'appelant) avant d'appeler le wrapper ; erreur `SCHEDULER_SPEC_INVALID` avec la règle fautive
et la raison (`cron_syntax`, `timezone`, `min_interval`, `jitter`, `calendar_rule`, `range`,
`no_future_fire`, `out_of_range`). `validate_spec` contrôle sans écrire ; `forecast` lit une
planification et rend ses prochaines échéances.

### Moteur (`engine/`)

Tout le moteur tourne sur la **session système** de l'hôte (T2) ; il ne lit et n'écrit que par
les fonctions `fn::scheduler_*` du moteur. `SchedulerEngine` réunit la session, le registre des
handlers, l'identifiant du nœud et les files servies.

| Worker | Rôle |
| :--- | :--- |
| `SchedulerLeaderWorker` | Un seul nœud à la fois : bail d'élection `leader` du runtime (clé `scheduler`, 30 s, renouvelé toutes les 10 s ; libéré à l'arrêt). Un tour par seconde : `due_list` ; pour chaque planification, prochaine date (`next_fire_at` absent : calculée et écrite ; pour une planification jamais traitée, les dates déjà échues depuis sa création, moins 5 s de marge, suivent la politique de rattrapage) ou dates manquées dans la fenêtre de rattrapage (1000 dernières au plus) avec leur décalage aléatoire tiré par `OsRng` (U5), puis `schedule_fire` ; règles illisibles ou sans date (U4) : planification `invalid` ; rejeux par lots de 1000 dates (une date déjà exécutée est ignorée). Toutes les 30 s : `run_rescue` ; toutes les heures : `run_prune`. Chaque écriture porte la garde de génération du bail (`node`, `generation`, Y2) : un nœud qui a perdu le bail, même au milieu d'un tour ou entre deux lots d'un rejeu, est refusé (`SCHEDULER_LEADER_FENCED`), oublie le bail et cesse de planifier. Sans bail : attend. |
| `SchedulerExecutorWorker` | Un par file et par nœud, au plus `workers` tentatives à la fois (W3 : 4 par défaut, de 1 à 64). File vide : interrogée chaque seconde ; sinon aussitôt après chaque fin. Chaque tentative est une tâche tenue par le worker (`JoinSet`, aucune tâche libre) : battement au plus tard à mi-bail (et toutes les 30 s), mis en course avec la tâche et le délai maximal (une base lente ne retarde ni l'annulation ni le délai), délai maximal (W4 : le handler reçoit l'annulation, le moteur cesse d'attendre et enregistre `SCHEDULER_RUN_TIMEOUT`, retentable), annulation demandée apprise au battement et transmise. Exécuteurs : handler inscrit ; fonction SurrealQL `fn::<cible>({ args, run, tenant, scheduled_for, attempt })` (résultat : objet gardé, autre valeur dans `{ value }`, erreur métier : son code et sa retentabilité, erreur technique : `SCHEDULER_EXECUTOR_FAILED`) ; publication différée par `run_publish`. Fin par `run_complete` / `run_fail` sous le jeton du bail ; une fin refusée pour bail perdu est journalisée, jamais réécrite. Arrêt : plus de réservation, annulation transmise, attente de 30 s, puis abandon (le bail expire et la reprise s'en charge). |

Le jeton de bail n'apparaît dans aucun journal. Les rythmes se règlent par `LeaderTiming` et
`ExecutorTiming` (valeurs de W1 et W2 par défaut, réduites dans les tests).

### Handlers (`handler.rs`) et client (`client.rs`)

Un module qui déclare une tâche `handler` inscrit son code dans le registre de l'hôte au
démarrage (`SchedulerHost::handlers`) :

```rust
#[async_trait]
impl TaskHandler for DigestHandler {
    fn task(&self) -> &str { "notification.digest" }
    async fn run(&self, ctx: RunContext) -> Result<TaskOutput, TaskFailure> {
        // idempotent (clé : ctx.run) ; s'arrête dès que ctx.cancellation est annulé
        Ok(TaskOutput::empty())
    }
}
```

`RunContext` : exécution, organisation, planification, date prévue, tentative, tentatives
permises, arguments, jeton d'annulation (annulation demandée, délai maximal, arrêt du nœud) ;
rien de secret. `TaskFailure::retryable` / `terminal` : code, message sans secret. Un deuxième
handler pour la même tâche, ou un nom mal formé, est refusé (`SCHEDULER_INVALID_PARAMETERS`).
`SchedulerClient` (au nom de l'appelant) : `enqueue` (différée ou immédiate), `schedule`
(règles contrôlées avant l'écriture), `cancel`.

### Forme texte d'un identifiant d'exécution (`run_ref.rs`)

Une exécution d'échéance a un identifiant composé `scheduler_run:[planification, date]`, qui ne
passe pas tel quel dans une adresse. `RunRef` en est la forme texte unique (X1) : l'identifiant
SurrealQL complet encodé en base64url sans remplissage. `RunRef::encode(&id)` la produit
(`RunRef::from_sql` pour un identifiant déjà écrit en texte, comme l'exécution d'une entrée du
journal) ;
`RunRef::new(texte).decode(&store, langue)` rend l'identifiant natif : base64url et UTF-8
contrôlés en Rust, puis `fn::scheduler_run_ref` contrôle la chaîne par la règle
`surql_record_string` du Core limitée à `scheduler_run` (l'identifiant entier sous sa forme
texte canonique : un texte après l'identifiant ou une autre écriture est refusé), la convertit et
contrôle le résultat
par la règle `record_id` limitée à `scheduler_run`. Toute autre forme (identifiant en clair,
autre table, texte illisible) : `SCHEDULER_INVALID_PARAMETERS`. Le décodage ne lit pas
l'exécution : existence et droits restent contrôlés par la fonction appelée ensuite.

### Accès par l'hôte (routes HTTP)

L'hôte `lyxal-server` expose les fonctions des personnes sous `/api/v1/scheduler/*`
(`apps/lyxal-server/src/http/scheduler.rs`, liste dans son `README.md`). Chaque requête ouvre
une session SurrealDB au nom du jeton de l'appelant : les droits, la permission propre d'une
tâche et l'isolation des organisations sont ceux des fonctions SurrealQL ; la session système
n'est jamais utilisée. `POST /schedules` et `PATCH /schedules/{id}` passent par
`SchedulerService` (règles de dates contrôlées avant l'écriture) ; `GET
/schedules/{id}/forecast?count=` (100 au plus) et `POST /specs/validate` sont en lecture seule
(X3). Les exécutions sont désignées par leur `RunRef`, dans les adresses comme dans les
réponses (`id`, `retry_of`, `last_run`, `recent_runs`, exécution d'une entrée du journal).
Aucune route n'appelle une fonction du moteur (X2). Toutes les réponses portent
`Cache-Control: no-store` (X4), y compris le 404 d'une adresse inconnue du planificateur.
`POST /runs` rend 201, ou 200 avec l'exécution existante quand l'unicité la rend
(`duplicate`). Une règle de dates refusée rend `SCHEDULER_SPEC_INVALID` avec
`error.details.fields.rule` (règle fautive) et `reason`.

### Module et santé

`SchedulerModule` (`LyxalModule`, descripteur du manifeste). `SchedulerHealthCheck` : malade si
`fn::scheduler_health` échoue ; dégradé si aucune file (ou une file active) n'a d'exécuteur sur
ce nœud, si des exécutions réservables attendent depuis plus de 5 min au-delà de leur date, ou si
une tâche `handler` active n'a de handler inscrit sur aucun nœud actif. Chaque exécuteur
enregistre à chaque réservation les handlers de son nœud (`scheduler_node`, oublié après un jour
sans réservation) : un handler absent de ce nœud mais servi par un nœud actif dans la dernière
minute est une simple information du message. Le texte ne contient aucune donnée d'organisation.

### Réglages de l'hôte

| Variable | Défaut | Rôle |
| :--- | :--- | :--- |
| `LYXAL__SCHEDULER__WORKERS` | 4 (1 à 64) | Tentatives simultanées par file sur ce nœud (W3) ; la concurrence de la file et celle de chaque organisation restent tenues par la base |

### Tests Rust

`cargo test -p lyxal_scheduler` : 75 tests — expressions cron (jeux de cas de `croner`,
Quartz et Croniq), changement d'heure à Paris et New York, calendriers, intervalles, bornes,
exclusions, décalage, dates manquées, prévision ; forme texte des identifiants d'exécution (aller-retour d'un
identifiant simple et composé, forme illisible, autre table) ; en base embarquée (`mem://`)
chacune des fonctions des lots 1 et 3 appelée par son wrapper (fonctions du planificateur sous un bail pris par le test), avec décodage sans perte de chaque résultat ; et le moteur :
planification à intervalle exécutée de bout en bout (handler, fonction SurrealQL d'un module
d'essai, publication différée lue dans `event_outbox`), deux planificateurs simultanés (un seul
bail, aucun doublon), perte du bail, nœud arrêté pendant une exécution puis reprise par un
autre, délai maximal (handler coopératif ou non), annulation demandée, nouvelles tentatives puis
`dead`, chevauchement `skip` et `buffer_one`, décalage aléatoire, équité entre organisations,
handler absent, arrêt propre, sonde de santé (handler servi par un autre nœud), registre des
handlers, aucun jeton de bail dans les journaux, planificateur dont le bail est perdu au milieu
d'un tour (garde de génération, aucune écriture), règles écrites directement à moins d'une
minute rendues invalides par le moteur (U1), limite d'exécutions en attente appliquée à un tour,
nom de fonction refusé par `call_fn` (échec terminal). Ils ne remplacent pas le banc SurrealQL.

## Exploitation

### Réglages

* **Hôte** : `LYXAL__SCHEDULER__WORKERS` (4 par défaut, 1 à 64) fixe les tentatives simultanées
  par file sur chaque nœud. La concurrence globale d'une file (`scheduler_queue.concurrency`,
  `default` 10, `maintenance` 2) se change en session système ; celle de chaque organisation par
  `tenant_concurrency`.
* **Base** : `fn::scheduler_settings_set` pour l'installation (`scheduler.installation.manage`) ou
  une organisation (`scheduler.settings.manage`) : fenêtre de rattrapage, conservation,
  exécutions gardées, places par organisation, limites (planifications, exécutions en attente,
  taille des arguments). Voir « Réglages ».

### Surveillance

* **Sonde** `SchedulerHealthCheck` (runtime, `/health` de l'hôte) : dégradée si une file active
  n'a pas d'exécuteur sur le nœud, si des exécutions réservables attendent depuis plus de
  5 minutes, ou si une tâche `handler` active n'a de handler sur aucun nœud actif.
* **Événements** : s'abonner à `scheduler.run.dead` (dernière tentative en échec) pour alerter,
  `scheduler.run.failed` pour suivre les nouvelles tentatives, `scheduler.schedule.invalid` (règles
  refusées par le moteur) et `scheduler.queue.paused`.
* **Journal du worker** : le planificateur écrit un bilan par tour (`fired`, `backfilled`,
  `limited`, `invalid`, `rescued`, `pruned`, `failed`) ; `limited` signale une organisation qui
  atteint `max_pending_runs`. Une perte de bail (`SCHEDULER_LEADER_FENCED`) est un avertissement :
  un autre nœud reprend la planification.
* **Journal des actions** : `fn::scheduler_audit_list` (réglages, files, calendriers,
  planifications, rejeux, déclenchements, exécutions différées, annulations, relances).

### File en pause

`fn::scheduler_queue_pause({ queue, reason })` (`scheduler.installation.manage`) : plus aucune
réservation dans la file ; les exécutions en cours finissent, les autres attendent. La sonde ne
signale pas une file en pause. Reprise par `fn::scheduler_queue_resume` ; les exécutions en
attente sont réservées dans l'ordre (priorité, puis date).

### Reprise après panne

* **Nœud arrêté pendant une exécution** : le bail de l'exécution expire (délai maximal de la
  tâche + 1 min) ; le planificateur la reprend (`run_rescue`, toutes les 30 s) : nouvelle
  tentative s'il en reste, sinon `dead`. Les handlers doivent être idempotents (clé : `ctx.run`).
* **Planificateur arrêté** : son bail (`runtime_lease` `leader`, clé `scheduler`) expire en 30 s
  au plus (il est libéré à un arrêt propre) ; un autre nœud le prend. Les échéances manquées sont
  rattrapées selon `catchup` dans la fenêtre de rattrapage ; une même date ne crée jamais deux
  exécutions.
* **Compteurs de places** : recalés à chaque reprise sur les exécutions réellement en cours.

### Rejouer une période

`fn::scheduler_schedule_backfill({ schedule, from, to, overlap })` (écriture et permission propre
de la tâche) : période passée d'un an au plus, un seul rejeu en cours par planification. Le
planificateur crée les exécutions par lots de 1000 dates ; une date déjà exécutée est ignorée,
les dates au-delà de la limite `max_pending_runs` aussi (comptées dans le journal du
planificateur : relever la limite puis relancer un rejeu pour les reprendre).

### Relancer une exécution

`fn::scheduler_run_retry({ run })` (`scheduler.run.manage` et permission propre de la tâche)
pour une exécution `dead` ou `cancelled` : nouvelle exécution immédiate, mêmes arguments,
`retry_of` vers l'exécution d'origine, qui reste dans l'historique.

### Conservation de l'historique

L'élagage (toutes les heures) supprime les exécutions terminées plus vieilles que
`run_retention` (30 jours par défaut) et garde toujours les `keep_last_runs` (10) dernières de
chaque planification. Le journal `scheduler_audit` n'est pas élagué ; il part avec son
organisation.

## Fichiers

| Dossier | Contenu |
| :--- | :--- |
| `schema/` | `scheduler_settings`, `scheduler_task`, `scheduler_queue`, `scheduler_slot` et `scheduler_node`, `scheduler_calendar`, `scheduler_schedule`, `scheduler_backfill`, `scheduler_run`, `scheduler_audit` |
| `functions/` | droits et outils (`access`), réglages, tâches, files, calendriers, planifications, exécutions, chevauchement, moteur (échéances, puis réservation et fin), journal |
| `events/` | gardes, journal, bus |
| `error/` | 23 définitions d'erreurs |
| `seeds/` | permissions et attributions de rôles ; files `default` (10) et `maintenance` (2) |
| `src/` | crate Rust : `spec/` (calcul des dates), `models/` (contrats), `store.rs` (wrappers), `service.rs`, `client.rs` (`SchedulerClient`), `handler.rs` (`TaskHandler`, registre), `run_ref.rs` (`RunRef`), `engine/` (planificateur, exécuteurs, tentative), `module.rs`, `health.rs`, `error.rs` |
| `tests/it/` | tests Rust (calcul des dates, contrats et moteur en base embarquée) |
| `tests/` | banc SurrealQL (`scripts/ci/test_lyxal_modules.py`) : droits, tâches et files, calendriers, planifications, échéances, chevauchement, exécutions, réservation et fin, places et élagage, moteur (disponibilité décalée, handlers du nœud, publication différée, santé), journal, fonctions internes, sécurité (droits renforcés, garde du bail, limite d'attente, cible d'une tâche, forme texte d'une exécution) ; le banc installe le schéma du runtime comme l'hôte |
