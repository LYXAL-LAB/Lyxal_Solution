use sqlx::postgres::{PgPool, PgPoolOptions};
use std::time::Duration;
use tracing::info;
use crate::error::Result;

/// Database manager for the Lyxal Identity system.
/// This structure wraps the SQLx Postgres pool and provides methods
/// for initialization and health checks.
#[derive(Clone, Debug)]
pub struct Database {
    pool: PgPool,
}

impl Database {
    /// Creates a new Database instance by connecting to the provided URL.
    ///
    /// # Arguments
    /// * `url` - The PostgreSQL connection string (e.g., "postgres://user:pass@localhost/db")
    pub async fn new(url: &str) -> Result<Self> {
        info!("Initializing database connection pool...");

        let pool = PgPoolOptions::new()
            .max_connections(20)
            .min_connections(5)
            .acquire_timeout(Duration::from_secs(3))
            .idle_timeout(Duration::from_secs(600))
            .max_lifetime(Duration::from_secs(1800))
            .connect(url)
            .await?;

        info!("Database connection pool established successfully.");

        Ok(Self { pool })
    }

    /// Returns a reference to the internal PgPool.
    pub fn pool(&self) -> &PgPool {
        &self.pool
    }

    /// Checks the health of the database connection.
    pub async fn health_check(&self) -> Result<()> {
        sqlx::query("SELECT 1").execute(&self.pool).await?;
        Ok(())
    }

    /// Closes the database connection pool.
    pub async fn close(&self) {
        self.pool.close().await;
        info!("Database connection pool closed.");
    }
}

/// Extension trait for database-related operations
#[async_trait::async_trait]
pub trait DatabaseExt {
    async fn migrate(&self) -> Result<()>;
}

#[async_trait::async_trait]
impl DatabaseExt for Database {
    /// Runs pending migrations.
    /// This expects a `migrations` folder at the root of the project or in the workspace.
    async fn migrate(&self) -> Result<()> {
        info!("Running database migrations...");
        // In a real scenario, we would use:
        // sqlx::migrate!("./migrations").run(&self.pool).await?;
        // For now, we keep it as a placeholder for when migrations are added.
        Ok(())
    }
}
