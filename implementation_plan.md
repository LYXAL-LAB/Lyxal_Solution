# Plan d'implémentation — audit externe, lot 2 (A04)

Deuxième lot de correction de l'audit externe
[`audit_externe/2026-11-07_audit_crates_cto_chatgpt_codex.md`](audit_externe/2026-11-07_audit_crates_cto_chatgpt_codex.md).
Constat vérifié sur `main` (après #89) en lecture seule. Changement dans `lyxal_pipeline_ingestion`
et son hôte `apps/lyxal-server` (câblage) ; aucun autre module ne consomme ces événements
(vérifié par recherche dans le dépôt). Plan placé à la racine comme le lot 1, supprimé une fois
exécuté.

**En attente de validation du CTO (Q1, Q2).**

## 1. Constat

| ID | Constat | Preuve |
| :- | :--- | :--- |
| A04-a | `ingestion.manifest.published` est émis par Rust **après** l'écriture de l'état `COMMITTED`. Un arrêt entre les deux perd l'événement, et la reprise sort aussitôt sans le réémettre (« manifeste déjà exécuté »). | `controlled_publisher.rs:106` (retour anticipé), `:204-226` (écriture puis émission) |
| A04-b | Même fenêtre pour `ingestion.batch.staged` : passage du lot à `STAGED`, puis émission Rust ; un lot déjà `STAGED` n'est pas retraité. | `ingestion_worker.rs:451-474`, `:168` |
| A04-c | Même fenêtre pour `ingestion.batch.failed` : passage à `FAILED`, puis émission Rust. Le code d'erreur n'est conservé nulle part en base (seul le motif est dans le journal des transitions). | `ingestion_worker.rs:525-547` |
| Référence | `ingestion.manifest.approved` est déjà émis correctement : `DEFINE EVENT` sur le passage à `APPROVED`, `fn::event_publish` dans la même transaction, `THROW` si la publication échoue (`.agents/AGENTS.md` §5.6.1). | `events/01_events.surql` |

## 2. Décisions demandées

| # | Question | Options | Recommandation |
| :- | :--- | :--- | :--- |
| Q1 | Émission des trois événements | **A.** `DEFINE EVENT` sur la transition d'état, comme `ingestion.manifest.approved` : l'événement est écrit dans l'outbox dans la **même transaction** que le changement d'état ; si la publication échoue, `THROW` annule la transition. L'émission Rust est supprimée. **B.** Garder l'émission Rust et ajouter un marqueur « événement émis » relu à la reprise. | **A** : c'est la règle §5.6.1 et le modèle déjà en place ; l'état et l'événement ne peuvent plus diverger, sans logique de reprise supplémentaire. B garde deux écritures séparées et ajoute un état à maintenir. |
| Q2 | Où conserver le code d'erreur d'un lot en échec (nécessaire à `ingestion.batch.failed`) | **A.** Dans l'entrée du journal `transitions` du passage à `FAILED` (champ `error_code`, le motif y est déjà). **B.** Nouveaux champs `failure_code` / `failure_message` sur `ingestion_batch`. | **A** : le journal décrit déjà chaque transition (origine, auteur, motif, date) ; le code d'erreur y a sa place, sans dupliquer le motif dans deux champs. |

## 3. Contrat cible (si Q1-A, Q2-A)

### SurrealQL (`events/01_events.surql`)

Trois `DEFINE EVENT OVERWRITE`, même forme que l'événement d'approbation (`fn::event_publish`,
`producer: "lyxal_pipeline_ingestion"`, `THROW` si `!$published.ok`), déclenchés **une seule
fois** par la transition (`$before.statut != $after.statut`) :

| Événement | Table, condition | Charge utile (lue dans l'enregistrement) |
| :- | :- | :--- |
| `ingestion.batch.staged` | `ingestion_batch`, passage à `STAGED` | `batch_id`, `source_type`, `total_lignes`, `verified_count`, `to_confirm_count`, `rejected_count` (compteurs du dernier checkpoint, enregistré avant la transition) |
| `ingestion.batch.failed` | `ingestion_batch`, passage à `FAILED` | `batch_id`, `error_code` et `message` (dernière entrée de `transitions`) |
| `ingestion.manifest.published` | `ingestion_publication_manifest`, passage à `COMMITTED` | `manifest_ref`, `batch_id`, `items_committed`, `items_failed`, `publisher_agent` (auteur de la dernière transition) |

Les charges utiles gardent exactement les champs des structures Rust `BatchStagedEvent`,
`BatchFailedEvent` et `ManifestPublishedEvent` (contrat inchangé pour les consommateurs).

### SurrealQL (`fn::ingestion_batch_transition`)

* Nouveau paramètre `error_code` (code `INGESTION_*` ou d'un autre module, majuscules,
  1 à 128), **obligatoire** pour `FAILED` et refusé pour les autres états
  (`INGESTION_INVALID_PARAMETERS`) ; enregistré dans l'entrée de `transitions` (Q2-A).
* Validation par le moteur de `lyxal_core` (règles `required_string`, `regex` déjà utilisées) ;
  aucune fonction Core nouvelle.

### Rust

* `IngestionWorker` : suppression de `with_publisher`, du champ `publisher` et des deux
  émissions ; le passage à `FAILED` transmet `error_code` (`IngestionError::code()`).
  `IngestionStore::update_batch_status` reçoit le code d'erreur (paramètre `Option<&str>`,
  `BatchTransitionParams.error_code`).
* `ControlledPublisher` : suppression de `with_event_publisher`, du champ `event_publisher` et de
  l'émission.
* `apps/lyxal-server/src/modules/ingestion.rs` : plus de `EventPublisher` pour l'ingestion (le
  contexte d'événement devenu inutile est retiré).
* `src/events.rs` : structures conservées (contrat typé des consommateurs), documentation
  « émis par la base » ; `events/01_events.surql` : commentaire d'en-tête mis à jour.
* `README.md` de l'ingestion : tableau des événements (émetteur : la base, sur transition).

Rupture coordonnée (§0.3) : `with_publisher` et `with_event_publisher` disparaissent ; seul
appelant, `lyxal-server`, mis à jour dans le même changement.

## 4. Tests

| Cas | Preuve attendue |
| :- | :--- |
| Atomicité | Banc SurrealQL : la transition vers `STAGED`, `FAILED` ou `COMMITTED` écrit exactement un événement du bon type dans `event_outbox`, avec la charge utile attendue ; si `fn::event_publish` échoue (publication rendue impossible dans le test), la transition est annulée et le statut reste inchangé. |
| Unicité | Une seconde écriture sur un lot déjà `STAGED` ou un manifeste déjà `COMMITTED` (mise à jour d'un autre champ) n'émet aucun nouvel événement. |
| Code d'erreur | `fn::ingestion_batch_transition` vers `FAILED` sans `error_code` → `INGESTION_INVALID_PARAMETERS` ; avec `error_code` vers un autre état → idem. |
| Reprise | Test d'intégration Rust : une publication terminée laisse exactement un `ingestion.manifest.published` dans l'outbox ; la rejouer sur le manifeste `COMMITTED` n'en ajoute pas. Un lot traité jusqu'à `STAGED` laisse exactement un `ingestion.batch.staged`. Les tests existants de publication et du worker restent verts. |

Contrôle complet : `scripts/ci/ci_local.sh`.

## 5. Checklist (§13)

* Événements : émission par `DEFINE EVENT` → `fn::event_publish` exclusivement, résultat vérifié
  (`THROW`) ; producteur sans référence à un consommateur.
* SurrealQL : `$params: object` ; entrées par `fn::validation_object_execute` ; écriture
  vérifiée (inchangé).
* Rust : aucun DTO public modifié hors `BatchTransitionParams` (interne) ; aucune logique
  dupliquée.
* Zéro dette : émission Rust supprimée, aucun double chemin ; plan supprimé après exécution.

## 6. Lots suivants (rappel)

3 : A01 (sceau du contenu publié) · 4 : A02 (personnalisations par locataire) · 5 : A05
(adaptateurs sur `lyxal_parsing`) · 6 : A07 puis A06.
