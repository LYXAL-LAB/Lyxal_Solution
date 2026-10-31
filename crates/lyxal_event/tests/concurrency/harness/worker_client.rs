//! Client worker simulé pour le banc de concurrence
//! Pilote les requêtes de claim, la réconciliation et l'acquittement avec traçabilité.
//! Référence : LOT2_BENCHMARK_IMPLEMENTATION_PLAN.md §2.1, §4.2

use surrealdb::engine::any::Any;
use surrealdb::Surreal;
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::Arc;
use std::time::SystemTime;
use serde::{Deserialize, Serialize};
use super::journal::ImmutableAuditJournal;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ClaimedItem {
    pub id: surrealdb::sql::Thing,
    #[serde(default)]
    pub claim_nonce: Option<String>,
    #[serde(default)]
    pub lease_owner: Option<String>,
    #[serde(default)]
    pub locked_until: Option<String>,
    #[serde(default)]
    pub claim_request_id: Option<String>,
}

pub struct ClaimBatchParams {
    pub subscription_id: String,
    pub batch_size: usize,
    pub lease_duration_ms: u64,
    pub claim_request_id: String,
}

pub struct DeliverySuccessParams {
    pub delivery_id: String,
    pub claim_nonce: Option<String>,
}

pub struct DeliveryFailureParams {
    pub delivery_id: String,
    pub claim_nonce: Option<String>,
    pub error_code: String,
    pub retry_after_ms: u64,
}

pub struct DeadLetterParams {
    pub delivery_id: String,
    pub claim_nonce: Option<String>,
    pub reason: String,
}

pub struct LeaseRenewParams {
    pub delivery_id: String,
    pub claim_nonce: Option<String>,
    pub extend_by_ms: u64,
}

#[derive(Debug, Clone)]
pub struct BenchWorkerClient {
    pub worker_id: String,
    db: Surreal<Any>,
    journal: ImmutableAuditJournal,
    pub claims_count: Arc<AtomicUsize>,
    pub completions_count: Arc<AtomicUsize>,
    pub rejected_count: Arc<AtomicUsize>,
    pub mvcc_conflicts_count: Arc<AtomicUsize>,
}

impl BenchWorkerClient {
    pub fn new(db: Surreal<Any>, worker_id: impl Into<String>, journal: ImmutableAuditJournal) -> Self {
        Self {
            worker_id: worker_id.into(),
            db,
            journal,
            claims_count: Arc::new(AtomicUsize::new(0)),
            completions_count: Arc::new(AtomicUsize::new(0)),
            rejected_count: Arc::new(AtomicUsize::new(0)),
            mvcc_conflicts_count: Arc::new(AtomicUsize::new(0)),
        }
    }

    /// Exécute un claim atomique avec Option B unifiée
    pub async fn claim_batch(
        &self,
        params: ClaimBatchParams,
    ) -> Result<Vec<ClaimedItem>, surrealdb::Error> {
        let t_claim = SystemTime::now();
        let lease_seconds = params.lease_duration_ms.div_ceil(1000);
        let t_locked_until = t_claim + std::time::Duration::from_millis(params.lease_duration_ms);

        let query = format!(
            "UPDATE (\
                SELECT VALUE id FROM event_delivery \
                WHERE ( \
                    (status = 'pending' AND (next_retry_at == NONE OR next_retry_at <= time::now())) \
                    OR (status = 'failed' AND (next_retry_at == NONE OR next_retry_at <= time::now())) \
                    OR (status = 'processing' AND locked_until != NONE AND locked_until < time::now()) \
                ) \
                ORDER BY next_retry_at ASC \
                LIMIT {} \
            ) \
            SET status = 'processing', \
                locked_until = time::now() + {}s, \
                lease_owner = '{}', \
                claim_nonce = rand::uuid::v7(), \
                claim_request_id = '{}', \
                attempts = attempts + 1 \
            WHERE ( \
                (status = 'pending' AND (next_retry_at == NONE OR next_retry_at <= time::now())) \
                OR (status = 'failed' AND (next_retry_at == NONE OR next_retry_at <= time::now())) \
                OR (status = 'processing' AND locked_until != NONE AND locked_until < time::now()) \
            ) \
            RETURN AFTER;",
            params.batch_size,
            lease_seconds.max(1),
            self.worker_id,
            params.claim_request_id,
        );

        match self.db.query(&query).await {
            Ok(mut res) => {
                let items: Vec<ClaimedItem> = res.take(0)?;
                self.claims_count.fetch_add(items.len(), Ordering::SeqCst);

                // Enregistrement dans le journal d'audit immuable
                for item in &items {
                    let nonce = item.claim_nonce.clone().unwrap_or_else(|| "none".to_string());
                    self.journal.record_claim(
                        item.id.to_string(),
                        nonce,
                        self.worker_id.clone(),
                        t_claim,
                        t_locked_until,
                    );
                }

                Ok(items)
            }
            Err(e) => {
                let err_str = e.to_string();
                if err_str.contains("conflict") || err_str.contains("Transaction") {
                    self.mvcc_conflicts_count.fetch_add(1, Ordering::SeqCst);
                }
                Err(e)
            }
        }
    }

    /// Réconciliation S-09 Run A : recherche globale par `worker_id` seul
    pub async fn reconcile_in_doubt_naive(&self) -> Result<Vec<ClaimedItem>, surrealdb::Error> {
        let mut res = self
            .db
            .query("SELECT * FROM event_delivery WHERE lease_owner = $worker_id AND status = 'processing' AND locked_until >= time::now()")
            .bind(("worker_id", self.worker_id.clone()))
            .await?;

        let items: Vec<ClaimedItem> = res.take(0)?;
        Ok(items)
    }

