//! SurrealDB persistence transport for Lyxal Booking.
//!
//! This module owns the SurrealDB connection only.
//! Business operations are implemented through typed `fn::booking_*`
//! wrappers in their respective domain modules.

use lyxal_surreal::{LyxalSurrealCall, LyxalSurrealError};
use serde::de::DeserializeOwned;
use surrealdb::engine::any::{self, Any};
use surrealdb::opt::auth::Root;
use surrealdb::Surreal;

/// Persistent store implementation for Lyxal Booking backed by SurrealDB (`Surreal<Any>`).
#[derive(Clone)]
pub struct SurrealBookingStore {
    db: Surreal<Any>,
}

pub type SurrealStore = SurrealBookingStore;

#[derive(Debug, Clone)]
pub struct SurrealConnectionConfig<'a> {
    pub endpoint: &'a str,
    pub namespace: &'a str,
    pub database: &'a str,
    pub credentials: Option<RootCredentials<'a>>,
}

#[derive(Debug, Clone)]
pub struct RootCredentials<'a> {
    pub username: &'a str,
    pub password: &'a str,
}

impl SurrealBookingStore {
    /// Create a `SurrealBookingStore` wrapping an established `Surreal<Any>` client connection.
    pub fn new(db: Surreal<Any>) -> Self {
        Self { db }
    }

    /// Access the underlying `Surreal<Any>` client reference.
    pub fn client(&self) -> &Surreal<Any> {
        &self.db
    }

    /// Connect asynchronously to a SurrealDB endpoint (`ws://`, `wss://`, `mem://`, `"memory"`).
    pub async fn connect(
        config: SurrealConnectionConfig<'_>,
    ) -> Result<Self, LyxalSurrealError> {
        let endpoint = normalize_endpoint(config.endpoint);
        validate_endpoint_scheme(&endpoint)?;

        let db = any::connect(endpoint.clone()).await?;

        let embedded = endpoint == "memory" || endpoint.starts_with("mem://");

        match (embedded, config.credentials) {
            (true, _) => {
                // No Root signin for embedded memory engine.
            }
            (false, Some(credentials)) => {
                db.signin(Root {
                    username: credentials.username,
                    password: credentials.password,
                })
                .await?;
            }
            (false, None) => {
                return Err(LyxalSurrealError::MissingCredentials { endpoint });
            }
        }

        db.use_ns(config.namespace)
            .use_db(config.database)
            .await?;

        Ok(Self::new(db))
    }

    /// Connect asynchronously using environment variables (`SURREALDB_URL`, `SURREALDB_NS`, `SURREALDB_DB`, `SURREALDB_USER`, `SURREALDB_PASS`).
    pub async fn connect_from_env() -> anyhow::Result<Self> {
        let endpoint_val = std::env::var("SURREALDB_URL")
            .map_err(|_| anyhow::anyhow!("SURREALDB_URL environment variable is required (e.g. ws://127.0.0.1:8000)"))?;
        let ns_val = std::env::var("SURREALDB_NS").unwrap_or_else(|_| "lyxal".into());
        let db_val = std::env::var("SURREALDB_DB").unwrap_or_else(|_| "booking".into());

        let user_val = std::env::var("SURREALDB_USER").ok().filter(|s| !s.trim().is_empty());
        let pass_val = std::env::var("SURREALDB_PASS").ok().filter(|s| !s.trim().is_empty());

        let (u_str, p_str) = match (user_val, pass_val) {
            (Some(u), Some(p)) => (u, p),
            _ => (String::new(), String::new()),
        };

        let credentials = if u_str.is_empty() && p_str.is_empty() {
            None
        } else {
            Some(RootCredentials {
                username: &u_str,
                password: &p_str,
            })
        };

        let config = SurrealConnectionConfig {
            endpoint: &endpoint_val,
            namespace: &ns_val,
            database: &db_val,
            credentials,
        };

        Ok(Self::connect(config).await?)
    }

    /// Read a string setting value from `booking_setting` table via SurrealQL primitive `fn::booking_get_setting`.
    pub async fn get_setting(&self, key: &str) -> Result<Option<String>, LyxalSurrealError> {
        let mut response = self
            .client()
            .query("RETURN fn::booking_get_setting($key_name);")
            .bind(("key_name", key.to_string()))
            .await?;
        let raw: Option<lyxal_error::LyxalResult<Option<String>>> = response.take(0)?;
        match raw {
            Some(res) => Ok(res.into_result("booking_get_setting")?),
            None => Ok(None),
        }
    }

    /// Legacy connection helper for backwards compatibility during migration.
    pub async fn connect_legacy(
        endpoint: &str,
        ns: &str,
        db_name: &str,
        user: &str,
        pass: &str,
    ) -> anyhow::Result<Self> {
        let credentials = if user.is_empty() && pass.is_empty() {
            None
        } else {
            Some(RootCredentials {
                username: user,
                password: pass,
            })
        };
        let config = SurrealConnectionConfig {
            endpoint,
            namespace: ns,
            database: db_name,
            credentials,
        };
        Ok(Self::connect(config).await?)
    }

    /// Escape hatch reserved for:
    /// - Module Runtime schema/function installation;
    /// - migrations;
    /// - integration-test setup.
    ///
    /// Business operations must use typed `call_fn()` wrappers.
    pub(crate) async fn raw_query(
        &self,
        query_str: &str,
    ) -> Result<surrealdb::Response, LyxalSurrealError> {
        Ok(self.db.query(query_str).await?)
    }
}

impl LyxalSurrealCall for SurrealBookingStore {
    fn surreal_client(&self) -> &Surreal<Any> {
        &self.db
    }
}

fn normalize_endpoint(endpoint: &str) -> String {
    let trimmed = endpoint.trim().trim_end_matches('/');
    trimmed
        .strip_suffix("/rpc")
        .unwrap_or(trimmed)
        .trim_end_matches('/')
        .to_owned()
}

fn validate_endpoint_scheme(endpoint: &str) -> Result<(), LyxalSurrealError> {
    let ep = endpoint.trim();
    if ep.starts_with("ws://")
        || ep.starts_with("wss://")
        || ep.starts_with("mem://")
        || ep == "memory"
    {
        Ok(())
    } else {
        Err(LyxalSurrealError::UnsupportedEndpoint {
            endpoint: ep.to_owned(),
        })
    }
}

/// Helper to extract an optional single item from a SurrealDB query response.
#[deprecated(note = "Migrate the caller to a typed fn::booking_* wrapper via store.call_fn(...)")]
pub fn surreal_query_opt<T: DeserializeOwned>(
    res: Result<surrealdb::Response, surrealdb::Error>,
) -> Result<Option<T>, LyxalSurrealError> {
    let mut response = res?;
    Ok(response.take::<Option<T>>(0)?)
}

/// Helper to extract a vector of items from a SurrealDB query response.
#[deprecated(note = "Migrate the caller to a typed fn::booking_* wrapper via store.call_fn(...)")]
pub fn surreal_query_vec<T: DeserializeOwned>(
    res: Result<surrealdb::Response, surrealdb::Error>,
) -> Result<Vec<T>, LyxalSurrealError> {
    let mut response = res?;
    Ok(response.take::<Vec<T>>(0)?)
}
