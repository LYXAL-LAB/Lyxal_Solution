# 🚀 Guide d'Intégration Développeur — `lyxal_event`

Ce guide présente comment intégrer un module métier Lyxal OS en tant que producteur ou consommateur d'événements.

---

## 1. Émission d'Événements (Module Producteur)

Un module producteur (ex: `lyxal_booking`) n'importe **jamais** de dépendances vers ses consommateurs.

### Étape 1 : Définir la Structure de l'Événement
Implémenter le trait `lyxal_event::Event` :
```rust
use lyxal_event::Event;
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct InvoiceIssued {
    pub invoice_id: String,
    pub amount_cents: u64,
    pub customer_id: String,
}

impl Event for InvoiceIssued {
    const EVENT_TYPE: &'static str = "billing.invoice.issued";
}
```

### Étape 2 : Publier via `EventPublisher`
Dans un store ou un service métier :
```rust
pub async fn finalize_invoice(
    store: &Store,
    publisher: &EventPublisher,
    invoice: Invoice,
) -> Result<(), AppError> {
    // 1. Mutation métier principale dans SurrealDB
    store.save_invoice(&invoice).await?;

    // 2. Publication d'événement transactionnelle
    publisher.publish(&InvoiceIssued {
        invoice_id: invoice.id.to_string(),
        amount_cents: invoice.total_cents,
        customer_id: invoice.customer_id,
    }).await?;

    Ok(())
}
```

### Étape 3 : Déclencheur SurrealQL Automatique (`DEFINE EVENT`)
Si l'événement est produit directement par une mutation SQL en base de données :
```surql
DEFINE EVENT IF NOT EXISTS booking_created_event ON TABLE booking WHEN $event = "CREATE" THEN (
    fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: "booking.created",
        producer: "lyxal_booking",
        payload: {
            booking_id: <string> $after.id,
            customer_email: $after.customer_email
        },
        metadata: {}
    })
);
```

---

## 2. Consommation d'Événements (Module Consommateur)

Un module consommateur (ex: `lyxal_notification`) s'abonne aux événements déclarés sans impacter le producteur.

### Étape 1 : Implémenter le `Handler<E>`
```rust
use async_trait::async_trait;
use lyxal_event::{Handler, HandlerContext, LyxalEventError};

pub struct InvoiceNotificationHandler {
    mailer: Arc<MailerService>,
}

#[async_trait]
impl Handler<InvoiceIssued> for InvoiceNotificationHandler {
    async fn handle(&self, event: &InvoiceIssued, ctx: &HandlerContext) -> Result<(), LyxalEventError> {
        // Idempotence : vérifier ctx.delivery_id si nécessaire
        self.mailer.send_invoice_email(&event.customer_id, event.amount_cents).await
            .map_err(|e| LyxalEventError::Handler(format!("Échec de l'envoi email: {e}")))?;
        Ok(())
    }
}
```

### Étape 2 : Déclarer la Souscription au Runtime
Dans l'implémentation de `EventConsumerModule` du module :
```rust
use lyxal_runtime::event_engine::EventConsumerModule;
use lyxal_event::HandlerRegistry;

impl EventConsumerModule for NotificationModule {
    fn register_event_handlers(&self, registry: &mut HandlerRegistry) -> Result<(), RuntimeError> {
        registry.register(InvoiceNotificationHandler { mailer: self.mailer.clone() })?;
        Ok(())
    }
}
```

### Étape 3 : Abonnement Persistant SurrealDB
Déclarer la souscription dans le script de migration ou de seed du module consommateur :
```surql
CREATE event_subscription CONTENT {
    name: "notification_on_invoice_issued",
    target_module: "lyxal_notification",
    event_pattern: "billing.invoice.issued",
    handler_name: "InvoiceNotificationHandler",
    max_attempts: 5,
    is_active: true
};
```

---

## 3. Bonnes Pratiques & Erreurs à Éviter

1. **Idempotence Obligatoire** : Les handlers doivent être idempotents (utiliser `event.invoice_id` ou `ctx.delivery_id`). Le moteur garantit une livraison *At-Least-Once*.
2. **Ne jamais masquer d'erreurs** : Retourner `Err(LyxalEventError::Handler(...))` en cas d'échec transitoire afin d'activer le retry automatique et le backoff exponentiel.
3. **Erreurs Terminales** : Si l'échec n'est pas rejouable (ex: format de payload invalide), remonter une erreur typée pour déclencher la mise en Dead-Letter Queue immédiate sans gaspiller le budget de retries.

