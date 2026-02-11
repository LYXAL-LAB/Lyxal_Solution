use crate::fnc::util::crypto::{get_scheduler_secret, derive_key, xor_cipher};
use crate::val::Value;
use uuid::Uuid;
use anyhow::Result;

pub(crate) fn encrypt_payload(payload: &Value) -> Result<String> {
    let secret = get_scheduler_secret();
    // Use native LyxalRevisioned serialization
    let data = lyxal_revision::to_vec(payload).map_err(|e| anyhow::anyhow!(e.to_string()))?;
    let salt = Uuid::new_v4().into_bytes().to_vec();
    let key = derive_key(&secret, &salt);
    let ciphered = xor_cipher(&data, &key);
    
    let mut result = salt;
    result.extend_from_slice(&ciphered);
    Ok(base64::encode(result))
}

pub fn decrypt_payload(encrypted_data: &str) -> Result<serde_json::Value> {
    let secret = get_scheduler_secret();
    let decoded = base64::decode(encrypted_data).map_err(|e| anyhow::anyhow!(e.to_string()))?;
    if decoded.len() < 16 {
        return Err(anyhow::anyhow!("Invalid encrypted payload length"));
    }
    
    let (salt, ciphered) = decoded.split_at(16);
    let key = derive_key(&secret, salt);
    let data = xor_cipher(ciphered, &key);
    
    // Decode directly to Value via lyxal_revision
    let val: Value = lyxal_revision::from_slice(&data).map_err(|e| anyhow::anyhow!(e.to_string()))?;
    
    // Use to_raw_string() to get the JSON-like representation of Value
    serde_json::from_str(&val.to_raw_string()).map_err(|e| anyhow::anyhow!(e.to_string()))
}
