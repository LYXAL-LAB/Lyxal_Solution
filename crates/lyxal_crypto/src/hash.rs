use sha2::{Digest, Sha256};

/// Calcule la somme de contrôle SHA-256 (32 octets) à partir d'un flux d'octets.
pub fn sha256(data: &[u8]) -> [u8; 32] {
    let mut hasher = Sha256::new();
    hasher.update(data);
    hasher.finalize().into()
}

/// Calcule la somme de contrôle SHA-256 sous forme de chaîne hexadécimale minuscule (64 caractères).
pub fn sha256_hex(data: &[u8]) -> String {
    let bytes = sha256(data);
    hex::encode(bytes)
}

/// Calcule le hash BLAKE3 (32 octets) à partir d'un flux d'octets.
pub fn blake3(data: &[u8]) -> [u8; 32] {
    let hash = blake3::hash(data);
    *hash.as_bytes()
}

/// Calcule le hash BLAKE3 sous forme de chaîne hexadécimale minuscule (64 caractères).
pub fn blake3_hex(data: &[u8]) -> String {
    let bytes = blake3(data);
    hex::encode(bytes)
}

/// Hasher incrémental SHA-256 pour les calculs par flux ou multi-parties.
#[derive(Default, Clone)]
pub struct Sha256Hasher(Sha256);

impl Sha256Hasher {
    pub fn new() -> Self {
        Self(Sha256::new())
    }

    pub fn update(&mut self, data: &[u8]) {
        self.0.update(data);
    }

    pub fn finalize(self) -> [u8; 32] {
        self.0.finalize().into()
    }

    pub fn finalize_hex(self) -> String {
        let bytes = self.finalize();
        hex::encode(bytes)
    }
}

/// Hasher incrémental BLAKE3 pour les calculs par flux ou multi-parties.
#[derive(Default, Clone)]
pub struct Blake3Hasher(blake3::Hasher);

impl Blake3Hasher {
    pub fn new() -> Self {
        Self(blake3::Hasher::new())
    }

    pub fn update(&mut self, data: &[u8]) {
        self.0.update(data);
    }

    pub fn finalize(self) -> [u8; 32] {
        *self.0.finalize().as_bytes()
    }

    pub fn finalize_hex(self) -> String {
        let bytes = self.finalize();
        hex::encode(bytes)
    }
}
