//! Availability calculations & busy interval merging for bookable resources.

use chrono::NaiveDateTime;
use chrono_tz::Tz;
use lyxal_surreal::LyxalSurrealCall;
use surrealdb::RecordId;

use super::error::ResourceError;
use super::model::{
    EventTypeResourcesResult, GetEventTypeResourcesParams, GetResourceBusyContextParams,
    ResourceBusyContext,
};
use crate::db::SurrealBookingStore;
use crate::utils::{convert_event_to_tz, parse_ical_datetime};

/// Fetch busy time intervals for a single resource within `[window_start, window_end]`.
pub async fn busy_for_resource(
    store: &SurrealBookingStore,
    resource_id: &RecordId,
    window_start: NaiveDateTime,
    window_end: NaiveDateTime,
    host_tz: Tz,
    exclude_booking_id: Option<&RecordId>,
) -> Result<Vec<(NaiveDateTime, NaiveDateTime)>, ResourceError> {
    let start_dt = surrealdb::sql::Datetime::from(window_start.and_utc());
    let end_dt = surrealdb::sql::Datetime::from(window_end.and_utc());

    let sync_params = serde_json::json!({
        "resource_id": resource_id,
        "start_at": start_dt,
        "end_at": end_dt,
        "exclude_booking_id": exclude_booking_id,
        "language": "fr",
    });

    let busy_ctx: ResourceBusyContext = store
        .call_fn("booking_get_resource_busy_context", sync_params)
        .await?;

    let mut busy: Vec<(NaiveDateTime, NaiveDateTime)> = Vec::new();
    let mut recurring_inputs = Vec::new();

    for ev in busy_ctx.cached_events {
        // Skip CANCELLED / TRANSPARENT
        if let Some(ref st) = ev.status {
            if st.eq_ignore_ascii_case("CANCELLED") {
                continue;
            }
        }
        if let Some(ref tr) = ev.transp {
            if tr.eq_ignore_ascii_case("TRANSPARENT") {
                continue;
            }
        }

        if let Some(ref rrule) = ev.rrule {
            if !rrule.trim().is_empty() {
                let raw_end = ev.raw_end_at.unwrap_or_else(|| ev.raw_start_at.clone());
                recurring_inputs.push((
                    ev.raw_start_at,
                    raw_end,
                    rrule.clone(),
                    ev.raw_ical,
                    ev.timezone,
                ));
                continue;
            }
        }

        // Single non-recurring event
        if let Some(start_naive) = parse_ical_datetime(&ev.raw_start_at) {
            let end_naive = ev
                .raw_end_at
                .as_ref()
                .and_then(|r| parse_ical_datetime(r))
                .unwrap_or_else(|| start_naive + chrono::Duration::hours(1));

            let cs = match convert_event_to_tz(start_naive, ev.timezone.as_deref(), host_tz) {
                Ok(dt) => dt,
                Err(err) => {
                    tracing::warn!(error = %err, "Failed to convert cached event start datetime");
                    start_naive
                }
            };
            let ce = match convert_event_to_tz(end_naive, ev.timezone.as_deref(), host_tz) {
                Ok(dt) => dt,
                Err(err) => {
                    tracing::warn!(error = %err, "Failed to convert cached event end datetime");
                    end_naive
                }
            };
            busy.push((cs, ce));
        }
    }

    // Expand recurring events using neutral recurrence module
    busy.extend(crate::recurrence::expand_recurring_into_busy(
        &recurring_inputs,
        window_start,
        window_end,
        host_tz,
    ));

    // Add confirmed internal bookings
    for b in busy_ctx.confirmed_bookings {
        let start_utc = b.start_at.0.with_timezone(&chrono::Utc).naive_utc();
        let end_utc = b.end_at.0.with_timezone(&chrono::Utc).naive_utc();

        let cs = convert_event_to_tz(start_utc, None, host_tz).unwrap_or(start_utc);
        let ce = convert_event_to_tz(end_utc, None, host_tz).unwrap_or(end_utc);
        busy.push((cs, ce));
    }

    Ok(busy)
}

/// Sort intervals and merge overlapping/adjacent ones.
pub(crate) fn normalize(
    mut intervals: Vec<(NaiveDateTime, NaiveDateTime)>,
) -> Vec<(NaiveDateTime, NaiveDateTime)> {
    intervals.retain(|(s, e)| s < e);
    intervals.sort();
    let mut out: Vec<(NaiveDateTime, NaiveDateTime)> = Vec::new();
    for (s, e) in intervals {
        match out.last_mut() {
            Some(last) if s <= last.1 => {
                if e > last.1 {
                    last.1 = e;
                }
            }
            _ => out.push((s, e)),
        }
    }
    out
}

/// Intersect two sorted/normalized interval lists.
pub(crate) fn intersect(
    a: &[(NaiveDateTime, NaiveDateTime)],
    b: &[(NaiveDateTime, NaiveDateTime)],
) -> Vec<(NaiveDateTime, NaiveDateTime)> {
    let mut out = Vec::new();
    let mut i = 0;
    let mut j = 0;
    while i < a.len() && j < b.len() {
        let start = a[i].0.max(b[j].0);
        let end = a[i].1.min(b[j].1);
        if start < end {
            out.push((start, end));
        }
        if a[i].1 < b[j].1 {
            i += 1;
        } else {
            j += 1;
        }
    }
    out
}

/// Merge multiple busy lists according to selection mode.
pub fn merge_mode_busy(
    per_resource_busy: &[Vec<(NaiveDateTime, NaiveDateTime)>],
    selection_mode: &str,
) -> Vec<(NaiveDateTime, NaiveDateTime)> {
    if per_resource_busy.is_empty() {
        return Vec::new();
    }
    let norm: Vec<Vec<(NaiveDateTime, NaiveDateTime)>> =
        per_resource_busy.iter().map(|b| normalize(b.clone())).collect();

    if selection_mode.eq_ignore_ascii_case("all") {
        let mut acc = norm[0].clone();
        for other in &norm[1..] {
            acc = intersect(&acc, other);
        }
        acc
    } else {
        let mut combined = Vec::new();
        for list in &norm {
            combined.extend(list.clone());
        }
        normalize(combined)
    }
}

/// Compute blocking busy intervals for an event type across its resources.
pub async fn blocking_intervals_for_event_type(
    store: &SurrealBookingStore,
    event_type_id: &RecordId,
    window_start: NaiveDateTime,
    window_end: NaiveDateTime,
    host_tz: Tz,
    exclude_booking_id: Option<&RecordId>,
) -> Result<Vec<(NaiveDateTime, NaiveDateTime)>, ResourceError> {
    let et_resources: EventTypeResourcesResult = store
        .call_fn(
            "booking_get_event_type_resources",
            serde_json::json!({
                "event_type_id": event_type_id,
                "language": "fr",
            }),
        )
        .await?;

    if et_resources.resources.is_empty() {
        return Ok(Vec::new());
    }

    let mut per_resource = Vec::new();
    for res_ref in &et_resources.resources {
        let busy = busy_for_resource(
            store,
            &res_ref.id,
            window_start,
            window_end,
            host_tz,
            exclude_booking_id,
        )
        .await?;
        per_resource.push(busy);
    }

    Ok(merge_mode_busy(&per_resource, &et_resources.scheduling_mode))
}
