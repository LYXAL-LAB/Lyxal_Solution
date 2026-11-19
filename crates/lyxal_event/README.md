# Module `lyxal_event` — Événements entre modules de Lyxal OS

`lyxal_event` transporte les événements de domaine d'un module producteur vers les modules
abonnés, sans que le producteur connaisse ses consommateurs. Il repose sur une outbox
transactionnelle dans SurrealDB et, pour chaque hôte (binaire qui porte des handlers, par
exemple `lyxal_server`), un worker chef des événements qui livre chaque événement aux
abonnements de son hôte. Plusieurs hôtes peuvent partager une même base.

Version `0.1.0` (régime pré-production, `.agents/AGENTS.md` §0). Cible : SurrealDB 3.3.4,
SDK `surrealdb` 3.3. Dépend de `lyxal_core` (validation des entrées), `lyxal_error` (contrat de
résultat, définitions d'erreurs) et `lyxal_surreal` (transport).


Évolutions prévues : [`ROADMAP.md`](ROADMAP.md).

---

## 1. Garanties

* **Au moins une fois** : un événement publié est livré à chaque abonnement actif concerné,
  y compris après un crash du worker. Un handler peut donc recevoir deux fois la même
  livraison et doit être idempotent.
* **Abonnement suspendu** (`is_active = false`) : ses livraisons sont créées et attendent sa
  réactivation ; un événement publié pendant la suspension n'est pas perdu.
* **Ordre et curseur contigu par abonnement** : chaque abonnement a son propre flux de
  séquences. Son curseur durable (`last_persisted_cursor`) n'avance que lorsque toutes les
  séquences précédentes sont résolues (livrées, en dead letter ou abandonnées).
* **Un chef des événements par hôte** : chaque abonnement appartient à un hôte (`host`),
  recopié sur chacune de ses livraisons. Seul le worker qui détient le bail de cet hôte
  (`event_stream_lease:<hôte>`) lit, numérote et solde ses livraisons ; plusieurs copies d'un
  même hôte se partagent le bail (un seul chef à la fois). Toute écriture dans le flux vérifie
  le bail de l'hôte et sa génération (un ancien chef est rejeté : `EVENT_STALE_LEADER_FENCED`)
  et que l'abonnement appartient à cet hôte (`EVENT_SUBSCRIPTION_NOT_OWNED`).
* **Hôte arrêté** : ses livraisons restent `pending`, sans essai compté ni dead letter, jusqu'à
  son retour ; les autres hôtes continuent. `fn::event_backlog` et la sonde `lyxal_event` du
  runtime le signalent. Un abonnement ne change d'hôte que par
  `fn::event_subscription_transfer`, refusé tant que l'ancien hôte est en marche.
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
| `event_subscription` | Abonnements : module consommateur, hôte propriétaire (`host`), motif (`type`, `prefixe.*`, `*`), budget d'essais `max_attempts`. |
| `event_delivery` | Une livraison par couple (événement, abonnement) : hôte de l'abonnement, statut, séquence, verrou, retry. Index de lecture `(host, status, next_retry_at)`. |
| `event_subscription_progress` | Dernière séquence attribuée et curseur durable de chaque abonnement. |
| `event_stream_lease` | Un bail par hôte (`event_stream_lease:<hôte>`) : chef des événements de l'hôte et sa génération. |
| `event_dead_letter` | Livraisons en quarantaine, rejouables. |

Toutes en `TYPE NORMAL SCHEMAFULL PERMISSIONS NONE`.

---

## 3. Fonctions SurrealQL (`functions/`)

Toutes prennent un objet unique `$params`, acceptent `language` (défaut `fr`) et renvoient
`{ ok, data, error }`. Une entrée invalide renvoie `EVENT_INVALID_PARAMETERS` avec le détail
par champ.

* **Appelées par les modules**, validées par `fn::validation_object_execute` de `lyxal_core` :
  `fn::event_publish`, `fn::event_subscription_register` (hôte obligatoire),
  `fn::event_subscription_transfer` (exploitation : changement d'hôte), `fn::event_backlog`
  (attente par hôte), `fn::event_outbox_get`, `fn::event_delivery_get`,
  `fn::event_dead_letter_list`, `fn::event_dead_letter_replay`, `fn::event_purge_garbage`.
* **Internes au moteur**, appelées à chaque livraison et validées par les primitives de
  `lyxal_core` (le moteur d'objet coûte environ 23 ms par appel, décision CTO) :
  `fn::event_fanout`, `fn::event_recover_pending_fanouts`, `fn::event_delivery_fetch_pending`,
  `fn::event_delivery_assign_seq`, `fn::event_delivery_failure`,
  `fn::event_dead_letter_transfer`, `fn::event_flush_batch`, `fn::event_progress_get`,
  `fn::event_lease_acquire`, `fn::event_lease_renew`, `fn::event_lease_release`. Toutes, sauf
  la ventilation, la reprise des ventilations et la lecture de progression, prennent l'hôte
  (`host`) du chef qui les appelle.

Les quatre fonctions protégées par le bail de l'hôte (`assign_seq`, `delivery_failure`,
`dead_letter_transfer`, `flush_batch`) lèvent leurs erreurs de garde et de curseur par `THROW` pour annuler toute la
transaction, y compris l'écriture de garde sur le bail (exception documentée, décision CTO). Le
refus de propriété (`EVENT_SUBSCRIPTION_NOT_OWNED`) est un résultat d'erreur ordinaire : il
suit la garde et n'écrit rien d'autre.

Paramètres, données renvoyées et règles : [`docs/SURREALQL_API.md`](docs/SURREALQL_API.md).

---

## 4. Codes d'erreur (`error/`)

| Code | Catégorie | HTTP | Cause |
| :--- | :--- | :--- | :--- |
| `EVENT_INVALID_PARAMETERS` | `validation` | 400 | Paramètre absent, inconnu ou invalide (`details.fields`) |
| `EVENT_DELIVERY_NOT_FOUND` | `not_found` | 404 | Livraison inconnue |
| `EVENT_SUBSCRIPTION_NOT_FOUND` | `not_found` | 404 | Abonnement inconnu (`fn::event_subscription_transfer`) |
| `EVENT_WRITE_FORBIDDEN` | `authorization` | 403 | Écriture refusée par les permissions (session autre que système) |
| `EVENT_SUBSCRIPTION_HOST_CONFLICT` | `conflict` | 409 | Abonnement déjà enregistré par un autre hôte |
| `EVENT_SUBSCRIPTION_NOT_OWNED` | `conflict` | 409 | Écriture d'un chef sur un abonnement ou une livraison d'un autre hôte |
| `EVENT_HOST_ACTIVE` | `conflict` | 409 | Changement d'hôte refusé : le bail de l'ancien hôte est vivant (réessayable) |
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
* **Exécution** : `EventWorker::run(cancel)` avec `EventWorkerConfig::new(host)` (hôte servi,
  obligatoire, sans valeur par défaut ; identifiant du nœud, instance, bail, taille des lots,
  messages en vol par abonnement, délais d'exécution et d'ACK, backoff). Le bail est tenu par
  `OutboxLeaseManager::new(client, host, node_id, ttl)`. Le budget d'essais vient de l'abonnement, pas du worker. `GarbageCollector::run`
  purge périodiquement : au-delà de la rétention, seules les livraisons livrées couvertes par le
  curseur durable de leur abonnement et les événements qu'aucune livraison ne référence sont
  supprimés (la purge ne crée jamais de trou avant le curseur). Métriques :
  `EventWorker::metrics()`.
* **Abonnements** : `EventSubscription::new(name, target_module, event_pattern, handler_name,
  host)`, enregistré par `EventStore::register_subscription` ; changement d'hôte par
  `EventStore::transfer_subscription(name, host)` ; attente par hôte par
  `EventStore::backlog(older_than)` (`EventBacklog`).
* **Persistance** : `EventStore` (`Surreal<Any>`, `LyxalSurrealCall`).
* **Installation** : `MANIFEST` (le manifeste) et `EMBEDDED_RESOURCES` (les fichiers déclarés,
  embarqués dans le binaire), lus par `lyxal_runtime`.
* **Erreurs** : `LyxalEventError`, dont `StaleLeaderFenced` pour le fencing.

`lyxal_runtime` intègre le moteur : `EventConsumerModule` (déclaration des handlers d'un module),
`EventWorkerService`, `EventGarbageCollectorService` et la sonde `EventEngineHealthCheck`
(module `lyxal_event` : « dégradé » quand un hôte a des livraisons de plus de 5 minutes sans chef
vivant). Le runtime construit `EventEngineConfig::new(&host)` avec l'hôte de son
`RuntimeConfig`.

Guide pas à pas : [`docs/INTEGRATION_GUIDE.md`](docs/INTEGRATION_GUIDE.md).

---

## 6. Installation (`manifest.toml`)

Le manifeste déclare les 6 schémas, les 20 fonctions et les définitions d'erreurs (rejouables
sans doublon, `IF !record::exists(...)`). `lyxal_runtime` installe le module depuis ce manifeste
(`EventEngineConfig::auto_init_schema`, ou `lyxal_runtime::schema::install_embedded` avec
`MANIFEST` et `EMBEDDED_RESOURCES`). Un test vérifie que les fichiers embarqués sont exactement
ceux du manifeste et du disque. Pas de migration ni de seed : les abonnements sont déclarés par
les modules consommateurs.

---

## 7. Vérification

```bash
cargo test -p lyxal_event
python3 -I scripts/ci/test_lyxal_modules.py   # tests SurrealQL tests/*.test.surql
```

Les tests d'intégration installent `lyxal_core`, `lyxal_error` puis `lyxal_event` dans une base
embarquée et exercent le chemin de production (`EventWorker::run`) : publication et fan-out,
retries et dead letters, rejeu, reprise après crash, isolation par instance, `DEFINE EVENT`,
concurrence entre plusieurs workers, purge, et plusieurs hôtes sur une base
(`tests/it/integration_multi_host.rs` : chaque événement au handler de son hôte, hôte arrêté,
deux nœuds d'un hôte et reprise, propriété, conflit et changement d'hôte). Le moteur complet,
démarré par le runtime à deux hôtes sur une base, est aussi essayé par
`crates/lyxal_runtime/tests/it/two_hosts_shared_database_tests.rs`, sur moteur embarqué et sur
un serveur SurrealDB 3.3.4 (`ws://`, `scripts/ci/test_all.sh`). Les tests SurrealQL
(`tests/hotes.test.surql`, `tests/moteur.test.surql`) appellent chaque fonction publique, sous
la session système et sous une identité sans droit. `scripts/ci/ci_local.sh` rejoue la CI complète,
dont la validation du SurrealQL par un binaire SurrealDB 3.3.4.

---

## 8. Licence

Les fichiers de `src/engine/` portant l'en-tête Apache-2.0 sont dérivés de Danube Messaging.
Cet en-tête est conservé comme l'exige la licence. Le crate est publié sous la licence du
workspace (MIT OR Apache-2.0).
