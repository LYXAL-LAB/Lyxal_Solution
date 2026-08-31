//! Account, User, AuthUserRecord, and Session domain models for Lyxal Booking.

use serde::{Deserialize, Serialize};
use super::types::{BookingDatetime, BookingRecordId};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Account {
    pub id: BookingRecordId,
    pub name: String,
    pub email: String,
    pub timezone: String,
    pub created_at: BookingDatetime,
    pub updated_at: BookingDatetime,
    pub user_id: Option<BookingRecordId>,
}

/// Public user domain model — ZÉRO secret ou password_hash.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct User {
    pub id: BookingRecordId,
    pub email: String,
    pub name: String,
    pub timezone: String,
    pub role: String,
    pub auth_provider: String,
    pub oidc_subject: Option<String>,
    pub enabled: bool,
    pub created_at: BookingDatetime,
    pub updated_at: BookingDatetime,
    pub username: Option<String>,
    pub booking_email: Option<String>,
    pub title: Option<String>,
    pub bio: Option<String>,
    pub avatar_path: Option<String>,
    pub allow_dynamic_group: bool,
    pub language: Option<String>,
}

/// Modèle d'enregistrement d'authentification interne (interne `pub(crate)`).
#[derive(Clone, Deserialize)]
pub(crate) struct AuthUserRecord {
    pub id: BookingRecordId,
    pub password_hash: String,
    pub enabled: bool,
    pub role: String,
}

impl std::fmt::Debug for AuthUserRecord {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("AuthUserRecord")
            .field("id", &self.id)
            .field("password_hash", &"[REDACTED]")
            .field("enabled", &self.enabled)
            .field("role", &self.role)
            .finish()
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Session {
    pub id: BookingRecordId,
    pub user_id: BookingRecordId,
    pub expires_at: BookingDatetime,
    pub created_at: BookingDatetime,
}
