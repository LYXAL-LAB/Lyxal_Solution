//! Microsoft Exchange Web Services (EWS) calendar provider.
//!
//! Targets on-prem **Exchange 2019** and earlier (2016, 2013) which all speak
//! the same SOAP protocol at `<host>/EWS/Exchange.asmx`. The implementation
//! intentionally keeps surface area minimal: we discover calendar folders,
//! fetch / write events, and run delta sync — nothing more. Anything more
//! exotic (free/busy of other users, room booking, delegate access) belongs
//! in a follow-up PR.
//!
//! ## Authentication
//!
//! HTTP Basic over TLS. NTLM and Kerberos are common in on-prem environments
//! but require additional crates (`reqwest` does not natively negotiate
//! either). For now, admins should either enable Basic on a service mailbox
//! or place a reverse proxy in front that handles the negotiate handshake.
//! See `docs/ews.md` (planned) for setup details.
//!
//! ## Layout
//!
//! - `autodiscover` — POX Autodiscover lookup so users can configure a source
//!   with just an email address.
//! - `soap` — envelope wrapping, basic auth, response parsing helpers.
//! - `operations` — typed wrappers for FindFolder, FindItem, GetItem,
//!   CreateItem, DeleteItem, SyncFolderItems.
//! - `parse` — XML response decoders.
//! - `ical` — synthesise an iCalendar block from EWS structured fields, used
//!   when MIME content is unavailable.
//!
//! The public surface is [`EwsProvider`], which implements
//! [`crate::providers::CalendarProvider`].

pub mod autodiscover;
pub mod ical;
pub mod operations;
pub mod parse;
pub mod soap;

use anyhow::Result;
use async_trait::async_trait;
use std::collections::HashMap;

use crate::providers::{CalendarProvider, DeltaResult, RawEvent, RemoteCalendar};

/// EWS-backed calendar provider. Constructed from the SOAP endpoint URL plus
/// credentials. Designed to be cheap to clone — no HTTP client cached on the
/// instance because each request rebuilds one with the appropriate timeout.
pub struct EwsProvider {
    endpoint: String,
    username: String,
    password: String,
}

impl EwsProvider {
    pub fn new(endpoint: &str, username: &str, password: &str) -> Result<Self> {
        let trimmed = endpoint.trim_end_matches('/');
        Self::validate_url(trimmed)?;
        Ok(Self {
            endpoint: trimmed.to_string(),
            username: username.to_string(),
            password: password.to_string(),
        })
    }

    /// Validate the URL the same way the CalDAV path does (HTTPS only,
    /// no SSRF-prone hostnames). Re-exported here so the source-add flow can
    /// validate before persisting.
    pub fn validate_url(url: &str) -> Result<()> {
        crate::caldav::validate_caldav_url(url)
    }
}

#[async_trait]
impl CalendarProvider for EwsProvider {
    async fn check_connection(&self) -> Result<bool> {
        operations::check_connection(&self.endpoint, &self.username, &self.password).await
    }

    async fn list_calendars(&self) -> Result<Vec<RemoteCalendar>> {
        let folders =
            operations::list_calendar_folders(&self.endpoint, &self.username, &self.password)
                .await?;
        Ok(folders
            .into_iter()
            .map(|f| RemoteCalendar {
                id: f.id,
                display_name: f.display_name,
                color: None,
                change_marker: f.change_key,
                sync_state: None,
            })
            .collect())
    }

    async fn fetch_events(&self, calendar_id: &str) -> Result<Vec<RawEvent>> {
        let items =
            operations::list_items(&self.endpoint, &self.username, &self.password, calendar_id)
                .await?;
        Ok(synth_raw_events(items))
    }

    async fn fetch_events_since(
        &self,
        calendar_id: &str,
        since_utc: &str,
    ) -> Result<Vec<RawEvent>> {
        let end_utc = upper_bound_iso(since_utc);
        let items = operations::list_items_in_window(
            &self.endpoint,
            &self.username,
            &self.password,
            calendar_id,
            since_utc,
            &end_utc,
        )
        .await?;
        Ok(synth_raw_events(items))
    }

