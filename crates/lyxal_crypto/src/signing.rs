//! Asymmetric signatures, computed by `aws-lc-rs` (the only asymmetric engine of the crate,
//! CTO decision C1).
//!
//! * Push protocols (CTO decision K8): ES256 (ECDSA P-256 with SHA-256, fixed-size `r || s`) for
//!   Web Push VAPID and APNs provider tokens, and RS256 (RSASSA-PKCS1-v1_5 with SHA-256) for the
//!   Google service-account token exchanged for an FCM access token. These signatures are checked
//!   by Google, Apple and the push services: no ES256 verification is offered.
//! * Mail program, batch 2 (P6 b, d): RSA keys generated (2048, 3072, 4096 bits) and exported for
//!   the secrets vault (C6), RSA public keys and RS256 verification, Ed25519 (RFC 8032) keys,
//!   signature and verification. DKIM (`crate::dkim`) is built on these types.
//!
//! Private keys are opaque, redacted in `Debug`, never `Clone`, and only held as wiped PKCS#8
//! bytes, parsed by `aws-lc-rs` for each signature (the transient `aws-lc-rs` object lives in C
//! memory, released by `EVP_PKEY_free`). Verification: `Ok(true)` valid signature, `Ok(false)`
//! wrong signature, `Err(InvalidSignatureEncoding)` signature of the wrong length,
//! `Err(InvalidKeyEncoding)` / `Err(KeyTooWeak)` unusable key.
use crate::{CryptoError, SecretBytes};
use aws_lc_rs::encoding::{AsDer, Pkcs8V1Der, PublicKeyX509Der};
use aws_lc_rs::rand::SystemRandom;
use aws_lc_rs::rsa::KeySize;
use aws_lc_rs::signature::{
    EcdsaKeyPair, Ed25519KeyPair, KeyPair, RsaKeyPair, RsaParameters, RsaSubjectPublicKey,
    UnparsedPublicKey, ECDSA_P256_SHA256_FIXED_SIGNING, ED25519,
    RSA_PKCS1_1024_8192_SHA256_FOR_LEGACY_USE_ONLY, RSA_PKCS1_2048_8192_SHA256, RSA_PKCS1_SHA256,
};
use base64::engine::general_purpose::STANDARD;
use base64::Engine;
use std::fmt;
use zeroize::{ZeroizeOnDrop, Zeroizing};

/// Largest private key accepted (DER or PEM), in bytes: an RSA-4096 PEM is about 3.3 KiB.
const MAX_KEY_BYTES: usize = 16 * 1024;
/// Largest public key accepted (DER), in bytes: an RSA-8192 SubjectPublicKeyInfo is 1 062 bytes.
const MAX_PUBLIC_KEY_BYTES: usize = 2 * 1024;
const PEM_BEGIN: &str = "-----BEGIN PRIVATE KEY-----";
const PEM_END: &str = "-----END PRIVATE KEY-----";
/// Smallest RSA key used for signing, and for RS256 verification outside DKIM.
const RSA_MIN_BITS: u32 = 2048;
/// Largest RSA private key accepted (the K8 limit, unchanged).
const RSA_MAX_PRIVATE_BITS: u32 = 4096;
/// Largest RSA public key accepted by [`RsaPublicKey::verify_rs256`].
const RSA_MAX_PUBLIC_BITS: u32 = 8192;
/// Length of an Ed25519 public key and of an Ed25519 signature (RFC 8032).
const ED25519_PUBLIC_KEY_BYTES: usize = 32;
const ED25519_SIGNATURE_BYTES: usize = 64;

/// PKCS#8 bytes from DER, or from a PEM `PRIVATE KEY` block (the form of Apple `.p8` files, of
/// the `private_key` of a Google service-account file and of `openssl genpkey`). Other PEM labels
/// (`RSA PRIVATE KEY`, `EC PRIVATE KEY`, encrypted keys) are refused. The input is wiped by its
/// owner.
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

/// Wiped copy of a PKCS#8 document serialized by `aws-lc-rs`.
fn wiped(document: &[u8]) -> Zeroizing<Vec<u8>> {
    Zeroizing::new(document.to_vec())
}

