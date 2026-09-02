use crate::error::RuntimeError;
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use std::fmt;

/// Somme de contrôle cryptographique SHA-256 garantissant l'immuabilité d'un script de migration.
#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub struct MigrationChecksum(String);

impl MigrationChecksum {
    /// Calcule la somme de contrôle SHA-256 à partir d'un flux d'octets.
    pub fn from_bytes(bytes: &[u8]) -> Self {
        let mut hasher = Sha256::new();
        hasher.update(bytes);
        let result = hasher.finalize();
        let hex = format!("{:x}", result);
        Self(hex)
    }

    /// Calcule la somme de contrôle SHA-256 à partir du contenu d'un script SurrealQL.
    pub fn from_surql(content: &str) -> Self {
        Self::from_bytes(content.as_bytes())
    }

    /// Crée une instance à partir d'une chaîne hexadécimale existante en vérifiant son format SHA-256 (64 caractères hex).
    pub fn from_hex(hex: impl Into<String>) -> Result<Self, RuntimeError> {
        let raw = hex.into().trim().to_lowercase();
        if raw.len() != 64 || !raw.chars().all(|c| c.is_ascii_hexdigit()) {
            return Err(RuntimeError::InvalidChecksum {
                expected: "64-character lowercase SHA-256 hexadecimal string".to_string(),
                found: raw,
            });
        }
        Ok(Self(raw))
    }

    /// Retourne la représentation hexadécimale du checksum.
    pub fn as_str(&self) -> &str {
        &self.0
    }

    /// Vérifie si le contenu donné produit exactement la même somme de contrôle.
    pub fn verify(&self, bytes: &[u8]) -> bool {
        let computed = Self::from_bytes(bytes);
        self.0 == computed.0
    }
}

impl fmt::Display for MigrationChecksum {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.0)
    }
}

impl AsRef<str> for MigrationChecksum {
    fn as_ref(&self) -> &str {
        &self.0
    }
}
