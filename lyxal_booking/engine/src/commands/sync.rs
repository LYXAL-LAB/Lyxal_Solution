use anyhow::{bail, Result};
use lyxal_crypto::EncryptionKey;
use lyxal_surreal::LyxalSurrealCall;
use serde::{Deserialize, Serialize};
use surrealdb::sql::Datetime;
use surrealdb::RecordId;

use crate::crypto_helpers::{decrypt_caldav_password, BookingCryptoEngine};
use crate::db::SurrealBookingStore;
use crate::providers::factory::build_provider;
use crate::providers::CalendarProvider;

#[allow(dead_code)]
#[derive(Debug, Deserialize)]
pub struct CaldavSourceDetails {
    pub id: RecordId,
    pub provider: String,
    pub auth_kind: Option<String>,
    pub url: String,
    pub username: String,
    #[serde(alias = "password")]
    pub password_enc: Option<String>,
    #[serde(alias = "access_token")]
    pub access_token_enc: Option<String>,
    #[serde(alias = "refresh_token")]
    pub refresh_token_enc: Option<String>,
    pub token_expires_at: Option<Datetime>,
    pub sync_status: Option<String>,
    pub sync_state: Option<String>,
}

#[allow(dead_code)]
#[derive(Debug, Deserialize)]
struct CalendarState {
    id: RecordId,
    href: String,
    sync_state: Option<String>,
}

#[derive(Debug, Serialize)]
struct UpdateSourceStatusParams {
    source_id: RecordId,
    sync_status: String,
    last_sync_error: Option<String>,
}

#[derive(Debug, Default)]
pub struct SyncStats {
    pub total_sources: usize,
    pub succeeded_sources: usize,
    pub failed_sources: usize,
    pub events_synced: usize,
}

pub async fn run(
    store: &SurrealBookingStore,
    crypto: &BookingCryptoEngine,
    legacy_key: Option<&EncryptionKey>,
    tenant: &str,
    full: bool,
) -> Result<()> {
    println!("Starting calendar synchronization (Full sync: {})...", full);

    let sources: Vec<CaldavSourceDetails> = store
        .call_fn("booking_list_all_caldav_sources", serde_json::json!({}))
        .await?;

    if sources.is_empty() {
        println!("No active calendar sources configured for sync.");
        return Ok(());
    }

    let mut stats = SyncStats {
        total_sources: sources.len(),
        ..Default::default()
    };

    for source in &sources {
        println!("Syncing source '{}' ({})", source.id, source.url);
        match sync_source_internal(store, crypto, legacy_key, tenant, source, full).await {
            Ok(count) => {
                stats.succeeded_sources += 1;
                stats.events_synced += count;
            }
            Err(err) => {
                stats.failed_sources += 1;
                eprintln!("Failed to sync source '{}': {}", source.id, err);
            }
        }
    }

    println!(
        "Synchronization complete: {} succeeded, {} failed ({} total events processed).",
        stats.succeeded_sources, stats.failed_sources, stats.events_synced
    );

    if stats.succeeded_sources == 0 && stats.total_sources > 0 {
        bail!("All {} calendar source syncs failed.", stats.total_sources);
    }

    Ok(())
}

pub async fn sync_source_by_id(
    store: &SurrealBookingStore,
    crypto: &BookingCryptoEngine,
    legacy_key: Option<&EncryptionKey>,
    tenant: &str,
    source_id: &RecordId,
) -> Result<()> {
    tracing::debug!(source_id = %source_id, "Background CalDAV sync triggered");

    let source: Option<CaldavSourceDetails> = store
        .call_fn(
            "booking_get_caldav_source_by_id",
            serde_json::json!({ "id": source_id }),
        )
        .await?;

    let source = match source {
        Some(s) => s,
        None => bail!("Source not found: {}", source_id),
    };

    sync_source_internal(store, crypto, legacy_key, tenant, &source, false).await?;
    Ok(())
}

