//! Atomic in-database resource assignment & reschedule.

use lyxal_surreal::LyxalSurrealCall;

use crate::db::SurrealBookingStore;
use super::error::ResourceError;
use super::model::{
    CreateWithResourceAssignmentParams, RescheduleWithResourceParams, ResourceAssignmentResult,
};

/// Atomically create a booking using the canonical DTO with resource assignment inside SurrealDB.
pub async fn create_with_resource_assignment(
    store: &SurrealBookingStore,
    params: CreateWithResourceAssignmentParams<'_>,
) -> Result<ResourceAssignmentResult, ResourceError> {
    let payload = serde_json::to_value(&params).map_err(|e| ResourceError::Parse(e.to_string()))?;
    let result: ResourceAssignmentResult = store
        .call_fn("booking_create_with_resource_assignment", payload)
        .await?;

    Ok(result)
}

/// Atomically reschedule a booking with optimistic locking and resource re-assignment inside SurrealDB.
pub async fn reschedule_with_resource_assignment(
    store: &SurrealBookingStore,
    params: RescheduleWithResourceParams<'_>,
) -> Result<ResourceAssignmentResult, ResourceError> {
    let payload = serde_json::to_value(&params).map_err(|e| ResourceError::Parse(e.to_string()))?;
    let result: ResourceAssignmentResult = store
        .call_fn("booking_reschedule_with_resource_assignment", payload)
        .await?;

    Ok(result)
}