/// ECDSA P-256 signing key (ES256). Generated from the operating system's randomness or
/// imported from PKCS#8 (DER or PEM, as `openssl genpkey` and Apple produce).
/// The private key is kept as wiped PKCS#8 bytes and parsed by `aws-lc-rs` for each signature;
/// no raw private scalar is exposed.
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
    /// Import a PKCS#8 P-256 key (DER, or PEM `-----BEGIN PRIVATE KEY-----`). A key of another
    /// curve or algorithm, a public key inconsistent with the private scalar, or a malformed key:
    /// `InvalidKeyEncoding`.
    pub fn import_pkcs8(secret: SecretBytes) -> Result<Self, CryptoError> {
        let der = pkcs8_der(&secret)?;
        drop(secret);
        Self::from_der(der)
    }

    /// Generate a new key pair from the operating system's randomness (AWS-LC `RAND_bytes`).
    pub fn generate() -> Result<Self, CryptoError> {
        let document =
            EcdsaKeyPair::generate_pkcs8(&ECDSA_P256_SHA256_FIXED_SIGNING, &SystemRandom::new())
                .map_err(|_| CryptoError::RandomUnavailable)?;
        Self::from_der(wiped(document.as_ref()))
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
        EcdsaKeyPair::from_pkcs8(&ECDSA_P256_SHA256_FIXED_SIGNING, pkcs8)
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
        let signature = Self::pair(&self.pkcs8)?
            .sign(&SystemRandom::new(), data)
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

/// Size of a generated RSA key.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum RsaModulusBits {
    /// 2048 bits: the DKIM signing key (RFC 8301 §3.2) and the usual minimum.
    Rsa2048,
    /// 3072 bits.
    Rsa3072,
    /// 4096 bits (generation can take more than a second: run it off the asynchronous loop).
    Rsa4096,
}

impl RsaModulusBits {
    fn key_size(self) -> KeySize {
        match self {
            Self::Rsa2048 => KeySize::Rsa2048,
            Self::Rsa3072 => KeySize::Rsa3072,
            Self::Rsa4096 => KeySize::Rsa4096,
        }
    }
}

/// Number of bits of a big-endian unsigned integer without leading zero bytes.
fn bit_length(big_endian: &[u8]) -> u32 {
    match big_endian.first() {
        None => 0,
        Some(first) => {
            let bytes = u32::try_from(big_endian.len()).unwrap_or(u32::MAX);
            bytes
                .saturating_sub(1)
                .saturating_mul(8)
                .saturating_add(8 - first.leading_zeros())
        }
    }
}

/// RSA signing key (RS256, and `rsa-sha256` of DKIM through `crate::dkim`). Generated from the
/// operating system's randomness ([`RsaSigningKey::generate`]), or imported from PKCS#8 (DER,
/// or PEM: the `private_key` of a Google service-account file). 2048 to 4096 bits. Kept as wiped
/// PKCS#8 bytes and parsed by `aws-lc-rs` for each signature (constant-time arithmetic of
/// AWS-LC; the `rsa` crate is never used, CTO decision C2). Exported only for the secrets vault.
///
/// ```compile_fail
/// use lyxal_crypto::{RsaSigningKey, SecretBytes};
/// let key = RsaSigningKey::import_pkcs8(SecretBytes::new(vec![]).unwrap()).unwrap();
/// let duplicate = key.clone();
/// ```
pub struct RsaSigningKey {
    pkcs8: Zeroizing<Vec<u8>>,
    modulus_len: usize,
    public: RsaPublicKey,
}

impl RsaSigningKey {
    /// Generate a new key pair from the operating system's randomness (AWS-LC). A 4096-bit key
    /// can take more than a second: the caller runs it off the asynchronous loop
    /// (`spawn_blocking`), as for Argon2id. Failure: `RandomUnavailable`.
    pub fn generate(bits: RsaModulusBits) -> Result<Self, CryptoError> {
        let pair =
            RsaKeyPair::generate(bits.key_size()).map_err(|_| CryptoError::RandomUnavailable)?;
        let document: Pkcs8V1Der<'static> =
            pair.as_der().map_err(|_| CryptoError::RandomUnavailable)?;
        Self::from_der(wiped(document.as_ref()))
    }

