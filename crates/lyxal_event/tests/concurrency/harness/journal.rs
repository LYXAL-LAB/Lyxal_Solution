//! Journal d'audit immuable en mémoire (append-only) pour le calcul de $\mathcal{D}_{\text{sim}}$ et $\mathcal{M}_{\text{rejet}}$
//! Référence : LOT2_CONCURRENCY_PROTOCOL_PROPOSAL.md §9 & LOT2_BENCHMARK_IMPLEMENTATION_PLAN.md §2.1

use std::sync::{Arc, Mutex};
use std::time::SystemTime;

#[derive(Debug, Clone)]
pub struct ClaimInterval {
    pub delivery_id: String,
    pub claim_nonce: String,
    pub lease_owner: String,
    pub t_claim: SystemTime,
    pub t_locked_until: SystemTime,
    pub t_complete: Option<SystemTime>,
}

#[derive(Debug, Clone)]
pub struct ZombieAttempt {
    pub delivery_id: String,
    pub presented_nonce: String,
    pub worker_id: String,
    pub mutation_type: String, // "success", "failure_retry", "failure_dlq"
    pub rejected: bool,
    pub timestamp: SystemTime,
}

#[derive(Debug, Default, Clone)]
pub struct ImmutableAuditJournal {
    claims: Arc<Mutex<Vec<ClaimInterval>>>,
    zombie_attempts: Arc<Mutex<Vec<ZombieAttempt>>>,
}

pub type AuditJournal = ImmutableAuditJournal;

impl ImmutableAuditJournal {
    pub fn new() -> Self {
        Self {
            claims: Arc::new(Mutex::new(Vec::new())),
            zombie_attempts: Arc::new(Mutex::new(Vec::new())),
        }
    }

    /// Enregistre une acquisition légitime (Groupe A)
    pub fn record_claim(
        &self,
        delivery_id: impl Into<String>,
        claim_nonce: impl Into<String>,
        lease_owner: impl Into<String>,
        t_claim: SystemTime,
        t_locked_until: SystemTime,
    ) {
        let mut claims = self.claims.lock().unwrap();
        claims.push(ClaimInterval {
            delivery_id: delivery_id.into(),
            claim_nonce: claim_nonce.into(),
            lease_owner: lease_owner.into(),
            t_claim,
            t_locked_until,
            t_complete: None,
        });
    }

    /// Enregistre la complétion normale d'une livraison (Groupe B)
    pub fn record_completion(
        &self,
        delivery_id: impl Into<String>,
        claim_nonce: impl Into<String>,
        t_complete: SystemTime,
    ) {
        let del_id = delivery_id.into();
        let nonce = claim_nonce.into();
        let mut claims = self.claims.lock().unwrap();

        if let Some(claim) = claims
            .iter_mut()
            .rfind(|c| c.delivery_id == del_id && c.claim_nonce == nonce)
        {
            claim.t_complete = Some(t_complete);
        }
    }

    /// Enregistre une tentative de mutation (zombie ou normale)
    pub fn record_zombie_attempt(
        &self,
        delivery_id: impl Into<String>,
        presented_nonce: impl Into<String>,
        worker_id: impl Into<String>,
        mutation_type: impl Into<String>,
        rejected: bool,
    ) {
        let mut attempts = self.zombie_attempts.lock().unwrap();
        attempts.push(ZombieAttempt {
            delivery_id: delivery_id.into(),
            presented_nonce: presented_nonce.into(),
            worker_id: worker_id.into(),
            mutation_type: mutation_type.into(),
            rejected,
            timestamp: SystemTime::now(),
        });
    }

    /// Calcule le nombre total de doubles détentions simultanées $\mathcal{D}_{\text{sim}}$
    pub fn compute_dsim(&self) -> usize {
        let claims = self.claims.lock().unwrap();
        let mut collisions = 0;

        for i in 0..claims.len() {
            for j in (i + 1)..claims.len() {
                let c1 = &claims[i];
                let c2 = &claims[j];

                // Même livraison physique
                if c1.delivery_id == c2.delivery_id {
                    let end1 = c1.t_complete.unwrap_or(c1.t_locked_until);
                    let end2 = c2.t_complete.unwrap_or(c2.t_locked_until);

                    // Chevauchement d'intervalles fermés [start, end]
                    let overlap = c1.t_claim <= end2 && c2.t_claim <= end1;
                    if overlap {
                        collisions += 1;
                    }
                }
            }
        }

        collisions
    }

    /// Calcule le taux d'efficacité de rejet des mutations zombies $\mathcal{M}_{\text{rejet}}$ en pourcentage
    pub fn compute_m_rejet(&self) -> f64 {
        let attempts = self.zombie_attempts.lock().unwrap();
        if attempts.is_empty() {
            100.0
        } else {
            let rejected_count = attempts.iter().filter(|a| a.rejected).count();
            ((rejected_count as f64) / (attempts.len() as f64)) * 100.0
        }
    }

    /// Total des tentatives zombies enregistrées
    pub fn zombie_attempts_count(&self) -> usize {
        self.zombie_attempts.lock().unwrap().len()
    }
}
