use crate::error::CryptoError;
use rand::RngCore;
use std::fmt;
use std::ops::Deref;
use zeroize::Zeroizing;

/// Identifiant unique et validé d'une clé de chiffrement (ex: "main", "main-2026-01").
///
/// Exige des caractères ASCII stricts : `[A-Za-z0-9._-]{1,64}` (sans ':', ni espaces, ni Unicode).
#[derive(Clone, PartialEq, Eq, Hash)]
pub struct KeyId(String);

impl KeyId {
    pub fn parse(s: impl AsRef<str>) -> Result<Self, CryptoError> {
        let trimmed = s.as_ref().trim();
        if trimmed.is_empty() || trimmed.len() > 64 {
            return Err(CryptoError::InvalidKeyId(trimmed.to_string()));
        }
        for ch in trimmed.chars() {
            if !ch.is_ascii_alphanumeric() && ch != '_' && ch != '-' && ch != '.' {
                return Err(CryptoError::InvalidKeyId(trimmed.to_string()));
            }
        }
        Ok(Self(trimmed.to_string()))
    }

    pub fn as_str(&self) -> &str {
        &self.0
    }
}

impl fmt::Debug for KeyId {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "KeyId({})", self.0)
    }
}

impl fmt::Display for KeyId {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.0)
    }
}

impl Deref for KeyId {
    type Target = str;
    fn deref(&self) -> &Self::Target {
        &self.0
    }
}

/// Clé de chiffrement symétrique AES-256 (32 octets) sécurisée en mémoire.
///
/// Ne peut pas être clônée, ni sérialisée, et masque son affichage `Debug`.
pub struct EncryptionKey {
    bytes: Zeroizing<[u8; 32]>,
}

impl EncryptionKey {
    /// Crée une nouvelle clé à partir d'un buffer de 32 octets bruts.
    pub fn from_bytes(raw: [u8; 32]) -> Self {
        Self {
            bytes: Zeroizing::new(raw),
        }
    }

    /// Tente de créer une clé depuis un slice d'octets.
    pub fn try_from_slice(slice: &[u8]) -> Result<Self, CryptoError> {
        if slice.len() != 32 {
            return Err(CryptoError::InvalidKeyLength);
        }
        let mut buf = [0u8; 32];
        buf.copy_from_slice(slice);
        Ok(Self::from_bytes(buf))
    }

    /// Génère une clé cryptographique aléatoire de 32 octets de haute qualité.
    pub fn generate() -> Self {
        let mut buf = [0u8; 32];
        rand::thread_rng().fill_bytes(&mut buf);
        Self::from_bytes(buf)
    }

    /// Expose les octets de la clé uniquement au module interne de chiffrement.
    pub(crate) fn expose(&self) -> &[u8; 32] {
        &self.bytes
    }
}

impl fmt::Debug for EncryptionKey {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str("EncryptionKey([REDACTED])")
    }
}
