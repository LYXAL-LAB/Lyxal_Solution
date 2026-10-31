//! Générateur de fixtures reproductibles pour le banc de concurrence
//! Assure l'injection contrôlée, le fan-out et la remise à zéro étanche de l'état.
//! Référence : LOT2_BENCHMARK_IMPLEMENTATION_PLAN.md §2.1, §4.1, §4.2

use surrealdb::engine::any::Any;
use surrealdb::Surreal;
use std::sync::Arc;
use serde::Deserialize;
use lyxal_event::prelude::*;

pub fn generate_sub_id() -> String {
    format!("sub_{}", uuid::Uuid::now_v7())
}

pub async fn create_test_db() -> Result<Surreal<Any>, surrealdb::Error> {
    let db = surrealdb::engine::any::connect("mem://").await?;
    db.use_ns("test").use_db("test").await?;
    let fixtures = BenchFixtures::new(db.clone());
    fixtures.init_schema().await?;
    Ok(db)
}

pub async fn inject_pending_deliveries(
    db: &Surreal<Any>,
    sub_id: &str,
    count: usize,
) -> Result<Vec<String>, surrealdb::Error> {
    let fixtures = BenchFixtures::new(db.clone());
    fixtures.register_test_subscription(sub_id, "bench.*", 5).await?;
    fixtures.inject_pending_deliveries(count).await?;

    let mut res = db
        .query("SELECT VALUE id FROM event_delivery WHERE status = 'pending'")
        .await?;
    let ids: Vec<surrealdb::sql::Thing> = res.take(0)?;
    Ok(ids.into_iter().map(|t| t.to_string()).collect())
}

pub async fn setup_in_doubt_fixtures(
    db: &Surreal<Any>,
    sub_id: &str,
    worker_id: &str,
) -> Result<(Vec<String>, Vec<String>), surrealdb::Error> {
    let fixtures = BenchFixtures::new(db.clone());
    fixtures.register_test_subscription(sub_id, "bench.*", 5).await?;
    fixtures.setup_in_doubt_fixtures(worker_id).await?;

    let mut res1 = db
        .query("SELECT VALUE id FROM event_delivery WHERE context.lot = 'lot1'")
        .await?;
    let old_ids: Vec<surrealdb::sql::Thing> = res1.take(0)?;

    let mut res2 = db
        .query("SELECT VALUE id FROM event_delivery WHERE context.lot = 'lot2'")
        .await?;
    let in_doubt_ids: Vec<surrealdb::sql::Thing> = res2.take(0)?;

    Ok((
        old_ids.into_iter().map(|t| t.to_string()).collect(),
        in_doubt_ids.into_iter().map(|t| t.to_string()).collect(),
    ))
}

pub async fn setup_replay_conflict_fixtures(
    db: &Surreal<Any>,
    sub_id: &str,
    _worker_id: &str,
) -> Result<(String, String), surrealdb::Error> {
    let fixtures = BenchFixtures::new(db.clone());
    fixtures.register_test_subscription(sub_id, "bench.*", 5).await?;
    fixtures.setup_replay_conflict_fixtures().await
}

pub struct BenchFixtures {
    db: Surreal<Any>,
    store: Arc<EventStore>,
}

impl BenchFixtures {
    pub fn new(db: Surreal<Any>) -> Self {
        let store = Arc::new(EventStore::new(db.clone()));
        Self { db, store }
    }

    pub fn store(&self) -> Arc<EventStore> {
        self.store.clone()
    }

    /// Initialise le schéma complet sur la base courante
    pub async fn init_schema(&self) -> Result<(), surrealdb::Error> {
        self.store
            .init_schema()
            .await
            .map_err(|e| surrealdb::Error::Api(surrealdb::error::Api::Query(e.to_string())))
    }

    /// Enregistre un abonnement de test pour les scénarios
    pub async fn register_test_subscription(
        &self,
        name: &str,
        event_pattern: &str,
        max_attempts: u32,
    ) -> Result<(), surrealdb::Error> {
        let sub = EventSubscription::new(name, "bench_consumer", event_pattern, "bench_handler")
            .with_max_attempts(max_attempts);
        self.store
            .register_subscription(&sub)
            .await
            .map(|_| ())
            .map_err(|e| surrealdb::Error::Api(surrealdb::error::Api::Query(e.to_string())))
    }

