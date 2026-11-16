# `lyxal_scheduler` — modèle et sources

Planificateurs dont `lyxal_scheduler` reprend un fonctionnement, règles de calcul des dates,
moyens contre la double exécution, constats sur SurrealDB 3.3.4 et décisions du CTO qui fixent
la conception du module. L'état du module et son exploitation sont décrits par son
[`README.md`](README.md), ses évolutions par sa [`ROADMAP.md`](ROADMAP.md).

Registres (crates.io, hex.pm, npm, RubyGems, NuGet, Maven Central, proxy Go), fichiers de
licence et code source officiel lus le 15 novembre 2026. Pour Temporal et Oban, le
fonctionnement a été lu dans le code source (proto Temporal, code Oban) ; pour Hatchet, Inngest,
Kestra, Sidekiq Enterprise et River Pro, il vient de leur documentation publique. Fonctionnement
de SurrealDB essayé sur un serveur 3.3.4.

## 1. Principe d'assemblage

* **Modèles** : Temporal Schedules (planifications), Oban (file des exécutions), Quartz (syntaxe
  cron et calendriers), Hatchet (équité entre organisations) ; fonctionnement transcrit en
  SurrealQL (données, règles, droits) et en Rust (calcul des dates, moteur). Aucun code copié
  d'un projet sous licence LGPL, MPL, AGPL, SSPL ou propriétaire.
* **Dépendances ajoutées** : `croner` (MIT) pour les expressions cron ; `jiff` (déjà dans le
  dépôt) pour les fuseaux et les dates.

## 2. Candidats open source

| Projet | Licence | Langage | Dernière version | Usage permis |
| :--- | :--- | :--- | :--- | :--- |
| **Temporal** (Schedules) | MIT | Go | v1.32.2 (oct. 2026) | Modèle et code |
| **Oban** (partie libre) | Apache-2.0 | Elixir | 2.24.2 (oct. 2026) | Modèle et code |
| Oban Pro | propriétaire | Elixir | — | Modèle seulement |
| **Quartz** | Apache-2.0 | Java | 2.5.2 (déc. 2025) | Modèle et code ; projet peu actif |
| Croniq | MIT OR Apache-2.0 | Rust | 0.4.0 | Modèle et code, avec l'avis de licence |
| apalis, apalis-cron | MIT OR Apache-2.0 / MIT | Rust | 1.2.0 / 1.1.0 (nov. 2026) | Modèle et code |
| pg-boss | MIT | Node | 12.38.2 (nov. 2026) | Modèle et code |
| Graphile Worker | MIT | Node | 0.18.0 (sept. 2026) | Modèle et code |
| BullMQ / Pro | MIT / commerciale | Node | 6.7.6 (nov. 2026) | Partie libre ; Pro : modèle seulement |
| Hatchet | MIT | Go | v0.120.5 (nov. 2026) | Modèle et code |
| Kestra / EE | Apache-2.0 / propriétaire | Java | 2.0.10 (nov. 2026) | Partie libre ; EE : modèle seulement |
| Trigger.dev | Apache-2.0 | TypeScript | 4.8.5 (nov. 2026) | Modèle et code |
| sidekiq-cron | MIT | Ruby | 2.4.0 | Modèle et code |
| River / Pro | MPL-2.0 / propriétaire | Go | v0.51.2 (nov. 2026) | Modèle seulement (un fichier copié resterait sous MPL) |
| Sidekiq / Pro / Enterprise | LGPL-3.0 / commerciale | Ruby | 8.1.7 | Modèle seulement |
| Hangfire / Pro | LGPL-3.0 / commerciale | C# | 1.8.25 | Modèle seulement |
| Dkron / Pro | LGPL-3.0 / propriétaire | Go | v4.2.1 | Modèle seulement |
| Windmill | AGPL-3.0 + propriétaire | Rust | 1.875.0 | Modèle seulement |
| Inngest (serveur) | SSPL-1.0 | Go | v1.53.0 | Modèle seulement |

## 3. Modèles retenus, par fonction

