//! Sonde administrative indépendante (`admin_probe`)
//! Dédiée à l'audit en lecture hors sessions workers pour valider les commits serveur,
//! l'extinction absolue des baux et les bilans partitionnés.
//! Référence : LOT2_BENCHMARK_IMPLEMENTATION_PLAN.md §4.1, §4.2

use surrealdb::engine::any::Any;
use surrealdb::Surreal;
use serde::Deserialize;

#[derive(Debug, Deserialize, Clone, Default)]
pub struct PartitionCounts {
    pub pending: usize,
    pub processing: usize,
    pub failed: usize,
    pub delivered: usize,
    pub dead_letter: usize,
    pub total_deliveries: usize,
}

#[derive(Debug, Deserialize)]
struct CountRow {
    status: String,
    total: usize,
}

#[derive(Debug, Clone)]
pub struct AdminProbe {
    db: Surreal<Any>,
}

impl AdminProbe {
    pub fn new(db: Surreal<Any>) -> Self {
        Self { db }
    }

    /// Contrôle de commit serveur en vol pour S-09 :
    /// Vérifie si les livraisons attribuées à `worker_id` sont bien persistées en statut `processing`
    pub async fn count_processing_for_worker(&self, worker_id: &str) -> Result<usize, surrealdb::Error> {
        let mut res = self
            .db
            .query("SELECT count() AS total FROM event_delivery WHERE lease_owner = $worker_id AND status = 'processing' GROUP ALL")
            .bind(("worker_id", worker_id.to_string()))
            .await?;

        #[derive(Deserialize)]
        struct TotalRow {
            total: usize,
        }

        let rows: Vec<TotalRow> = res.take(0)?;
        Ok(rows.first().map(|r| r.total).unwrap_or(0))
    }

    /// Relevé de l'échéance maximale de verrouillage encore active (S-12 Phase 5)
    pub async fn get_max_locked_until(&self) -> Result<Option<String>, surrealdb::Error> {
        let mut res = self
            .db
            .query("SELECT locked_until FROM event_delivery WHERE locked_until != NONE ORDER BY locked_until DESC LIMIT 1")
            .await?;

        #[derive(Deserialize)]
        struct LockedRow {
            locked_until: Option<String>,
        }

        let rows: Vec<LockedRow> = res.take(0)?;
        Ok(rows.into_iter().next().and_then(|r| r.locked_until))
    }

    pub async fn audit_max_locked_until(&self) -> Result<Option<String>, surrealdb::Error> {
        self.get_max_locked_until().await
    }

    /// Vérifie qu'aucun bail actif ne subsiste en base (S-12 Phase 5)
    pub async fn count_active_leases(&self) -> Result<usize, surrealdb::Error> {
        let mut res = self
            .db
            .query("SELECT count() AS total FROM event_delivery WHERE locked_until != NONE AND locked_until >= time::now() GROUP ALL")
            .await?;

        #[derive(Deserialize)]
        struct TotalRow {
            total: usize,
        }

        let rows: Vec<TotalRow> = res.take(0)?;
        Ok(rows.first().map(|r| r.total).unwrap_or(0))
    }

    pub async fn audit_active_leases(&self) -> Result<usize, surrealdb::Error> {
        self.count_active_leases().await
    }

    /// Calcule le bilan partitionné complet sur `event_delivery` (S-12 Phase 6)
    pub async fn get_partition_counts(&self) -> Result<PartitionCounts, surrealdb::Error> {
        let mut res = self
            .db
            .query("SELECT status, count() AS total FROM event_delivery GROUP BY status")
            .await?;

        let rows: Vec<CountRow> = res.take(0)?;
        let mut counts = PartitionCounts::default();

        for row in rows {
            match row.status.as_str() {
                "pending" => counts.pending = row.total,
                "processing" => counts.processing = row.total,
                "failed" => counts.failed = row.total,
                "delivered" => counts.delivered = row.total,
                "dead_letter" => counts.dead_letter = row.total,
                _ => {}
            }
        }

        counts.total_deliveries = counts.pending
            + counts.processing
            + counts.failed
            + counts.delivered
            + counts.dead_letter;

        Ok(counts)
    }

    pub async fn audit_balance(&self) -> Result<PartitionCounts, surrealdb::Error> {
        self.get_partition_counts().await
    }

    /// Contrôle de commit serveur pour un lot in-doubt (S-09)
    pub async fn check_in_doubt_committed(
        &self,
        worker_id: &str,
        request_id: &str,
    ) -> Result<bool, surrealdb::Error> {
        let mut res = self
            .db
            .query("SELECT count() AS total FROM event_delivery WHERE lease_owner = $w AND claim_request_id = $r AND status = 'processing' GROUP ALL")
            .bind(("w", worker_id.to_string()))
            .bind(("r", request_id.to_string()))
            .await?;

        #[derive(Deserialize)]
        struct TotalRow {
            total: usize,
        }

        let rows: Vec<TotalRow> = res.take(0)?;
        Ok(rows.first().map(|r| r.total > 0).unwrap_or(false))
    }
}
