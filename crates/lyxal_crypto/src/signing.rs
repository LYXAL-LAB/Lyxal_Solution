//! Signatures of third-party push protocols (CTO decision K8): ES256 (ECDSA P-256 with SHA-256,
//! fixed-size `r || s`) for Web Push VAPID and APNs provider tokens, and RS256 (RSASSA-PKCS1-v1_5
//! with SHA-256) for the Google service-account token exchanged for an FCM access token.
//! Computed by `ring`; keys are opaque, redacted in `Debug` and only held as wiped PKCS#8 bytes.
//! No verification function is offered: the signatures are checked by Google, Apple and the push
//! services.
use crate::{CryptoError, SecretBytes};
use base64::engine::general_purpose::STANDARD;
use base64::Engine;
use ring::rand::SystemRandom;
use ring::signature::{EcdsaKeyPair, KeyPair, RsaKeyPair, ECDSA_P256_SHA256_FIXED_SIGNING};
use std::fmt;
use zeroize::{ZeroizeOnDrop, Zeroizing};

/// Largest private key accepted (DER or PEM), in bytes: an RSA-4096 PEM is about 3.3 KiB.
const MAX_KEY_BYTES: usize = 16 * 1024;
const PEM_BEGIN: &str = "-----BEGIN PRIVATE KEY-----";
const PEM_END: &str = "-----END PRIVATE KEY-----";

/// PKCS#8 bytes from DER, or from a PEM `PRIVATE KEY` block (the form of Apple `.p8` files and of
/// the `private_key` of a Google service-account file). Other PEM labels (`RSA PRIVATE KEY`,
/// `EC PRIVATE KEY`, encrypted keys) are refused. The input is wiped by its owner.
fn pkcs8_der(secret: &SecretBytes) -> Result<Zeroizing<Vec<u8>>, CryptoError> {
    let raw = secret.expose_secret();
    if raw.len() > MAX_KEY_BYTES {
        return Err(CryptoError::InputTooLarge);
    }
    let Ok(text) = std::str::from_utf8(raw) else {
        return Ok(Zeroizing::new(raw.to_vec()));
    };
    let trimmed = text.trim();
    if !trimmed.starts_with("-----") {
        return Ok(Zeroizing::new(raw.to_vec()));
    }
    let body = trimmed
        .strip_prefix(PEM_BEGIN)
        .and_then(|rest| rest.strip_suffix(PEM_END))
        .ok_or(CryptoError::InvalidKeyEncoding)?;
    let compact = Zeroizing::new(
        body.bytes()
            .filter(|b| !b.is_ascii_whitespace())
            .collect::<Vec<u8>>(),
    );
    // Capacity reserved first: no reallocation leaves an unwiped copy behind
    let mut der = Zeroizing::new(Vec::with_capacity(compact.len() / 4 * 3 + 3));
    STANDARD
        .decode_vec(compact.as_slice(), &mut der)
        .map_err(|_| CryptoError::InvalidKeyEncoding)?;
    Ok(der)
}

/// ECDSA P-256 signing key (ES256). Generated from the operating system's randomness or
/// imported from PKCS#8 (DER or PEM, with its public key, as `openssl genpkey` and Apple produce).
/// The private key is kept as wiped PKCS#8 bytes and parsed by `ring` for each signature (the
/// transient `ring` state is not wiped); no raw private scalar is exposed.
///
/// ```compile_fail
/// use lyxal_crypto::EcdsaP256SigningKey;
/// let key = EcdsaP256SigningKey::generate().unwrap();
/// let duplicate = key.clone();
/// ```
pub struct EcdsaP256SigningKey {
    pkcs8: Zeroizing<Vec<u8>>,
    public: [u8; 65],
}

impl EcdsaP256SigningKey {
    /// Import a PKCS#8 P-256 key (DER, or PEM `-----BEGIN PRIVATE KEY-----`). A key without its
    /// public key, of another curve or algorithm, or malformed: `InvalidKeyEncoding`.
    pub fn import_pkcs8(secret: SecretBytes) -> Result<Self, CryptoError> {
        let der = pkcs8_der(&secret)?;
        drop(secret);
        Self::from_der(der)
    }

    /// Generate a new key pair from the operating system's randomness (`ring::rand::SystemRandom`).
    pub fn generate() -> Result<Self, CryptoError> {
        let rng = SystemRandom::new();
        let document = EcdsaKeyPair::generate_pkcs8(&ECDSA_P256_SHA256_FIXED_SIGNING, &rng)
            .map_err(|_| CryptoError::RandomUnavailable)?;
        Self::from_der(Zeroizing::new(document.as_ref().to_vec()))
    }