    /// Import a PKCS#8 RSA key (DER, or PEM `-----BEGIN PRIVATE KEY-----`). A key outside 2048
    /// to 4096 bits (AWS-LC already refuses a private key under 2048 bits when parsing it, as
    /// `ring` did), a PKCS#1 key, a key of another algorithm or an inconsistent key:
    /// `InvalidKeyEncoding`.
    pub fn import_pkcs8(secret: SecretBytes) -> Result<Self, CryptoError> {
        let pkcs8 = pkcs8_der(&secret)?;
        drop(secret);
        Self::from_der(pkcs8)
    }

    fn from_der(pkcs8: Zeroizing<Vec<u8>>) -> Result<Self, CryptoError> {
        let pair = Self::pair(&pkcs8)?;
        let public = RsaPublicKey::from_aws(pair.public_key())?;
        if public.bits < RSA_MIN_BITS {
            return Err(CryptoError::KeyTooWeak);
        }
        if public.bits > RSA_MAX_PRIVATE_BITS {
            return Err(CryptoError::InvalidKeyEncoding);
        }
        Ok(Self {
            modulus_len: pair.public_modulus_len(),
            pkcs8,
            public,
        })
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
                &RSA_PKCS1_SHA256,
                &SystemRandom::new(),
                data,
                &mut signature,
            )
            .map_err(|_| CryptoError::EncryptionFailed)?;
        Ok(signature)
    }

    /// Public key of this key pair.
    pub fn public_key(&self) -> RsaPublicKey {
        self.public.clone()
    }

    /// Size of the modulus, in bits.
    pub fn modulus_bits(&self) -> u32 {
        self.public.bits
    }

    /// Export the PKCS#8 (v1) DER private key, only so that the host can store a generated key
    /// (DKIM) in the secrets vault (CTO decision C6). The copy belongs to the caller (wiped on
    /// drop).
    pub fn export_pkcs8(&self) -> SecretBytes {
        SecretBytes {
            inner: Zeroizing::new(self.pkcs8.to_vec()),
        }
    }
}

impl fmt::Debug for RsaSigningKey {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str("RsaSigningKey([REDACTED])")
    }
}
impl ZeroizeOnDrop for RsaSigningKey {}

/// RSA public key (public data). Kept as `RSAPublicKey` DER (PKCS#1, RFC 8017) with its size.
#[derive(Clone, PartialEq, Eq)]
pub struct RsaPublicKey {
    pkcs1: Vec<u8>,
    spki: Vec<u8>,
    bits: u32,
}

/// Outer DER form of a public key, read from its first two tags only (the full parsing is done
/// by AWS-LC): SubjectPublicKeyInfo starts with a SEQUENCE in a SEQUENCE, RSAPublicKey with an
/// INTEGER in a SEQUENCE.
#[derive(PartialEq, Eq)]
enum PublicKeyForm {
    Spki,
    Pkcs1,
}

fn public_key_form(der: &[u8]) -> Option<PublicKeyForm> {
    if der.first() != Some(&0x30) {
        return None;
    }
    let length_byte = *der.get(1)?;
    let header = if length_byte < 0x80 {
        2
    } else {
        2 + usize::from(length_byte & 0x7f)
    };
    match der.get(header)? {
        0x30 => Some(PublicKeyForm::Spki),
        0x02 => Some(PublicKeyForm::Pkcs1),
        _ => None,
    }
}

impl RsaPublicKey {
    fn from_aws(public: &RsaSubjectPublicKey) -> Result<Self, CryptoError> {
        let spki: PublicKeyX509Der<'static> = public
            .as_der()
            .map_err(|_| CryptoError::InvalidKeyEncoding)?;
        Ok(Self {
            pkcs1: public.as_ref().to_vec(),
            spki: spki.as_ref().to_vec(),
            bits: bit_length(public.modulus().big_endian_without_leading_zero()),
        })
    }

    fn from_der(der: &[u8], form: Option<PublicKeyForm>) -> Result<Self, CryptoError> {
        if der.len() > MAX_PUBLIC_KEY_BYTES {
            return Err(CryptoError::InputTooLarge);
        }
        let found = public_key_form(der).ok_or(CryptoError::InvalidKeyEncoding)?;
        if form.is_some_and(|expected| expected != found) {
            return Err(CryptoError::InvalidKeyEncoding);
        }
        let public =
            RsaSubjectPublicKey::from_der(der).map_err(|_| CryptoError::InvalidKeyEncoding)?;
        Self::from_aws(&public)
    }

