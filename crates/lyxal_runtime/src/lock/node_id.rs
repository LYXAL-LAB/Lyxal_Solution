use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use std::fmt;
use std::ops::Deref;
use std::time::SystemTime;

/// Identifiant unique et immuable d'un nœud / instance d'exécution du Lyxal Runtime.
#[derive(Debug, Clone, PartialEq, Eq, Hash, PartialOrd, Ord, Serialize, Deserialize)]
pub struct NodeId(String);

impl NodeId {
    /// Crée un nouvel identifiant de nœud à partir d'une chaîne arbitraire normalisée.
    pub fn new(id: impl Into<String>) -> Self {
        Self(id.into().trim().to_string())
    }

    /// Génère un identifiant de nœud unique et déterministe combinant horodatage et entropie SHA-256.
    pub fn generate() -> Self {
        let now = SystemTime::now()
            .duration_since(SystemTime::UNIX_EPOCH)
            .unwrap_or_default();
        let nanos = now.as_nanos();
        let pid = std::process::id();

        let mut hasher = Sha256::new();
        hasher.update(nanos.to_le_bytes());
        hasher.update(pid.to_le_bytes());
        let hash = format!("{:x}", hasher.finalize());

        Self(format!("node-{}-{}", pid, &hash[..8]))
    }

    /// Retourne la référence slice str.
    pub fn as_str(&self) -> &str {
        &self.0
    }
}

impl Deref for NodeId {
    type Target = str;

    fn deref(&self) -> &Self::Target {
        &self.0
    }
}

impl AsRef<str> for NodeId {
    fn as_ref(&self) -> &str {
        &self.0
    }
}

impl fmt::Display for NodeId {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.0)
    }
}

impl From<&str> for NodeId {
    fn from(s: &str) -> Self {
        Self::new(s)
    }
}

impl From<String> for NodeId {
    fn from(s: String) -> Self {
        Self::new(s)
    }
}
