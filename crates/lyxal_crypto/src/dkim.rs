//! DKIM cryptography (RFC 6376, RFC 8301, RFC 8463; mail program batch 2, P6 c): everything
//! that decides the signed bytes and the signature itself (CTO decision C4).
//!
//! * [`DkimBodyHasher`]: canonicalization (`simple` or `relaxed`) and SHA-256 of the body, fed in
//!   chunks (value of `bh=`), with the `l=` limit for verification;
//! * [`DkimHeaderCanonicalizer`]: canonicalization of the headers chosen by `h=`, then of the
//!   signature header with its `b=` value deleted ([`DkimSignedData`]);
//! * [`DkimSigningKey`]: `rsa-sha256` (RSA 2048 to 4096 bits) and `ed25519-sha256` signatures,
//!   value `p=` of the public key;
//! * [`DkimPublicKey`]: key read from the decoded `p=` of a DNS record (RSA 1024 to 4096 bits,
//!   RFC 8301 §3.2; Ed25519), verification.
//!
//! Not here (mail crates, lots 5 to 7): splitting a message into headers and body, parsing the
//! `DKIM-Signature` tags, choosing the headers listed in `h=` (bottom-up, absent headers
//! over-signed), DNS, `t=` / `x=`, `i=` / `d=`, policy on `l=`, results. `rsa-sha1` does not
//! exist (RFC 8301); `l=` is read, never produced.
mod canonicalize;

use crate::signing::{Ed25519PublicKey, Ed25519SigningKey, RsaPublicKey, RsaSigningKey};
use crate::{sha256, CryptoError, Sha256Hasher};
use canonicalize::{BodyState, Sink};
use std::fmt;

/// Largest canonicalized signed data (headers and signature header), in bytes.
pub const DKIM_MAX_SIGNED_DATA_BYTES: usize = 256 * 1024;

/// Signature algorithm (tag `a=`). `rsa-sha1` does not exist (RFC 8301 §3.1).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum DkimAlgorithm {
    /// `rsa-sha256`: RSASSA-PKCS1-v1_5 with SHA-256 (RFC 6376 §3.3.2).
    RsaSha256,
    /// `ed25519-sha256`: Ed25519 of the SHA-256 of the signed data (RFC 8463 §3).
    Ed25519Sha256,
}

impl DkimAlgorithm {
    /// Value of the `a=` tag.
    pub fn as_tag(&self) -> &'static str {
        match self {
            Self::RsaSha256 => "rsa-sha256",
            Self::Ed25519Sha256 => "ed25519-sha256",
        }
    }

    /// Algorithm of an `a=` value (ASCII case ignored); `None` for `rsa-sha1` and any other.
    pub fn from_tag(tag: &str) -> Option<Self> {
        [Self::RsaSha256, Self::Ed25519Sha256]
            .into_iter()
            .find(|algorithm| algorithm.as_tag().eq_ignore_ascii_case(tag))
    }

    fn key_type(self) -> DkimKeyType {
        match self {
            Self::RsaSha256 => DkimKeyType::Rsa,
            Self::Ed25519Sha256 => DkimKeyType::Ed25519,
        }
    }
}

/// Canonicalization algorithm of the headers or of the body (tag `c=`, RFC 6376 §3.4).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum DkimCanonicalization {
    /// `simple`: almost no change (§3.4.1, §3.4.3).
    Simple,
    /// `relaxed`: whitespace and case normalized (§3.4.2, §3.4.4).
    Relaxed,
}

impl DkimCanonicalization {
    fn is_relaxed(self) -> bool {
        self == Self::Relaxed
    }
}

/// Body bytes sent to SHA-256: the first `limit` canonicalized bytes; all are counted.
struct BodySink {
    hasher: Sha256Hasher,
    limit: Option<u64>,
    hashed: u64,
    total: u64,
}