    /// SubjectPublicKeyInfo (RFC 5280) or bare RSAPublicKey (RFC 8017): the two forms of the DKIM
    /// `p=` value.
    pub(crate) fn from_any_der(der: &[u8]) -> Result<Self, CryptoError> {
        Self::from_der(der, None)
    }

    /// Read a DER SubjectPublicKeyInfo (RFC 5280) of an RSA key (2 KiB at most).
    pub fn from_spki_der(der: &[u8]) -> Result<Self, CryptoError> {
        Self::from_der(der, Some(PublicKeyForm::Spki))
    }

    /// Read a DER RSAPublicKey (PKCS#1, RFC 8017 §A.1.1; 2 KiB at most).
    pub fn from_pkcs1_der(der: &[u8]) -> Result<Self, CryptoError> {
        Self::from_der(der, Some(PublicKeyForm::Pkcs1))
    }

    /// DER SubjectPublicKeyInfo (RFC 5280): the `p=` value of a DKIM record (before Base64).
    pub fn to_spki_der(&self) -> Vec<u8> {
        self.spki.clone()
    }

    /// Size of the modulus, in bits.
    pub fn modulus_bits(&self) -> u32 {
        self.bits
    }

    /// RSASSA-PKCS1-v1_5 SHA-256 verification (RS256) with a key of 2048 to 8192 bits: a shorter
    /// key is `KeyTooWeak`, a longer one `InvalidKeyEncoding`; a signature whose length is not
    /// the modulus length: `InvalidSignatureEncoding`; a wrong signature: `Ok(false)`.
    pub fn verify_rs256(&self, data: &[u8], signature: &[u8]) -> Result<bool, CryptoError> {
        self.verify_pkcs1_sha256(
            RSA_MIN_BITS,
            RSA_MAX_PUBLIC_BITS,
            &RSA_PKCS1_2048_8192_SHA256,
            data,
            signature,
        )
    }

    /// DKIM `rsa-sha256` verification: keys of 1024 to 4096 bits (RFC 8301 §3.2), the only place
    /// where a 1024-bit key is accepted.
    pub(crate) fn verify_dkim(&self, data: &[u8], signature: &[u8]) -> Result<bool, CryptoError> {
        self.verify_pkcs1_sha256(
            1024,
            4096,
            &RSA_PKCS1_1024_8192_SHA256_FOR_LEGACY_USE_ONLY,
            data,
            signature,
        )
    }

    fn verify_pkcs1_sha256(
        &self,
        min_bits: u32,
        max_bits: u32,
        algorithm: &'static RsaParameters,
        data: &[u8],
        signature: &[u8],
    ) -> Result<bool, CryptoError> {
        if self.bits < min_bits {
            return Err(CryptoError::KeyTooWeak);
        }
        if self.bits > max_bits {
            return Err(CryptoError::InvalidKeyEncoding);
        }
        let modulus_len = usize::try_from(self.bits.div_ceil(8)).unwrap_or(usize::MAX);
        if signature.len() != modulus_len {
            return Err(CryptoError::InvalidSignatureEncoding);
        }
        Ok(UnparsedPublicKey::new(algorithm, &self.pkcs1)
            .verify(data, signature)
            .is_ok())
    }
}

impl fmt::Debug for RsaPublicKey {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(
            f,
            "RsaPublicKey({} bits, {})",
            self.bits,
            hex::encode(&self.pkcs1)
        )
    }
}

/// Ed25519 private key (RFC 8032), kept as wiped PKCS#8 v2 bytes (RFC 5958, with the public key)
/// and parsed by `aws-lc-rs` for each signature.
///
/// ```compile_fail
/// use lyxal_crypto::Ed25519SigningKey;
/// let key = Ed25519SigningKey::generate().unwrap();
/// let duplicate = key.clone();
/// ```
pub struct Ed25519SigningKey {
    pkcs8: Zeroizing<Vec<u8>>,
    public: Ed25519PublicKey,
}

impl Ed25519SigningKey {
    /// Generate a new key from the operating system's randomness (AWS-LC). Failure:
    /// `RandomUnavailable`.
    pub fn generate() -> Result<Self, CryptoError> {
        let pair = Ed25519KeyPair::generate().map_err(|_| CryptoError::RandomUnavailable)?;
        Self::from_pair(&pair)
    }

