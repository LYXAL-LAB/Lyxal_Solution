//! HMAC-SHA256 with distinct 256-bit keys and constant-time tag verification.
use crate::{CryptoError, ExternalHmacKey, HmacKey};
use hmac::{Hmac, Mac};
use sha2::Sha256;
type HmacSha256 = Hmac<Sha256>;
pub(crate) fn sign_bytes(key: &[u8], data: &[u8]) -> Result<[u8; 32], CryptoError> {
    let mut mac = HmacSha256::new_from_slice(key).map_err(|_| CryptoError::InvalidKeyLength)?;
    mac.update(data);
    Ok(mac.finalize().into_bytes().into())
}
pub(crate) fn verify_bytes(key: &[u8], data: &[u8], tag: &[u8]) -> Result<bool, CryptoError> {
    if tag.len() != 32 {
        return Err(CryptoError::InvalidTagEncoding);
    }
    let mut mac = HmacSha256::new_from_slice(key).map_err(|_| CryptoError::InvalidKeyLength)?;
    mac.update(data);
    Ok(mac.verify_slice(tag).is_ok())
}
/// Sign arbitrary bytes; caller controls admission and message-stream budgets.
pub fn sign_hmac_sha256(key: &HmacKey, data: &[u8]) -> Result<[u8; 32], CryptoError> {
    sign_bytes(key.expose(), data)
}
/// Verify exactly 32 tag bytes. Mismatch is false; malformed length is an error.
pub fn verify_hmac_sha256(key: &HmacKey, data: &[u8], tag: &[u8]) -> Result<bool, CryptoError> {
    verify_bytes(key.expose(), data, tag)
}
/// Explicit lowercase hex encoding of an authentication tag.
pub fn sign_hmac_sha256_hex(key: &HmacKey, data: &[u8]) -> Result<String, CryptoError> {
    Ok(hex::encode(sign_hmac_sha256(key, data)?))
}
/// Verify exactly 64 hex characters without trimming or input-sized allocation.
pub fn verify_hmac_sha256_hex(
    key: &HmacKey,
    data: &[u8],
    encoded: &str,
) -> Result<bool, CryptoError> {
    if encoded.len() != 64 {
        return Err(CryptoError::InvalidTagEncoding);
    }
    let mut tag = [0; 32];
    hex::decode_to_slice(encoded, &mut tag).map_err(|_| CryptoError::InvalidTagEncoding)?;
    verify_hmac_sha256(key, data, &tag)
}
/// Sign with a third-party protocol key (webhook of a provider), used as given (RFC 2104).
pub fn sign_external_hmac_sha256(
    key: &ExternalHmacKey,
    data: &[u8],
) -> Result<[u8; 32], CryptoError> {
    sign_bytes(key.expose(), data)
}
/// Verify exactly 32 tag bytes under a third-party protocol key, in constant time. Mismatch is
/// false; malformed length is an error.
pub fn verify_external_hmac_sha256(
    key: &ExternalHmacKey,
    data: &[u8],
    tag: &[u8],
) -> Result<bool, CryptoError> {
    verify_bytes(key.expose(), data, tag)
}
/// Verify exactly 20 tag bytes of HMAC-SHA1 under a third-party protocol key, in constant time
/// (`aws-lc-rs`). Verification only, for a provider that still signs with SHA-1 (Twilio's
/// `X-Twilio-Signature`, CTO decision K8): no signing function is offered. Mismatch is false;
/// malformed length is an error.
pub fn verify_external_hmac_sha1(
    key: &ExternalHmacKey,
    data: &[u8],
    tag: &[u8],
) -> Result<bool, CryptoError> {
    if tag.len() != 20 {
        return Err(CryptoError::InvalidTagEncoding);
    }
    let key =
        aws_lc_rs::hmac::Key::new(aws_lc_rs::hmac::HMAC_SHA1_FOR_LEGACY_USE_ONLY, key.expose());
    Ok(aws_lc_rs::hmac::verify(&key, data, tag).is_ok())
}
#[cfg(test)]
mod vectors {
    include!("hmac_vectors.rs");
}
#[cfg(test)]
mod external {
    use super::*;
    use crate::{SecretBytes, MAX_EXTERNAL_HMAC_KEY_BYTES};

    fn key(bytes: &[u8]) -> Result<ExternalHmacKey, CryptoError> {
        ExternalHmacKey::import(SecretBytes::new(bytes.to_vec()).expect("secret"))
    }

