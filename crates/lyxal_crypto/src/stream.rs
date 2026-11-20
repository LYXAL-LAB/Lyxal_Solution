//! Streaming file encryption, format v1 (`STREAM_FORMAT_V1.md`, CTO decision C9).
//!
//! One random 32-byte key per file ([`StreamKey`]), sealed by enc:v2 under the organisation key
//! and stored in the file record, never in the file. The content is cut into 64 KiB segments,
//! each encrypted and authenticated by AES-256-GCM under a key derived by HKDF-SHA256 from the
//! file key and the header salt. The nonce of a segment carries its index and a "last segment"
//! flag; the associated data binds the header and the exact `SecretContext` identity. A
//! modified, moved, duplicated, removed or appended segment, a truncated file, a modified header
//! or another context fails authentication. A byte range is read without decrypting the rest.
//!
//! Synchronous on purpose (no `tokio`, no `futures`): the asynchronous adapter belongs to the
//! consumer. A segment is returned only after its tag is verified, but the following segments
//! are not verified yet: on an error further on, the caller interrupts its response.
use crate::{
    CryptoEngine, CryptoError, EncryptedEnvelope, KeyResolver, SecretBytes, SecretContext,
};
use aes_gcm::{
    aead::{AeadInPlace, KeyInit},
    Aes256Gcm, Nonce, Tag,
};
use hkdf::Hkdf;
use rand_core::{CryptoRng, OsRng, RngCore};
use sha2::Sha256;
use std::fmt;
use std::ops::Range;
use zeroize::{Zeroize, ZeroizeOnDrop, Zeroizing};

/// Size of the clear header at the start of every encrypted file, in bytes.
pub const STREAM_HEADER_BYTES: usize = 47;
/// Plaintext size of every segment but the last one (the last one holds 1 to 65 536 bytes, or
/// 0 only for an empty file).
pub const STREAM_SEGMENT_BYTES: usize = 65_536;
/// Authentication tag following each encrypted segment, in bytes.
pub const STREAM_TAG_BYTES: usize = 16;

const MAGIC: &[u8; 4] = b"LXS1";
const VERSION: u8 = 0x01;
const SUITE_AES_256_GCM: u8 = 0x01;
const SEGMENT_EXPONENT: u8 = 0x10;
const FLAGS: u8 = 0x00;
const SALT_BYTES: usize = 32;
const NONCE_PREFIX_BYTES: usize = 7;
/// HKDF info and AAD prefix, NUL included (35 bytes).
const DOMAIN: &[u8] = b"lyxal:crypto:stream:v1:aes-256-gcm\0";
const SEGMENT: u64 = STREAM_SEGMENT_BYTES as u64;
const SEGMENT_CIPHERTEXT: u64 = (STREAM_SEGMENT_BYTES + STREAM_TAG_BYTES) as u64;
const HEADER: u64 = STREAM_HEADER_BYTES as u64;
const TAG: u64 = STREAM_TAG_BYTES as u64;
/// 2^32 segments (32-bit index in the nonce), hence 2^48 plaintext bytes (256 TiB).
const MAX_SEGMENTS: u64 = 1 << 32;
const MAX_PLAINTEXT: u64 = MAX_SEGMENTS * SEGMENT;

fn segment_count(plaintext_len: u64) -> u64 {
    plaintext_len.div_ceil(SEGMENT).max(1)
}

/// Total encrypted size (header, segments and tags) of a plaintext of `plaintext_len` bytes.
/// More than 2^48 bytes (2^32 segments): `InputTooLarge`.
pub fn stream_ciphertext_len(plaintext_len: u64) -> Result<u64, CryptoError> {
    if plaintext_len > MAX_PLAINTEXT {
        return Err(CryptoError::InputTooLarge);
    }
    Ok(HEADER + plaintext_len + TAG * segment_count(plaintext_len))
}

/// Key of one file (32 bytes from the operating system), wiped on drop, `Debug` redacted,
/// without `Clone`. Stored only sealed by enc:v2 ([`StreamKey::seal`]).
///
/// ```compile_fail
/// use lyxal_crypto::StreamKey;
/// let key = StreamKey::generate().unwrap();
/// let duplicate = key.clone();
/// ```
pub struct StreamKey {
    key: Zeroizing<[u8; 32]>,
}