impl Sink for BodySink {
    fn write(&mut self, bytes: &[u8]) {
        let length = u64::try_from(bytes.len()).unwrap_or(u64::MAX);
        let take = match self.limit {
            None => bytes.len(),
            Some(limit) => {
                let remaining = limit.saturating_sub(self.hashed).min(length);
                usize::try_from(remaining).unwrap_or(bytes.len())
            }
        };
        if let Some(part) = bytes.get(..take) {
            self.hasher.update(part);
            self.hashed = self
                .hashed
                .saturating_add(u64::try_from(take).unwrap_or(u64::MAX));
        }
        self.total = self.total.saturating_add(length);
    }
}

/// SHA-256 of the canonicalized body, fed in chunks (RFC 6376 §3.4.3 to §3.4.5, §3.7). The
/// result does not depend on how the body is cut into chunks (a CRLF may be split between two
/// chunks).
pub struct DkimBodyHasher {
    canonicalization: DkimCanonicalization,
    state: BodyState,
    sink: BodySink,
}

/// Result of [`DkimBodyHasher::finish`].
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct DkimBodyHash {
    /// SHA-256 of the canonicalized body (limited to `l=` octets if given): the value of `bh=`
    /// once Base64-encoded by the caller.
    pub digest: [u8; 32],
    /// Number of canonicalized body octets, whole body (not limited by `l=`): a signature whose
    /// `l=` is larger is invalid; a smaller `l=` means unsigned trailing content (policy of the
    /// verifier, lot 5).
    pub canonical_length: u64,
}

impl DkimBodyHasher {
    /// `length_limit`: value of `l=`, at verification only (octets of the *canonicalized* body,
    /// RFC 6376 §3.5); never produced when signing.
    pub fn new(canonicalization: DkimCanonicalization, length_limit: Option<u64>) -> Self {
        Self {
            canonicalization,
            state: BodyState::new(),
            sink: BodySink {
                hasher: Sha256Hasher::new(),
                limit: length_limit,
                hashed: 0,
                total: 0,
            },
        }
    }

    /// Feed the next raw body bytes (as received, after the blank line ending the headers).
    pub fn update(&mut self, chunk: &[u8]) {
        self.state
            .write(self.canonicalization.is_relaxed(), chunk, &mut self.sink);
    }

    /// Apply the final line-end rules and return the digest.
    pub fn finish(mut self) -> DkimBodyHash {
        self.state
            .finish(self.canonicalization.is_relaxed(), &mut self.sink);
        DkimBodyHash {
            digest: self.sink.hasher.finalize(),
            canonical_length: self.sink.total,
        }
    }
}

impl fmt::Debug for DkimBodyHasher {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("DkimBodyHasher")
            .field("canonicalization", &self.canonicalization)
            .finish_non_exhaustive()
    }
}

/// Signed data of a DKIM signature (RFC 6376 §3.7): canonicalized headers then signature header,
/// without final CRLF; [`DKIM_MAX_SIGNED_DATA_BYTES`] at most. Public data.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct DkimSignedData {
    bytes: Vec<u8>,
}

impl DkimSignedData {
    /// Canonicalized bytes, as hashed and signed.
    pub fn as_bytes(&self) -> &[u8] {
        &self.bytes
    }
}

/// Builder of [`DkimSignedData`]: headers in the order chosen by `h=`, then the signature header.
#[derive(Debug)]
pub struct DkimHeaderCanonicalizer {
    canonicalization: DkimCanonicalization,
    bytes: Vec<u8>,
}

impl DkimHeaderCanonicalizer {
    /// Start empty signed data for the header canonicalization of `c=`.
    pub fn new(canonicalization: DkimCanonicalization) -> Self {
        Self {
            canonicalization,
            bytes: Vec::new(),
        }
    }

