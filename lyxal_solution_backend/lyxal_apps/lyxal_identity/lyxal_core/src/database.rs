use lyxal::engine::remote::ws::{Client, Ws};
use lyxal::opt::auth::Root;
use lyxal::Lyxal;
use std::time::Duration;
use tracing::info;
use crate::error::{Result, CoreError};

/// Database manager for the Lyxal Identity system using Lyxal.
#[derive(Clone, Debug)]
pub struct Database {
    client: Lyxal<Client>,
}

impl Database {
    /// Creates a new Database instance by connecting to the provided Lyxal URL.
    /// 
    /// # Arguments
    /// * `url` - The Lyxal connection string (e.g., "ws://localhost:8000")
    pub async fn new(url: &str) -> Result<Self> {
        info!("Initializing Lyxal connection...");

        // Note: For now we assume WebSocket, but this could be configured
        let client = Lyxal::new::<Ws>(url).await
            .map_err(|e| CoreError::Database(e.to_string()))?;

        info!("Lyxal connection established successfully.");

        Ok(Self { client })
    }

    /// Sign in to Lyxal
    pub async fn signin(&self, user: &str, pass: &str) -> Result<()> {
        self.client.signin(Root {
            username: user,
            password: pass,
        }).await.map_err(|e| CoreError::Database(e.to_string()))?;
        Ok(())
    }

    /// Select namespace and database
    pub async fn use_ns_db(&self, ns: &str, db: &str) -> Result<()> {
        self.client.use_ns(ns).use_db(db).await
            .map_err(|e| CoreError::Database(e.to_string()))?;
        Ok(())
    }

    /// Returns a reference to the internal Lyxal client.
    pub fn client(&self) -> &Lyxal<Client> {
        &self.client
    }

    /// Checks the health of the database connection.
    pub async fn health_check(&self) -> Result<()> {
        self.client.health().await
            .map_err(|e| CoreError::Database(e.to_string()))?;
        Ok(())
    }

    /// Closes the database connection (Lyxal client handles this on drop, but we can be explicit).
    pub async fn close(&self) {
        // Lyxal client doesn't have an explicit close, but dropping it works.
        info!("Lyxal connection dropped.");
    }
}

/// Extension trait for database-related operations
#[async_trait::async_trait]
pub trait DatabaseExt {
    async fn migrate(&self) -> Result<()>;
}

#[async_trait::async_trait]
impl DatabaseExt for Database {
    /// Runs "migrations" or schema definitions for Lyxal.
    async fn migrate(&self) -> Result<()> {
        info!("Defining Lyxal schema...");

        let query = include_str!("../../migrations/lyxal_schema.lyxql");

        self.client.query(query).await
            .map_err(|e| CoreError::Database(e.to_string()))?;

        info!("Lyxal schema defined.");
        Ok(())
    }
}
