# Module `lyxal_event` — Événements entre modules de Lyxal OS

`lyxal_event` transporte les événements de domaine d'un module producteur vers les modules
abonnés, sans que le producteur connaisse ses consommateurs. Il repose sur une outbox
transactionnelle dans SurrealDB et un worker leader qui livre chaque événement à chaque
abonnement concerné.

Version `0.1.0` (régime pré-production, `.agents/AGENTS.md` §0). Cible : SurrealDB 3.3.4,
SDK `surrealdb` 3.3. Dépend de `lyxal_core` (validation des entrées), `lyxal_error` (contrat de
résultat, définitions d'erreurs) et `lyxal_surreal` (transport).


Évolutions prévues : [`ROADMAP.md`](ROADMAP.md).

---

## 1. Garanties

* **Au moins une fois** : un événement publié est livré à chaque abonnement actif concerné,
  y compris après un crash du worker. Un handler peut donc recevoir deux fois la même
  livraison et doit être idempotent.
* **Ordre et curseur contigu par abonnement** : chaque abonnement a son propre flux de
  séquences. Son curseur durable (`last_persisted_cursor`) n'avance que lorsque toutes les
  séquences précédentes sont résolues (livrées, en dead letter ou abandonnées).
* **Un seul distributeur** : le worker qui détient le bail distribue. Toute écriture dans le
  flux vérifie le bail et sa génération : un ancien leader est rejeté
  (`EVENT_STALE_LEADER_FENCED`).
* **Dead letter avant curseur** : une livraison qui épuise son budget, échoue de façon
  terminale ou dont les données sont incomplètes est écrite dans `event_dead_letter` avant de
  compter comme résolue. Elle ne bloque pas les suivantes et peut être rejouée.
* **Aucune erreur masquée, aucune valeur inventée** : un échec remonte ou est journalisé ; une
  livraison corrompue part en dead letter avec son motif.

Détails : [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

---

## 2. Tables (`schema/`)

| Table | Rôle |
| :--- | :--- |
| `event_outbox` | Événements publiés. |
| `event_subscription` | Abonnements : module consommateur, motif (`type`, `prefixe.*`, `*`), budget d'essais `max_attempts`. |
| `event_delivery` | Une livraison par couple (événement, abonnement) : statut, séquence, verrou, retry. |
| `event_subscription_progress` | Dernière séquence attribuée et curseur durable de chaque abonnement. |
| `event_stream_lease` | Bail du leader (`event_stream_lease:outbox_leader`) et sa génération. |
| `event_dead_letter` | Livraisons en quarantaine, rejouables. |

Toutes en `TYPE NORMAL SCHEMAFULL PERMISSIONS NONE`.

---

## 3. Fonctions SurrealQL (`functions/`)

Toutes prennent un objet unique `$params`, acceptent `language` (défaut `fr`) et renvoient
`{ ok, data, error }`. Une entrée invalide renvoie `EVENT_INVALID_PARAMETERS` avec le détail
par champ.

* **Appelées par les modules**, validées par `fn::validation_object_execute` de `lyxal_core` :
  `fn::event_publish`, `fn::event_subscription_register`, `fn::event_outbox_get`,
  `fn::event_delivery_get`, `fn::event_dead_letter_list`, `fn::event_dead_letter_replay`,
  `fn::event_purge_garbage`.
* **Internes au moteur**, appelées à chaque livraison et validées par les primitives de
  `lyxal_core` (le moteur d'objet coûte environ 23 ms par appel, décision CTO) :
  `fn::event_fanout`, `fn::event_recover_pending_fanouts`, `fn::event_delivery_fetch_pending`,
  `fn::event_delivery_assign_seq`, `fn::event_delivery_failure`,
  `fn::event_dead_letter_transfer`, `fn::event_flush_batch`, `fn::event_progress_get`,
  `fn::event_lease_acquire`, `fn::event_lease_renew`, `fn::event_lease_release`.

Les trois fonctions protégées par le bail (`assign_seq`, `dead_letter_transfer`, `flush_batch`)
lèvent leurs erreurs par `THROW` pour annuler toute la transaction, y compris l'écriture de
garde sur le bail (exception documentée, décision CTO).

Paramètres, données renvoyées et règles : [`docs/SURREALQL_API.md`](docs/SURREALQL_API.md).

---

## 4. Codes d'erreur (`error/`)

| Code | Catégorie | HTTP | Cause |
| :--- | :--- | :--- | :--- |
| `EVENT_INVALID_PARAMETERS` | `validation` | 400 | Paramètre absent, inconnu ou invalide (`details.fields`) |
| `EVENT_DELIVERY_NOT_FOUND` | `not_found` | 404 | Livraison inconnue |
| `EVENT_DEAD_LETTER_REPLAY_NOT_SETTLED` | `conflict` | 409 | Rejeu demandé avant que le curseur ne couvre la séquence de la livraison (réessayable) |
| `EVENT_STALE_LEADER_FENCED` | `conflict` | 412 | Écriture d'un leader qui a perdu le bail |
| `EVENT_CURSOR_NON_MONOTONIC` | `validation` | 422 | Curseur qui recule |
| `EVENT_CURSOR_EXCEEDS_ASSIGNED_SEQ` | `validation` | 422 | Curseur au-delà de la dernière séquence attribuée |
| `EVENT_CURSOR_INVARIANT_VIOLATION_UNRESOLVED_SEQUENCES` | `validation` | 422 | Séquence non résolue sous le curseur demandé |
| `EVENT_CURSOR_MISSING_SEQUENCE_HOLE` | `validation` | 422 | Séquence absente sous le curseur demandé |

---

## 5. Contrats Rust (`src/`)

* **Événements** : `Event` (`const EVENT_TYPE`), enveloppe `LyxalEventEnvelope`, contexte
  `EventContext` (`instance_id`, `namespace`, `database`), identifiants `EventId`,
  `CorrelationId`, `CausationId`.
* **Publication** : `EventPublisher::publish`, `publish_with_context`, `publish_envelope`.
* **Consommation** : `Handler<E>` (`handle(event, &HandlerContext)`), `HandlerRegistry`.
  `HandlerContext` donne `event_id`, `delivery_id`, `correlation_id`, `causation_id`, `context`,
  `attempt` et un `CancellationToken`. Un handler signale un échec par
  `LyxalEventError::HandlerFailed { …, terminal }` : `terminal: true` envoie directement en dead
  letter.
* **Exécution** : `EventWorker::run(cancel)` avec `EventWorkerConfig` (identifiant du nœud,
  instance, bail, taille des lots, messages en vol par abonnement, délais d'exécution et d'ACK,
  backoff). Le budget d'essais vient de l'abonnement, pas du worker. `GarbageCollector::run`
  purge périodiquement. Métriques : `EventWorker::metrics()`.
* **Persistance** : `EventStore` (`Surreal<Any>`, `LyxalSurrealCall`).
* **Installation** : `MANIFEST` (le manifeste) et `EMBEDDED_RESOURCES` (les fichiers déclarés,
  embarqués dans le binaire), lus par `lyxal_runtime`.
* **Erreurs** : `LyxalEventError`, dont `StaleLeaderFenced` pour le fencing.

`lyxal_runtime` intègre le moteur : `EventConsumerModule` (déclaration des handlers d'un module),
`EventWorkerService` et `EventGarbageCollectorService`.

Guide pas à pas : [`docs/INTEGRATION_GUIDE.md`](docs/INTEGRATION_GUIDE.md).

---

## 6. Installation (`manifest.toml`)

Le manifeste déclare les 6 schémas, les 18 fonctions et les définitions d'erreurs (rejouables
sans doublon, `IF !record::exists(...)`). `lyxal_runtime` installe le module depuis ce manifeste
(`EventEngineConfig::auto_init_schema`, ou `lyxal_runtime::schema::install_embedded` avec
`MANIFEST` et `EMBEDDED_RESOURCES`). Un test vérifie que les fichiers embarqués sont exactement
ceux du manifeste et du disque. Pas de migration ni de seed : les abonnements sont déclarés par
les modules consommateurs.

---

## 7. Vérification

```bash
cargo test -p lyxal_event
```

Les tests d'intégration installent `lyxal_core`, `lyxal_error` puis `lyxal_event` dans une base
embarquée et exercent le chemin de production (`EventWorker::run`) : publication et fan-out,
retries et dead letters, rejeu, reprise après crash, isolation par instance, `DEFINE EVENT`,
concurrence entre plusieurs workers, purge. `scripts/ci/ci_local.sh` rejoue la CI complète,
dont la validation du SurrealQL par un binaire SurrealDB 3.3.4.

---

## 8. Licence

Les fichiers de `src/engine/` portant l'en-tête Apache-2.0 sont dérivés de Danube Messaging.
Cet en-tête est conservé comme l'exige la licence. Le crate est publié sous la licence du
workspace (MIT OR Apache-2.0).
