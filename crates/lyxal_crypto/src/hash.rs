//! Generic SHA-256 and BLAKE3 hashing; never a substitute for Argon2 password hashing.
use sha2::{Digest, Sha256};

/// Compute the SHA-256 digest (32 bytes) of a byte slice.
pub fn sha256(data: &[u8]) -> [u8; 32] {
    let mut hasher = Sha256::new();
    hasher.update(data);
    hasher.finalize().into()
}

/// Compute the SHA-256 digest as lowercase hexadecimal (64 characters).
pub fn sha256_hex(data: &[u8]) -> String {
    let bytes = sha256(data);
    hex::encode(bytes)
}

/// Compute the BLAKE3 hash (32 bytes) of a byte slice.
pub fn blake3(data: &[u8]) -> [u8; 32] {
    let hash = blake3::hash(data);
    *hash.as_bytes()
}

/// Compute the BLAKE3 hash as lowercase hexadecimal (64 characters).
pub fn blake3_hex(data: &[u8]) -> String {
    let bytes = blake3(data);
    hex::encode(bytes)
}

/// Incremental SHA-256 hasher for streamed or multi-part input.
#[derive(Default, Clone)]
pub struct Sha256Hasher(Sha256);

impl Sha256Hasher {
    /// Start an empty streaming hash.
    pub fn new() -> Self {
        Self(Sha256::new())
    }

    /// Feed the next public-data chunk into the hash.
    pub fn update(&mut self, data: &[u8]) {
        self.0.update(data);
    }

    /// Finalize and consume the hasher, returning 32 digest bytes.
    pub fn finalize(self) -> [u8; 32] {
        self.0.finalize().into()
    }

    /// Finalize and consume the hasher, returning lowercase hexadecimal.
    pub fn finalize_hex(self) -> String {
        let bytes = self.finalize();
        hex::encode(bytes)
    }
}

/// Incremental BLAKE3 hasher for streamed or multi-part input.
#[derive(Default, Clone)]
pub struct Blake3Hasher(blake3::Hasher);

impl Blake3Hasher {
    /// Start an empty streaming hash.
    pub fn new() -> Self {
        Self(blake3::Hasher::new())
    }

    /// Feed the next public-data chunk into the hash.
    pub fn update(&mut self, data: &[u8]) {
        self.0.update(data);
    }

    /// Finalize and consume the hasher, returning 32 digest bytes.
    pub fn finalize(self) -> [u8; 32] {
        *self.0.finalize().as_bytes()
    }

    /// Finalize and consume the hasher, returning lowercase hexadecimal.
    pub fn finalize_hex(self) -> String {
        let bytes = self.finalize();
        hex::encode(bytes)
    }
}
