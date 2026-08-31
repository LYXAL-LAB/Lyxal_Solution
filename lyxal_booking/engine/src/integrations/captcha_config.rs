use anyhow::Result;
use lyxal_surreal::LyxalSurrealCall;
use serde::{Deserialize, Serialize};
use surrealdb::RecordId;

use crate::crypto_helpers::{encrypt_captcha_secret, BookingCryptoEngine};
use crate::db::SurrealBookingStore;

#[derive(Debug, Serialize)]
struct SetCaptchaConfigParams {
    id: RecordId,
    site_key: String,
    secret_enc: String,
}

#[derive(Debug, Deserialize)]
struct SetCaptchaConfigResult {
    updated: bool,
}

pub async fn set_captcha_config(
    store: &SurrealBookingStore,
    crypto: &BookingCryptoEngine,
    tenant: &str,
    site_key: &str,
    secret_raw: &str,
) -> Result<()> {
    let setting_id = RecordId::from(("booking_setting", "captcha_secret"));
    let secret_enc = encrypt_captcha_secret(crypto, tenant, &setting_id, secret_raw.as_bytes())?;

    let params = SetCaptchaConfigParams {
        id: setting_id,
        site_key: site_key.to_string(),
        secret_enc,
    };

    let _: serde_json::Value = store
        .call_fn("booking_set_captcha_config", params)
        .await?;

    Ok(())
}
