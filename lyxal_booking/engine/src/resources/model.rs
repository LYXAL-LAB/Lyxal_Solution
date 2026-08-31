//! Resource Domain Models and DTOs.

use serde::{Deserialize, Serialize};
use surrealdb::RecordId;

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct ResourceRef {
    pub id: RecordId,
    pub name: String,
}

/// Outcome of non-transactional availability preview.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum AvailabilityPreview {
    NoResources,
    Free { assigned: Option<RecordId> },
    Busy,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ResourceEventInput {
    pub uid: String,
    pub recurrence_id: Option<String>,
    pub summary: Option<String>,
    pub start_at: Option<surrealdb::sql::Datetime>,
    pub end_at: Option<surrealdb::sql::Datetime>,
    pub raw_start_at: String,
    pub raw_end_at: Option<String>,
    pub all_day: bool,
    pub timezone: Option<String>,
    pub rrule: Option<String>,
    pub raw_ical: String,
    pub status: Option<String>,
    pub transp: Option<String>,
}

#[derive(Debug, Serialize)]
pub(crate) struct GetResourceSyncContextParams<'a> {
    pub record_id: &'a RecordId,
    pub language: &'a str,
}

#[derive(Debug, Deserialize)]
pub(crate) struct ResourceSyncContext {
    pub record_id: RecordId,
    pub feed_url: String,
    pub last_synced_at: Option<surrealdb::sql::Datetime>,
    pub enabled: bool,
}

#[derive(Debug, Serialize)]
pub(crate) struct ReplaceResourceEventsParams<'a> {
    pub resource_id: &'a RecordId,
    pub events: &'a [ResourceEventInput],
    pub synced_at: surrealdb::sql::Datetime,
}

#[derive(Debug, Deserialize)]
pub(crate) struct ReplaceResourceEventsResult {
    pub resource_id: RecordId,
    pub inserted: u64,
    pub updated: u64,
    pub deleted: u64,
}

#[derive(Debug, Serialize)]
pub(crate) struct MarkSyncFailedParams<'a> {
    pub resource_id: &'a RecordId,
    pub error_message: &'a str,
    pub synced_at: surrealdb::sql::Datetime,
}

#[derive(Debug, Deserialize)]
pub(crate) struct MarkSyncFailedResult {
    pub updated: bool,
}

#[derive(Debug, Serialize)]
pub(crate) struct GetEventTypeResourcesParams<'a> {
    pub event_type_id: &'a RecordId,
    pub language: &'a str,
}

#[derive(Debug, Deserialize)]
pub(crate) struct EventTypeResourcesResult {
    pub event_type_id: RecordId,
    pub scheduling_mode: String,
    pub resources: Vec<ResourceRef>,
}

#[derive(Debug, Serialize)]
pub(crate) struct GetResourceBusyContextParams<'a> {
    pub resource_id: &'a RecordId,
    pub start_at: surrealdb::sql::Datetime,
    pub end_at: surrealdb::sql::Datetime,
    pub exclude_booking_id: Option<&'a RecordId>,
    pub language: &'a str,
}

#[derive(Debug, Deserialize)]
pub(crate) struct ResourceBusyContext {
    pub cached_events: Vec<ResourceCachedEvent>,
    pub confirmed_bookings: Vec<ResourceBookingInterval>,
}

#[derive(Debug, Deserialize)]
pub(crate) struct ResourceCachedEvent {
    pub uid: String,
    pub recurrence_id: Option<String>,
    pub raw_start_at: String,
    pub raw_end_at: Option<String>,
    pub timezone: Option<String>,
    pub rrule: Option<String>,
    pub raw_ical: Option<String>,
    pub status: Option<String>,
    pub transp: Option<String>,
    pub all_day: bool,
}

#[derive(Debug, Deserialize)]
pub(crate) struct ResourceBookingInterval {
    pub booking_id: RecordId,
    pub start_at: surrealdb::sql::Datetime,
    pub end_at: surrealdb::sql::Datetime,
}

/// DTO canonique complet de création de réservation avec affectation atomique.
#[derive(Debug, Serialize)]
pub struct CreateWithResourceAssignmentParams<'a> {
    pub event_type_id: &'a RecordId,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub uid: Option<&'a str>,
    pub start_at: surrealdb::sql::Datetime,
    pub end_at: surrealdb::sql::Datetime,
    pub customer_name: &'a str,
    pub customer_email: &'a str,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub customer_time_zone: Option<&'a str>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub customer_notes: Option<&'a str>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub location: Option<&'a str>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub additional_notes: Option<&'a str>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub cancel_token: Option<&'a str>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub reschedule_token: Option<&'a str>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub assigned_user_id: Option<&'a RecordId>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub status: Option<&'a str>,
    pub language: &'a str,
}

/// DTO canonique de report avec verrouillage optimiste.
#[derive(Debug, Serialize)]
pub struct RescheduleWithResourceParams<'a> {
    pub booking_id: &'a RecordId,
    pub expected_start_at: surrealdb::sql::Datetime,
    pub expected_end_at: surrealdb::sql::Datetime,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub expected_updated_at: Option<&'a surrealdb::sql::Datetime>,
    pub new_start_at: surrealdb::sql::Datetime,
    pub new_end_at: surrealdb::sql::Datetime,
    pub language: &'a str,
}

#[derive(Debug, Deserialize)]
pub struct ResourceAssignmentResult {
    pub booking_id: RecordId,
    pub assigned_resource_id: Option<RecordId>,
    pub scheduling_mode: String,
}
