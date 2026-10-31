//! Intercepteur / Simulateur de coupure réseau contrôlée (In-Doubt S-09)
//! Permet d'injecter une rupture socket TCP délibérée immédiatement après commit serveur.
//! Référence : LOT2_BENCHMARK_IMPLEMENTATION_PLAN.md §4.2

use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Arc;

#[derive(Debug, Clone, Default)]
pub struct TcpDropInterceptor {
    drop_next_response: Arc<AtomicBool>,
    dropped_count: Arc<std::sync::atomic::AtomicUsize>,
}

impl TcpDropInterceptor {
    pub fn new() -> Self {
        Self {
            drop_next_response: Arc::new(AtomicBool::new(false)),
            dropped_count: Arc::new(std::sync::atomic::AtomicUsize::new(0)),
        }
    }

    /// Arme l'intercepteur pour simuler une rupture de socket sur la prochaine réponse
    pub fn arm_drop(&self) {
        self.drop_next_response.store(true, Ordering::SeqCst);
    }

    /// Vérifie et consomme l'armement (déclenche la simulation de coupure)
    pub fn should_drop(&self) -> bool {
        if self.drop_next_response.swap(false, Ordering::SeqCst) {
            self.dropped_count.fetch_add(1, Ordering::SeqCst);
            true
        } else {
            false
        }
    }

    /// Nombre de coupures simulées avec succès
    pub fn total_dropped(&self) -> usize {
        self.dropped_count.load(Ordering::SeqCst)
    }

    /// Réinitialise l'intercepteur
    pub fn reset(&self) {
        self.drop_next_response.store(false, Ordering::SeqCst);
        self.dropped_count.store(0, Ordering::SeqCst);
    }
}