    fn from_der(pkcs8: Zeroizing<Vec<u8>>) -> Result<Self, CryptoError> {
        let pair = Self::pair(&pkcs8)?;
        let public: [u8; 65] = pair
            .public_key()
            .as_ref()
            .try_into()
            .map_err(|_| CryptoError::InvalidKeyEncoding)?;
        Ok(Self { pkcs8, public })
    }

    fn pair(pkcs8: &[u8]) -> Result<EcdsaKeyPair, CryptoError> {
        EcdsaKeyPair::from_pkcs8(
            &ECDSA_P256_SHA256_FIXED_SIGNING,
            pkcs8,
            &SystemRandom::new(),
        )
        .map_err(|_| CryptoError::InvalidKeyEncoding)
    }

    /// Public key, uncompressed SEC1 point (`0x04 || x || y`): the VAPID `k` parameter and the
    /// `applicationServerKey` of browsers (once Base64url-encoded).
    pub fn public_key_uncompressed(&self) -> [u8; 65] {
        self.public
    }

    /// ES256 signature of `data` (JWS, RFC 7518 §3.4): SHA-256 then ECDSA P-256 with a fresh
    /// random nonce, as `r || s` (64 bytes).
    pub fn sign_es256(&self, data: &[u8]) -> Result<[u8; 64], CryptoError> {
        let rng = SystemRandom::new();
        let signature = Self::pair(&self.pkcs8)?
            .sign(&rng, data)
            .map_err(|_| CryptoError::EncryptionFailed)?;
        signature
            .as_ref()
            .try_into()
            .map_err(|_| CryptoError::EncryptionFailed)
    }

    /// Export the PKCS#8 DER private key, only so that the host can store a generated VAPID key
    /// in the secrets vault. The copy belongs to the caller (wiped on drop).
    pub fn export_pkcs8(&self) -> SecretBytes {
        SecretBytes {
            inner: Zeroizing::new(self.pkcs8.to_vec()),
        }
    }
}

impl fmt::Debug for EcdsaP256SigningKey {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str("EcdsaP256SigningKey([REDACTED])")
    }
}
impl ZeroizeOnDrop for EcdsaP256SigningKey {}

/// RSA signing key (RS256), imported from PKCS#8 (DER, or PEM: the `private_key` of a Google
/// service-account file). 2048 to 4096 bits, as accepted by `ring`. Never generated. Kept as
/// wiped PKCS#8 bytes and parsed by `ring` for each signature (the transient `ring` state is not
/// wiped).
///
/// ```compile_fail
/// use lyxal_crypto::{RsaSigningKey, SecretBytes};
/// let key = RsaSigningKey::import_pkcs8(SecretBytes::new(vec![]).unwrap()).unwrap();
/// let duplicate = key.clone();
/// ```
pub struct RsaSigningKey {
    pkcs8: Zeroizing<Vec<u8>>,
    modulus_len: usize,
}

impl RsaSigningKey {
    /// Import a PKCS#8 RSA key (DER, or PEM `-----BEGIN PRIVATE KEY-----`). A PKCS#1 key, a key
    /// of another algorithm or an inconsistent key: `InvalidKeyEncoding`.
    pub fn import_pkcs8(secret: SecretBytes) -> Result<Self, CryptoError> {
        let pkcs8 = pkcs8_der(&secret)?;
        drop(secret);
        let modulus_len = Self::pair(&pkcs8)?.public().modulus_len();
        Ok(Self { pkcs8, modulus_len })
    }

    fn pair(pkcs8: &[u8]) -> Result<RsaKeyPair, CryptoError> {
        RsaKeyPair::from_pkcs8(pkcs8).map_err(|_| CryptoError::InvalidKeyEncoding)
    }

    /// RS256 signature of `data` (JWS, RFC 7518 §3.3): RSASSA-PKCS1-v1_5 with SHA-256, as long as
    /// the modulus (deterministic).
    pub fn sign_rs256(&self, data: &[u8]) -> Result<Vec<u8>, CryptoError> {
        let mut signature = vec![0; self.modulus_len];
        Self::pair(&self.pkcs8)?
            .sign(
                &ring::signature::RSA_PKCS1_SHA256,
                &SystemRandom::new(),
                data,
                &mut signature,
            )
            .map_err(|_| CryptoError::EncryptionFailed)?;
        Ok(signature)
    }
}

impl fmt::Debug for RsaSigningKey {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str("RsaSigningKey([REDACTED])")
    }
}
impl ZeroizeOnDrop for RsaSigningKey {}

#[cfg(test)]
#[allow(clippy::expect_used, clippy::unwrap_used)]
mod tests {
    include!("signing_vectors.rs");
}
