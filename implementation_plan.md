# Plan d'implémentation — programme `lyxal_scheduler` V1

Création du crate du Noyau Technique `lyxal_scheduler` (rang 5 de
[`docs/14-roadmap/ROADMAP_NOYAU.md`](docs/14-roadmap/ROADMAP_NOYAU.md)) : planification et
exécution des tâches différées et périodiques de tous les modules. Étude du module existant, des
planificateurs open source et des briques de Lyxal OS :
[`crates/lyxal_scheduler/RECHERCHE_SOURCES.md`](crates/lyxal_scheduler/RECHERCHE_SOURCES.md).

**Deux niveaux de validation** (`AGENTS.md` §3) : ce plan fixe le programme (architecture,
modèle, lots, décisions). Chaque lot a ensuite son propre plan détaillé, soumis au CTO avant
toute ligne de code : contrats Rust `XxxParams` / `XxxResult`, signatures SurrealQL, codes
d'erreurs, tests.

## 1. Point de départ

Le dossier `lyxal_scheduler/` existant (copie de Croniq) n'est relié à aucune brique Lyxal, ses
tests ne compilent pas, et il refait l'authentification, le chiffrement et le serveur HTTP en
contradiction avec les règles (`RECHERCHE_SOURCES.md` §1). **Le nouveau crate repart de zéro**
dans `crates/lyxal_scheduler/`, sur le modèle des projets complets du marché, en reprenant les
idées valables de Croniq (calendriers, rattrapage, prévision, états des exécutions). Le dossier
existant et les écrans Surrealist qui écrivent dans ses tables sont supprimés (décision S1).

**Modèles** : Temporal Schedules (planifications), Oban (file des exécutions), Quartz (syntaxe
cron et calendriers), Hatchet (équité entre organisations) ; licences MIT ou Apache-2.0. Aucun code
copié d'un projet sous licence LGPL, MPL, AGPL, SSPL ou propriétaire.

## 2. Architecture

### 2.1. Les trois objets

```text
Tâche (scheduler_task)        « ce qui peut être exécuté » — déclarée par un module
   │                           ex. notification.digest, auth.purge
   ▼
Planification (scheduler_schedule)   « quand » — créée par un module ou une personne
   │                                  cron, intervalle, date unique ; fuseau ; calendriers
   ▼
Exécution (scheduler_run)     « une fois » — créée à chaque échéance, réservée, exécutée,
                                retentée, terminée ; identifiant [planification, date prévue]
```

Une exécution peut aussi être créée sans planification : tâche **différée** (« dans 3 jours »,
« le 1er mars à 9 h ») ou **immédiate**, avec une clé d'unicité facultative.

### 2.2. Ce qu'une tâche exécute (décision S2)

Une tâche est **déclarée par le module qui la possède** (seed de son manifeste), jamais par un
utilisateur. Elle indique son exécuteur, la permission exigée pour la planifier, sa file, sa
politique de tentatives, son délai maximal et ses règles d'unicité. Trois exécuteurs :

| Exécuteur | Ce qui est exécuté | Pour qui |
| :--- | :--- | :--- |
| `handler` | Code Rust inscrit par le module (trait `TaskHandler`, sur le modèle de `SecretRotator`) | Modules avec du Rust : envoi, rotation, appels externes |
| `function` | Une fonction SurrealQL publique du module (`fn::<module>_<action>`), avec les arguments de l'exécution | Modules en SurrealQL seul : purges, recalculs, agrégats |
| `event` | Publication d'un événement déclaré par le module, via `fn::event_publish`, à la date prévue | **Publication différée** (ex. relance de notification) : `lyxal_event` livre ensuite |

Aucune commande système, aucune requête SurrealQL libre, aucun appel réseau générique : un
utilisateur choisit seulement une tâche déclarée pour laquelle il a la permission, et lui passe
des arguments vérifiés par le schéma déclaré avec la tâche (moteur `fn::validation_object_execute`).

### 2.3. Répartition SurrealQL / Rust