    /// Import a PKCS#8 Ed25519 key: v1 (the form of `openssl genpkey -algorithm ed25519`) or v2
    /// (with its public key, checked against the private key), DER or PEM `PRIVATE KEY`, 16 KiB
    /// at most. Any other key: `InvalidKeyEncoding`.
    pub fn import_pkcs8(secret: SecretBytes) -> Result<Self, CryptoError> {
        let der = pkcs8_der(&secret)?;
        drop(secret);
        let pair = Self::pair(&der)?;
        Self::from_pair(&pair)
    }

    fn from_pair(pair: &Ed25519KeyPair) -> Result<Self, CryptoError> {
        let document = pair
            .to_pkcs8()
            .map_err(|_| CryptoError::InvalidKeyEncoding)?;
        Ok(Self {
            pkcs8: wiped(document.as_ref()),
            public: Ed25519PublicKey::from_bytes(pair.public_key().as_ref())?,
        })
    }

    fn pair(pkcs8: &[u8]) -> Result<Ed25519KeyPair, CryptoError> {
        Ed25519KeyPair::from_pkcs8(pkcs8).map_err(|_| CryptoError::InvalidKeyEncoding)
    }

    /// Export the PKCS#8 v2 DER private key, only so that the host can store it in the secrets
    /// vault (CTO decision C6). The copy belongs to the caller (wiped on drop).
    pub fn export_pkcs8(&self) -> SecretBytes {
        SecretBytes {
            inner: Zeroizing::new(self.pkcs8.to_vec()),
        }
    }

    /// Public key of this key pair.
    pub fn public_key(&self) -> Ed25519PublicKey {
        self.public
    }

    /// Ed25519 signature of `data` (pure Ed25519, RFC 8032 §5.1.6; deterministic).
    pub fn sign(&self, data: &[u8]) -> Result<[u8; 64], CryptoError> {
        let signature = Self::pair(&self.pkcs8)?
            .try_sign(data)
            .map_err(|_| CryptoError::EncryptionFailed)?;
        signature
            .as_ref()
            .try_into()
            .map_err(|_| CryptoError::EncryptionFailed)
    }
}

impl fmt::Debug for Ed25519SigningKey {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str("Ed25519SigningKey([REDACTED])")
    }
}
impl ZeroizeOnDrop for Ed25519SigningKey {}

/// Ed25519 public key: 32 bytes (RFC 8032 §5.1.2; public data).
#[derive(Clone, Copy, PartialEq, Eq)]
pub struct Ed25519PublicKey([u8; 32]);

impl Ed25519PublicKey {
    /// Read a public key of exactly 32 bytes (otherwise `InvalidKeyEncoding`). The point itself
    /// is decoded at verification: a key that is not a point gives `Ok(false)`.
    pub fn from_bytes(bytes: &[u8]) -> Result<Self, CryptoError> {
        let key: [u8; ED25519_PUBLIC_KEY_BYTES] = bytes
            .try_into()
            .map_err(|_| CryptoError::InvalidKeyEncoding)?;
        Ok(Self(key))
    }

    /// The 32 bytes of the key (the `p=` value of a DKIM `k=ed25519` record, before Base64).
    pub fn as_bytes(&self) -> &[u8; 32] {
        &self.0
    }

    /// Ed25519 verification (pure Ed25519, RFC 8032 §5.1.7). A signature that is not 64 bytes
    /// long: `InvalidSignatureEncoding`; a wrong signature: `Ok(false)`.
    pub fn verify(&self, data: &[u8], signature: &[u8]) -> Result<bool, CryptoError> {
        if signature.len() != ED25519_SIGNATURE_BYTES {
            return Err(CryptoError::InvalidSignatureEncoding);
        }
        Ok(UnparsedPublicKey::new(&ED25519, &self.0)
            .verify(data, signature)
            .is_ok())
    }
}

impl fmt::Debug for Ed25519PublicKey {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "Ed25519PublicKey({})", hex::encode(self.0))
    }
}

#[cfg(test)]
#[allow(clippy::expect_used, clippy::unwrap_used)]
mod tests {
    include!("signing_vectors.rs");
}