impl StreamKey {
    /// Draw a new file key from `OsRng`. Randomness failure: `RandomUnavailable`.
    pub fn generate() -> Result<Self, CryptoError> {
        Self::generate_with(&mut OsRng)
    }
    fn generate_with(rng: &mut (impl RngCore + CryptoRng)) -> Result<Self, CryptoError> {
        let mut key = Zeroizing::new([0u8; 32]);
        rng.try_fill_bytes(&mut *key)
            .map_err(|_| CryptoError::RandomUnavailable)?;
        Ok(Self { key })
    }
    /// Seal the key by enc:v2 under the engine's active key: one invocation of the sealing
    /// budget of that key (SECURITY.md).
    pub fn seal<R: KeyResolver>(
        &self,
        engine: &CryptoEngine<R>,
        context: &SecretContext,
    ) -> Result<EncryptedEnvelope, CryptoError> {
        let mut raw = Vec::new();
        raw.try_reserve_exact(32)
            .map_err(|_| CryptoError::AllocationFailed)?;
        raw.extend_from_slice(&*self.key);
        engine.seal(&SecretBytes::new(raw)?, context)
    }
    /// Open a sealed file key; the authenticated value must be exactly 32 bytes
    /// (`InvalidKeyLength`).
    pub fn open<R: KeyResolver>(
        engine: &CryptoEngine<R>,
        envelope: &EncryptedEnvelope,
        context: &SecretContext,
    ) -> Result<Self, CryptoError> {
        let opened = engine.open(envelope, context)?;
        if opened.len() != 32 {
            return Err(CryptoError::InvalidKeyLength);
        }
        let mut key = Zeroizing::new([0u8; 32]);
        key.copy_from_slice(opened.expose_secret());
        Ok(Self { key })
    }
    #[cfg(test)]
    pub(crate) fn from_test_bytes(bytes: [u8; 32]) -> Self {
        Self {
            key: Zeroizing::new(bytes),
        }
    }
}
impl fmt::Debug for StreamKey {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str("StreamKey([REDACTED])")
    }
}
impl ZeroizeOnDrop for StreamKey {}

fn build_header(
    salt: &[u8; SALT_BYTES],
    prefix: &[u8; NONCE_PREFIX_BYTES],
) -> [u8; STREAM_HEADER_BYTES] {
    let mut header = [0u8; STREAM_HEADER_BYTES];
    header[..4].copy_from_slice(MAGIC);
    header[4] = VERSION;
    header[5] = SUITE_AES_256_GCM;
    header[6] = SEGMENT_EXPONENT;
    header[7] = FLAGS;
    header[8..40].copy_from_slice(salt);
    header[40..].copy_from_slice(prefix);
    header
}

/// AES-256-GCM of one segment, nonce chosen by the format; private.
pub(crate) fn seal_segment(
    key: &[u8; 32],
    nonce: &[u8; 12],
    aad: &[u8],
    buffer: &mut [u8],
) -> Result<[u8; 16], CryptoError> {
    let cipher = Aes256Gcm::new_from_slice(key).map_err(|_| CryptoError::EncryptionFailed)?;
    let tag = cipher
        .encrypt_in_place_detached(Nonce::from_slice(nonce), aad, buffer)
        .map_err(|_| CryptoError::EncryptionFailed)?;
    Ok(tag.into())
}

/// Authenticated decryption of one segment; on failure the buffer content is unspecified and
/// must be wiped by its owner.
pub(crate) fn open_segment(
    key: &[u8; 32],
    nonce: &[u8; 12],
    aad: &[u8],
    buffer: &mut [u8],
    tag: &[u8; 16],
) -> Result<(), CryptoError> {
    let cipher = Aes256Gcm::new_from_slice(key).map_err(|_| CryptoError::EncryptionFailed)?;
    cipher
        .decrypt_in_place_detached(Nonce::from_slice(nonce), aad, buffer, Tag::from_slice(tag))
        .map_err(|_| CryptoError::AuthenticationFailed)
}

