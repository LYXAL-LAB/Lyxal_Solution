//! Factories et générateurs de fixtures pour les tests d'intégration Lyxal Booking.
//!
//! Utilise exclusivement les primitives canoniques SurrealQL via `harness.call_fn(...)`.

use anyhow::Result;
use serde::{Deserialize, Serialize};
use surrealdb::RecordId;

use super::harness::TestHarness;

/// Représentation typée d'un compte utilisateur de test créé en base.
#[derive(Debug, Clone, Deserialize)]
pub struct TestUser {
    pub id: RecordId,
    pub name: String,
    pub email: String,
    pub username: String,
    pub role: String,
    pub timezone: String,
    pub language: String,
    pub enabled: bool,
}

#[derive(Debug, Clone, Serialize)]
struct CreateLocalAccountParams {
    name: String,
    email: String,
    username: String,
    password_hash: String,
    force_admin: bool,
    language: String,
}

/// Représentation typée d'une ressource de test créée en base.
#[derive(Debug, Clone, Deserialize)]
pub struct TestResource {
    pub id: RecordId,
    pub created: bool,
}

#[derive(Debug, Clone, Serialize)]
struct CreateResourceParams {
    name: String,
    description: Option<String>,
    capacity: Option<i32>,
    location: Option<String>,
    id: Option<RecordId>,
}

/// Représentation typée d'un type d'événement de test créé en base.
#[derive(Debug, Clone, Deserialize)]
pub struct TestEventType {
    pub id: RecordId,
    pub created: bool,
}

#[derive(Debug, Clone, Serialize)]
struct CreateEventTypeParams {
    account_id: RecordId,
    team_id: Option<RecordId>,
    title: String,
    slug: String,
    duration_min: i32,
    location_type: Option<String>,
    location_value: Option<String>,
    id: Option<RecordId>,
}

#[derive(Debug, Clone, Serialize)]
struct CreateBookingParams {
    event_type_slug: String,
    start_time: String,
    guest_name: String,
    guest_email: String,
    notes: Option<String>,
    user_id: Option<RecordId>,
}

#[derive(Debug, Clone, Deserialize)]
pub struct TestBooking {
    pub id: RecordId,
    pub event_type: RecordId,
    pub guest_name: String,
    pub guest_email: String,
    pub status: String,
    pub cancel_token: String,
    pub reschedule_token: String,
}

impl TestHarness {
    /// Crée un compte utilisateur de test via la primitive `fn::booking_create_local_account`.
    pub async fn create_test_user(
        &self,
        name: &str,
        email: &str,
        username: &str,
        password: &str,
        force_admin: bool,
    ) -> Result<TestUser> {
        let password_hash = lyxal_booking::auth::hash_password(password)?;
        let params = CreateLocalAccountParams {
            name: name.to_string(),
            email: email.to_string(),
            username: username.to_string(),
            password_hash,
            force_admin,
            language: "fr".to_string(),
        };

        let user: TestUser = self
            .call_fn("booking_create_local_account", params)
            .await
            .map_err(|e| anyhow::anyhow!("Échec create_test_user: {}", e))?;

        Ok(user)
    }

    /// Crée une ressource physique (salle, équipement) via la primitive `fn::booking_create_resource`.
    pub async fn create_test_resource(
        &self,
        name: &str,
        capacity: Option<i32>,
        location: Option<String>,
        description: Option<String>,
    ) -> Result<TestResource> {
        let params = CreateResourceParams {
            name: name.to_string(),
            description,
            capacity,
            location,
            id: None,
        };

        let resource: TestResource = self
            .call_fn("booking_create_resource", params)
            .await
            .map_err(|e| anyhow::anyhow!("Échec create_test_resource: {}", e))?;

        Ok(resource)
    }

    /// Crée un type d'événement via la primitive `fn::booking_create_event_type`.
    pub async fn create_test_event_type(
        &self,
        account_id: RecordId,
        title: &str,
        slug: &str,
        duration_min: i32,
    ) -> Result<TestEventType> {
        let params = CreateEventTypeParams {
            account_id,
            team_id: None,
            title: title.to_string(),
            slug: slug.to_string(),
            duration_min,
            location_type: Some("link".to_string()),
            location_value: Some("https://meet.lyxal.com".to_string()),
            id: None,
        };

        let event_type: TestEventType = self
            .call_fn("booking_create_event_type", params)
            .await
            .map_err(|e| anyhow::anyhow!("Échec create_test_event_type: {}", e))?;

        Ok(event_type)
    }

    /// Crée une réservation via la primitive `fn::booking_create_booking`.
    pub async fn create_test_booking(
        &self,
        event_type_slug: &str,
        start_time: &str,
        guest_name: &str,
        guest_email: &str,
        notes: Option<String>,
        user_id: Option<RecordId>,
    ) -> Result<TestBooking> {
        let params = CreateBookingParams {
            event_type_slug: event_type_slug.to_string(),
            start_time: start_time.to_string(),
            guest_name: guest_name.to_string(),
            guest_email: guest_email.to_string(),
            notes,
            user_id,
        };

        let booking: TestBooking = self
            .call_fn("booking_create_booking", params)
            .await
            .map_err(|e| anyhow::anyhow!("Échec create_test_booking: {}", e))?;

        Ok(booking)
    }
}
