# ⚡ LYXAL Event Engine (`lyxal_event`)

> **Moteur transactionnel unifié d'événements et de distribution streaming in-process pour Lyxal OS.**  
> Compatible SurrealDB 3.2.0 | Version 1.0.0 | Statut : Production-Ready

---

## 🌟 1. Présentation & Rôle dans l'Architecture Lyxal OS

Dans l'architecture modulaire de **Lyxal OS**, les modules métiers (`lyxal_booking`, `lyxal_notification`, `lyxal_crm`, `lyxal_catalogue`, etc.) doivent rester **strictement découplés** (Règle 5.6 de la Charte d'Architecture). Aucun module producteur ne doit connaître ses consommateurs.

`lyxal_event` constitue la dorsale événementielle asynchrone officielle de la plateforme. Il implémente :
1. Le pattern **Transactional Outbox** dans SurrealDB 3.2.0 (écriture atomique lors des mutations métier).
2. Un mécanisme d'**éventail asynchrone (Fan-Out)** vers les abonnements déclarés (`event_subscription`).
3. Un moteur de **distribution streaming in-process pipeliné** (`ReliableDispatcher`) garantissant un débit élevé, le contrôle strict de backpressure et la gestion granulaire des retries/poisons.
4. Une protection par **bail distribué et Fencing transactionnel** (`event_stream_lease`) pour exclure strictement tout split-brain ou leader zombie.
5. Une garantie d'**avancement contigu du curseur sans trou** (`fn::event_flush_batch` et `event_subscription_progress`).
6. Une **Barrière Dead-Letter Queue (DLQ)** garantissant qu'aucun message poison ne bloque le curseur ni n'est perdu lors des dépassements de quotas d'échecs.

```text
┌─────────────────────────┐
│     Module Métier       │  (ex: lyxal_booking)
│ (Mutation Transaction)  │
└────────────┬────────────┘
             │ DEFINE EVENT / EventPublisher
             ▼
┌─────────────────────────┐
│      event_outbox       │  (Persistance atomique SurrealDB 3.2.0)
└────────────┬────────────┘
             │ fn::event_fanout
             ▼
┌─────────────────────────┐
│     event_delivery      │  (Livraisons unitaires par abonnement)
└────────────┬────────────┘
             │ OutboxFeeder (Attribution atomique fn::event_delivery_assign_seq)
             ▼
┌─────────────────────────┐
│    ReliableDispatcher   │  (Fenêtre glissante, Round-Robin, Backpressure)
└────────────┬────────────┘
             │ HandlerConsumerBridge
             ▼
┌─────────────────────────┐
│     HandlerRegistry     │  (Handlers typés Handler<E> en Rust)
└────────────┬────────────┘
             │ ACK / NACK / Timeout
             ▼
┌─────────────────────────┐
│ SubscriptionProgress    │  (Curseur contigu sans trou fn::event_flush_batch)
└─────────────────────────┘
```

---

## 🛡️ 2. Garanties & Invariants de Conception

* **Garantie de livraison At-Least-Once** : Aucun événement publié n'est perdu. En cas de crash ou redémarrage du serveur, les fan-outs et livraisons non résolues sont automatiquement repris.
* **Fencing Transactionnel Étanche** : Le leader actif détient un bail (`event_stream_lease`) associé à une génération monotone (`generation`). Toute écriture (assignation de séquence, flush de curseur, transfert DLQ) vérifie et met à jour le bail de manière atomique. Tout leader déchu est rejeté immédiatement avec l'erreur `EVENT_STALE_LEADER_FENCED`.
* **Séquencement Continu & Invariant de Contiguïté** : Chaque abonnement dispose d'un flux ordonné (`last_assigned_seq`). Le curseur persistant (`last_persisted_cursor`) ne progresse que si toutes les séquences antérieures sont résolues (`delivered`, `dead_letter` ou `dropped`), interdisant formellement l'apparition de trous.
* **Barrière DLQ Atomique** : Un message épuisant ses retries est transféré dans `event_dead_letter` avant que le curseur ne puisse être avancé.
* **Isolation Multi-Instance & Multi-Tenant** : Chaque livraison et événement transporte son contexte d'isolation (`EventContext` : `tenant_id`, `instance_id`, `environment`).

---

## 🗄️ 3. Modèle de Données SurrealDB 3.2.0

### Tables Déclaratives

| Table | Rôle | Clé / Index Majeurs |
| :--- | :--- | :--- |
| `event_outbox` | Table d'entrée transactionnelle de l'Outbox | `event_id`, `idx_outbox_unprocessed` (`status`, `created_at`) |
| `event_subscription` | Abonnements déclaratifs aux patterns d'événements | `UNIQUE(name)` |
| `event_delivery` | Livraisons unitaires fannées aux abonnements | `UNIQUE(outbox_event, subscription)`, index `(subscription, delivery_seq)` |
| `event_dead_letter` | Quarantaine des messages empoisonnés (DLQ) | `delivery`, `outbox_event`, `exhausted_at` |
| `event_stream_lease` | Verrou distribué de leadership streaming | Record singleton `event_stream_lease:outbox_leader` |
| `event_subscription_progress` | Curseur de progression durable par abonnement | Record déterministe `event_subscription_progress:prog_<sub_id>` |

---

