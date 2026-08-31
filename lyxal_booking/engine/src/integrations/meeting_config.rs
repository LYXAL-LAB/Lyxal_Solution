use anyhow::Result;
use lyxal_surreal::LyxalSurrealCall;
use serde::{Deserialize, Serialize};
use surrealdb::RecordId;

use crate::crypto_helpers::{encrypt_meeting_webhook_secret, BookingCryptoEngine};
use crate::db::SurrealBookingStore;

#[derive(Debug, Serialize)]
struct SetMeetingConfigParams {
    id: RecordId,
    webhook_url: String,
    secret_enc: String,
}

pub async fn set_meeting_config(
    store: &SurrealBookingStore,
    crypto: &BookingCryptoEngine,
    tenant: &str,
    webhook_url: &str,
    secret_raw: &str,
) -> Result<()> {
    let setting_id = RecordId::from(("booking_setting", "meeting_webhook_secret"));
    let secret_enc = encrypt_meeting_webhook_secret(crypto, tenant, &setting_id, secret_raw.as_bytes())?;

    let params = SetMeetingConfigParams {
        id: setting_id,
        webhook_url: webhook_url.to_string(),
        secret_enc,
    };

    let _: serde_json::Value = store
        .call_fn("booking_set_meeting_config", params)
        .await?;

    Ok(())
}