    /// Réconciliation S-09 Run B : recherche ciblée par `claim_request_id`
    pub async fn reconcile_in_doubt(&self, request_id: &str) -> Result<Vec<ClaimedItem>, surrealdb::Error> {
        let mut res = self
            .db
            .query("SELECT * FROM event_delivery WHERE claim_request_id = $request_id AND lease_owner = $worker_id AND status = 'processing' AND locked_until >= time::now()")
            .bind(("request_id", request_id.to_string()))
            .bind(("worker_id", self.worker_id.clone()))
            .await?;

        let items: Vec<ClaimedItem> = res.take(0)?;
        Ok(items)
    }

    /// Acquittement succès protégé (Groupe B)
    pub async fn delivery_success(
        &self,
        params: DeliverySuccessParams,
    ) -> Result<bool, surrealdb::Error> {
        let nonce = params.claim_nonce.as_deref().unwrap_or("");
        let query = format!(
            "UPDATE {} SET status = 'delivered', delivered_at = time::now(), locked_until = NONE \
            WHERE id = {} \
              AND claim_nonce = '{}' \
              AND lease_owner = '{}' \
              AND status = 'processing' \
              AND locked_until >= time::now() \
            RETURN AFTER;",
            params.delivery_id, params.delivery_id, nonce, self.worker_id
        );

        let mut res = self.db.query(&query).await?;
        let updated: Vec<ClaimedItem> = res.take(0)?;
        let success = !updated.is_empty();

        if success {
            self.completions_count.fetch_add(1, Ordering::SeqCst);
            self.journal.record_completion(params.delivery_id, nonce, SystemTime::now());
        } else {
            self.rejected_count.fetch_add(1, Ordering::SeqCst);
            self.journal.record_zombie_attempt(params.delivery_id, nonce, self.worker_id.clone(), "success", true);
        }

        Ok(success)
    }

    /// Échec protégé avec transition retry (Groupe B)
    pub async fn delivery_failure(
        &self,
        params: DeliveryFailureParams,
    ) -> Result<bool, surrealdb::Error> {
        let nonce = params.claim_nonce.as_deref().unwrap_or("");
        let delay_sec = params.retry_after_ms.div_ceil(1000);
        let query = format!(
            "UPDATE {} SET status = 'failed', locked_until = NONE, next_retry_at = time::now() + <duration> string::concat($delay, 's') \
            WHERE id = {} \
              AND claim_nonce = '{}' \
              AND lease_owner = '{}' \
              AND status = 'processing' \
              AND locked_until >= time::now() \
            RETURN AFTER;",
            params.delivery_id, params.delivery_id, nonce, self.worker_id
        );

        let mut res = self.db.query(&query).bind(("delay", delay_sec.max(1))).await?;
        let updated: Vec<ClaimedItem> = res.take(0)?;
        let success = !updated.is_empty();

        if success {
            self.completions_count.fetch_add(1, Ordering::SeqCst);
            self.journal.record_completion(params.delivery_id, nonce, SystemTime::now());
        } else {
            self.rejected_count.fetch_add(1, Ordering::SeqCst);
            self.journal.record_zombie_attempt(params.delivery_id, nonce, self.worker_id.clone(), "failure", true);
        }

        Ok(success)
    }

    /// Envoi en dead-letter protégé (Groupe B)
    pub async fn dead_letter(
        &self,
        params: DeadLetterParams,
    ) -> Result<bool, surrealdb::Error> {
        let nonce = params.claim_nonce.as_deref().unwrap_or("");
        let query = format!(
            "UPDATE {} SET status = 'dead_letter', locked_until = NONE \
            WHERE id = {} \
              AND claim_nonce = '{}' \
              AND lease_owner = '{}' \
              AND status = 'processing' \
              AND locked_until >= time::now() \
            RETURN AFTER;",
            params.delivery_id, params.delivery_id, nonce, self.worker_id
        );

        let mut res = self.db.query(&query).await?;
        let updated: Vec<ClaimedItem> = res.take(0)?;
        let success = !updated.is_empty();

        if success {
            self.completions_count.fetch_add(1, Ordering::SeqCst);
            self.journal.record_completion(params.delivery_id, nonce, SystemTime::now());
        } else {
            self.rejected_count.fetch_add(1, Ordering::SeqCst);
            self.journal.record_zombie_attempt(params.delivery_id, nonce, self.worker_id.clone(), "dead_letter", true);
        }

        Ok(success)
    }

    /// Renouvellement de bail protégé (Groupe B)
    pub async fn lease_renew(
        &self,
        params: LeaseRenewParams,
    ) -> Result<bool, surrealdb::Error> {
        let nonce = params.claim_nonce.as_deref().unwrap_or("");
        let extend_sec = params.extend_by_ms.div_ceil(1000);
        let query = format!(
            "UPDATE {} SET locked_until = time::now() + {}s \
            WHERE id = {} \
              AND claim_nonce = '{}' \
              AND lease_owner = '{}' \
              AND status = 'processing' \
              AND locked_until >= time::now() \
            RETURN AFTER;",
            params.delivery_id, extend_sec.max(1), params.delivery_id, nonce, self.worker_id
        );

        let mut res = self.db.query(&query).await?;
        let updated: Vec<ClaimedItem> = res.take(0)?;
        let success = !updated.is_empty();

        if !success {
            self.rejected_count.fetch_add(1, Ordering::SeqCst);
            self.journal.record_zombie_attempt(params.delivery_id, nonce, self.worker_id.clone(), "renew", true);
        }

        Ok(success)
    }
}