/// Derived segment key, nonce prefix and associated data of one file.
struct SegmentCipher {
    key: Zeroizing<[u8; 32]>,
    nonce_prefix: [u8; NONCE_PREFIX_BYTES],
    aad: Vec<u8>,
}

impl SegmentCipher {
    fn new(
        file_key: &StreamKey,
        header: &[u8; STREAM_HEADER_BYTES],
        context: &SecretContext,
    ) -> Result<Self, CryptoError> {
        let mut key = Zeroizing::new([0u8; 32]);
        Hkdf::<Sha256>::new(Some(&header[8..40]), &*file_key.key)
            .expand(DOMAIN, &mut *key)
            .map_err(|_| CryptoError::HkdfFailed)?;
        let identity = context.identity();
        let mut aad = Vec::new();
        aad.try_reserve_exact(DOMAIN.len() + STREAM_HEADER_BYTES + identity.len())
            .map_err(|_| CryptoError::AllocationFailed)?;
        aad.extend_from_slice(DOMAIN);
        aad.extend_from_slice(header);
        aad.extend_from_slice(&identity);
        let mut nonce_prefix = [0u8; NONCE_PREFIX_BYTES];
        nonce_prefix.copy_from_slice(&header[40..]);
        Ok(Self {
            key,
            nonce_prefix,
            aad,
        })
    }
    fn nonce(&self, index: u64, last: bool) -> Result<[u8; 12], CryptoError> {
        let index = u32::try_from(index).map_err(|_| CryptoError::InputTooLarge)?;
        let mut nonce = [0u8; 12];
        nonce[..7].copy_from_slice(&self.nonce_prefix);
        nonce[7..11].copy_from_slice(&index.to_be_bytes());
        nonce[11] = u8::from(last);
        Ok(nonce)
    }
}

/// Encryption of one file from end to end, in one pass. `update` writes every complete
/// segment; a full buffered segment is kept until more data or `finish` tells whether it is
/// the last one. After an error the encryptor refuses any further call (`EncryptionFailed`).
pub struct StreamEncryptor {
    cipher: SegmentCipher,
    buffer: Zeroizing<Vec<u8>>,
    next_index: u64,
    plaintext_len: u64,
    failed: bool,
}

