use anyhow::Result;
use lyxal_surreal::LyxalSurrealCall;
use serde::{Deserialize, Serialize};
use surrealdb::RecordId;

use crate::crypto_helpers::{encrypt_google_client_secret, BookingCryptoEngine};
use crate::db::SurrealBookingStore;

#[derive(Debug, Serialize)]
struct SetOauthConfigParams {
    id: RecordId,
    client_id: String,
    client_secret_enc: String,
}

pub async fn set_google_oauth_config(
    store: &SurrealBookingStore,
    crypto: &BookingCryptoEngine,
    tenant: &str,
    client_id: &str,
    client_secret_raw: &str,
) -> Result<()> {
    let setting_id = RecordId::from(("booking_setting", "auth_config"));
    let client_secret_enc = encrypt_google_client_secret(crypto, tenant, &setting_id, client_secret_raw.as_bytes())?;

    let params = SetOauthConfigParams {
        id: setting_id,
        client_id: client_id.to_string(),
        client_secret_enc,
    };

    let _: serde_json::Value = store
        .call_fn("booking_set_google_oauth_config", params)
        .await?;

    Ok(())
}
