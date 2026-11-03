# Guide d'intégration — `lyxal_event`

Comment un module Lyxal OS publie ou consomme des événements. Un producteur ne connaît jamais
ses consommateurs (`.agents/AGENTS.md` §5.6.1) : il ne les importe pas et ne les déclare pas
en dépendance.

---

## 1. Publier un événement

### 1.1. Depuis Rust

Définir l'événement :

```rust
use lyxal_event::Event;
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct InvoiceIssued {
    pub invoice_id: String,
    pub amount_cents: u64,
}

impl Event for InvoiceIssued {
    const EVENT_TYPE: &'static str = "billing.invoice.issued";
}
```

Le publier avec `EventPublisher` (module producteur et contexte d'instance fixés à la
construction) :

```rust
use lyxal_event::{EventContext, EventPublisher, EventStore};
use std::sync::Arc;

let publisher = EventPublisher::new(
    Arc::new(EventStore::new(client)),
    "lyxal_billing",
    EventContext::new("instance_1", "lyxal", "main"),
);
publisher
    .publish(&InvoiceIssued { invoice_id: "inv_1".into(), amount_cents: 1200 })
    .await?;
```

`publish_with_context` propage en plus `correlation_id`, `causation_id` et `source`.

### 1.2. Depuis une mutation SurrealDB (`DEFINE EVENT`)

Un `DEFINE EVENT` ne fait que publier : il n'écrit dans aucune table d'un autre module et
n'appelle aucun service externe. Il **vérifie le résultat** de `fn::event_publish` et lève une
erreur en cas d'échec, pour annuler la mutation d'origine plutôt que de perdre l'événement :

```surql
DEFINE EVENT OVERWRITE invoice_issued_event ON TABLE billing_invoice
WHEN $event = "UPDATE" AND $after.status = "issued" AND $before.status != "issued"
THEN {
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: "billing.invoice.issued",
        producer: "lyxal_billing",
        source: $after.id,
        payload: { invoice_id: <string> $after.id, amount_cents: $after.amount_cents },
        metadata: {}
    });
    IF !$published.ok {
        THROW $published.error.code;
    };
};
```

---

## 2. Consommer un événement

### 2.1. Écrire le handler

```rust
use async_trait::async_trait;
use lyxal_event::{Handler, HandlerContext, LyxalEventError};

pub struct InvoiceMailer { /* … */ }

#[async_trait]
impl Handler<InvoiceIssued> for InvoiceMailer {
    async fn handle(&self, event: InvoiceIssued, ctx: &HandlerContext) -> Result<(), LyxalEventError> {
        // Clé d'idempotence : la livraison peut être reçue plusieurs fois
        let key = format!("invoice_mail:{}", ctx.event_id.0);
        self.send_once(&key, &event).await.map_err(|e| LyxalEventError::HandlerFailed {
            event_id: ctx.event_id.0,
            event_type: "billing.invoice.issued".into(),
            error: e.to_string(),
            terminal: e.is_permanent(),
        })
    }
}
```

* **Idempotence obligatoire** : la livraison est garantie *au moins une fois*. Dédupliquer par
  `ctx.event_id`, `ctx.delivery_id` ou une clé métier.
* **Erreurs** : ne jamais masquer un échec. `terminal: false` déclenche un nouvel essai avec
  backoff ; `terminal: true` envoie directement la livraison en dead letter (échec non
  rejouable, par exemple une donnée invalide).
* **Annulation** : un handler long surveille `ctx.cancellation` ; il est interrompu à la perte
  du bail ou à l'arrêt du worker, et au-delà de `dispatch_timeout`.
* `ctx.attempt` donne le numéro de l'essai en cours.

### 2.2. Déclarer le handler au runtime

```rust
use lyxal_event::HandlerRegistry;
use lyxal_runtime::{EventConsumerModule, RuntimeError};

impl EventConsumerModule for BillingMailModule {
    fn register_event_handlers(&self, registry: &mut HandlerRegistry) -> Result<(), RuntimeError> {
        registry
            .register::<InvoiceIssued, _>(InvoiceMailer { /* … */ })
            .map_err(|e| RuntimeError::EventEngineError { message: e.to_string() })?;
        Ok(())
    }
}
```

Un type d'événement ne peut avoir qu'un handler par registre.

### 2.3. Déclarer l'abonnement persistant

Sans abonnement, le fan-out ne crée aucune livraison. Le module consommateur déclare le sien
dans ses seeds, sans écraser un abonnement déjà réglé :

```surql
IF array::len(SELECT id FROM event_subscription WHERE name = "billing_mail_on_invoice_issued") == 0 {
    LET $registered = fn::event_subscription_register({
        name: "billing_mail_on_invoice_issued",
        target_module: "lyxal_billing_mail",
        event_pattern: "billing.invoice.issued",
        handler_name: "InvoiceMailer",
        max_attempts: 5
    });
    IF !$registered.ok {
        THROW $registered.error.code;
    };
};
```

* `event_pattern` : type exact, préfixe (`billing.*`) ou `*`.
* `max_attempts` : nombre d'envois d'une livraison avant dead letter (1 à 100).
* Une livraison n'est créée que pour les événements publiés **après** l'enregistrement de
  l'abonnement.

---

## 3. Exploiter

* **Dead letters** : `fn::event_dead_letter_list` les liste ; `fn::event_dead_letter_replay`
  rejoue une livraison une fois la cause corrigée.
* **Purge** : `fn::event_purge_garbage({ retention_days })`, ou le service
  `EventGarbageCollectorService` du runtime.
* **Métriques** : `EventWorker::metrics()` (livraisons envoyées, acquittées, en échec, en dead
  letter ; prises et pertes de bail ; conflits de fencing).

Référence complète des fonctions et des codes d'erreur : [`SURREALQL_API.md`](SURREALQL_API.md).
