use anyhow::Result;
use lyxal_surreal::LyxalSurrealCall;
use serde::{Deserialize, Serialize};
use surrealdb::RecordId;

use crate::crypto_helpers::{encrypt_smtp_password, BookingCryptoEngine};
use crate::db::SurrealBookingStore;

#[derive(Debug, Serialize)]
struct SetSmtpConfigParams {
    id: RecordId,
    host: String,
    port: u16,
    username: String,
    password_enc: String,
    from_email: String,
}

pub async fn set_smtp_config(
    store: &SurrealBookingStore,
    crypto: &BookingCryptoEngine,
    tenant: &str,
    host: &str,
    port: u16,
    username: &str,
    password_raw: &str,
    from_email: &str,
) -> Result<()> {
    let setting_id = RecordId::from(("booking_setting", "smtp_config"));
    let password_enc = encrypt_smtp_password(crypto, tenant, &setting_id, password_raw.as_bytes())?;

    let params = SetSmtpConfigParams {
        id: setting_id,
        host: host.to_string(),
        port,
        username: username.to_string(),
        password_enc,
        from_email: from_email.to_string(),
    };

    let _: serde_json::Value = store
        .call_fn("booking_set_smtp_config", params)
        .await?;

    Ok(())
}