    /// Reserve room for a header of these sizes (`:` and CRLF included), or `InputTooLarge`.
    fn reserve(&mut self, name: &[u8], value: &[u8]) -> Result<(), CryptoError> {
        let needed = name
            .len()
            .checked_add(value.len())
            .and_then(|length| length.checked_add(3))
            .and_then(|length| length.checked_add(self.bytes.len()))
            .ok_or(CryptoError::InputTooLarge)?;
        if needed > DKIM_MAX_SIGNED_DATA_BYTES {
            return Err(CryptoError::InputTooLarge);
        }
        self.bytes
            .try_reserve(needed - self.bytes.len())
            .map_err(|_| CryptoError::AllocationFailed)
    }

    fn write_header(&mut self, name: &[u8], value: &[u8]) {
        match self.canonicalization {
            DkimCanonicalization::Simple => {
                canonicalize::write_simple_header(name, value, &mut self.bytes);
            }
            DkimCanonicalization::Relaxed => {
                canonicalize::write_relaxed_name(name, &mut self.bytes);
                canonicalize::write_relaxed_value(value, &mut self.bytes);
            }
        }
    }

    /// Add a header chosen by `h=`: its raw name (the bytes before the first `:`) and its raw
    /// value (the bytes after that `:`, folding included, **without** the final CRLF). A header
    /// listed in `h=` but absent from the message is not pushed (it contributes nothing).
    /// Signed data over [`DKIM_MAX_SIGNED_DATA_BYTES`]: `InputTooLarge`.
    pub fn push_header(&mut self, name: &[u8], raw_value: &[u8]) -> Result<(), CryptoError> {
        self.reserve(name, raw_value)?;
        self.write_header(name, raw_value);
        self.bytes.extend_from_slice(b"\r\n");
        Ok(())
    }

    /// Add the signature header (`DKIM-Signature`, or `ARC-Message-Signature` / `ARC-Seal` for
    /// ARC) last: raw name and raw value as for [`Self::push_header`]. The value of its `b=` tag
    /// is deleted here (not `bh=`); everything else is kept byte for byte; no CRLF is appended.
    pub fn finish(
        mut self,
        signature_name: &[u8],
        signature_raw_value: &[u8],
    ) -> Result<DkimSignedData, CryptoError> {
        self.reserve(signature_name, signature_raw_value)?;
        let mut stripped = Vec::new();
        stripped
            .try_reserve(signature_raw_value.len())
            .map_err(|_| CryptoError::AllocationFailed)?;
        canonicalize::strip_signature_value(signature_raw_value, &mut stripped);
        self.write_header(signature_name, &stripped);
        Ok(DkimSignedData { bytes: self.bytes })
    }
}

/// Signing key of a domain (selector). RSA keys are 2048 to 4096 bits (RFC 8301 §3.2: a signer
/// MUST use at least 1024 bits, SHOULD use 2048; Lyxal requires 2048).
pub enum DkimSigningKey {
    /// `rsa-sha256`.
    Rsa(RsaSigningKey),
    /// `ed25519-sha256`.
    Ed25519(Ed25519SigningKey),
}

impl DkimSigningKey {
    /// Algorithm of the `a=` tag for this key.
    pub fn algorithm(&self) -> DkimAlgorithm {
        match self {
            Self::Rsa(_) => DkimAlgorithm::RsaSha256,
            Self::Ed25519(_) => DkimAlgorithm::Ed25519Sha256,
        }
    }

    /// Signature of the signed data (value of `b=` once Base64-encoded by the caller). RSA:
    /// RSASSA-PKCS1-v1_5 SHA-256 of the data; Ed25519: Ed25519 of SHA-256(data) (RFC 8463 §3).
    pub fn sign(&self, data: &DkimSignedData) -> Result<Vec<u8>, CryptoError> {
        match self {
            Self::Rsa(key) => key.sign_rs256(&data.bytes),
            Self::Ed25519(key) => Ok(key.sign(&sha256(&data.bytes))?.to_vec()),
        }
    }

