# 📋 Rapport d'Implémentation Complet — `lyxal_event`

> **Date** : 1er Septembre 2026  
> **Auteur** : Antigravity (Assistant Ingénierie & Architecture Système)  
> **Destinataire** : CTO & Équipe d'Ingénierie Lyxal OS  
> **Statut** : ✅ Implémenté, Validé et Testé

---

## 1. Architecture Réellement Implémentée

Le crate `lyxal_event` a été conçu et implémenté nativement pour la suite **Lyxal OS** et la base de données **SurrealDB**.

Il implémente un bus asynchrone découplé selon le principe fondamental :
* **Un producteur publie un événement.**
* **Il ne connaît jamais ses consommateurs.**

### Flux de Données & Traitement :

```text
             PRODUCERS

      SurrealDB DEFINE EVENT
                │
                │
                ▼
          event_outbox
                ▲
                │
          Rust publish()
                │

                ▼

          LYXAL EVENT
             ENGINE

                │
                ▼
        event_subscription
                │
                ▼
             FAN-OUT
                │
                ▼
         event_delivery

       ┌────────┼─────────┐
       ▼        ▼         ▼

 notification scheduler webhook
       crm     analytics    ai
```

---

## 2. Arborescence du Crate

```text
crates/lyxal_event/
├── Cargo.toml
├── README.md
├── THIRD_PARTY_LICENSES.md
├── LYXAL_EVENT_AUDIT.md
├── LYXAL_EVENT_IMPLEMENTATION_REPORT.md
├── schema/
│   ├── event_outbox.surql
│   ├── event_subscription.surql
│   ├── event_delivery.surql
│   └── event_dead_letter.surql
├── functions/
│   ├── event_publish.surql
│   ├── event_fanout.surql
│   ├── event_recover_pending_fanouts.surql
│   ├── event_claim_batch.surql
│   ├── event_delivery_success.surql
│   ├── event_delivery_failure.surql
│   ├── event_dead_letter_replay.surql
│   └── event_purge_garbage.surql
├── error/
│   └── events.surql
├── src/
│   ├── lib.rs
│   ├── error.rs
│   ├── types.rs
│   ├── models/
│   │   ├── mod.rs
│   │   ├── envelope.rs
│   │   ├── subscription.rs
│   │   ├── delivery.rs
│   │   └── dead_letter.rs
│   ├── handler/
│   │   ├── mod.rs
│   │   ├── event.rs
│   │   ├── context.rs
│   │   ├── handler.rs
│   │   ├── erased.rs
│   │   └── registry.rs
│   ├── store/
│   │   ├── mod.rs
│   │   └── event_store.rs
│   ├── publisher/
│   │   ├── mod.rs
│   │   └── publisher.rs
│   ├── worker/
│   │   ├── mod.rs
│   │   ├── config.rs
│   │   ├── retry.rs
│   │   └── worker.rs
│   └── gc/
│       ├── mod.rs
│       └── collector.rs
└── tests/
    ├── unit_tests.rs
    ├── integration_publish_fanout.rs
    ├── integration_fanout_recovery.rs
    ├── integration_define_event.rs
    ├── integration_retry_dlq_replay.rs
    ├── integration_concurrency_1000.rs
    ├── integration_crash_recovery.rs
    └── integration_instance_isolation.rs
```

---

## 3. Tables SurrealDB

1. **`event_outbox`** (`SCHEMAFULL`) : table outbox principale contenant l'événement immuable (`event_id`, `event_type`, `version`, `producer`, `source`, `context`, `correlation_id`, `causation_id`, `payload`, `metadata`, `status: pending | fanned_out | archived`, `created_at`, `fanned_out_at`).
2. **`event_subscription`** (`SCHEMAFULL`) : catalogue des abonnements des modules (`name`, `target_module`, `event_pattern`, `handler_name`, `is_active`, `max_attempts`).
3. **`event_delivery`** (`SCHEMAFULL`) : unité de distribution par abonné (`outbox_event`, `subscription`, `target_module`, `context`, `status: pending | processing | delivered | failed | dead_letter`, `attempts`, `max_attempts`, `next_retry_at`, `locked_until`, `lease_owner`, `last_error`).
   * **Contrainte d'unicité (Correction CTO 1)** : Index unique strict sur `(outbox_event, subscription)` permettant à un même module d'avoir plusieurs abonnements distincts sans duplication.
4. **`event_dead_letter`** (`SCHEMAFULL`) : mise en quarantaine des livraisons ayant épuisé leur budget de retry (`delivery`, `outbox_event`, `target_module`, `attempts`, `last_error`, `payload`, `metadata`, `replayed`, `replayed_at`, `exhausted_at`).

---

## 4. Fonctions SurrealQL

