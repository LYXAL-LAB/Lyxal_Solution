# Plan d'implémentation — `lyxal_scheduler`, lot 4 : routes HTTP de l'hôte

Quatrième lot du programme `lyxal_scheduler` (`implementation_plan.md` à la racine). Il ouvre le
planificateur aux interfaces (console, applications, outils) par des routes HTTP de l'hôte
`lyxal-server`, sur le modèle des routes de `lyxal_secrets` : chaque route appelle le contrat Rust
du lot 2 ou 3 **au nom de l'appelant** (sa session SurrealDB), jamais au nom du système, et rend le
contrat `{ ok, data, error }`. Aucune logique métier dans l'hôte. Aucune ligne de code avant la
validation du CTO (`.agents/AGENTS.md` §3).

## 1. Décisions du CTO (15 novembre 2026)

X1 à X4 validées selon les propositions.

| N° | Question | Décision |
| :- | :--- | :--- |
| **X1** | Identifiant d'une exécution dans une adresse | Une exécution d'échéance a un identifiant composé `scheduler_run:[planification, date]`, qui ne passe pas tel quel dans une adresse. Les routes l'acceptent et le rendent sous une **forme texte unique** : l'identifiant SurrealQL complet encodé en base64url (sans remplissage). L'hôte décode la chaîne ; elle est contrôlée par la règle `surql_record_string` du Core avec la table `scheduler_run` (`string::is_record`, qui accepte les identifiants composés), convertie en identifiant natif, puis contrôlée par la règle `record_id` limitée à `scheduler_run` (la règle `record`, qui découpe la chaîne à chaque « : », refuserait un identifiant composé). Aucune autre forme acceptée. |
| **X2** | Fonctions du moteur | **Aucune route** pour les fonctions du moteur (`due_list`, `schedule_fire`, `run_claim`, `run_heartbeat`, `run_complete`, `run_fail`, `run_publish`, `run_rescue`, `run_prune`, `backfill_fire`, `schedule_next_set`, `task_set_state`) : elles restent réservées aux workers de l'hôte. |
| **X3** | Prévision et contrôle d'une planification | Deux routes en lecture seule : prévision des N prochaines dates d'une planification (lot 2, 100 au plus) et contrôle d'une règle sans l'enregistrer (`validate_spec`), pour qu'une interface affiche l'erreur exacte avant l'enregistrement. |
| **X4** | Cache | Toutes les réponses portent `Cache-Control: no-store` (arguments et résultats de tâches). |

## 2. Routes (`/api/v1/scheduler/*`, jeton de session obligatoire)

| Méthode et adresse | Fonction | Droit (lot 1) |
| :--- | :--- | :--- |
| `GET /settings`, `PUT /settings` | `settings_get`, `settings_set` | lecture / réglages |
| `GET /tasks`, `GET /tasks/{nom}` | `task_list`, `task_get` | lecture |
| `GET /queues` ; `POST /queues/{nom}/pause`, `/resume` | `queue_list`, `queue_pause`, `queue_resume` | lecture / installation |
| `GET /calendars`, `POST /calendars` ; `GET`, `PATCH`, `DELETE /calendars/{id}` | `calendar_*` | lecture / calendriers |
| `GET /schedules`, `POST /schedules` (contrôlée, lot 2) ; `GET`, `PATCH` (contrôlée), `DELETE /schedules/{id}` | `schedule_*` | lecture / écriture + permission de la tâche |
| `POST /schedules/{id}/pause`, `/resume`, `/trigger`, `/backfill` | `schedule_pause`, `_resume`, `_trigger`, `_backfill` | écriture |
| `GET /schedules/{id}/forecast?count=` | prévision (X3) | lecture |
| `POST /specs/validate` | `validate_spec` (X3), sans écriture | lecture |
| `GET /runs`, `POST /runs` (exécution différée ou immédiate) ; `GET /runs/{id}` (X1) | `run_list`, `run_enqueue`, `run_get` | lecture / écriture + permission de la tâche |
| `POST /runs/{id}/cancel`, `/retry` | `run_cancel`, `run_retry` | exécutions |
| `GET /audit` | `audit_list` | lecture |

Les paramètres de chaque route sont les `XxxParams` du lot 2, lus en JSON (corps) ou en requête
(listes) ; les dates en RFC 3339, les durées au format SurrealQL (`30m`, `1h`). Une erreur de
lecture du corps rend `SERVER_INVALID_REQUEST` ; toute autre erreur est celle du module
(`SCHEDULER_*`), avec son statut HTTP (400, 403, 404, 409).

## 3. Côté Rust

* `apps/lyxal-server/src/http/scheduler.rs` : routes, décodage des identifiants (X1), statuts.
* `lyxal_scheduler` : `RunRef` (forme texte d'un identifiant d'exécution, `encode` / `decode`,
  testée), `SchedulerService::forecast` déjà présent ; aucun autre changement de contrat.
* Aucun changement SurrealQL attendu ; si un manque apparaît, il est signalé avant d'être ajouté.

## 4. Tests

* `apps/lyxal-server/tests/scheduler_http.rs`, de bout en bout sur l'hôte :
  * calendrier, planification contrôlée (règle fausse refusée avec la règle en cause), prévision,
    pause, reprise, déclenchement immédiat, rejeu ;
  * exécution différée exécutée par le moteur de l'hôte (tâche d'essai), lue par son identifiant
    texte, annulée, relancée ;
  * droits : sans jeton, sans permission, permission propre de la tâche, autre organisation ;
  * `no-store` sur chaque réponse ; aucune route du moteur.
* `RunRef` : aller-retour, forme invalide, autre table refusée.
* Contrôle complet : `scripts/ci/ci_local.sh`.

## 5. Documents

`apps/lyxal-server/README.md` (routes du planificateur), `crates/lyxal_scheduler/README.md`
(accès par l'hôte), `ROADMAP.md` (lot 4 retiré) ; ligne 4 du plan racine passée à « Réalisé ». Ce
plan est supprimé dans la demande de fusion de l'implémentation.

## 6. Checklist (§13)

* Aucune logique métier dans l'hôte : chaque route appelle un contrat existant, au nom de
  l'appelant.
* Entrées : identifiants d'exécution contrôlés par les règles `surql_record_string` puis `record_id` du Core après décodage (X1) ; le reste par les
  fonctions SurrealQL du lot 1.
* Aucun `panic!` ni `unwrap`, aucune erreur masquée, aucun détail interne dans les réponses.
