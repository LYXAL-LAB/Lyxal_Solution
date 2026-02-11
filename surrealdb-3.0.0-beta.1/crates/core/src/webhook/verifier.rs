//! Webhook Signature Verification
//!
//! Cryptographic verification for webhook signatures.
//! Supports HMAC-SHA256, Stripe-Signature, and extensible for RSA.

use std::collections::HashMap;
use sha2::{Digest, Sha256};
use subtle::ConstantTimeEq;

use super::error::{Result, WebhookError};
use super::types::WebhookVerifyMode;

/// Webhook signature verifier
pub struct WebhookVerifier;

impl WebhookVerifier {
    /// Verify a webhook signature based on the verification mode
    pub fn verify(
        mode: &WebhookVerifyMode,
        secret: Option<&str>,
        body: &[u8],
        headers: &HashMap<String, String>,
    ) -> Result<bool> {
        match mode {
            WebhookVerifyMode::None => Ok(true),
            WebhookVerifyMode::Hmac => Self::verify_hmac(secret, body, headers),
            WebhookVerifyMode::Stripe => Self::verify_stripe(secret, body, headers),
            WebhookVerifyMode::Rsa => Err(WebhookError::Internal(
                "RSA verification not yet implemented".to_string(),
            )),
            WebhookVerifyMode::Custom(name) => Err(WebhookError::Internal(format!(
                "Custom verification '{}' not implemented",
                name
            ))),
        }
    }

    /// Simple HMAC-SHA256 implementation without the hmac crate
    fn compute_hmac_sha256(key: &[u8], data: &[u8]) -> Vec<u8> {
        // HMAC implementation: H(K XOR opad, H(K XOR ipad, message))
        const BLOCK_SIZE: usize = 64;
        
        // Normalize key
        let key = if key.len() > BLOCK_SIZE {
            let mut hasher = Sha256::new();
            hasher.update(key);
            hasher.finalize().to_vec()
        } else {
            key.to_vec()
        };
        
        // Pad key to block size
        let mut padded_key = vec![0u8; BLOCK_SIZE];
        padded_key[..key.len()].copy_from_slice(&key);
        
        // Create ipad and opad
        let mut ipad = vec![0x36u8; BLOCK_SIZE];
        let mut opad = vec![0x5cu8; BLOCK_SIZE];
        for i in 0..BLOCK_SIZE {
            ipad[i] ^= padded_key[i];
            opad[i] ^= padded_key[i];
        }
        
        // Inner hash: H(K XOR ipad, message)
        let mut inner_hasher = Sha256::new();
        inner_hasher.update(&ipad);
        inner_hasher.update(data);
        let inner_hash = inner_hasher.finalize();
        
        // Outer hash: H(K XOR opad, inner_hash)
        let mut outer_hasher = Sha256::new();
        outer_hasher.update(&opad);
        outer_hasher.update(&inner_hash);
        outer_hasher.finalize().to_vec()
    }

    /// Verify HMAC-SHA256 signature
    ///
    /// Supports common header formats:
    /// - X-Signature: <hex>
    /// - X-Hub-Signature-256: sha256=<hex>
    /// - X-Webhook-Signature: <hex>
    fn verify_hmac(
        secret: Option<&str>,
        body: &[u8],
        headers: &HashMap<String, String>,
    ) -> Result<bool> {
        let secret = secret.ok_or_else(|| WebhookError::SecretNotConfigured {
            name: "HMAC".to_string(),
        })?;

        // Try common signature headers
        let signature_hex = Self::extract_signature(headers, &[
            "x-signature",
            "x-hub-signature-256",
            "x-webhook-signature",
            "x-signature-256",
        ])?;

        // Strip "sha256=" prefix if present
        let signature_hex = signature_hex
            .strip_prefix("sha256=")
            .unwrap_or(&signature_hex);

        // Compute expected signature
        let expected = Self::compute_hmac_sha256(secret.as_bytes(), body);

        // Decode provided signature
        let provided = hex::decode(signature_hex).map_err(|_| WebhookError::SignatureInvalid {
            reason: "Invalid hex encoding in signature".to_string(),
        })?;

        // Constant-time comparison to prevent timing attacks
        if expected.as_slice().ct_eq(&provided).into() {
            Ok(true)
        } else {
            Ok(false)
        }
    }

