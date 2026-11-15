# `lyxal_scheduler` — recherche de sources

Étude préalable à la création du crate du Noyau Technique `lyxal_scheduler` (rang 5 de
[`docs/14-roadmap/ROADMAP_NOYAU.md`](../../docs/14-roadmap/ROADMAP_NOYAU.md)) : le module
existant du dépôt, les planificateurs open source du marché et les briques déjà présentes dans
Lyxal OS. Le plan du programme est [`implementation_plan.md`](../../implementation_plan.md).

Registres (crates.io, hex.pm, npm, RubyGems, NuGet, Maven Central, proxy Go), fichiers de
licence et code source officiel lus le 15 novembre 2026. Le réseau de la session bloque
docs.temporal.io, hexdocs.pm, riverqueue.com et docs.bullmq.io : pour ces projets, le
fonctionnement a été lu dans le code source (proto Temporal, code Oban) ; pour Hatchet, Inngest,
Kestra, Sidekiq Enterprise et River Pro, il vient de leur documentation publique et n'a pas été
relu dans le code.

## 1. Le module existant `lyxal_scheduler/`

Le dossier `lyxal_scheduler/`, à la racine du dépôt, est une copie adaptée de **Croniq**
(github.com/nuetzliches/croniq, MIT OR Apache-2.0, v0.4.0) avec une couche SurrealQL.

| Partie | Contenu réel |
| :--- | :--- |
| `engine/` | Workspace Rust séparé (13 crates, environ 57 000 lignes), absent du workspace Lyxal. Compile pour Linux une fois la cible Windows imposée par `engine/.cargo/config.toml` retirée ; **les tests ne compilent pas** (`SqliteStore` supprimé) et le portage vers SurrealDB est inachevé (`unimplemented!` dans dix tests serveur, tests de contrat désactivés). |
| `schema/` | 13 tables `scheduler_*` ; 9 autres tables (utilisateurs, jetons, TOTP, OIDC…) utilisées par le Rust sans être déclarées. `PERMISSIONS NONE` partout, aucune organisation. |
| `functions/` | 62 fonctions `fn::scheduler::*` à paramètres positionnels, sans `fn::result_ok` / `fn::error_result`, sans `lyxal_core`. |
| `access/`, `api/` | 3 `DEFINE ACCESS` (administrateurs, clés API, runners sans secret) et 9 `DEFINE API`. |
| Absents | `manifest.toml`, `error/`, `seeds/`, `tests/`, `migrations/`, `events/`, `ROADMAP.md`. |
| Ailleurs | Écrans Surrealist `views/scheduler/` (11 fichiers) qui écrivent directement dans les tables ; ancien planificateur de l'agent IA (`lyxal_agent/.../scheduler.rs`), hors sujet. |

**Écarts bloquants aux règles Lyxal** : identités et chiffrement en double de `lyxal_auth` et
`lyxal_crypto` (`bcrypt`, `sha2`, `hmac`, `aes-gcm`, `hkdf`, `totp-rs`, `rand::rng()`) ; serveur
HTTP propre au lieu de l'hôte `lyxal-server` ; 25 `tokio::spawn` hors `LyxalWorker` ; runner
qui exécute une commande shell arbitraire (`sh -c`) ; transport `Surreal<Client>` et 119 requêtes
écrites à la main au lieu de `call_fn` ; aucune organisation ; documents et commentaires
historiques (« Source : Croniq migrations… », liens `file:///C:/…`).

**Ce qui mérite d'être repris** (idées, réécrites dans le nouveau crate) :

* calcul de la prochaine date et traitement du changement d'heure, avec ses tests ;
* calendriers d'exceptions (« toutes les inclusions et aucune exclusion ») ;
* politique de rattrapage et prévision des N prochaines dates ;
* modèle de données : définition, planification et exécution séparées ; date planifiée
  constante à travers les nouvelles tentatives ; clé d'idempotence ; états
  `queued → claimed → running → completed | failed | dead` ; réservation conditionnelle ; remise en
  file des exécutions abandonnées ; purge par âge ou en gardant les N dernières.

**À jeter** : serveur, CLI, MCP, authentification, runners distants et exécuteur shell, langage de
configuration propre à Croniq, `access/`, `api/`, tables d'identité, écrans Surrealist actuels.

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

## 3. Fonctions d'un planificateur de premier rang

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
4. **Garde de génération** sur chaque écriture du moteur, comme `lyxal_event`.

## 6. Ce que Lyxal OS fournit déjà

| Brique | Fourni | Conséquence |
| :--- | :--- | :--- |
| `lyxal_runtime` | `LyxalWorker`, supervision, annulation, sondes de santé, baux à génération (`fn::runtime_lease_*`) | Réutilisés. Le champ `runtime_lease.kind` n'accepte aujourd'hui que `migration` et `installation` |
| `lyxal_event` | Outbox, livraison au moins une fois, nouvelles tentatives, dead letter, rejeu | Les événements du scheduler passent par lui. Il n'a pas de publication différée |
| `lyxal_auth` | Identités, organisations, permissions | Droits `scheduler.*` ; aucune identité propre |
| `lyxal_core` | Moteurs de validation, `fn::validation_retry_policy` | Entrées et politiques de tentatives |
| `lyxal-server` | Hôte HTTP | Routes `/api/v1/scheduler/*` ; aucun serveur propre |

**Besoins exprimés par les autres modules** :

* `lyxal_notification` (lot V1-c) : délais longs (attente fixe, jusqu'à une date, date lue dans
  l'événement), digests planifiés, purges ;
* `lyxal_auth` : purges planifiées ;
* `lyxal_connect` (à venir) : renouvellement des jetons en arrière-plan ;
* `lyxal_error` (V3) : seuils d'alerte périodiques.

Workers périodiques existants, candidats à une bascule après le programme :
`AuthPurgeWorker`, `NotificationPurgeWorker`, `StorageCleanupWorker`,
`SecretsMaintenanceWorker`.

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