| SurrealQL (données et règles) | Rust (crate `lyxal_scheduler`) |
| :--- | :--- |
| Tâches, planifications, calendriers, exécutions, états et transitions | Calcul des dates : cron, intervalles, fuseaux, changement d'heure, calendriers, prévision (`croner`, `jiff`) |
| Droits par organisation (`lyxal_auth`), unicité, réservation conditionnelle, bail par exécution, garde de génération | Worker **planificateur** (un seul nœud, sous bail) : échéances → exécutions, rattrapage, chevauchement |
| Politique de tentatives (`fn::validation_retry_policy`), délai suivant avec gigue, état `dead` | Workers **exécuteurs** (tous les nœuds) : réservation, appel du handler ou de la fonction, battement du bail, délai maximal, annulation |
| Événements `scheduler.*`, élagage, journal des actions | Registre des `TaskHandler` ; `SchedulerClient` pour les autres modules ; routes HTTP de l'hôte |

SurrealDB 3.3.4 n'a ni cron ni minuterie : le calcul des dates est en Rust et écrit
`next_fire_at` par une fonction SurrealQL ; tout le reste (règles, états, droits) est en SurrealQL.

### 2.4. Modèle (préfixe `scheduler_`)

| Table | Contenu |
| :--- | :--- |
| `scheduler_settings` | réglages de l'installation, surchargés par organisation : fenêtre de rattrapage, conservation de l'historique, concurrence par organisation, limites (planifications, exécutions en file) |
| `scheduler_task` | nom (`notification.digest`), module, exécuteur et cible, permission exigée, schéma des arguments, file, priorité, tentatives, délai maximal, unicité, conservation ; état (`active`, `disabled`) |
| `scheduler_queue` | file : concurrence maximale par nœud et globale, pause |
| `scheduler_calendar` | calendrier d'exceptions nommé, par organisation : jours fériés, dates annuelles, jours de semaine, plages horaires ; inclusion ou exclusion |
| `scheduler_schedule` | `tenant`, tâche, arguments, règles (cron, intervalle, date unique), exclusions, fuseau, début et fin, calendriers, décalage aléatoire, rattrapage, chevauchement, nombre d'exécutions restant, pause (motif, pause sur échec), prochaine date, résultats des dernières exécutions |
| `scheduler_run` | identifiant `[planification, date prévue]` ou aléatoire ; `tenant`, tâche, arguments, priorité, date prévue et date réelle, état (`scheduled`, `queued`, `claimed`, `running`, `completed`, `failed`, `retrying`, `cancelled`, `dead`, `skipped`), tentative, bail (nœud, génération, échéance), erreur, durée, résultat court, clé d'unicité, origine (planification, différée, immédiate, rejeu) |
| `scheduler_audit` | journal des actions des personnes (création, pause, rejeu, annulation) ; aucune donnée d'argument sensible |

* **Droits** (`fn::auth_has_permission`) : `scheduler.schedule.read`, `scheduler.schedule.write`,
  `scheduler.run.read`, `scheduler.run.manage` (annuler, rejouer), `scheduler.calendar.write`,
  `scheduler.settings.manage`, `scheduler.installation.manage`, `scheduler.worker` ; et, pour
  chaque tâche, la permission déclarée par son module.
* Données d'une organisation supprimées avec elle (`REFERENCE ON DELETE CASCADE`).
* Arguments limités en taille ; **aucun secret dans les arguments** : une tâche qui en a besoin
  lit une référence `lyxal_secrets` à l'exécution.

### 2.5. Moteur

1. **Planificateur** (un nœud, bail `scheduler_leader` à génération) : pour chaque planification
   échue, crée l'exécution `scheduler_run:[planification, date]` (un doublon échoue), applique le
   chevauchement et le rattrapage, calcule la date suivante en Rust.
2. **Exécuteurs** (tous les nœuds) : réservent la prochaine exécution par file, priorité et date,
   en respectant la concurrence par file et par organisation (tour de rôle entre organisations) ;
   renouvellent le bail pendant l'exécution ; une exécution dont le bail a expiré est reprise.