| Fonction | Meilleur modèle | Ce qui est repris |
| :--- | :--- | :--- |
| Cron complet | Quartz `CronExpression`, crate `croner` | 5 à 7 champs (secondes, année), `L`, `5L`, `15W`, `LW`, `6#3`, alias `@daily`… |
| Plusieurs règles et exclusions | Temporal `ScheduleSpec` | Union de règles (cron, intervalle) moins les exclusions, entre une date de début et une date de fin, fuseau par planification |
| Exécution unique différée | pg-boss `startAfter`, Graphile `run_at` | Une date de départ |
| Nombre limité d'exécutions | Temporal `remaining_actions` | Une exécution sautée ne consomme rien |
| Calendriers d'exceptions | Quartz (jours fériés, annuel, mensuel, hebdomadaire, quotidien), Croniq | Calendrier nommé, partagé, appliqué après le calcul |
| Rattrapage | Temporal `catchup_window`, Hangfire / Kestra (`last`, `all`, `none`) | Fenêtre de rattrapage et choix entre la dernière, toutes ou aucune |
| Rejeu d'une période passée | Temporal `BackfillRequest`, Kestra | Plage de dates rejouée avec sa propre politique de chevauchement |
| Déclenchement immédiat | Temporal `TriggerImmediately` | Exécution hors calendrier |
| Chevauchement | Temporal `ScheduleOverlapPolicy` | `skip` (défaut), `buffer_one`, `buffer_all`, `cancel_other`, `terminate_other`, `allow_all` |
| Pause | Temporal (`paused`, `notes`, `pause_on_failure`), Oban (files) | Pause d'une planification avec motif, pause sur échec, pause d'une file |
| Décalage aléatoire | Temporal `jitter` | La date planifiée reste l'identité de l'exécution |
| Unicité | Oban `unique`, Graphile `job_key` | Clé d'unicité par tâche, période et états |
| Priorités, files, concurrence | Oban (files), Hatchet (concurrence par clé, `GROUP_ROUND_ROBIN`) | Priorité entière ; limite par file et par organisation (équité) |
| Nouvelles tentatives | Oban, pg-boss | Fixe, linéaire ou exponentielle, avec gigue ; politique validée par `fn::validation_retry_policy` de `lyxal_core` |
| Délai maximal, annulation | Oban `timeout`, apalis `TimeoutLayer` | État `cancelled`, annulation coopérative |
| Réservation et reprise | Oban Lifeline, Quartz recovery, `SKIP LOCKED` | Bail par exécution renouvelé ; exécutions orphelines reprises |
| Historique et élagage | Oban `Pruner`, pg-boss | Durée de conservation par état ; résultats des dernières exécutions |
| Prévision | Croniq `forecast`, Temporal `future_action_times` | N prochaines dates calculées |
| Débounce, throttle, limite de débit | Inngest, pg-boss | Hors V1 |
| Workflows (DAG), lots | Hatchet, Oban Pro, BullMQ Pro | Hors V1 |

## 4. Calcul des dates

**Algorithme** (Oban `bump_*`, Quartz `getTimeAfter`) : à partir de « maintenant + 1 », recherche
champ par champ (année, mois, jour, heure, minute, seconde) ; un champ qui déborde incrémente le
champ du dessus et remet ceux du dessous à leur minimum. Le calcul se fait en heure locale du
fuseau, puis la date est convertie en UTC.

**Changement d'heure** — règles comparées :

| Projet | Heure qui n'existe pas (printemps) | Heure répétée (automne) |
| :--- | :--- | :--- |
| Temporal | Aucune exécution ce jour-là | Deux exécutions |
| Quartz | Exécution à l'heure suivante qui existe | Une exécution |
| Oban, `croner` (règle OCPS / Vixie-cron) | Heure fixe : exécution juste après le saut ; joker ou pas (`*/5`) : occurrences du saut ignorées | Heure fixe : une exécution ; joker ou pas : les deux |

La règle d'Oban et `croner` ne perd ni ne double une tâche quotidienne.

**Bibliothèques Rust**

| Crate | Licence | Version | Verdict |
| :--- | :--- | :--- | :--- |
| `croner` | MIT | 4.0.3 (nov. 2026) | **Retenu** : 5 à 7 champs, `L`, `W`, `#`, alias, règle OCPS, compatible `jiff` |
| `jiff` | Unlicense OR MIT | 0.2.45 | **Retenu** : déjà dans le dépôt (`lyxal_i18n`), base des fuseaux intégrée |
| `cron` | MIT OR Apache-2.0 | 0.17.0 | Écarté : secondes obligatoires, ni `W`, ni `#` |
| `saffron` | BSD-3 | 0.1.0 (2021) | Écarté : abandonné, sans fuseau |
| `chrono-tz` | MIT OR Apache-2.0 | 0.10.4 | Inutile avec `jiff` |
| `tokio-cron-scheduler` | MIT / Apache | 0.15.1 | Écarté : lance ses propres tâches (§5.8.3) |

## 5. Éviter la double exécution

