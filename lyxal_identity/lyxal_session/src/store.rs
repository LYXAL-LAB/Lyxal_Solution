use sqlx::PgPool;
use tower_sessions_sqlx_store::PostgresStore;
use lyxal_core::Result;
use tracing::info;

/// SessionStore manages the persistence of user sessions using PostgreSQL.
/// It wraps the tower-sessions PostgresStore to provide a seamless integration
/// with the Axum web framework and our database pool.
#[derive(Clone)]
pub struct SessionStore {
    inner: PostgresStore,
}

impl SessionStore {
    /// Creates a new SessionStore instance and initializes the session table if needed.
    ///
    /// # Arguments
    /// * `pool` - The SQLx PostgreSQL connection pool.
    pub async fn new(pool: PgPool) -> Result<Self> {
        info!("Initializing PostgreSQL session store...");

        let inner = PostgresStore::new(pool);

        // This will create the `sessions` table in the database if it doesn't exist.
        inner.migrate().await.map_err(|e| {
            lyxal_core::CoreError::Internal(anyhow::anyhow!("Failed to migrate session store: {}", e))
        })?;

        info!("Session store initialized and migrated successfully.");

        Ok(Self { inner })
    }

    /// Returns the inner tower-sessions compatible store.
    pub fn inner(&self) -> PostgresStore {
        self.inner.clone()
    }
}

/// Helper to configure session expiration and cleanup policies.
pub struct SessionConfig {
    pub idle_timeout: std::time::Duration,
    pub session_table_name: String,
}

impl Default for SessionConfig {
    fn default() -> Self {
        Self {
            idle_timeout: std::time::Duration::from_secs(60 * 60 * 24), // 24 hours
            session_table_name: "sessions".to_string(),
        }
    }
}