3. **Fin** : succès, échec avec nouvelle tentative (délai exponentiel, linéaire ou fixe, gigue),
   ou `dead` après la dernière ; délai maximal dépassé → annulation coopérative ; annulation
   demandée par une personne → `cancelled`.
4. **Élagage** : historique conservé selon les réglages (30 jours par défaut, et toujours les
   10 dernières exécutions de chaque planification).

Garanties : **au moins une fois** pour l'exécution d'une tâche (comme `lyxal_event`) ; une même
échéance d'une planification ne crée jamais deux exécutions. Les handlers doivent être
idempotents (§5.6.3) ; la clé de l'exécution leur est fournie.

## 3. Dépendances

`lyxal_scheduler` dépend de `lyxal_core`, `lyxal_error`, `lyxal_event`, `lyxal_auth` et, en Rust,
de `lyxal_surreal` et `lyxal_runtime`. **Bibliothèque nouvelle** : `croner` (MIT, décision S3) ;
`jiff` est déjà dans le dépôt. Aucun module existant ne dépend de `lyxal_scheduler` dans ce
programme (décision S8).

## 4. Fonctions publiques (`fn::scheduler_*($params: object)`)

| Domaine | Fonctions |
| :--- | :--- |
| Réglages, files | `scheduler_settings_get`, `_set` ; `scheduler_queue_list`, `_pause`, `_resume` |
| Tâches | `scheduler_task_list`, `_get` (déclarées par les modules ; seed, pas de création par l'API) |
| Calendriers | `scheduler_calendar_create`, `_update`, `_get`, `_list`, `_delete` |
| Planifications | `scheduler_schedule_create`, `_update`, `_get`, `_list`, `_pause`, `_resume`, `_trigger` (immédiat), `_backfill` (période passée), `_delete` |
| Exécutions | `scheduler_run_enqueue` (différée ou immédiate, unicité), `_get`, `_list`, `_cancel`, `_retry` (rejeu d'une exécution `dead`) |
| Moteur (worker) | `scheduler_due_list`, `_fire`, `_next_set`, `_claim`, `_heartbeat`, `_complete`, `_fail`, `_rescue`, `_prune` |
| Journal | `scheduler_audit_list` |

Entrées par les moteurs de `lyxal_core` ; erreurs `SCHEDULER_*` en master data ; écriture
principale vérifiée (`SCHEDULER_WRITE_FORBIDDEN`).

Côté Rust : `SchedulerClient` (planifier, différer, annuler) et le trait `TaskHandler` pour les
autres modules ; ils ne touchent jamais les tables.

## 5. Événements (`fn::event_publish`)

`scheduler.schedule.created`, `.updated`, `.paused`, `.resumed`, `.deleted`,
`scheduler.run.completed`, `.failed`, `.dead`, `.cancelled`, `.skipped`,
`scheduler.queue.paused`, `.resumed` : identifiants, tâche, date prévue, tentative, code
d'erreur ; jamais les arguments. `lyxal_notification` pourra s'abonner à `scheduler.run.dead`
pour alerter, sans que le scheduler le connaisse.

## 6. Lots

| Lot | Contenu | Touche |
| :- | :--- | :--- |
| **1** | **Réalisé.** Socle SurrealQL : réglages, tâches (déclarées par seed), files, calendriers, planifications, exécutions, états et transitions, droits par organisation, unicité, réservation et bail, tentatives, journal, événements, erreurs, banc. Suppression du dossier `lyxal_scheduler/` et des écrans Surrealist `views/scheduler/` | `lyxal_scheduler`, suppressions |
| **2** | **Réalisé.** Calcul des dates en Rust : cron 5 à 7 champs, intervalles, date unique, fuseaux, changement d'heure (règle d'Oban et `croner`), exclusions, calendriers, bornes, décalage aléatoire, prévision ; contrôle des expressions à l'écriture | `lyxal_scheduler` |
| **3** | Moteur : bail du planificateur (`lyxal_runtime`, décision S4), échéances, rattrapage, chevauchement, rejeu de période, exécuteurs par file avec concurrence et équité, battement, reprise, délai maximal, annulation, tentatives, élagage ; `TaskHandler`, exécuteurs `function` et `event`, `SchedulerClient`, module, sonde de santé, hébergement par l'hôte | `lyxal_scheduler`, `lyxal_runtime`, `apps/lyxal-server` |
| **4** | Hôte : routes HTTP `/api/v1/scheduler/*` au nom de l'appelant (planifications, calendriers, exécutions, files, prévision, rejeu, déclenchement immédiat) | `apps/lyxal-server` |
| **5** | Clôture : audit `lyxal-audit`, procédures d'exploitation, `README.md`, `ROADMAP.md`, `AGENTS.md` §6, `ROADMAP_NOYAU.md`, `RECHERCHE_SOURCES.md` réduit en `MODELE_SOURCES.md` | docs |

**Feuille de route après la V1** : débounce, throttle et limite de débit (modèle Inngest) ;
workflows et dépendances entre tâches (DAG) ; lots ; déclencheurs sur événement ; politique
`terminate_other` ; règles RRULE ; tableau de bord Surrealist sur les `fn::scheduler_*` ;
bascule des workers périodiques existants (`AuthPurgeWorker`, `NotificationPurgeWorker`,
`StorageCleanupWorker`, `SecretsMaintenanceWorker`) ; délais longs de `lyxal_notification`
(son lot V1-c).

## 7. Tests et critères de production

* **Banc SurrealQL** : chaque fonction ; isolation entre organisations ; chaque droit refusé sans
  permission, y compris la permission propre d'une tâche ; arguments refusés hors schéma ; une
  même échéance ne crée qu'une exécution ; réservation concurrente ; bail périmé repris ; garde de
  génération ; transitions d'état interdites refusées ; tentatives et `dead` ; élagage.
* **Rust** : jeux de cas de `croner`, Quartz et Croniq (fin de mois, `L`, `W`, `#`, années
  bissextiles) ; changement d'heure à Paris et New York dans les deux sens ; calendriers ;
  prévision ; deux planificateurs simultanés sans doublon ; arrêt d'un nœud pendant une
  exécution puis reprise ; chevauchement (chaque politique) ; rattrapage après une panne ; délai
  maximal ; annulation ; équité entre organisations.
* **Hôte** : parcours de bout en bout, droits de l'appelant.
* Contrôle complet : `scripts/ci/ci_local.sh` à chaque lot.

## 8. Décisions du CTO (validées le 15 novembre 2026)

| Code | Décision |
| :--- | :--- |
| **S1** | Repartir de zéro dans `crates/lyxal_scheduler/` ; supprimer le dossier `lyxal_scheduler/` (copie de Croniq) et les écrans Surrealist `views/scheduler/` au lot 1. Les idées valables de Croniq sont reprises (calendriers, rattrapage, prévision, états). |
| **S2** | Trois exécuteurs seulement : code Rust inscrit par un module, fonction SurrealQL publique d'un module, publication différée d'un événement. Les tâches sont déclarées par les modules ; aucune commande système ni requête libre. |
| **S3** | Nouvelle bibliothèque `croner` (MIT) pour les expressions cron, avec `jiff` (déjà présent) pour les fuseaux. |
| **S4** | Bail du planificateur pris dans `lyxal_runtime` : le champ `runtime_lease.kind` accepte une nouvelle valeur `leader` (un seul système de baux), plutôt qu'un bail propre au module. |
| **S5** | Changement d'heure selon la règle d'Oban et `croner` : heure manquante → juste après le saut ; heure répétée → une seule exécution (heure fixe) ; fuseau par planification, UTC par défaut. |
| **S6** | Valeurs par défaut sur le modèle de Temporal : chevauchement `skip` ; rattrapage de la dernière échéance manquée dans une fenêtre d'une heure ; politiques `skip`, `buffer_one`, `buffer_all`, `cancel_other`, `allow_all` en V1. |
| **S7** | Exécution au moins une fois, handlers idempotents ; historique gardé 30 jours et toujours les 10 dernières exécutions de chaque planification. |
| **S8** | Aucune bascule de module dans ce programme : les workers existants et les délais de `lyxal_notification` passent au scheduler ensuite, chacun par son propre plan. |