    /// Verify Stripe-Signature header
    ///
    /// Format: t=<timestamp>,v1=<signature>[,v0=<signature>]
    /// Verifies: HMAC-SHA256(timestamp + "." + payload)
    fn verify_stripe(
        secret: Option<&str>,
        body: &[u8],
        headers: &HashMap<String, String>,
    ) -> Result<bool> {
        let secret = secret.ok_or_else(|| WebhookError::SecretNotConfigured {
            name: "Stripe".to_string(),
        })?;

        let header = headers
            .get("stripe-signature")
            .or_else(|| headers.get("Stripe-Signature"))
            .ok_or_else(|| WebhookError::MissingHeader {
                header: "Stripe-Signature".to_string(),
            })?;

        // Parse the header
        let mut timestamp: Option<i64> = None;
        let mut signatures: Vec<String> = Vec::new();

        for part in header.split(',') {
            let mut kv = part.splitn(2, '=');
            match (kv.next(), kv.next()) {
                (Some("t"), Some(t)) => {
                    timestamp = t.parse().ok();
                }
                (Some("v1"), Some(sig)) => {
                    signatures.push(sig.to_string());
                }
                _ => {}
            }
        }

        let timestamp = timestamp.ok_or_else(|| WebhookError::SignatureInvalid {
            reason: "Missing timestamp in Stripe-Signature".to_string(),
        })?;

        if signatures.is_empty() {
            return Err(WebhookError::SignatureInvalid {
                reason: "No v1 signature found in Stripe-Signature".to_string(),
            });
        }

        // Check timestamp (5 minute tolerance for replay protection)
        let now = chrono::Utc::now().timestamp();
        let tolerance = 300; // 5 minutes
        if (now - timestamp).abs() > tolerance {
            return Err(WebhookError::SignatureExpired);
        }

        // Compute expected signature: HMAC-SHA256(timestamp + "." + payload)
        let signed_payload = format!("{}.{}", timestamp, String::from_utf8_lossy(body));
        let expected = hex::encode(Self::compute_hmac_sha256(
            secret.as_bytes(),
            signed_payload.as_bytes(),
        ));

        // Check if any of the provided signatures match
        for sig in &signatures {
            if expected.as_bytes().ct_eq(sig.as_bytes()).into() {
                return Ok(true);
            }
        }

        Ok(false)
    }

    /// Extract signature from headers, trying multiple header names
    fn extract_signature(headers: &HashMap<String, String>, names: &[&str]) -> Result<String> {
        for name in names {
            // Try lowercase
            if let Some(sig) = headers.get(*name) {
                return Ok(sig.clone());
            }
            // Try with different cases
            let upper = name.to_uppercase();
            if let Some(sig) = headers.get(&upper) {
                return Ok(sig.clone());
            }
            // Try HTTP-style header case
            let title_case: String = name
                .split('-')
                .map(|part| {
                    let mut chars = part.chars();
                    match chars.next() {
                        None => String::new(),
                        Some(c) => c.to_uppercase().collect::<String>() + chars.as_str(),
                    }
                })
                .collect::<Vec<_>>()
                .join("-");
            if let Some(sig) = headers.get(&title_case) {
                return Ok(sig.clone());
            }
        }

        Err(WebhookError::MissingHeader {
            header: names.join(" or "),
        })
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_hmac_verification() {
        let secret = "test_secret";
        let body = b"test payload";

        // Compute expected signature
        let signature = hex::encode(WebhookVerifier::compute_hmac_sha256(secret.as_bytes(), body));

        let mut headers = HashMap::new();
        headers.insert("x-signature".to_string(), signature);

        let result = WebhookVerifier::verify_hmac(Some(secret), body, &headers);
        assert!(result.is_ok());
        assert!(result.unwrap());
    }

    #[test]
    fn test_hmac_invalid_signature() {
        let secret = "test_secret";
        let body = b"test payload";

        let mut headers = HashMap::new();
        headers.insert("x-signature".to_string(), "invalid_signature".to_string());

        let result = WebhookVerifier::verify_hmac(Some(secret), body, &headers);
        // Should fail to decode hex
        assert!(result.is_err());
    }

    #[test]
    fn test_stripe_signature_format() {
        let secret = "whsec_test";
        let body = b"test payload";
        let timestamp = chrono::Utc::now().timestamp();

        // Compute expected signature
        let signed_payload = format!("{}.{}", timestamp, String::from_utf8_lossy(body));
        let signature = hex::encode(WebhookVerifier::compute_hmac_sha256(
            secret.as_bytes(),
            signed_payload.as_bytes(),
        ));

        let header = format!("t={},v1={}", timestamp, signature);
        let mut headers = HashMap::new();
        headers.insert("stripe-signature".to_string(), header);

        let result = WebhookVerifier::verify_stripe(Some(secret), body, &headers);
        assert!(result.is_ok());
        assert!(result.unwrap());
    }
}