    async fn sync_delta(&self, calendar_id: &str, sync_state: Option<&str>) -> Result<DeltaResult> {
        let delta = operations::sync_folder_items(
            &self.endpoint,
            &self.username,
            &self.password,
            calendar_id,
            sync_state,
        )
        .await?;

        // If caller passed None to seed cursor, return starting sync_state with empty items
        if sync_state.is_none() {
            return Ok(DeltaResult {
                added_or_changed: Vec::new(),
                deleted_remote_ids: Vec::new(),
                new_sync_state: delta.new_sync_state,
            });
        }

        // Real incremental sync: resolve added/changed items into iCal text via MIME
        let ids: Vec<&str> = delta
            .added_or_changed
            .iter()
            .map(|(id, _uid)| id.as_str())
            .collect();
        let mime_pairs = if ids.is_empty() {
            Vec::new()
        } else {
            operations::get_items_mime(&self.endpoint, &self.username, &self.password, &ids).await?
        };
        let mut mime_by_id: HashMap<String, String> = mime_pairs.into_iter().collect();

        let mut added_or_changed = Vec::with_capacity(delta.added_or_changed.len());
        for (id, _uid) in delta.added_or_changed {
            if let Some(ical) = mime_by_id.remove(&id) {
                added_or_changed.push(RawEvent {
                    remote_id: id,
                    ical,
                });
            }
        }

        let deleted_remote_ids = delta.deleted_item_ids;

        Ok(DeltaResult {
            added_or_changed,
            deleted_remote_ids,
            new_sync_state: delta.new_sync_state,
        })
    }

    async fn put_event(&self, calendar_id: &str, uid: &str, ics: &str) -> Result<()> {
        let existing = operations::find_items_by_uid(
            &self.endpoint,
            &self.username,
            &self.password,
            calendar_id,
            uid,
        )
        .await?;

        for item_id in &existing {
            operations::delete_item(&self.endpoint, &self.username, &self.password, item_id)
                .await?;
        }

        operations::create_item_from_ics(
            &self.endpoint,
            &self.username,
            &self.password,
            calendar_id,
            ics,
        )
        .await?;
        Ok(())
    }

    async fn delete_event(&self, calendar_id: &str, uid: &str) -> Result<()> {
        let existing = operations::find_items_by_uid(
            &self.endpoint,
            &self.username,
            &self.password,
            calendar_id,
            uid,
        )
        .await?;
        for item_id in &existing {
            operations::delete_item(&self.endpoint, &self.username, &self.password, item_id)
                .await?;
        }
        Ok(())
    }
}

/// Build a `RawEvent` for each item via [`ical::synth_vcalendar`].
///
/// We don't follow up with a MIME `GetItem` for recurring items: `CalendarView`
/// already expanded every occurrence in the requested window, and for those
/// virtual occurrence IDs Exchange frequently returns the metadata block
/// without `MimeContent` — which the parser then silently drops, losing the
/// entire series. Synthesising directly from the occurrence's own Start/End
/// keeps every one, and the `RECURRENCE-ID` emitted by `synth_vcalendar`
/// makes them addressable under their shared master UID.
fn synth_raw_events(items: Vec<parse::EwsCalendarItem>) -> Vec<RawEvent> {
    let mut out = Vec::with_capacity(items.len());
    for item in &items {
        if let Some(ics) = ical::synth_vcalendar(item) {
            out.push(RawEvent {
                remote_id: item.item_id.clone(),
                ical: ics,
            });
        }
    }
    out
}

