# Architecture — `lyxal_event`

`lyxal_event` livre chaque événement publié à chaque abonnement concerné, au moins une fois,
dans l'ordre des séquences de l'abonnement, sans jamais perdre un événement et sans laisser un
message en échec bloquer les suivants.

---

## 1. Chemin d'un événement

```text
Module producteur
  │  EventPublisher::publish  ou  DEFINE EVENT … fn::event_publish
  ▼
event_outbox ─── fn::event_fanout ───► event_delivery (une par abonnement actif concerné)
                                            │
          EventWorker (leader, sous bail)   │ fn::event_delivery_fetch_pending
                                            ▼
              ┌──────────── une file par abonnement ─────────────┐
              │ OutboxFeeder   fn::event_delivery_assign_seq     │
              │      │         (séquence, verrou)                │
              │      ▼                                           │
              │ ReliableDispatcher   fenêtre des messages en vol │
              │      │                                           │
              │      ▼                                           │
              │ HandlerConsumerBridge  ──►  Handler<E>           │
              │      │  ACK / NACK / délai dépassé               │
              │      ▼                                           │
              │ SubscriptionProgressTracker                      │
              │      fn::event_flush_batch  (curseur durable)    │
              │      fn::event_dead_letter_transfer (barrière)   │
              └──────────────────────────────────────────────────┘
```

1. **Publication** : l'événement est écrit dans `event_outbox`, puis ventilé immédiatement
   (`auto_fanout`, défaut). Un événement resté `pending` (fan-out interrompu) est ventilé par
   `fn::event_recover_pending_fanouts`, appelée à chaque tour du worker.
2. **Récupération** : le leader lit les livraisons éligibles, c'est-à-dire non résolues, au
   verrou expiré et au retry échu.
3. **Séquencement** : `fn::event_delivery_assign_seq` attribue la séquence suivante de
   l'abonnement et verrouille la livraison. Une livraison qui a déjà une séquence (reprise) la
   conserve.
4. **Distribution** : le dispatcher de l'abonnement envoie le message au bridge, qui exécute le
   handler avec un délai maximal (`dispatch_timeout`) et intercepte ses paniques.
5. **Résolution** : un ACK marque la séquence livrée ; un échec transitoire programme un nouvel
   essai avec backoff exponentiel et Full Jitter ; un échec terminal ou un budget épuisé envoie
   la livraison en dead letter.
6. **Avancement du curseur** : `fn::event_flush_batch` enregistre les résolutions et avance
   `last_persisted_cursor` jusqu'à la plus grande séquence contiguë résolue.

Chaque abonnement a sa propre file (dispatcher, feeder, tracker), créée à la première
livraison de l'abonnement dans le terme du leader. Les séquences de deux abonnements ne se
mélangent jamais.

---

## 2. Bail et fencing

Un seul worker distribue à la fois : celui qui détient le bail
`event_stream_lease:outbox_leader`.

* **Prise** : `fn::event_lease_acquire` réussit si le bail est libre, expiré ou libéré ; la
  `generation` augmente à chaque prise.
* **Renouvellement** : une tâche de fond, liée à la vie du worker, appelle
  `fn::event_lease_renew` toutes les `lease_renew_interval`. Un échec met fin au terme : le
  jeton d'annulation du terme est annulé et toutes les files sont abandonnées.
* **Fencing** : les fonctions qui écrivent dans le flux (`assign_seq`, `flush_batch`,
  `dead_letter_transfer`) commencent par une écriture conditionnelle sur le bail : même nœud,
  même génération, bail non libéré, non expiré. Sinon elles lèvent `EVENT_STALE_LEADER_FENCED`
  et toute la transaction est annulée. Un ancien leader ne peut donc rien écrire après avoir
  perdu son bail.
* **Arrêt propre** : le worker enregistre une dernière fois les résolutions déjà acquittées,
  puis libère le bail (`fn::event_lease_release`) pour qu'un autre nœud le reprenne sans
  attendre l'expiration.

---

## 3. Séquences et curseur

* **En base** : `event_subscription_progress` garde `last_assigned_seq` et
  `last_persisted_cursor`. `fn::event_flush_batch` refuse un curseur qui recule, dépasse la
  dernière séquence attribuée, couvre une séquence non résolue ou une séquence absente.