impl StreamEncryptor {
    /// Start a file: fresh salt (32 bytes) and nonce prefix (7 bytes) from `OsRng`. Returns the
    /// header to write first.
    pub fn new(
        key: &StreamKey,
        context: &SecretContext,
    ) -> Result<(Self, [u8; STREAM_HEADER_BYTES]), CryptoError> {
        Self::new_with(key, context, &mut OsRng)
    }
    fn new_with(
        key: &StreamKey,
        context: &SecretContext,
        rng: &mut (impl RngCore + CryptoRng),
    ) -> Result<(Self, [u8; STREAM_HEADER_BYTES]), CryptoError> {
        let mut salt = [0u8; SALT_BYTES];
        let mut prefix = [0u8; NONCE_PREFIX_BYTES];
        rng.try_fill_bytes(&mut salt)
            .map_err(|_| CryptoError::RandomUnavailable)?;
        rng.try_fill_bytes(&mut prefix)
            .map_err(|_| CryptoError::RandomUnavailable)?;
        Self::with_parameters(key, context, &salt, &prefix)
    }
    /// Fixed salt and prefix: reference vectors of STREAM_FORMAT_V1.md only, never public.
    pub(crate) fn with_parameters(
        key: &StreamKey,
        context: &SecretContext,
        salt: &[u8; SALT_BYTES],
        prefix: &[u8; NONCE_PREFIX_BYTES],
    ) -> Result<(Self, [u8; STREAM_HEADER_BYTES]), CryptoError> {
        let header = build_header(salt, prefix);
        let cipher = SegmentCipher::new(key, &header, context)?;
        let mut buffer = Zeroizing::new(Vec::new());
        buffer
            .try_reserve_exact(STREAM_SEGMENT_BYTES)
            .map_err(|_| CryptoError::AllocationFailed)?;
        Ok((
            Self {
                cipher,
                buffer,
                next_index: 0,
                plaintext_len: 0,
                failed: false,
            },
            header,
        ))
    }
    /// Add plaintext; appends each complete encrypted segment (65 552 bytes) to `out`. More
    /// than 2^48 bytes in total: `InputTooLarge`.
    pub fn update(&mut self, plaintext: &[u8], out: &mut Vec<u8>) -> Result<(), CryptoError> {
        if self.failed {
            return Err(CryptoError::EncryptionFailed);
        }
        let result = self.absorb(plaintext, out);
        self.failed = result.is_err();
        result
    }
    fn absorb(&mut self, plaintext: &[u8], out: &mut Vec<u8>) -> Result<(), CryptoError> {
        let total = u64::try_from(plaintext.len())
            .ok()
            .and_then(|len| self.plaintext_len.checked_add(len))
            .filter(|total| *total <= MAX_PLAINTEXT)
            .ok_or(CryptoError::InputTooLarge)?;
        let mut rest = plaintext;
        while !rest.is_empty() {
            if self.buffer.len() == STREAM_SEGMENT_BYTES {
                self.emit(false, out)?;
            }
            let take = (STREAM_SEGMENT_BYTES - self.buffer.len()).min(rest.len());
            self.buffer.extend_from_slice(&rest[..take]);
            rest = &rest[take..];
        }
        self.plaintext_len = total;
        Ok(())
    }
    fn emit(&mut self, last: bool, out: &mut Vec<u8>) -> Result<(), CryptoError> {
        let nonce = self.cipher.nonce(self.next_index, last)?;
        let start = out.len();
        // Reserved first: no reallocation of `out` while it holds plaintext.
        out.try_reserve(self.buffer.len() + STREAM_TAG_BYTES)
            .map_err(|_| CryptoError::AllocationFailed)?;
        out.extend_from_slice(&self.buffer);
        match seal_segment(
            &self.cipher.key,
            &nonce,
            &self.cipher.aad,
            &mut out[start..],
        ) {
            Ok(tag) => out.extend_from_slice(&tag),
            Err(error) => {
                out[start..].zeroize();
                out.truncate(start);
                return Err(error);
            }
        }
        self.buffer.zeroize();
        self.next_index += 1;
        Ok(())
    }
    /// Encrypt the last segment (flagged "last") and return the plaintext size.
    pub fn finish(mut self, out: &mut Vec<u8>) -> Result<u64, CryptoError> {
        if self.failed {
            return Err(CryptoError::EncryptionFailed);
        }
        self.emit(true, out)?;
        Ok(self.plaintext_len)
    }
}
impl fmt::Debug for StreamEncryptor {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str("StreamEncryptor([REDACTED])")
    }
}
impl ZeroizeOnDrop for StreamEncryptor {}

/// Segments and encrypted bytes to read for a plaintext range.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct StreamSpan {
    /// Index of the first segment to decrypt.
    pub first_segment: u64,
    /// Index of the last segment to decrypt (inclusive).
    pub last_segment: u64,
    /// Offsets of these segments in the encrypted file (header included), end excluded.
    pub ciphertext: Range<u64>,
    /// Plaintext bytes to skip at the start of the first segment.
    pub skip_in_first: usize,
    /// Plaintext bytes to return from there (the requested range length).
    pub take: u64,
}

/// Reading of an encrypted file whose total size is known (file record). The header is
/// authenticated with each segment, not by `new`.
pub struct StreamDecryptor {
    cipher: SegmentCipher,
    segments: u64,
    plaintext_len: u64,
}

