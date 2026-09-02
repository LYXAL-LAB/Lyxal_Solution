use crate::error::RuntimeError;
use crate::event::event::{RuntimeEvent, RuntimeEventDraft};
use crate::event::filter::RuntimeEventFilter;
use crate::event::id::RuntimeEventId;
use crate::event::journal::RuntimeEventJournal;
use crate::event::stats::RuntimeEventBusStats;
use crate::event::subscription::RuntimeEventSubscription;
use crate::lock::node_id::NodeId;
use async_trait::async_trait;
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::{Arc, RwLock};
use std::time::SystemTime;
use tokio::sync::broadcast;
use tokio::sync::mpsc::{self, error::TrySendError};

/// Contrat du bus d'événements interne du Runtime.
#[async_trait]
pub trait RuntimeEventBus: Send + Sync {
    /// Publie un brouillon d'événement.
    ///
    /// Le bus lui attribue son identifiant unique, sa séquence monotone node-locale,
    /// son horodatage et son `node_id`.
    async fn publish(&self, draft: RuntimeEventDraft) -> Result<RuntimeEvent, RuntimeError>;

    /// Crée un nouvel abonnement filtré au flux d'événements.
    fn subscribe(&self, filter: RuntimeEventFilter) -> RuntimeEventSubscription;

    /// Retourne un instantané des statistiques opérationnelles du bus.
    fn stats(&self) -> RuntimeEventBusStats;
}

/// Implémentation officielle en mémoire vive du bus d'événements du Runtime.
///
/// Elle s'appuie sur `tokio::sync::broadcast` pour la diffusion multi-abonnés non bloquante,
/// un séquenceur atomique local et une file bornée asynchrone dédiée pour la journalisation.
pub struct MemoryRuntimeEventBus {
    node_id: NodeId,
    sequence: AtomicU64,
    broadcast_tx: broadcast::Sender<RuntimeEvent>,
    journal_tx: Option<mpsc::Sender<RuntimeEvent>>,
    stats: Arc<RwLock<RuntimeEventBusStats>>,
}

impl MemoryRuntimeEventBus {
    /// Capacité par défaut du canal de diffusion broadcast.
    pub const DEFAULT_BROADCAST_CAPACITY: usize = 2048;
    /// Capacité par défaut de la file bornée de journalisation asynchrone.
    pub const DEFAULT_JOURNAL_QUEUE_CAPACITY: usize = 4096;

    /// Crée une nouvelle instance du bus d'événements pour le nœud spécifié.
    pub fn new(node_id: NodeId) -> Self {
        Self::with_capacity(node_id, Self::DEFAULT_BROADCAST_CAPACITY)
    }

    /// Crée une instance avec une capacité de diffusion broadcast personnalisée.
    pub fn with_capacity(node_id: NodeId, broadcast_capacity: usize) -> Self {
        let (broadcast_tx, _) = broadcast::channel(broadcast_capacity.max(16));
        Self {
            node_id,
            sequence: AtomicU64::new(0),
            broadcast_tx,
            journal_tx: None,
            stats: Arc::new(RwLock::new(RuntimeEventBusStats::default())),
        }
    }

    /// Attache un journal d'événements persistant ou mémoire avec un worker de fond dédié et borné.
    pub fn with_journal(mut self, journal: Arc<dyn RuntimeEventJournal>) -> Self {
        let (tx, mut rx) = mpsc::channel::<RuntimeEvent>(Self::DEFAULT_JOURNAL_QUEUE_CAPACITY);
        let stats_clone = self.stats.clone();

        tokio::spawn(async move {
            while let Some(event) = rx.recv().await {
                if let Err(_err) = journal.append(&event).await {
                    if let Ok(mut stats) = stats_clone.write() {
                        stats.journal_failures += 1;
                    }
                }
            }
        });

        self.journal_tx = Some(tx);
        self
    }
}

#[async_trait]
impl RuntimeEventBus for MemoryRuntimeEventBus {
    async fn publish(&self, draft: RuntimeEventDraft) -> Result<RuntimeEvent, RuntimeError> {
        let seq = self.sequence.fetch_add(1, Ordering::SeqCst) + 1;
        let event_id = RuntimeEventId::generate();
        let now_ms = SystemTime::now()
            .duration_since(SystemTime::UNIX_EPOCH)
            .unwrap_or_default()
            .as_millis() as u64;

        let event = RuntimeEvent {
            id: event_id,
            sequence: seq,
            node_id: self.node_id.clone(),
            timestamp_ms: now_ms,
            kind: draft.kind,
            module_id: draft.module_id,
            correlation_id: draft.correlation_id,
            causation_id: draft.causation_id,
            payload: draft.payload,
        };

        // Diffusion non bloquante vers les abonnés locaux
        // Si aucun récepteur n'est actuellement abonné, SendError est ignoré gracieusement.
        let _ = self.broadcast_tx.send(event.clone());

        if let Ok(mut stats) = self.stats.write() {
            stats.published += 1;
        }

        // Journalisation asynchrone bornée si configurée
        if let Some(journal_tx) = &self.journal_tx {
            match journal_tx.try_send(event.clone()) {
                Ok(()) => {}
                Err(TrySendError::Full(_)) => {
                    // La file du journal est saturée : incrémenter les compteurs sans bloquer le producteur
                    if let Ok(mut stats) = self.stats.write() {
                        stats.journal_dropped += 1;
                        stats.journal_failures += 1;
                    }
                }
                Err(TrySendError::Closed(_)) => {
                    if let Ok(mut stats) = self.stats.write() {
                        stats.journal_failures += 1;
                    }
                }
            }
        }

        Ok(event)
    }

    fn subscribe(&self, filter: RuntimeEventFilter) -> RuntimeEventSubscription {
        let rx = self.broadcast_tx.subscribe();
        RuntimeEventSubscription::new(rx, filter)
    }

    fn stats(&self) -> RuntimeEventBusStats {
        self.stats.read().map(|s| s.clone()).unwrap_or_default()
    }
}
