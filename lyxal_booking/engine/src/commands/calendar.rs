use anyhow::{bail, Result};
use chrono::{DateTime, Utc};
use lyxal_surreal::LyxalSurrealCall;
use serde::{Deserialize, Serialize};
use tabled::{Table, Tabled};

use crate::db::SurrealBookingStore;

/// Plage maximale de filtrage par défaut pour éviter la surcharge mémoire (366 jours)
pub const MAX_CALENDAR_RANGE_DAYS: i64 = 366;

#[derive(Debug, Serialize)]
struct CalendarEventsParams {
    from: String,
    to: String,
}

#[derive(Debug, Deserialize, Tabled)]
pub struct CalendarEventRow {
    #[tabled(rename = "ID")]
    pub id: String,
    #[tabled(rename = "TITLE")]
    pub title: String,
    #[tabled(rename = "GUEST")]
    pub guest_name: String,
    #[tabled(rename = "START AT (UTC)")]
    pub start_at: String,
    #[tabled(rename = "END AT (UTC)")]
    pub end_at: String,
}

/// Interprète une chaîne de date/heure.
/// Les formats YYYY-MM-DD sont interprétés en UTC à minuit (00:00:00Z) de manière déterministe.
fn parse_datetime_param(raw: &str) -> Result<DateTime<Utc>> {
    let clean = raw.trim();
    if let Ok(dt) = DateTime::parse_from_rfc3339(clean) {
        return Ok(dt.with_timezone(&Utc));
    }

    if let Ok(date) = chrono::NaiveDate::parse_from_str(clean, "%Y-%m-%d") {
        let naive = chrono::NaiveDateTime::new(date, chrono::NaiveTime::MIN);
        return Ok(DateTime::<Utc>::from_naive_utc_and_offset(naive, Utc));
    }

    bail!(
        "Invalid date format '{}'. Expected RFC3339 (e.g. 2026-07-29T10:00:00Z) or YYYY-MM-DD (interpreted in UTC)",
        clean
    )
}

pub async fn run(
    store: &SurrealBookingStore,
    from_raw: Option<String>,
    to_raw: Option<String>,
) -> Result<()> {
    let now = Utc::now();
    let from_dt = match from_raw {
        Some(s) => parse_datetime_param(&s)?,
        None => now - chrono::Duration::days(7),
    };

    let to_dt = match to_raw {
        Some(s) => parse_datetime_param(&s)?,
        None => now + chrono::Duration::days(30),
    };

    // 1. Contrôle du demi-intervalle [from, to) : from < to
    if from_dt >= to_dt {
        bail!(
            "Invalid time interval: --from ({}) must be strictly earlier than --to ({})",
            from_dt,
            to_dt
        );
    }

    // 2. Contrôle de la plage maximale permise (366 jours)
    let range_days = (to_dt - from_dt).num_days();
    if range_days > MAX_CALENDAR_RANGE_DAYS {
        bail!(
            "Requested range of {} days exceeds the maximum allowed limit of {} days",
            range_days,
            MAX_CALENDAR_RANGE_DAYS
        );
    }

    let params = CalendarEventsParams {
        from: from_dt.to_rfc3339(),
        to: to_dt.to_rfc3339(),
    };

    let events: Vec<CalendarEventRow> = store
        .call_fn("booking_get_calendar_events", params)
        .await?;

    if events.is_empty() {
        println!("No calendar events found in UTC period [{} .. {}).", from_dt, to_dt);
    } else {
        println!("Calendar events in UTC period [{} .. {}):", from_dt, to_dt);
        println!("{}", Table::new(events));
    }

    Ok(())
}
