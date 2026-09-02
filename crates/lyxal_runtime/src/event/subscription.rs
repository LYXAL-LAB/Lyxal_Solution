use crate::event::event::RuntimeEvent;
use crate::event::filter::RuntimeEventFilter;
use std::fmt;
use tokio::sync::broadcast::error::RecvError;
use tokio::sync::broadcast::Receiver;

/// Erreur de consommation rencontrée par un abonné au flux d'événements.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum SubscriptionError {
    /// Le consommateur a pris du retard et a manqué un certain nombre d'événements dans le buffer circulaire.
    Lagged(u64),
    /// Le bus d'événements a été fermé et ne produira plus aucun message.
    Closed,
}

impl fmt::Display for SubscriptionError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::Lagged(count) => {
                write!(f, "Subscription lagged behind by {} events", count)
            }
            Self::Closed => write!(f, "Subscription channel closed"),
        }
    }
}

impl std::error::Error for SubscriptionError {}

/// Abonnement actif à un flux d'événements filtré du `RuntimeEventBus`.
pub struct RuntimeEventSubscription {
    receiver: Receiver<RuntimeEvent>,
    filter: RuntimeEventFilter,
}

impl RuntimeEventSubscription {
    /// Crée un nouvel abonnement à partir d'un récepteur broadcast et d'un filtre.
    pub fn new(receiver: Receiver<RuntimeEvent>, filter: RuntimeEventFilter) -> Self {
        Self { receiver, filter }
    }

    /// Retourne une référence vers le filtre configuré pour cet abonnement.
    pub fn filter(&self) -> &RuntimeEventFilter {
        &self.filter
    }

    /// Attend et extrait de manière asynchrone le prochain événement satisfaisant le filtre.
    pub async fn recv(&mut self) -> Result<RuntimeEvent, SubscriptionError> {
        loop {
            match self.receiver.recv().await {
                Ok(event) => {
                    if self.filter.matches(&event) {
                        return Ok(event);
                    }
                    // Si l'événement ne correspond pas au filtre, poursuivre l'écoute
                }
                Err(RecvError::Lagged(count)) => {
                    return Err(SubscriptionError::Lagged(count));
                }
                Err(RecvError::Closed) => {
                    return Err(SubscriptionError::Closed);
                }
            }
        }
    }
}
