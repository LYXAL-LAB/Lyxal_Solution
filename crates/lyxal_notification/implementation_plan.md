# Plan d'implémentation — `lyxal_notification`, lot 2 : parcours complets

Deuxième lot du programme `lyxal_notification` V1 complet (`implementation_plan.md` à la racine,
décisions K1 à K10 validées ; lot 1 livré : abonnés, préférences, heures calmes, désabonnement,
diffusion). Ce lot fait des parcours de vraies suites d'étapes : **attente**, **regroupement**
(digest), **limitation** (throttle), **conditions d'étape**, **surcharges au déclenchement**,
**envoi groupé**, **annulation**, **aperçu** et **envoi de test**. Les attentes et la purge
passent par `lyxal_scheduler` (K3). Le module reste sur l'e-mail : les autres canaux viennent aux
lots 3 à 6 et se brancheront sur le même moteur d'étapes. Aucune ligne de code avant la
validation du CTO (`.agents/AGENTS.md` §3).

## 1. Questions soumises au CTO

| N° | Question | Proposition |
| :- | :--- | :--- |
| **C1** | Comment les étapes s'enchaînent | Aujourd'hui toutes les étapes d'un parcours partent en même temps. Désormais elles s'exécutent **dans l'ordre** : une étape n'est créée qu'à la fin de la précédente. Une seule fonction SurrealQL fait avancer un déclenchement (`notification_run_advance`) ; elle est appelée au déclenchement, à la fin de chaque envoi et à la fin de chaque attente. |
| **C2** | Précision de K3 (attentes, tentatives, purge) | **Attentes** (délai, fin d'un regroupement) : une exécution différée de `lyxal_scheduler`, qui appelle directement la fonction de reprise du module (exécuteur `function`) plutôt que de passer par un événement (exécuteur `event`) : un intermédiaire de moins, reprise et fin dans la même transaction. **Purge** : planification horaire de `lyxal_scheduler`, créée à l'installation du module ; le worker de purge du module disparaît. **Nouvelles tentatives d'envoi** : elles restent dans la file du module (attente croissante déjà en place) : l'envoi est fait par le worker du canal, et passer chaque tentative par le scheduler ajouterait un aller-retour sans rien apporter. C'est une précision de K3, soumise ici à validation. |
| **C3** | Regroupement (digest) | Fenêtre fixe (ex. 30 min) avec clé de regroupement facultative lue dans les données (ex. un regroupement par projet), et option « recul » : si rien n'est arrivé pour cette clé depuis un temps donné, le premier message part tout de suite. Le message regroupé reçoit le nombre d'événements et leurs données (100 au plus) pour son gabarit. Le regroupement « à heure fixe » (ex. chaque jour à 9 h) va à la feuille de route V2. |
| **C4** | Limitation (throttle) | Au plus N messages par fenêtre fixe (ex. 3 par heure), par abonné et par parcours, avec clé facultative lue dans les données. Au-delà, le déclenchement s'arrête avec le motif `throttled` (rien n'est mis en attente). Un parcours critique n'est jamais limité. |
| **C5** | Surcharges au déclenchement | Pour un envoi précis : sauter une étape, changer la durée d'une attente ou d'une fenêtre de regroupement. Le choix du fournisseur s'ajoutera au lot 3 (intégrations). Pas de texte remplacé au déclenchement : les gabarits traduits restent la seule source du contenu. |
| **C6** | « Sauter si déjà lu » | Il ne peut porter que sur un message du fil in-app, qui arrive au lot 5. Ce lot prépare tout (conditions sur l'état des étapes précédentes) ; la valeur « lu » sera fournie au lot 5. |
| **C7** | Aperçu et envoi de test | **Aperçu** : rendu d'une étape (objet, HTML, texte) avec des données d'exemple, par le moteur de rendu Rust, exposé par une route de l'hôte réservée à `notification.read`. **Envoi de test** : le parcours part vers un abonné choisi en ignorant attentes, regroupement et limitation (`notification.manage`) ; liste de suppression et préférences restent appliquées. |

## 2. Modèle (SurrealQL, réécrit en place)

### 2.1 Étapes d'un parcours (`notification_workflow.steps`)

Chaque étape a un **type** (rupture coordonnée : `channel` devient `type`) :

| Type | Champs propres |
| :--- | :--- |
| `email` | (canal ; les canaux `sms`, `chat`, `webhook`, `in_app`, `push` s'ajoutent aux lots 3 à 6) |
| `delay` | `amount` + `unit` (`seconds` … `weeks`), ou `until` : chemin d'une date dans les données (ex. `payload.rendez_vous`), avec `offset` facultatif (ex. −1 j) |
| `digest` | `window` (`amount` + `unit`), `key` (chemin facultatif), `lookback` facultatif (C3) |
| `throttle` | `limit` (1 à 1000), `window` (`amount` + `unit`), `key` (chemin facultatif) (C4) |

Champs communs : `key` (unique dans le parcours), `condition` facultative (forme K2, contrôlée par
`fn::utils_condition_check`, évaluée par `fn::utils_condition_evaluate` sur
`{ payload, subscriber: { subscriber_id, locale, timezone, data }, steps: { <clé>: { status } } }`,
jamais le secret). Un parcours a au moins une étape de canal ; une étape `digest` ou `throttle`
précède au moins une étape de canal. Toutes les durées sont bornées par le réglage
`max_wait_days`.

### 2.2 Tables

| Table | Changement |
| :--- | :--- |
| `notification_settings` | + `max_wait_days` (30 par défaut, 1 à 366) |
| `notification_run` | + `cursor` (étape courante), `overrides` (C5), `test` (C7), `digest` (regroupement rejoint) ; états `pending`, `waiting`, `completed`, `failed`, `skipped`, `canceled`, `merged` ; motifs `condition`, `throttled`, `canceled` en plus |
| `notification_job` | + `type` (type de l'étape), `wait_until`, `scheduler_run` (référence texte de l'exécution différée) ; états + `waiting` et `merged` ; `channel` disparaît au profit de `type` |
| `notification_digest` (nouvelle) | regroupement ouvert : portée, parcours, abonné, clé d'étape, clé de regroupement, déclenchement porteur, `ends_at`, nombre et données des événements (100 au plus), état `open` / `closed` ; unique par (portée, parcours, abonné, étape, clé) tant qu'il est ouvert |
| `notification_rate_limit` (nouvelle) | compteur par (portée, parcours, abonné, étape, clé, début de fenêtre), avec date de purge |

Permissions : comme `notification_run` (lecture `notification.read`, écriture par les fonctions
du module en session `send` ou worker) ; données supprimées avec l'organisation et l'abonné.

### 2.3 Tâches `lyxal_scheduler` (seed du module, K3 / C2)

| Tâche | Exécuteur | Cible | Usage |
| :--- | :--- | :--- | :--- |
| `notification.run_resume` | `function` | `notification_run_resume` | fin d'une attente ou d'un regroupement ; `unique_for` 1 j, clé `<déclenchement>/<étape>` |
| `notification.purge` | `function` | `notification_purge` | planification horaire `notification.purge` créée à l'installation (Rust, `SchedulerClient::schedule`, si absente par son nom) |

Permission propre des deux tâches : `notification.worker`. File : `scheduler_queue:default`.
`lyxal_scheduler` devient une dépendance du module (manifeste et Cargo ; aucune dépendance
circulaire : le scheduler ne connaît pas la notification).

## 3. Moteur d'étapes

```text
déclenchement ──► advance ──► étape suivante (condition fausse ou sautée : skipped, on continue)
                                 │
     email ──────────────────────┼─► job queued ─► worker e-mail ─► complete ─► advance
     delay ──────────────────────┼─► job queued (wait) ─► worker d'étapes ─► scheduler (run_at)
                                 │                           └─► run_resume ─► advance
     digest : regroupement ouvert pour la clé ? oui : déclenchement « merged », fin
                                              non : ouvert, attente de la fenêtre comme delay
     throttle : compteur de la fenêtre < limite ? oui : continue ; non : skipped (throttled)
```

* `fn::notification_run_advance` (interne) : évalue les étapes depuis `cursor` jusqu'à la
  première qui attend (canal, attente) ; idempotente (rejouée deux fois, elle ne crée rien de
  plus) ; fin du parcours : `notification_run_finalize`.
* Un job d'attente est créé `queued` ; le **worker d'étapes** (session système de l'hôte) le
  confie au scheduler par `fn::scheduler_run_enqueue` et le passe `waiting`. La personne qui
  déclenche n'a donc besoin d'aucune permission `scheduler.*`.
* `fn::notification_run_resume` (appelée par le scheduler) : termine l'attente et avance ; un
  déclenchement annulé entre-temps n'avance pas (l'exécution du scheduler se termine sans rien
  faire : pas besoin de l'annuler, ce qui demanderait `scheduler.run.manage`).
* Un regroupement fermé passe ses événements au gabarit (`digest.count`, `digest.events`) par
  `notification_job_payload`.
* Heures calmes (lot 1) : inchangées, appliquées à la réservation de l'étape de canal.

## 4. Fonctions publiques (`fn::notification_*($params: object)`)

| Fonction | Rôle | Permission |
| :--- | :--- | :--- |
| `notification_trigger` (étendue) | + `overrides: { steps: { <clé>: { skip, amount, unit, window } } }` | `notification.send` |
| `notification_trigger_bulk` | 1 à 100 déclenchements (chacun comme `notification_trigger`), rapport par entrée ; bornes par `fn::validation_array_length` | `notification.send` |
| `notification_cancel` | `{ tenant, idempotency_key }` : annule les déclenchements en cours de cette clé (abonné ou liste `<clé>/…`) : étapes en attente annulées, regroupement porté refermé sans envoi ; un envoi déjà parti n'est pas rappelé | `notification.send` |
| `notification_test_send` | `{ tenant, workflow_key, to (un abonné), payload }` : déclenchement `test` (C7) | `notification.manage` |
| `notification_workflow_create` / `_update` (étendues) | étapes typées contrôlées (§2.1), conditions par `fn::utils_condition_check` | `notification.manage` |
| `notification_settings_set` (étendue) | + `max_wait_days` | `notification.manage` |
| `notification_wait_schedule` (worker) | confie au scheduler les attentes `queued` (paquet borné) | `notification.worker` |
| `notification_run_resume` (scheduler) | `{ args: { run, step_key }, run, tenant, scheduled_for, attempt }` | session système du moteur |
| `notification_purge` (scheduler, étendue) | forme d'appel du scheduler ; + regroupements fermés et compteurs expirés | session système du moteur |

Internes : `notification_run_advance`, `notification_step_check` (contrôle d'une étape),
`notification_step_context` (contexte des conditions), `notification_digest_join`,
`notification_throttle_hit`, `notification_wait_due` (date de fin d'attente).

## 5. Erreurs (master data `error/parcours/`)

`NOTIFICATION_STEP_INVALID` (étape mal formée, avec le détail par champ),
`NOTIFICATION_WAIT_TOO_LONG` (au-delà de `max_wait_days`), `NOTIFICATION_RUN_NOT_FOUND`
(annulation sans déclenchement en cours pour cette clé), `NOTIFICATION_OVERRIDE_INVALID` (étape
inconnue ou surcharge non permise pour son type). Les autres cas réutilisent les codes existants
(`NOTIFICATION_INVALID_INPUT`, `NOTIFICATION_CONDITION_INVALID`, `NOTIFICATION_WRITE_FORBIDDEN`…).

## 6. Événements (`fn::event_publish`, identifiants seulement)

`notification.run.canceled` (`run_id`, `tenant`, `workflow_id`), `notification.run.merged`
(`run_id`, `digest_id`) ; jamais d'adresse, de données ni de secret.

## 7. Rust et hôte

* Modèles : `TriggerBulkParams` / `TriggerBulkResult`, `CancelParams` / `CancelResult`,
  `TestSendParams`, `WaitScheduleParams` / `WaitScheduleResult`, `StepPreviewParams` /
  `StepPreviewResult`, étapes typées (`WorkflowStep` en énumération `#[surreal(tag = "type")]`) ;
  wrappers 1-ligne `store.call_fn`.
* `NotificationStepWorker` (`LyxalWorker`, annulation coopérative) : appelle
  `notification_wait_schedule` toutes les secondes quand il y a du travail, sinon toutes les 5 s.
* `NotificationPurgeWorker` supprimé ; `install` du module crée la planification
  `notification.purge` (horaire) si elle n'existe pas.
* Le worker e-mail lit le type `email` au lieu du canal ; variables `digest` passées au rendu.
* Aperçu (C7) : `NotificationPreview::render(workflow, step_key, payload, locale)` (moteur
  MiniJinja existant, aucune écriture) ; route `POST /api/v1/notification/preview` de l'hôte
  (session `lyxal_auth`, `notification.read`, corps borné, aucun secret accepté).
* `NotificationConsumer` et seeds (`lyxal_auth`, `lyxal_notification`) : étapes au nouveau format.

## 8. Tests

* Banc SurrealQL : étapes typées et refus (forme, bornes, condition invalide, ordre) ; moteur
  (enchaînement, condition fausse, étape sautée, idempotence de `advance`) ; attente (fixe, date
  des données, décalage, trop longue) ; reprise (normale, après annulation, rejouée) ;
  regroupement (ouverture, rejoint → `merged`, clé, recul, fermeture et variables, 100 au plus) ;
  limitation (sous et au-dessus de la limite, clé, fenêtre suivante, parcours critique) ;
  surcharges ; envoi groupé (100 au plus, rapport) ; annulation (abonné, liste, regroupement porté,
  rien en cours) ; envoi de test ; purge (regroupements, compteurs) ; tâches du scheduler
  déclarées ; permissions et identités (`send`, `manage`, `read`, sans droit, autre organisation).
* Rust, moteur embarqué : parcours e-mail → attente → e-mail de bout en bout avec le moteur du
  scheduler (exécution différée réellement reprise), regroupement de trois déclenchements en un
  e-mail, annulation pendant l'attente, planification de purge créée une fois, aperçu ; route de
  l'hôte (droits, corps refusé).
* `scripts/ci/ci_local.sh` vert.

## 9. Documents

`README.md` du module (étapes, moteur, nouvelles fonctions, tâches du scheduler, exploitation),
`ROADMAP.md` (V1-c retirée ; regroupement à heure fixe ajouté en V2 ; « sauter si déjà lu » au
lot 5), README de l'hôte (route d'aperçu). Ce plan est supprimé une fois exécuté.

## 10. Checklist (§13)

* `lyxal_core` réutilisé : `fn::validation_object_execute`, `fn::validation_array_length`,
  `fn::utils_condition_check`, `fn::utils_condition_evaluate`, `fn::utils_object_get_path` ;
  aucune primitive Core nouvelle, aucun besoin crypto.
* Contrats publics seulement : `fn::scheduler_run_enqueue`, `SchedulerClient::schedule`, tâches
  déclarées par seed ; `fn::auth_*` inchangés.
* Écritures vérifiées (`NOTIFICATION_WRITE_FORBIDDEN`), seeds rejouables, une seule migration,
  versions `0.y.z`, aucun code mort (worker de purge et champ `channel` retirés).
