use crate::error::LyxalEventError;
use crate::store::EventStore;
use std::sync::Arc;
use std::time::Duration;
use tokio_util::sync::CancellationToken;
use tracing::{debug, info, warn};

/// Tâche de fond périodique de nettoyage (Garbage Collector) des événements archivés.
pub struct GarbageCollector {
    store: Arc<EventStore>,
    retention_days: u32,
    interval: Duration,
}

impl GarbageCollector {
    /// Crée un nouveau GarbageCollector.
    #[must_use]
    pub fn new(store: Arc<EventStore>, retention_days: u32, interval: Duration) -> Self {
        Self {
            store,
            retention_days,
            interval,
        }
    }

    /// Démarre la boucle périodique de nettoyage jusqu'à signal d'annulation.
    pub async fn run(&self, cancel: CancellationToken) -> Result<(), LyxalEventError> {
        info!(
            retention_days = self.retention_days,
            interval = ?self.interval,
            "Lyxal Event Garbage Collector started"
        );

        while !cancel.is_cancelled() {
            tokio::select! {
                () = tokio::time::sleep(self.interval) => {
                    debug!("Running event garbage collection purge");
                    if let Err(e) = self.store.purge_garbage(self.retention_days).await {
                        warn!(error = ?e, "Garbage collection purge encountered an error");
                    }
                }
                () = cancel.cancelled() => break,
            }
        }

        info!("Lyxal Event Garbage Collector stopped");
        Ok(())
    }
}