* **En mémoire** : la fenêtre du dispatcher suit les messages en vol et calcule le curseur sûr
  contigu. À la création de la file, elle est positionnée sur le curseur persisté
  (`OutboxFeeder::restore_progress`) : la contiguïté est vérifiée à partir de
  `last_persisted_cursor + 1`, même si la première séquence reçue est plus loin.
* **Backpressure** : une file accepte au plus `max_unacked` messages en vol. Au-delà, la
  livraison reste en base et sera reprise à un tour suivant.

---

## 4. Échecs, retries et dead letters

* **Budget** : `max_attempts` de l'abonnement (1 à 100, défaut 5) borne le nombre d'envois
  d'une livraison pendant un terme. Il est lu à la création de la file.
* **Échec transitoire** (`HandlerFailed { terminal: false }`, délai dépassé, panique, handler
  absent) : nouvel essai après backoff. `fn::event_delivery_failure` enregistre l'erreur et la
  date du prochain essai, sans libérer le verrou du leader.
* **Échec terminal** (`HandlerFailed { terminal: true }`, payload illisible) : dead letter
  immédiate, sans consommer le reste du budget.
* **Barrière DLQ** : la dead letter est écrite par `fn::event_dead_letter_transfer`, sous garde
  de bail, **avant** que la séquence ne compte comme résolue pour le curseur. C'est la seule
  autorité qui décide d'une dead letter.
* **Données corrompues** : une livraison dont l'événement d'origine est incomplet part en dead
  letter avec la liste des champs manquants, sans appeler le handler. Si elle avait déjà une
  séquence, celle-ci est résolue dans la fenêtre pour ne pas bloquer les suivantes. Une
  livraison dont l'abonnement a disparu part en dead letter avec son motif. Aucune valeur n'est
  jamais inventée.
* **Rejeu** : `fn::event_dead_letter_replay` remet la livraison en attente sans séquence ; elle
  en reçoit une nouvelle en fin de flux. Refusé tant que le curseur ne couvre pas l'ancienne
  séquence (`EVENT_DEAD_LETTER_REPLAY_NOT_SETTLED`).

---

## 5. Reprise après crash

* Ce qui est résolu en base est définitif : statuts `delivered`, `dead_letter`, `dropped` et
  `last_persisted_cursor`.
* Une livraison en cours au moment du crash garde son verrou (`locked_until`, 30 s par
  défaut). À son expiration, le nouveau leader la récupère et la reverrouille **avec sa
  séquence d'origine**, puis la redistribue. Le handler peut donc la recevoir deux fois : il
  doit être idempotent.
* Les acquittements reçus mais pas encore enregistrés sont perdus avec le processus : ces
  livraisons sont relivrées (at-least-once).

---

## 6. Purge

`GarbageCollector` (ou le service runtime `EventGarbageCollectorService`) appelle
périodiquement `fn::event_purge_garbage`. La purge supprime les livraisons livrées et les
événements ventilés plus anciens que la rétention, mais conserve tout événement dont une
livraison n'est pas encore livrée.

---

## 7. Composants Rust

| Composant | Fichier | Rôle |
| :--- | :--- | :--- |
| `EventWorker` | `src/worker/worker.rs` | Boucle du leader : bail, récupération, files par abonnement, arrêt propre. |
| `OutboxLeaseManager` | `src/engine/lease.rs` | Bail, génération, jeton d'annulation par terme. |
| `OutboxFeeder` | `src/engine/feeder.rs` | Séquencement, reprise du curseur, résolution des ACK / NACK, dead letters. |
| `ReliableDispatcher`, `DispatchWindow` | `src/engine/dispatcher.rs`, `dispatch_window.rs` | Fenêtre des messages en vol, curseur contigu, délais d'ACK, retries. |
| `HandlerConsumerBridge` | `src/engine/consumer_bridge.rs` | Exécution supervisée des handlers (délai, panique, annulation). |
| `SubscriptionProgressTracker` | `src/engine/progress.rs` | Barrière DLQ et avancement durable du curseur, conflits d'écriture réessayés. |
| `EventStore` | `src/store/event_store.rs` | Installation et appels `fn::event_*` (`LyxalSurrealCall`). |

Toutes les tâches de fond du worker sont liées à sa vie (`AbortOnDropHandle`) et coopèrent avec
son `CancellationToken`.

`pending_delivery.rs`, `dispatch_window.rs`, `poison_handler.rs`, `dispatcher.rs` et les
autres fichiers de `src/engine/` qui portent l'en-tête Apache-2.0 sont dérivés de Danube
Messaging. L'en-tête est conservé comme l'exige cette licence.