    /// Bytes of the `p=` value of the DNS record (before Base64): SubjectPublicKeyInfo for RSA
    /// (RFC 6376 §3.6.1), the 32 bytes of the key for Ed25519 (RFC 8463 §4).
    pub fn public_key_record_bytes(&self) -> Vec<u8> {
        match self {
            Self::Rsa(key) => key.public_key().to_spki_der(),
            Self::Ed25519(key) => key.public_key().as_bytes().to_vec(),
        }
    }
}

impl fmt::Debug for DkimSigningKey {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str("DkimSigningKey([REDACTED])")
    }
}
impl zeroize::ZeroizeOnDrop for DkimSigningKey {}

/// Key type of a DKIM record (tag `k=`).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum DkimKeyType {
    /// `k=rsa` (the default).
    Rsa,
    /// `k=ed25519` (RFC 8463).
    Ed25519,
}

#[derive(Debug, Clone, PartialEq, Eq)]
enum DkimPublicKeyInner {
    Rsa(RsaPublicKey),
    Ed25519(Ed25519PublicKey),
}

/// Public key read from a DKIM DNS record (public data).
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct DkimPublicKey {
    inner: DkimPublicKeyInner,
}

/// Smallest and largest RSA keys accepted at DKIM verification (RFC 8301 §3.2).
const DKIM_RSA_MIN_BITS: u32 = 1024;
const DKIM_RSA_MAX_BITS: u32 = 4096;

impl DkimPublicKey {
    /// Key from the Base64-decoded `p=` value. RSA: SubjectPublicKeyInfo or bare RSAPublicKey,
    /// 1024 to 4096 bits (shorter: `KeyTooWeak`; longer or unreadable: `InvalidKeyEncoding`).
    /// Ed25519: exactly 32 bytes. An empty `p=` (revoked key) is refused (`InvalidKeyEncoding`).
    pub fn from_record(key_type: DkimKeyType, p: &[u8]) -> Result<Self, CryptoError> {
        let inner = match key_type {
            DkimKeyType::Rsa => {
                let key = RsaPublicKey::from_any_der(p)?;
                if key.modulus_bits() < DKIM_RSA_MIN_BITS {
                    return Err(CryptoError::KeyTooWeak);
                }
                if key.modulus_bits() > DKIM_RSA_MAX_BITS {
                    return Err(CryptoError::InvalidKeyEncoding);
                }
                DkimPublicKeyInner::Rsa(key)
            }
            DkimKeyType::Ed25519 => DkimPublicKeyInner::Ed25519(Ed25519PublicKey::from_bytes(p)?),
        };
        Ok(Self { inner })
    }

    /// Type of the key (`k=`).
    pub fn key_type(&self) -> DkimKeyType {
        match self.inner {
            DkimPublicKeyInner::Rsa(_) => DkimKeyType::Rsa,
            DkimPublicKeyInner::Ed25519(_) => DkimKeyType::Ed25519,
        }
    }

    /// Verify the `b=` signature (Base64-decoded) of the signed data. `a=` not matching `k=`:
    /// `AlgorithmMismatch`; signature of the wrong length: `InvalidSignatureEncoding` (both
    /// `permerror` for the caller); wrong signature: `Ok(false)` (`fail`).
    pub fn verify(
        &self,
        algorithm: DkimAlgorithm,
        data: &DkimSignedData,
        signature: &[u8],
    ) -> Result<bool, CryptoError> {
        if algorithm.key_type() != self.key_type() {
            return Err(CryptoError::AlgorithmMismatch);
        }
        match &self.inner {
            DkimPublicKeyInner::Rsa(key) => key.verify_dkim(&data.bytes, signature),
            DkimPublicKeyInner::Ed25519(key) => key.verify(&sha256(&data.bytes), signature),
        }
    }
}

#[cfg(test)]
#[allow(clippy::expect_used, clippy::unwrap_used)]
mod tests {
    include!("dkim_vectors.rs");
}
