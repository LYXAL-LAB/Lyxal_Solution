use crate::types::ModuleId;
use crate::worker::context::CancellationToken;
use crate::worker::id::WorkerId;
use crate::worker::metrics::WorkerMetrics;
use crate::worker::state::{WorkerExitReason, WorkerState};
use std::sync::atomic::{AtomicU32, AtomicU64, Ordering};
use std::sync::RwLock;
use std::time::SystemTime;
use tokio::task::JoinHandle;

/// Structure de gestion interne et d'encapsulation de l'exécution d'un worker.
pub struct WorkerHandle {
    pub worker_id: WorkerId,
    pub module_id: ModuleId,
    state: RwLock<WorkerState>,
    cancellation: RwLock<CancellationToken>,
    join_handle: RwLock<Option<JoinHandle<()>>>,
    metrics: RwLock<WorkerMetrics>,
    last_exit_reason: RwLock<Option<WorkerExitReason>>,
    generation: AtomicU64,
    restart_attempts: AtomicU32,
}

impl WorkerHandle {
    /// Crée un nouveau handle initialisé à l'état `Registered`.
    pub fn new(worker_id: WorkerId, module_id: ModuleId) -> Self {
        Self {
            worker_id,
            module_id,
            state: RwLock::new(WorkerState::Registered),
            cancellation: RwLock::new(CancellationToken::new()),
            join_handle: RwLock::new(None),
            metrics: RwLock::new(WorkerMetrics::default()),
            last_exit_reason: RwLock::new(None),
            generation: AtomicU64::new(1),
            restart_attempts: AtomicU32::new(0),
        }
    }

    /// Retourne l'époque/génération actuelle du handle.
    pub fn generation(&self) -> u64 {
        self.generation.load(Ordering::SeqCst)
    }

    /// Incrémente et retourne la nouvelle génération (invalidation des tâches/timers antérieurs).
    pub fn next_generation(&self) -> u64 {
        self.generation.fetch_add(1, Ordering::SeqCst) + 1
    }

    /// Retourne l'état courant du worker.
    pub fn state(&self) -> WorkerState {
        self.state.read().map(|s| *s).unwrap_or(WorkerState::Failed)
    }

    /// Met à jour l'état courant du worker.
    pub fn set_state(&self, new_state: WorkerState) {
        if let Ok(mut lock) = self.state.write() {
            *lock = new_state;
        }
    }

    /// Retourne le jeton d'annulation actif.
    pub fn cancellation_token(&self) -> CancellationToken {
        self.cancellation
            .read()
            .map(|t| t.clone())
            .unwrap_or_else(|_| CancellationToken::new())
    }

    /// Réinitialise le jeton d'annulation pour une nouvelle exécution.
    pub fn renew_cancellation(&self) -> CancellationToken {
        let new_token = CancellationToken::new();
        if let Ok(mut lock) = self.cancellation.write() {
            *lock = new_token.clone();
        }
        new_token
    }

    /// Annule le jeton actif.
    pub fn cancel(&self) {
        if let Ok(lock) = self.cancellation.read() {
            lock.cancel();
        }
    }

    /// Associe la `JoinHandle` de la tâche Tokio en cours d'exécution.
    pub fn set_join_handle(&self, handle: JoinHandle<()>) {
        if let Ok(mut lock) = self.join_handle.write() {
            *lock = Some(handle);
        }
    }

    /// Extrait la `JoinHandle` active (si présente).
    pub fn take_join_handle(&self) -> Option<JoinHandle<()>> {
        let mut lock = self.join_handle.write().ok()?;
        lock.take()
    }

    /// Retourne le nombre de tentatives de redémarrage consécutives.
    pub fn restart_attempts(&self) -> u32 {
        self.restart_attempts.load(Ordering::SeqCst)
    }

    /// Incrémente et retourne le compteur de redémarrages.
    pub fn increment_restart_attempts(&self) -> u32 {
        let prev = self.restart_attempts.fetch_add(1, Ordering::SeqCst);
        if let Ok(mut m) = self.metrics.write() {
            m.restart_count += 1;
        }
        prev + 1
    }

    /// Réinitialise le compteur de redémarrages consécutifs à 0 (après stabilisation).
    pub fn reset_restart_attempts(&self) {
        self.restart_attempts.store(0, Ordering::SeqCst);
    }

    /// Enregistre le timestamp de démarrage dans les métriques.
    pub fn record_started(&self) {
        let now = SystemTime::now()
            .duration_since(SystemTime::UNIX_EPOCH)
            .unwrap_or_default()
            .as_secs();
        if let Ok(mut m) = self.metrics.write() {
            m.started_at = Some(now);
        }
    }

    /// Enregistre le timestamp d'arrêt dans les métriques.
    pub fn record_stopped(&self) {
        let now = SystemTime::now()
            .duration_since(SystemTime::UNIX_EPOCH)
            .unwrap_or_default()
            .as_secs();
        if let Ok(mut m) = self.metrics.write() {
            m.stopped_at = Some(now);
        }
    }

    /// Enregistre une sortie de worker (raison, métriques, échec éventuel).
    pub fn record_exit(&self, reason: WorkerExitReason) {
        let now = SystemTime::now()
            .duration_since(SystemTime::UNIX_EPOCH)
            .unwrap_or_default()
            .as_secs();

        if let Ok(mut m) = self.metrics.write() {
            if reason.is_failure() {
                m.failure_count += 1;
                m.last_failure_at = Some(now);
                m.last_error = match &reason {
                    WorkerExitReason::Failed(err) => Some(err.clone()),
                    WorkerExitReason::Panicked(err) => Some(format!("Panicked: {}", err)),
                    WorkerExitReason::ForcedAbort => {
                        Some("Forcibly aborted after shutdown timeout".to_string())
                    }
                    _ => None,
                };
            }
        }

        if let Ok(mut r) = self.last_exit_reason.write() {
            *r = Some(reason);
        }
    }

    /// Retourne la dernière raison de sortie enregistrée.
    pub fn last_exit_reason(&self) -> Option<WorkerExitReason> {
        self.last_exit_reason.read().ok()?.clone()
    }

    /// Retourne un instantané des métriques du worker.
    pub fn metrics(&self) -> WorkerMetrics {
        self.metrics.read().map(|m| m.clone()).unwrap_or_default()
    }
}
