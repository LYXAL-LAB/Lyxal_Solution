use std::sync::Arc;
use crate::crypto_helpers::BookingCryptoEngine;
use crate::db::{surreal_query_opt, SurrealBookingStore};
use lyxal_crypto::EncryptionKey;

#[derive(Debug, serde::Deserialize)]
struct StalestCaldavSourceRow {
    source_id: surrealdb::sql::Thing,
}

pub async fn run_calendar_sync_step(
    store: &SurrealBookingStore,
    crypto: &Arc<BookingCryptoEngine>,
    legacy_secret_key: Option<&EncryptionKey>,
) {
    let stalest_res: Result<Option<StalestCaldavSourceRow>, lyxal_surreal::LyxalSurrealError> =
        surreal_query_opt(
            store
                .client()
                .query("RETURN fn::booking_get_stalest_caldav_source();")
                .await,
        );

    if let Ok(Some(stalest)) = stalest_res {
        if let Err(error) = crate::commands::sync::sync_source_by_id(
            store,
            crypto.as_ref(),
            legacy_secret_key,
            "default",
            &surrealdb::RecordId::from(("calendar_source", stalest.source_id.id.to_raw())),
        )
        .await
        {
            tracing::warn!(
                %error,
                source_id = %stalest.source_id,
                "Background CalDAV synchronization failed"
            );
        }
    }
}