async fn sync_source_internal(
    store: &SurrealBookingStore,
    crypto: &BookingCryptoEngine,
    legacy_key: Option<&EncryptionKey>,
    tenant: &str,
    source: &CaldavSourceDetails,
    force_full: bool,
) -> Result<usize> {
    let auth_kind = source.auth_kind.as_deref().unwrap_or("basic");

    let provider: Box<dyn CalendarProvider> = match (source.provider.as_str(), auth_kind) {
        ("caldav", "basic") | ("ews", "basic") => {
            let password_enc = source
                .password_enc
                .as_deref()
                .ok_or_else(|| anyhow::anyhow!("Missing encrypted password for source {}", source.id))?;

            let secret_bytes = decrypt_caldav_password(
                crypto,
                legacy_key,
                tenant,
                &source.id,
                password_enc,
            )?;
            let plain_password = String::from_utf8((*secret_bytes).clone())?;

            build_provider(&source.provider, &source.url, &source.username, &plain_password)?
        }
        ("caldav", "oauth2") => {
            if source.sync_status.as_deref() == Some("pending_oauth") {
                bail!("Source {} is pending OAuth consent", source.id);
            }

            let expiry_str = source.token_expires_at.as_ref().map(|dt| dt.0.to_rfc3339());
            let client = crate::oauth2_caldav::build_client_for_source(
                store,
                crypto,
                legacy_key,
                tenant,
                &source.id,
                &source.url,
                "oauth2",
                &source.username,
                None,
                source.access_token_enc.as_deref(),
                expiry_str.as_deref(),
            )
            .await?;

            Box::new(crate::providers::caldav::CaldavProvider::from_client(client))
        }
        ("ews", "oauth2") => {
            bail!("EWS OAuth2 authentication is not supported yet.");
        }
        (other, _) => bail!("Unsupported provider type: {}", other),
    };

    let calendars = provider.list_calendars().await?;
    let mut events_processed = 0;

    for cal in calendars {
        let existing_cal: Option<CalendarState> = store
            .call_fn(
                "booking_get_calendar_by_href",
                serde_json::json!({
                    "source_id": source.id,
                    "calendar_href": cal.id,
                }),
            )
            .await?;

        let cal_sync_token = existing_cal.as_ref().and_then(|c| c.sync_state.clone());
        let is_full_sync = force_full || cal_sync_token.is_none();

        if is_full_sync {
            let raw_events = provider.fetch_events(&cal.id).await?;
            let delta = provider.sync_delta(&cal.id, None).await?;
            let new_state = delta.new_sync_state.or(cal.sync_state);

            let payload_events: Vec<serde_json::Value> = raw_events
                .iter()
                .map(|ev| {
                    serde_json::json!({
                        "remote_id": ev.remote_id,
                        "ical": ev.ical,
                    })
                })
                .collect();

            let count = payload_events.len();

            // Single 1-transaction Full Sync atomique (upsert, suppression des orphelins & mise à jour du token)
            let _: serde_json::Value = store
                .call_fn(
                    "booking_replace_synchronized_calendar_snapshot",
                    serde_json::json!({
                        "source_id": source.id,
                        "calendar_id": cal.id,
                        "events": payload_events,
                        "sync_state": new_state,
                    }),
                )
                .await?;

            events_processed += count;
        } else {
            let delta = provider
                .sync_delta(&cal.id, cal_sync_token.as_deref())
                .await?;

            for ev in delta.added_or_changed {
                let _: serde_json::Value = store
                    .call_fn(
                        "booking_upsert_synchronized_event",
                        serde_json::json!({
                            "source_id": source.id,
                            "calendar_id": cal.id,
                            "remote_id": ev.remote_id,
                            "ical": ev.ical,
                        }),
                    )
                    .await?;
                events_processed += 1;
            }

            for remote_id in delta.deleted_remote_ids {
                // Suppression distante avec contrat remote_id exact
                let _: serde_json::Value = store
                    .call_fn(
                        "booking_delete_synchronized_event_by_remote_id",
                        serde_json::json!({
                            "source_id": source.id,
                            "calendar_id": cal.id,
                            "remote_id": remote_id,
                        }),
                    )
                    .await?;
            }

            let _: serde_json::Value = store
                .call_fn(
                    "booking_update_calendar_sync_state",
                    serde_json::json!({
                        "source_id": source.id,
                        "calendar_href": cal.id,
                        "sync_state": delta.new_sync_state,
                    }),
                )
                .await?;
        }
    }

    let _: serde_json::Value = store
        .call_fn(
            "booking_update_caldav_source_status",
            UpdateSourceStatusParams {
                source_id: source.id.clone(),
                sync_status: "active".to_string(),
                last_sync_error: None,
            },
        )
        .await?;

    Ok(events_processed)
}