* **`fn::event_publish($params)`** : insère dans `event_outbox` et déclenche le fan-out immédiat.
* **`fn::event_fanout($params)`** : ventile l'événement vers tous les abonnements correspondants avec vérification d'unicité `(outbox_event, subscription)`.
* **`fn::event_recover_pending_fanouts($params)`** : reprend de manière idempotente les fan-outs d'événements restés en `pending` (Correction CTO 2).
* **`fn::event_claim_batch($params)`** : claim atomique par lot avec bail exclusif `locked_until` et incrémentation de `attempts`.
* **`fn::event_delivery_success($params)`** : acquitte le succès et libère le bail.
* **`fn::event_delivery_failure($params)`** : enregistre l'erreur et replanifie avec backoff ou déplace en dead-letter.
* **`fn::event_dead_letter_replay($params)`** : réinitialise une dead letter en livraison `pending` pour rejeu contrôlé.
* **`fn::event_purge_garbage($params)`** : purge les enregistrements `delivered` et `fanned_out` anciens selon la rétention.

---

## 5. API Rust Publique

* `EventPublisher` : façade d'émission (`publish`, `publish_with_context`, `publish_envelope`).
* `EventStore` : wrapper d'infrastructure sur `Surreal<Any>` implémentant `LyxalSurrealCall`.
* `EventWorker` : moteur asynchrone d'exécution (`run`, `poll_cycle`).
* `GarbageCollector` : tâche de fond pour la purge de rétention.
* `LyxalEventEnvelope`, `EventContext`, `EventSubscription`, `EventDelivery`, `EventDeadLetter`.

---

## 6. Handler Registry

Architecture sans enum globale monolithique :
* `Event` : trait typé avec `const EVENT_TYPE: &'static str`.
* `Handler<E: Event>` : trait asynchrone typé.
* `TypedHandler<E, H>` : adaptateur d'effacement de type.
* `ErasedHandler` : trait object stocké dans `HandlerRegistry` indexé par `event_type`.

---

## 7. Architecture du Worker

* Exécution asynchrone sur Tokio.
* Arrêt coopératif gracieux via `tokio_util::sync::CancellationToken`.
* Tâche périodique automatique de reprise des fan-outs interrompus (`recover_pending_fanouts`).
* Isolation des timeouts de handlers : exécution sous `tokio::time::timeout` avec déclenchement immédiat d'un `cancel.child_token()`.

---

## 8. Algorithme de Claim & Lease

* Formule de bail : `lease_duration = batch_size * dispatch_timeout`.
* Horloge serveur SurrealDB : `locked_until = time::now() + duration::from::secs(lease)` pour garantir l'absence de dérive d'horloge entre workers.
* Claim atomique : `UPDATE event_delivery ... WHERE (status = 'pending' AND next_retry_at <= time::now()) OR ... RETURN AFTER`.

---

## 9. Retry & Full Jitter

* Formule de backoff : `min(retry_max_delay, retry_base_delay * 2^attempts)`.
* Full Jitter : tirage aléatoire uniforme `fastrand::u64(0..=delay_nanos)` éliminant les réveils synchrones.

---

## 10. Dead Letter Queue & Replay

* Bascule automatique en `event_dead_letter` dès que `attempts >= max_attempts`.
* Sauvegarde intégrale du payload et des métadonnées.
* Rejeu sécurisé via `store.dead_letter_replay` : la livraison repasse en `pending`, `attempts` est remis à 0, et l'audit de rejeu est horodaté dans la dead letter.

---

## 11. Isolation Multi-Instance / Multi-Tenant

* `EventContext` transporte `instance_id`, `namespace`, `database`.
* Le claim et le dispatch filtrent obligatoirement sur `context.instance_id`.
* Aucune contamination possible entre instances distinctes.

---

## 12. Intégration DEFINE EVENT

Démontrée de bout en bout : mutation sur une table métier (ex: `booking`) -> déclenchement `DEFINE EVENT` SurrealDB -> `fn::event_publish` -> `event_outbox` -> fan-out -> `event_delivery` -> exécution par le handler.

---

## 13. Sémantique de Distribution (Correction CTO 3)

* **Garantie** : **At-Least-Once**.
* **Claim** : Zéro double claim simultané garanti par le bail exclusif.
* **Crash Recovery** : Réexécution normale après expiration du bail si un worker s'arrête entre l'effet et l'acquittement.
* **Idempotence** : Le handler dispose de `event_id` et `delivery_id` dans `HandlerContext` pour garantir l'idempotence de ses effets de bord.

---

## 14. Validation par les Tests Automatisés

1. `test_envelope_creation_and_decoding` : ✅ Validé.
2. `test_handler_registry_duplicate_rejection` : ✅ Validé.
3. `test_retry_delay_exponential_with_jitter` : ✅ Validé.
4. `test_lease_duration_scaling_by_batch` : ✅ Validé.
5. `test_publish_and_fanout_end_to_end` : ✅ Validé.
6. `test_recover_pending_fanouts_after_crash` : ✅ Validé (Correction 2).
7. `test_surrealdb_define_event_triggers_lyxal_event` : ✅ Validé.
8. `test_retry_dlq_and_replay_cycle` : ✅ Validé.
9. `test_massive_concurrency_1000_deliveries_10_workers` : ✅ Validé (1000 livraisons, 10 workers, 0 double claim, 0 perte).
10. `test_worker_crash_and_lease_recovery` : ✅ Validé (reprise après expiration du bail).
11. `test_strict_multi_instance_isolation` : ✅ Validé (étanchéité totale Alpha vs Beta).