    #[test]
    fn external_keys_of_any_length_follow_rfc_4231() {
        // Cas 2 : clé de 4 octets
        let short = key(b"Jefe").expect("clé");
        let tag = sign_external_hmac_sha256(&short, b"what do ya want for nothing?").expect("tag");
        assert_eq!(
            hex::encode(tag),
            "5bdcc146bf60754e6a042426089575c75a003f089d2739839dec58b964ec3843"
        );
        assert!(
            verify_external_hmac_sha256(&short, b"what do ya want for nothing?", &tag)
                .expect("verify")
        );
        // Cas 6 : clé de 131 octets (plus longue qu'un bloc)
        let long = key(&[0xaa; 131]).expect("clé");
        let tag = sign_external_hmac_sha256(
            &long,
            b"Test Using Larger Than Block-Size Key - Hash Key First",
        )
        .expect("tag");
        assert_eq!(
            hex::encode(tag),
            "60e431591ee0b67f0d8a26aacbf5b77f8e0bc6213728c5140546040f0ee37f54"
        );
        // Clé de 33 à 64 octets (ex. clé Mailgun « key-… ») : acceptée telle quelle
        let middle = key(&[7; 40]).expect("clé");
        let tag = sign_external_hmac_sha256(&middle, b"data").expect("tag");
        assert_eq!(tag, sign_bytes(&[7; 40], b"data").expect("tag"));
        assert!(!verify_external_hmac_sha256(&middle, b"autre", &tag).expect("verify"));
        assert!(matches!(
            verify_external_hmac_sha256(&middle, b"data", &tag[..31]),
            Err(CryptoError::InvalidTagEncoding)
        ));
    }

    #[test]
    fn external_sha1_verification_follows_rfc_2202() {
        // RFC 2202, cas 1 à 7 : (clé, données, étiquette attendue)
        let block_key = vec![0xaa; 80];
        let cases: [(Vec<u8>, Vec<u8>, &str); 7] = [
            (
                vec![0x0b; 20],
                b"Hi There".to_vec(),
                "b617318655057264e28bc0b6fb378c8ef146be00",
            ),
            (
                b"Jefe".to_vec(),
                b"what do ya want for nothing?".to_vec(),
                "effcdf6ae5eb2fa2d27416d5f184df9c259a7c79",
            ),
            (
                vec![0xaa; 20],
                vec![0xdd; 50],
                "125d7342b9ac11cd91a39af48aa17b4f63f175d3",
            ),
            (
                (1u8..=25).collect(),
                vec![0xcd; 50],
                "4c9007f4026250c6bc8414f9bf50c86c2d7235da",
            ),
            (
                vec![0x0c; 20],
                b"Test With Truncation".to_vec(),
                "4c1a03424b55e07fe7f27be1d58bb9324a9a5a04",
            ),
            (
                block_key.clone(),
                b"Test Using Larger Than Block-Size Key - Hash Key First".to_vec(),
                "aa4ae5e15272d00e95705637ce8a3b55ed402112",
            ),
            (
                block_key,
                b"Test Using Larger Than Block-Size Key and Larger Than One Block-Size Data"
                    .to_vec(),
                "e8e99d0f45237d786d6bbaa7965c7808bbff1a91",
            ),
        ];
        for (index, (raw, data, expected)) in cases.iter().enumerate() {
            let case = index + 1;
            let key = key(raw).expect("clé");
            let tag = hex::decode(expected).expect("hex");
            assert!(
                verify_external_hmac_sha1(&key, data, &tag).expect("verify"),
                "cas {case}"
            );
            let mut altered = tag.clone();
            altered[19] ^= 1;
            assert!(
                !verify_external_hmac_sha1(&key, data, &altered).expect("verify"),
                "cas {case}"
            );
            assert!(
                !verify_external_hmac_sha1(&key, b"autre", &tag).expect("verify"),
                "cas {case}"
            );
        }
        let key = key(b"Jefe").expect("clé");
        for length in [0, 19, 21, 32] {
            assert!(matches!(
                verify_external_hmac_sha1(&key, b"data", &vec![0; length]),
                Err(CryptoError::InvalidTagEncoding)
            ));
        }
    }

    #[test]
    fn external_key_bounds_and_debug() {
        assert!(matches!(key(&[]), Err(CryptoError::InvalidKeyLength)));
        assert!(matches!(
            key(&vec![1; MAX_EXTERNAL_HMAC_KEY_BYTES + 1]),
            Err(CryptoError::InvalidKeyLength)
        ));
        let accepted = key(&vec![1; MAX_EXTERNAL_HMAC_KEY_BYTES]).expect("clé");
        assert_eq!(format!("{accepted:?}"), "ExternalHmacKey([REDACTED])");
    }
}
