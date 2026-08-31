//! Domain module for availability and slot checking in Lyxal Booking.

use lyxal_surreal::{LyxalSurrealCall, LyxalSurrealError};
use serde::{Deserialize, Serialize};
use surrealdb::sql::Datetime;
use surrealdb::RecordId;
use crate::db::SurrealBookingStore;

#[derive(Debug, Serialize)]
pub struct IsSlotAvailableParams {
    pub event_type_id: RecordId,
    pub start_at: Datetime,
    pub end_at: Datetime,
}

#[derive(Debug, Deserialize)]
pub struct SlotAvailabilityResult {
    pub available: bool,
}

/// Execute a native SurrealQL slot availability check via `fn::booking_is_slot_available`.
pub async fn is_slot_available(
    store: &SurrealBookingStore,
    event_type_id: RecordId,
    start_at: Datetime,
    end_at: Datetime,
) -> Result<bool, LyxalSurrealError> {
    let result: SlotAvailabilityResult = store
        .call_fn(
            "booking_is_slot_available",
            IsSlotAvailableParams {
                event_type_id,
                start_at,
                end_at,
            },
        )
        .await?;

    Ok(result.available)
}