impl StreamDecryptor {
    /// Check the header (`InvalidStreamHeader`; unknown version: `UnsupportedVersion`) and the
    /// total encrypted size, header included (incoherent: `InvalidStreamHeader`).
    pub fn new(
        key: &StreamKey,
        context: &SecretContext,
        header: &[u8],
        ciphertext_len: u64,
    ) -> Result<Self, CryptoError> {
        let header: &[u8; STREAM_HEADER_BYTES] = header
            .try_into()
            .map_err(|_| CryptoError::InvalidStreamHeader)?;
        if &header[..4] != MAGIC {
            return Err(CryptoError::InvalidStreamHeader);
        }
        if header[4] != VERSION {
            return Err(CryptoError::UnsupportedVersion);
        }
        if header[5] != SUITE_AES_256_GCM || header[6] != SEGMENT_EXPONENT || header[7] != FLAGS {
            return Err(CryptoError::InvalidStreamHeader);
        }
        let body = ciphertext_len
            .checked_sub(HEADER)
            .filter(|body| *body >= TAG)
            .ok_or(CryptoError::InvalidStreamHeader)?;
        let segments = body.div_ceil(SEGMENT_CIPHERTEXT);
        let last = body - (segments - 1) * SEGMENT_CIPHERTEXT;
        if segments > MAX_SEGMENTS || last < TAG || (segments > 1 && last == TAG) {
            return Err(CryptoError::InvalidStreamHeader);
        }
        Ok(Self {
            cipher: SegmentCipher::new(key, header, context)?,
            segments,
            plaintext_len: body - TAG * segments,
        })
    }
    /// Plaintext size of the file.
    pub fn plaintext_len(&self) -> u64 {
        self.plaintext_len
    }
    /// Number of segments (1 for an empty file).
    pub fn segment_count(&self) -> u64 {
        self.segments
    }
    fn segment_plaintext_len(&self, index: u64) -> u64 {
        if index + 1 < self.segments {
            SEGMENT
        } else {
            self.plaintext_len - (self.segments - 1) * SEGMENT
        }
    }
    /// Segments and encrypted bytes to read for a plaintext range (end excluded). An empty
    /// range names the segment holding its position. Start after end, or end beyond the
    /// plaintext: `InputTooLarge`.
    pub fn plan_range(&self, plaintext: Range<u64>) -> Result<StreamSpan, CryptoError> {
        if plaintext.start > plaintext.end || plaintext.end > self.plaintext_len {
            return Err(CryptoError::InputTooLarge);
        }
        let first = (plaintext.start / SEGMENT).min(self.segments - 1);
        let last = if plaintext.is_empty() {
            first
        } else {
            (plaintext.end - 1) / SEGMENT
        };
        let skip = usize::try_from(plaintext.start - first * SEGMENT)
            .map_err(|_| CryptoError::InputTooLarge)?;
        let end = HEADER + last * SEGMENT_CIPHERTEXT + self.segment_plaintext_len(last) + TAG;
        Ok(StreamSpan {
            first_segment: first,
            last_segment: last,
            ciphertext: HEADER + first * SEGMENT_CIPHERTEXT..end,
            skip_in_first: skip,
            take: plaintext.end - plaintext.start,
        })
    }
    /// Decrypt segment `index` (its encrypted bytes and tag); the last segment is recognised by
    /// its rank. Index beyond the file or wrong length: `InvalidStreamHeader`; altered,
    /// moved or foreign segment, truncated or extended file, other context or key:
    /// `AuthenticationFailed`.
    pub fn decrypt_segment(
        &self,
        index: u64,
        ciphertext: &[u8],
    ) -> Result<SecretBytes, CryptoError> {
        if index >= self.segments {
            return Err(CryptoError::InvalidStreamHeader);
        }
        let len = self.segment_plaintext_len(index);
        if u64::try_from(ciphertext.len()).ok() != Some(len + TAG) {
            return Err(CryptoError::InvalidStreamHeader);
        }
        let len = usize::try_from(len).map_err(|_| CryptoError::InvalidStreamHeader)?;
        let nonce = self.cipher.nonce(index, index + 1 == self.segments)?;
        let tag: &[u8; 16] = ciphertext[len..]
            .try_into()
            .map_err(|_| CryptoError::InvalidStreamHeader)?;
        let mut plaintext = SecretBytes::zeroed(len)?;
        plaintext.inner.copy_from_slice(&ciphertext[..len]);
        open_segment(
            &self.cipher.key,
            &nonce,
            &self.cipher.aad,
            &mut plaintext.inner,
            tag,
        )?;
        Ok(plaintext)
    }
}
impl fmt::Debug for StreamDecryptor {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str("StreamDecryptor([REDACTED])")
    }
}
impl ZeroizeOnDrop for StreamDecryptor {}

#[cfg(test)]
mod vectors {
    include!("stream_vectors.rs");
}
