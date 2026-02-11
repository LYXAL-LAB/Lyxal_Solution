use chrono::{DateTime, Utc};
use lyxal_core::Result;
use serde::{Deserialize, Serialize};
use uuid::Uuid;

/// Represents a user's active session within the Lyxal Identity system.
/// This structure is used for both internal tracking and serialization
/// when managing session state.
#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Session {
    /// Unique identifier for the session
    pub id: String,
    /// ID of the user associated with this session
    pub user_id: Uuid,
    /// Optional Tenant ID if the session is scoped to an organization
    pub tenant_id: Option<Uuid>,
    /// When the session was created
    pub created_at: DateTime<Utc>,
    /// When the session expires
    pub expires_at: DateTime<Utc>,
    /// Client metadata: User Agent
    pub user_agent: Option<String>,
    /// Client metadata: IP Address
    pub ip_address: Option<String>,
    /// Authentication context (e.g., factors used)
    pub amr: Vec<String>,
}

impl Session {
    /// Creates a new session instance for a user.
    pub fn new(
        id: String,
        user_id: Uuid,
        tenant_id: Option<Uuid>,
        duration_hours: i64,
        user_agent: Option<String>,
        ip_address: Option<String>,
    ) -> Self {
        let now = Utc::now();
        Self {
            id,
            user_id,
            tenant_id,
            created_at: now,
            expires_at: now + chrono::Duration::hours(duration_hours),
            user_agent,
            ip_address,
            amr: Vec::new(),
        }
    }

    /// Checks if the session has expired.
    pub fn is_expired(&self) -> bool {
        self.expires_at < Utc::now()
    }

    /// Extends the session expiration by a given duration.
    pub fn extend(&mut self, duration_hours: i64) {
        self.expires_at = Utc::now() + chrono::Duration::hours(duration_hours);
    }

    /// Adds an Authentication Method Reference to the session.
    pub fn add_amr(&mut self, method: &str) {
        if !self.amr.contains(&method.to_string()) {
            self.amr.push(method.to_string());
        }
    }
}

/// Trait defining the requirements for session management logic.
#[async_trait::async_trait]
pub trait SessionManager: Send + Sync {
    /// Retrieves a session by its ID.
    async fn get_session(&self, session_id: &str) -> Result<Option<Session>>;

    /// Persists a new or updated session.
    async fn save_session(&self, session: &Session) -> Result<()>;

    /// Removes a session from storage (logout).
    async fn delete_session(&self, session_id: &str) -> Result<()>;

    /// Validates a session and returns the associated User ID if valid.
    async fn validate_session(&self, session_id: &str) -> Result<Uuid>;
}