    /// Injecte $N$ livraisons en statut 'pending' directement associées à un abonnement
    pub async fn inject_pending_deliveries(&self, count: usize) -> Result<usize, surrealdb::Error> {
        self.register_test_subscription("bench_sub_load", "bench.load", 5)
            .await?;

        let batch_size = 100;
        let mut inserted = 0;

        for batch_idx in 0..(count / batch_size) {
            let mut query = String::from("BEGIN TRANSACTION;\n");
            for i in 0..batch_size {
                let idx = batch_idx * batch_size + i;
                query.push_str(&format!(
                    "CREATE event_delivery CONTENT {{ \
                        target_module: 'bench_consumer', \
                        status: 'pending', \
                        attempts: 0, \
                        max_attempts: 5, \
                        next_retry_at: time::now(), \
                        context: {{ instance_id: 'bench_inst_{}' }} \
                    }};\n",
                    idx
                ));
            }
            query.push_str("COMMIT TRANSACTION;\n");
            self.db.query(&query).await?;
            inserted += batch_size;
        }

        let remaining = count % batch_size;
        if remaining > 0 {
            let mut query = String::from("BEGIN TRANSACTION;\n");
            for i in 0..remaining {
                let idx = (count / batch_size) * batch_size + i;
                query.push_str(&format!(
                    "CREATE event_delivery CONTENT {{ \
                        target_module: 'bench_consumer', \
                        status: 'pending', \
                        attempts: 0, \
                        max_attempts: 5, \
                        next_retry_at: time::now(), \
                        context: {{ instance_id: 'bench_inst_{}' }} \
                    }};\n",
                    idx
                ));
            }
            query.push_str("COMMIT TRANSACTION;\n");
            self.db.query(&query).await?;
            inserted += remaining;
        }

        Ok(inserted)
    }

    /// Prépare les fixtures pour S-09 (Lot 1 actif en cours + Lot 2 éligible)
    pub async fn setup_in_doubt_fixtures(
        &self,
        worker_id: &str,
    ) -> Result<(usize, usize), surrealdb::Error> {
        let mut q1 = String::from("BEGIN TRANSACTION;\n");
        for i in 0..10 {
            q1.push_str(&format!(
                "CREATE event_delivery CONTENT {{ \
                    target_module: 'bench_consumer', \
                    status: 'processing', \
                    attempts: 1, \
                    max_attempts: 5, \
                    locked_until: time::now() + 30s, \
                    lease_owner: '{}', \
                    claim_request_id: 'req-indoubt-02', \
                    context: {{ lot: 'lot1', idx: {} }} \
                }};\n",
                worker_id, i
            ));
        }
        q1.push_str("COMMIT TRANSACTION;\n");
        self.db.query(&q1).await?;

        let mut q2 = String::from("BEGIN TRANSACTION;\n");
        for i in 0..10 {
            q2.push_str(&format!(
                "CREATE event_delivery CONTENT {{ \
                    target_module: 'bench_consumer', \
                    status: 'processing', \
                    attempts: 1, \
                    max_attempts: 5, \
                    locked_until: time::now() + 30s, \
                    lease_owner: '{}', \
                    claim_request_id: 'req-old-01', \
                    context: {{ lot: 'lot2', idx: {} }} \
                }};\n",
                worker_id, i
            ));
        }
        q2.push_str("COMMIT TRANSACTION;\n");
        self.db.query(&q2).await?;

        Ok((10, 10))
    }

    /// Prépare les fixtures pour S-10 (1 livraison en processing associée à un dead_letter_id valide)
    pub async fn setup_replay_conflict_fixtures(&self) -> Result<(String, String), surrealdb::Error> {
        let mut res1 = self
            .db
            .query(
                "CREATE event_delivery CONTENT { \
                    target_module: 'bench_consumer', \
                    status: 'processing', \
                    attempts: 5, \
                    max_attempts: 5, \
                    locked_until: time::now() + 30s, \
                    lease_owner: 'worker_active_s10', \
                    claim_nonce: 'nonce_active_s10' \
                } RETURN id",
            )
            .await?;

        #[derive(Deserialize)]
        struct IdRow {
            id: surrealdb::sql::Thing,
        }

        let del_rows: Vec<IdRow> = res1.take(0)?;
        let delivery_id = del_rows.first().unwrap().id.to_string();

        let mut res2 = self
            .db
            .query(format!(
                "CREATE event_dead_letter CONTENT {{ \
                    delivery: {}, \
                    error_code: 'BENCH_ERR', \
                    error_message: 'Simulated failure', \
                    total_attempts: 5, \
                    replayed: false \
                }} RETURN id",
                delivery_id
            ))
            .await?;

        let dl_rows: Vec<IdRow> = res2.take(0)?;
        let dl_id = dl_rows.first().unwrap().id.to_string();

        Ok((delivery_id, dl_id))
    }

    /// Réinitialisation complète de l'environnement (REMOVE DATABASE)
    pub async fn reset_database(&self, ns: &str, db_name: &str) -> Result<(), surrealdb::Error> {
        self.db
            .query(format!("REMOVE DATABASE {};", db_name))
            .await?;
        self.db.use_ns(ns).use_db(db_name).await?;
        self.init_schema().await?;
        Ok(())
    }
}
