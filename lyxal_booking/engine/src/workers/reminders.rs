use std::sync::Arc;
use crate::crypto_helpers::BookingCryptoEngine;
use crate::db::{surreal_query_opt, surreal_query_vec, SurrealBookingStore};
use lyxal_crypto::EncryptionKey;
use surrealdb::sql::Thing;

#[derive(Debug, serde::Deserialize)]
struct DueReminderRow {
    booking_id: Thing,
    guest_name: String,
    guest_email: String,
    guest_timezone: String,
    start_at: String,
    end_at: String,
    event_title: String,
    host_name: String,
    host_email: String,
    location_value: Option<String>,
    cancel_token: Option<String>,
    uid: String,
    guest_language: Option<String>,
    host_language: Option<String>,
    host_timezone: Option<String>,
}

pub async fn run_reminder_loop(
    store: SurrealBookingStore,
    crypto: Arc<BookingCryptoEngine>,
    legacy_secret_key: Option<Arc<EncryptionKey>>,
    shutdown: tokio_util::sync::CancellationToken,
) -> anyhow::Result<()> {
    let mut last_session_cleanup = std::time::Instant::now();
    loop {
        tokio::select! {
            _ = shutdown.cancelled() => {
                tracing::info!("Reminder worker gracefully stopping");
                return Ok(());
            }
            _ = tokio::time::sleep(std::time::Duration::from_secs(60)) => {
                if last_session_cleanup.elapsed() >= std::time::Duration::from_secs(3600) {
                    match crate::auth::cleanup_expired_sessions(&store, "fr").await {
                        Ok(count) if count > 0 => {
                            tracing::info!(count, "expired sessions pruned");
                        }
                        Ok(_) => {}
                        Err(e) => tracing::warn!(error = %e, "session cleanup failed"),
                    }
                    last_session_cleanup = std::time::Instant::now();
                }

                let due_res: Result<Vec<DueReminderRow>, lyxal_surreal::LyxalSurrealError> = surreal_query_vec(
                    store.client().query("RETURN fn::booking_get_due_reminders();").await
                );

                let due_rows = match due_res {
                    Ok(rows) => rows,
                    Err(error) => {
                        tracing::error!(%error, "Failed to load due reminders; retrying on next tick");
                        Vec::new()
                    }
                };

                if !due_rows.is_empty() {
                    tracing::info!(count = due_rows.len(), "Processing due reminders");
                }

                super::calendar_sync::run_calendar_sync_step(&store, &crypto, legacy_secret_key.as_deref()).await;
            }
        }
    }
}
