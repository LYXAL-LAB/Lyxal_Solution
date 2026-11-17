//! Web Push message encryption (RFC 8291, CTO decision K8): `aes128gcm` content coding of
//! RFC 8188 with a single record of size 4096 and the padding delimiter `0x02`. A fresh P-256
//! ECDH key pair and a fresh 16-byte salt per message; HKDF-SHA256 as in RFC 8291 §3.3–3.4;
//! AES-128-GCM. Computed by `ring` (`agreement`, `hkdf`, `aead`); the salt is drawn from
//! `rand_core::OsRng`. Intermediate keys live in wiped buffers.
use crate::CryptoError;
use rand_core::{OsRng, RngCore};
use ring::aead::{Aad, LessSafeKey, Nonce, UnboundKey, AES_128_GCM};
use ring::agreement::{agree_ephemeral, EphemeralPrivateKey, UnparsedPublicKey, ECDH_P256};
use ring::hkdf::{KeyType, Salt, HKDF_SHA256};
use ring::rand::SystemRandom;
use zeroize::Zeroizing;

/// Record size written in the RFC 8188 header.
pub const WEBPUSH_RECORD_SIZE: u32 = 4096;
/// Bytes added to the plaintext: header (salt 16, record size 4, key length 1, public key 65),
/// padding delimiter 1 and authentication tag 16.
pub const WEBPUSH_OVERHEAD_BYTES: usize = 16 + 4 + 1 + 65 + 1 + 16;
/// Largest plaintext of the single record (record size minus delimiter and tag).
pub const WEBPUSH_MAX_PLAINTEXT_BYTES: usize = WEBPUSH_RECORD_SIZE as usize - 1 - 16;

/// Output length requested from HKDF-Expand.
struct Len(usize);
impl KeyType for Len {
    fn len(&self) -> usize {
        self.0
    }
}

fn expand(salt: &[u8], secret: &[u8], info: &[&[u8]], out: &mut [u8]) -> Result<(), CryptoError> {
    Salt::new(HKDF_SHA256, salt)
        .extract(secret)
        .expand(info, Len(out.len()))
        .and_then(|okm| okm.fill(out))
        .map_err(|_| CryptoError::HkdfFailed)
}

/// Encrypt `plaintext` for the browser subscription keys `ua_public` (`p256dh`, uncompressed
/// P-256 point) and `auth_secret` (`auth`). Output: the request body to POST with
/// `Content-Encoding: aes128gcm`. A plaintext over [`WEBPUSH_MAX_PLAINTEXT_BYTES`]:
/// `InputTooLarge` (push services also cap the whole body at 4096 bytes: see
/// [`WEBPUSH_OVERHEAD_BYTES`]); an invalid browser key: `InvalidKeyEncoding`.
pub fn webpush_encrypt(
    ua_public: &[u8; 65],
    auth_secret: &[u8; 16],
    plaintext: &[u8],
) -> Result<Vec<u8>, CryptoError> {
    if plaintext.len() > WEBPUSH_MAX_PLAINTEXT_BYTES {
        return Err(CryptoError::InputTooLarge);
    }
    let rng = SystemRandom::new();
    let ephemeral = EphemeralPrivateKey::generate(&ECDH_P256, &rng)
        .map_err(|_| CryptoError::RandomUnavailable)?;
    let as_public: [u8; 65] = ephemeral
        .compute_public_key()
        .map_err(|_| CryptoError::EncryptionFailed)?
        .as_ref()
        .try_into()
        .map_err(|_| CryptoError::EncryptionFailed)?;
    let ecdh_secret = agree_ephemeral(
        ephemeral,
        &UnparsedPublicKey::new(&ECDH_P256, ua_public),
        |shared| Zeroizing::new(shared.to_vec()),
    )
    .map_err(|_| CryptoError::InvalidKeyEncoding)?;
    let mut salt = [0u8; 16];
    OsRng
        .try_fill_bytes(&mut salt)
        .map_err(|_| CryptoError::RandomUnavailable)?;
    encrypt_with(
        &ecdh_secret,
        &as_public,
        ua_public,
        auth_secret,
        &salt,
        plaintext,
    )
}

/// Key derivation and encryption once the ECDH secret, the application server's ephemeral public
/// key and the salt are known (RFC 8291 §3.3–3.4, RFC 8188 §2). Separate so that the RFC 8291
/// Appendix A vector can be replayed in the tests (the ephemeral key is injected there).
fn encrypt_with(
    ecdh_secret: &[u8],
    as_public: &[u8; 65],
    ua_public: &[u8; 65],
    auth_secret: &[u8; 16],
    salt: &[u8; 16],
    plaintext: &[u8],
) -> Result<Vec<u8>, CryptoError> {
    if plaintext.len() > WEBPUSH_MAX_PLAINTEXT_BYTES {
        return Err(CryptoError::InputTooLarge);
    }
    // IKM = HKDF(auth_secret, ecdh_secret, "WebPush: info" || 0x00 || ua_public || as_public, 32)
    let mut ikm = Zeroizing::new([0u8; 32]);
    expand(
        auth_secret,
        ecdh_secret,
        &[b"WebPush: info\0", ua_public, as_public],
        ikm.as_mut(),
    )?;
    let mut cek = Zeroizing::new([0u8; 16]);
    expand(
        salt,
        ikm.as_ref(),
        &[b"Content-Encoding: aes128gcm\0"],
        cek.as_mut(),
    )?;
    let mut nonce = [0u8; 12];
    expand(
        salt,
        ikm.as_ref(),
        &[b"Content-Encoding: nonce\0"],
        &mut nonce,
    )?;
    let key = LessSafeKey::new(
        UnboundKey::new(&AES_128_GCM, cek.as_ref()).map_err(|_| CryptoError::EncryptionFailed)?,
    );
    // Header: salt || rs (u32 BE) || idlen || keyid (the ephemeral public key)
    let mut body = Vec::with_capacity(WEBPUSH_OVERHEAD_BYTES + plaintext.len());
    body.extend_from_slice(salt);
    body.extend_from_slice(&WEBPUSH_RECORD_SIZE.to_be_bytes());
    body.push(65);
    body.extend_from_slice(as_public);
    // Single (last) record: plaintext || 0x02, sealed in place
    let mut record = Vec::with_capacity(plaintext.len() + 1 + 16);
    record.extend_from_slice(plaintext);
    record.push(0x02);
    key.seal_in_place_append_tag(
        Nonce::assume_unique_for_key(nonce),
        Aad::empty(),
        &mut record,
    )
    .map_err(|_| CryptoError::EncryptionFailed)?;
    body.extend_from_slice(&record);
    Ok(body)
}

#[cfg(test)]
#[allow(clippy::expect_used, clippy::unwrap_used)]
mod tests {
    include!("webpush_vectors.rs");
}