1. **Un seul nœud crée les exécutions** (Oban, Sidekiq Enterprise, River, Dkron) : bail distribué.
2. **Identifiant déterministe** (Temporal : date planifiée dans l'identifiant ; Oban `unique`) :
   dans SurrealDB, `CREATE scheduler_run:[planification, date]` échoue si l'exécution existe déjà,
   même si deux nœuds se croient seuls.
3. **Réservation atomique** : passage conditionnel `queued → claimed` avec un bail ; les baux
   expirés sont repris (Oban Lifeline, Quartz recovery).
4. **Garde de génération** sur chaque écriture du planificateur, comme `lyxal_event` : le bail
   d'élection `leader` du runtime (clé `scheduler`) porte une génération croissante ; chaque
   fonction du planificateur reçoit `{ node, generation }` et refuse d'écrire
   (`SCHEDULER_LEADER_FENCED`) si le bail n'est plus le sien (Y2). Chaque exécution réservée a
   son propre jeton de bail, exigé par chaque fin de tentative.

## 6. SurrealDB 3.3.4

| Capacité | Constat | Décision |
| :--- | :--- | :--- |
| Minuterie, cron | Aucune : SurrealDB n'exécute rien de lui-même | Calcul des dates et moteur en Rust ; règles et états en SurrealQL |
| `DEFINE EVENT` | Exécuté dans la transaction de l'écriture ; un `THROW` l'annule | Gardes de toutes les tables (aussi pour une écriture directe), journal, publication |
| Droits d'une fonction | Une fonction s'exécute avec les droits de l'appelant ; `record::exists` et `SELECT` ne voient que ce qu'il peut lire | Contrôles de droits en tête des fonctions ; un enregistrement illisible vaut introuvable |
| Écriture refusée par les permissions | `CREATE` rend `[]`, `UPDATE ONLY` et `DELETE ONLY` rendent `NONE`, sans erreur | Écriture principale vérifiée (`SCHEDULER_WRITE_FORBIDDEN`) |
| `NONE` dans une comparaison | Inférieur à toute date | Conditions explicites `IS NOT NONE` (bail, prochaine échéance) |
| `type::record` d'une chaîne | Ignore un texte qui suit l'identifiant | Règle `surql_record_string` du Core : l'identifiant relu doit redonner exactement la chaîne (Y4) |
| Bail du runtime (`runtime_lease`) | Table lisible par la session système seulement | Fonctions du planificateur réservées à la session système de l'hôte |
| Identifiant composé | `CREATE scheduler_run:[planification, date]` échoue s'il existe déjà | Une échéance ne crée jamais deux exécutions |

## 7. Sources

* Temporal : `temporalio/api` — `temporal/api/schedule/v1/message.proto`,
  `temporal/api/enums/v1/schedule.proto` ; https://docs.temporal.io/schedule
* Oban : `oban-bg/oban` — `lib/oban/cron.ex`, `lib/oban/cron/expression.ex`,
  `guides/learning/periodic_jobs.md`, `LICENSE.txt` ; https://oban.dev/docs/pro
* Quartz : `quartz-scheduler/quartz` — `CronExpression.java`, `CronTrigger.java`,
  `SimpleTrigger.java`, `Trigger.java`, `LICENSE.txt`
* Hangfire : `HangfireIO/Hangfire` — `src/Hangfire.Core/MisfireHandlingMode.cs`, `LICENSE.md`
* Kestra : https://kestra.io/docs/workflow-components/triggers/schedule-trigger ,
  https://kestra.io/docs/concepts/backfill
* pg-boss : https://github.com/timgit/pg-boss , https://pgboss.io/
* Graphile Worker : https://github.com/graphile/worker
* apalis : https://github.com/apalis-dev/apalis
* BullMQ : https://docs.bullmq.io/guide/job-schedulers/repeat-options
* Hatchet : https://docs.hatchet.run/v1/concurrency
* Inngest : https://www.inngest.com/docs/guides/flow-control
* Sidekiq : https://sidekiq.org/products/enterprise/ , https://sidekiq.org/wiki/Ent-Unique-Jobs
* River : https://pkg.go.dev/github.com/riverqueue/river
* Dkron : https://pkg.go.dev/github.com/distribworks/dkron/v3/dkron
* Croniq : https://github.com/nuetzliches/croniq
* Bibliothèques Rust : https://github.com/Hexagon/croner-rust , https://github.com/zslayton/cron ,
  https://github.com/cloudflare/saffron , https://docs.rs/jiff
* Registres : crates.io, hex.pm, npmjs.com, rubygems.org, nuget.org, Maven Central,
  proxy.golang.org

## 8. Décisions du CTO

| Programme | Décisions |
| :--- | :--- |
| Programme V1 (15 nov. 2026) | **S1** repartir de zéro dans `crates/lyxal_scheduler/`, ancien dossier (copie de Croniq) et écrans Surrealist supprimés, idées valables reprises (calendriers, rattrapage, prévision, états) ; **S2** trois exécuteurs seulement (code Rust inscrit, fonction SurrealQL publique du module, publication différée d'un événement), tâches déclarées par les modules, aucune commande système ni requête libre ; **S3** `croner` avec `jiff` ; **S4** bail du planificateur dans `lyxal_runtime` (nouvelle valeur `leader` de `runtime_lease.kind`) ; **S5** changement d'heure selon la règle d'Oban et `croner` (heure manquante : juste après le saut ; heure répétée : une exécution), fuseau par planification, UTC par défaut ; **S6** valeurs par défaut de Temporal : chevauchement `skip`, rattrapage de la dernière échéance dans une fenêtre d'une heure, politiques `skip`, `buffer_one`, `buffer_all`, `cancel_other`, `allow_all` ; **S7** exécution au moins une fois, handlers idempotents, historique de 30 jours et toujours les 10 dernières exécutions de chaque planification ; **S8** aucune bascule de module dans ce programme |
| Lot 1 (socle SurrealQL) | **T1** tâche déclarée par le seed du module propriétaire, nom `<module>.<action>`, seule la session système l'active ou la désactive ; **T2** permission propre de la tâche contrôlée à la création et à chaque modification, exécution au nom du système pour l'organisation de la planification ; **T3** équité par deux compteurs à écriture conditionnelle (places de la file, places d'une organisation dans la file, 10 par défaut) ; **T4** journal simple en ajout seul des actions des personnes ; **T5** limites : arguments 16 Kio, résultat 4 Kio, message d'erreur 1 000 caractères, 1 000 planifications et 10 000 exécutions en attente par organisation, réglables |
| Lot 2 (calcul des dates) | **U1** cron de 5 à 7 champs, au moins une minute entre deux échéances (`SCHEDULER_SPEC_INVALID`) ; **U2** jour du mois ou jour de la semaine (règle Vixie), `?` de Quartz accepté ; **U3** intervalle compté depuis `start_at`, sinon la création, en durée réelle ; **U4** recherche limitée à 5 ans et 10 000 essais, sinon planification `invalid` (`no_future_fire`) ; **U5** décalage aléatoire tiré à chaque échéance, borné à une heure et à la moitié du plus petit écart, seule la date de disponibilité décalée |
| Lot 3 (moteur) | **W1** bail `leader` du runtime, clé `scheduler`, 30 s renouvelé toutes les 10 s ; **W2** un tour du planificateur par seconde, exécuteurs chaque seconde ou aussitôt après une fin, reprise des baux toutes les 30 s, élagage toutes les heures ; **W3** `LYXAL__SCHEDULER__WORKERS` tâches à la fois par file et par nœud (4 par défaut, 1 à 64) ; **W4** délai maximal : annulation du handler et échec `SCHEDULER_RUN_TIMEOUT` retentable, une fonction SurrealQL partie n'est plus attendue ; **W5** publication différée : charge = arguments, source = l'exécution, métadonnées `{ scheduled_for, attempt, tenant }`, publication et fin dans la même transaction |
| Lot 4 (routes de l'hôte) | **X1** exécution désignée par l'identifiant SurrealQL complet en base64url sans remplissage, contrôlé par la règle `surql_record_string` du Core puis `record_id` ; **X2** aucune route pour les fonctions du moteur ; **X3** routes de prévision et de contrôle d'une règle sans écriture ; **X4** `Cache-Control: no-store` sur toutes les réponses |
| Lot 5 (clôture, 16 nov. 2026) | **Y1** permission propre de la tâche exigée pour tout ce qui la fait exécuter (création, modification, reprise, déclenchement, rejeu, exécution différée, relance), pas pour ce qui l'arrête (pause, annulation, suppression), aussi en écriture directe ; **Y2** garde de génération `{ node, generation }` sur les fonctions du planificateur, code `SCHEDULER_LEADER_FENCED` ; **Y3** le module déclarant une tâche doit être installé, et un nom de module qui est le début d'un autre nom de module installé ne vise pas les fonctions de cet autre module ; **Y4** règle `surql_record_string` du Core corrigée (extension du Core) : identifiant entier sous sa forme texte canonique, aucun contrôle local dans le module ; **Y5** `LyxalSurrealCall::call_fn` accepte un nom `&str` (rupture coordonnée), contournement du moteur supprimé |