## ⚙️ 4. Fonctions SurrealQL Publiques

Toutes les fonctions respectent la convention `fn::event_<action>` et le contrat de retour universel Lyxal OS (`fn::result_ok` / `fn::error_result`) :

* `fn::event_publish($params)` : Publication atomique dans `event_outbox` et déclenchement du fan-out.
* `fn::event_fanout($params)` : Éclatement idempotent d'un événement vers tous les abonnements correspondants.
* `fn::event_recover_pending_fanouts($params)` : Reprise des événements non encore ventilés après un redémarrage.
* `fn::event_lease_acquire($params)` : Acquisition sous exclusion mutuelle du leadership avec attribution de génération monotone.
* `fn::event_lease_renew($params)` : Renouvellement périodique du bail leader par heartbeat.
* `fn::event_lease_release($params)` : Libération formelle coopérative pour permettre une reprise Zero-Wait.
* `fn::event_delivery_assign_seq($params)` : Attribution atomique d'une séquence contiguë et verrouillage de la livraison sous garde de fencing.
* `fn::event_flush_batch($params)` : Validation granulaire d'un lot de résolutions et avancement contigu du curseur.
* `fn::event_dead_letter_transfer($params)` : Transfert transactionnel d'un message poison en table de quarantaine.
* `fn::event_dead_letter_replay($params)` : Réarmement d'un message en quarantaine pour rejeu métier.
* `fn::event_progress_get($params)` : Lecture de l'état persistant d'avancement d'un abonnement.
* `fn::event_delivery_failure($params)` : Enregistrement canonique d'un échec de traitement avec calcul de retry ou bascule DLQ.
* `fn::event_delivery_success($params)` : Acquittement direct unitaire d'une livraison.
* `fn::event_purge_garbage($params)` : Purge planifiée des événements et livraisons archivés.

---

## 💻 5. Utilisation & Intégration en Rust

### 5.1. Définition d'un Événement de Domaine

```rust
use lyxal_event::Event;
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BookingCreated {
    pub booking_id: String,
    pub customer_email: String,
}

impl Event for BookingCreated {
    const EVENT_TYPE: &'static str = "booking.created";
}
```

### 5.2. Publication d'Événements

```rust
let published = publisher.publish(&BookingCreated {
    booking_id: "book_987".to_string(),
    customer_email: "client@lyxal.com".to_string(),
}).await?;
```

### 5.3. Implémentation d'un Handler Consommateur

```rust
use async_trait::async_trait;
use lyxal_event::{Handler, HandlerContext, LyxalEventError};

pub struct SendConfirmationHandler;

#[async_trait]
impl Handler<BookingCreated> for SendConfirmationHandler {
    async fn handle(&self, event: &BookingCreated, ctx: &HandlerContext) -> Result<(), LyxalEventError> {
        println!("Envoi de l'email à {} pour réservation {}", event.customer_email, event.booking_id);
        Ok(())
    }
}
```

### 5.4. Enregistrement auprès du Runtime (`lyxal_runtime`)

```rust
use lyxal_runtime::event_engine::EventConsumerModule;
use lyxal_event::HandlerRegistry;

impl EventConsumerModule for NotificationModule {
    fn register_event_handlers(&self, registry: &mut HandlerRegistry) -> Result<(), RuntimeError> {
        registry.register(SendConfirmationHandler)?;
        Ok(())
    }
}
```

---

## 📁 6. Structure Canonique du Module

```text
crates/lyxal_event/
├── manifest.toml            <-- Contrat Runtime officiel V1.0.0
├── schema/                  <-- Schémas déclaratifs SurrealDB 3.2.0
├── migrations/              <-- Migrations de persistance et durabilité
├── functions/               <-- Fonctions transactionnelles SurrealQL
├── error/                   <-- Master data d'erreurs (events.surql)
├── src/
│   ├── engine/              <-- Moteur de streaming in-process (Dispatcher, Feeder, Window, Bridge)
│   ├── models/              <-- Modèles de domaine typés (Delivery, Outbox, Subscription, Lease)
│   ├── store/               <-- Interface de persistance SurrealDB (EventStore)
│   ├── worker/              <-- Worker supervisé, supervision du bail, retries
│   └── lib.rs               <-- Façade publique et traits fondamentaux
├── tests/                   <-- Tests unitaires, concurrence, crash recovery, persistance disque
├── docs/                    <-- Documentation détaillée d'architecture et de référence
├── CHANGELOG.md             <-- Historique des versions
├── ROADMAP.md               <-- Feuille de route V2 (Observabilité) & V3 (IA / Fédéré)
└── README.md                <-- Présente documentation
```

---

## 🧪 7. Validation & Robustesse

Le module dispose d'une suite de tests complète validée sous SurrealDB 3.2.0 :
* **50 tests unitaires** (fenêtre de dispatching, backpressure, retries exponentiels, poison drop/DLQ, baux).
* **28 tests d'intégration** (scénarios nominaux, pannes de handlers, timeouts, concurrence, Fencing MVCC, reprise après crash serveur).
* **Validation disque persistant (`surrealkv://`)** : résistance démontrée aux arrêts brutaux `SIGKILL` sans perte ni duplication.

Pour exécuter la suite de tests :
```bash
cargo test -p lyxal_event
cargo clippy -p lyxal_event --all-targets -- -D warnings
```
