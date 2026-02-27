use crate::{Session, SessionResult};
use sqlx::PgPool;
use serde_json::json;

pub struct SessionManager {
    pool: PgPool,
}

impl SessionManager {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }

    pub async fn create_session(&self, user_id: &str) -> SessionResult<Session> {
        let id = uuid::Uuid::new_4().to_string();
        let now = chrono::Utc::now().timestamp_millis();
        let expires_at = now + (24 * 3600 * 1000); // 24 hours

        let session = Session {
            id,
            user_id: Some(user_id.to_string()),
            created_at: now,
            updated_at: now,
            expires_at,
            data: json!({}),
        };

        // En prod, on insérerait ici dans la table 'sessions'
        Ok(session)
    }

    pub async fn validate_session(&self, id: &str) -> SessionResult<Session> {
        // Logic to fetch from DB and check expiry
        tracing::info!("Validating session {}", id);
        Ok(Session {
            id: id.to_string(),
            user_id: Some("mock_user".to_string()),
            created_at: 0,
            updated_at: 0,
            expires_at: i64::MAX,
            data: json!({}),
        })
    }
}