/// Compute a far-enough upper bound for `CalendarView`. The input is the
/// caller's `since_utc` ISO 8601 string; we add roughly two years
/// (the horizon over which lyxal-booking ever needs free/busy data) and reformat as
/// RFC 3339 UTC. Anything we cannot parse falls back to "now + 2y".
fn upper_bound_iso(since_utc: &str) -> String {
    use chrono::{DateTime, Duration, Utc};

    if let Ok(parsed) = DateTime::parse_from_rfc3339(since_utc) {
        return (parsed + Duration::days(730))
            .with_timezone(&Utc)
            .to_rfc3339();
    }
    (Utc::now() + Duration::days(730)).to_rfc3339()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn upper_bound_extends_two_years() {
        let bound = upper_bound_iso("2026-05-06T00:00:00Z");
        // The result must be ~2 years after the input — basic sanity that the math works.
        assert!(bound.starts_with("2028-"));
    }

    #[test]
    fn upper_bound_falls_back_for_garbage_input() {
        let bound = upper_bound_iso("not-a-date");
        // Must still be parseable as RFC 3339.
        assert!(chrono::DateTime::parse_from_rfc3339(&bound).is_ok());
    }

    #[test]
    fn ews_provider_trims_trailing_slash() {
        let p = EwsProvider::new("https://mail.example.com/EWS/Exchange.asmx/", "u", "p").unwrap();
        assert_eq!(p.endpoint, "https://mail.example.com/EWS/Exchange.asmx");
    }

    // End-to-end probe against a real Exchange server. Ignored by default
    // because Exchange cannot be unit-tested; run explicitly with:
    //   EWS_URL=https://mail.example.com/EWS/Exchange.asmx \
    //   EWS_USER=alice@example.com \
    //   EWS_PASS=...                                       \
    //   cargo test ews_smoke -- --ignored --nocapture
    // Use EWS_EMAIL instead of EWS_URL to exercise autodiscover.
    #[tokio::test]
    #[ignore = "needs a real Exchange server; set EWS_URL/EWS_USER/EWS_PASS"]
    async fn ews_smoke() -> anyhow::Result<()> {
        let _ = tracing_subscriber::fmt()
            .with_env_filter(
                tracing_subscriber::EnvFilter::try_from_default_env()
                    .unwrap_or_else(|_| "lyxal_booking=debug,reqwest=info".into()),
            )
            .try_init();

        let url = std::env::var("EWS_URL").ok();
        let email = std::env::var("EWS_EMAIL").ok();
        let user = std::env::var("EWS_USER").expect("set EWS_USER");
        let pass = std::env::var("EWS_PASS").expect("set EWS_PASS");

        // --- 1. Resolve EWS endpoint -------------------------------------
        let endpoint = match url {
            Some(u) => {
                println!("[1] Using URL from EWS_URL: {}", u);
                u
            }
            None => {
                let email = email.expect("set EWS_URL or EWS_EMAIL for autodiscover");
                println!("[1] Running autodiscover for {}", email);
                autodiscover::discover_ews_url(&email, &pass).await?
            }
        };
        println!("    endpoint = {}", endpoint);

        let provider = EwsProvider::new(&endpoint, &user, &pass)?;

        // --- 2. check_connection -----------------------------------------
        print!("[2] check_connection()… ");
        match provider.check_connection().await {
            Ok(true) => println!("OK (calendar features advertised)"),
            Ok(false) => println!("connected, features uncertain"),
            Err(e) => {
                println!("FAILED: {:#}", e);
                return Err(e);
            }
        }

        // --- 3. list_calendars -------------------------------------------
        println!("[3] list_calendars()…");
        let calendars = provider.list_calendars().await?;
        println!("    {} calendar(s) discovered", calendars.len());
        for c in &calendars {
            println!(
                "    - {} (id={}…)",
                c.display_name.as_deref().unwrap_or("(unnamed)"),
                &c.id[..c.id.len().min(40)]
            );
        }
        if calendars.is_empty() {
            println!("    (no calendars — stopping here)");
            return Ok(());
        }

        // --- 4. fetch_events_since (last 7 days) -------------------------
        let target = &calendars[0];
        let since = (chrono::Utc::now() - chrono::Duration::days(7)).to_rfc3339();
        println!(
            "[4] fetch_events_since(target={}, since={})…",
            target.display_name.as_deref().unwrap_or(&target.id),
            since
        );
        let events = provider.fetch_events_since(&target.id, &since).await?;
        println!("    {} event(s) returned in the window", events.len());
        for ev in events.iter().take(3) {
            let preview = ev.ical.lines().take(8).collect::<Vec<_>>().join(" | ");
            println!("    - {}…", preview.chars().take(140).collect::<String>());
        }

        println!("\nSmoke test PASSED.");
        Ok(())
    }
}
