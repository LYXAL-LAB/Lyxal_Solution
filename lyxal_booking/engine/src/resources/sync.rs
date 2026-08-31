//! Resource Feed Synchronization Services (`sync_resource`, `sync_if_stale`, `sync_resources_if_stale`).

use lyxal_surreal::LyxalSurrealCall;
use surrealdb::RecordId;

use crate::db::SurrealBookingStore;
use super::error::ResourceError;
use super::feed::fetch_feed;
use super::model::{
    GetResourceSyncContextParams, MarkSyncFailedParams, MarkSyncFailedResult,
    ReplaceResourceEventsParams, ReplaceResourceEventsResult, ResourceSyncContext,
};
use super::parser::parse_calendar_events;

/// Re-sync a resource feed when older than 5 minutes.
pub const SYNC_STALE_MINUTES: i64 = 5;

/// Sync one resource's feed into `booking_resource_event`.
/// Returns the number of cached VEVENTs.
/// Orphans (events gone from the feed) are removed.
pub async fn sync_resource(
    store: &SurrealBookingStore,
    resource_id: &RecordId,
) -> Result<usize, ResourceError> {
    // 1. Load resource sync context
    let sync_ctx: ResourceSyncContext = store
        .call_fn(
            "booking_get_resource_sync_context",
            serde_json::json!({
                "record_id": resource_id,
                "language": "fr",
            }),
        )
        .await?;

    // Defense-in-depth record verification
    if sync_ctx.record_id != *resource_id {
        return Err(ResourceError::Parse(format!(
            "Unexpected resource sync context record (expected {}, got {})",
            resource_id, sync_ctx.record_id
        )));
    }

    if !sync_ctx.enabled {
        return Ok(0);
    }

    let now_dt = surrealdb::sql::Datetime::from(chrono::Utc::now());

    // 2. Fetch raw ICS feed
    let body = match fetch_feed(&sync_ctx.feed_url).await {
        Ok(b) => b,
        Err(err) => {
            // Record failure in DB without clearing cached events (observable error logging)
            let err_msg: String = err.to_string().chars().take(300).collect();

            match store
                .call_fn::<MarkSyncFailedResult, _>(
                    "booking_mark_resource_sync_failed",
                    serde_json::json!({
                        "resource_id": resource_id,
                        "error_message": err_msg,
                        "synced_at": now_dt,
                    }),
                )
                .await
            {
                Ok(result) if result.updated => {
                    tracing::debug!(resource_id = %resource_id, "Persisted resource sync failure status");
                }
                Ok(_) => {
                    tracing::warn!(
                        resource_id = %resource_id,
                        "Resource sync failure could not be recorded because the resource record changed"
                    );
                }
                Err(store_error) => {
                    tracing::warn!(
                        resource_id = %resource_id,
                        error = %store_error,
                        "Resource feed failed and the failure status could not be persisted"
                    );
                }
            }

            return Err(err);
        }
    };

    // 3. Parse ICS events
    let mut events = parse_calendar_events(&body);

    // Bound the event count: max 10,000
    const MAX_FEED_EVENTS: usize = 10_000;
    if events.len() > MAX_FEED_EVENTS {
        tracing::warn!(
            resource_id = %resource_id,
            count = events.len(),
            "resource feed truncated to {} events",
            MAX_FEED_EVENTS
        );
        events.truncate(MAX_FEED_EVENTS);
    }

    // 4. Atomically replace resource events in DB
    let replace_res: ReplaceResourceEventsResult = store
        .call_fn(
            "booking_replace_resource_events",
            serde_json::json!({
                "resource_id": resource_id,
                "events": events,
                "synced_at": now_dt,
            }),
        )
        .await?;

    Ok(replace_res.inserted as usize)
}

/// Sync a resource feed if it hasn't been synced within the last 5 minutes.
pub async fn sync_if_stale(
    store: &SurrealBookingStore,
    resource_id: &RecordId,
) -> Result<bool, ResourceError> {
    let sync_ctx: ResourceSyncContext = store
        .call_fn(
            "booking_get_resource_sync_context",
            serde_json::json!({
                "record_id": resource_id,
                "language": "fr",
            }),
        )
        .await?;

    let is_stale = match sync_ctx.last_synced_at {
        Some(dt) => {
            let last_sync = dt.0.with_timezone(&chrono::Utc);
            let age_mins = (chrono::Utc::now() - last_sync).num_minutes();
            age_mins >= SYNC_STALE_MINUTES
        }
        None => true,
    };

    if is_stale {
        sync_resource(store, resource_id).await?;
        Ok(true)
    } else {
        Ok(false)
    }
}

/// Batch sync multiple resources if stale.
pub async fn sync_resources_if_stale(
    store: &SurrealBookingStore,
    resource_ids: &[RecordId],
) -> Result<usize, ResourceError> {
    let mut count = 0;
    for resource_id in resource_ids {
        if sync_if_stale(store, resource_id).await? {
            count += 1;
        }
    }
    Ok(count)
}
