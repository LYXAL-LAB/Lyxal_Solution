use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use std::fmt;
use std::ops::Deref;
use std::sync::atomic::{AtomicU64, Ordering};
use std::time::SystemTime;

static EVENT_COUNTER: AtomicU64 = AtomicU64::new(1);

/// Identifiant unique, déterministe et fortement typé d'un événement interne du Runtime.
#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord, Hash, Serialize, Deserialize)]
pub struct RuntimeEventId(String);

impl RuntimeEventId {
    /// Crée un `RuntimeEventId` à partir d'une chaîne arbitraire validée.
    pub fn new(id: impl Into<String>) -> Self {
        Self(id.into().trim().to_string())
    }

    /// Génère un nouvel identifiant d'événement unique combinant horodatage nanoseconde, PID, compteur atomique et entropie SHA-256.
    pub fn generate() -> Self {
        let now = SystemTime::now()
            .duration_since(SystemTime::UNIX_EPOCH)
            .unwrap_or_default();
        let nanos = now.as_nanos();
        let pid = std::process::id();
        let count = EVENT_COUNTER.fetch_add(1, Ordering::SeqCst);

        let mut hasher = Sha256::new();
        hasher.update(nanos.to_le_bytes());
        hasher.update(pid.to_le_bytes());
        hasher.update(count.to_le_bytes());
        let hash = format!("{:x}", hasher.finalize());

        Self(format!("evt-{}-{:06x}-{}", pid, count, &hash[..8]))
    }

    /// Retourne la représentation textuelle sous forme de `&str`.
    pub fn as_str(&self) -> &str {
        &self.0
    }
}

impl Deref for RuntimeEventId {
    type Target = str;

    fn deref(&self) -> &Self::Target {
        &self.0
    }
}

impl AsRef<str> for RuntimeEventId {
    fn as_ref(&self) -> &str {
        &self.0
    }
}

impl fmt::Display for RuntimeEventId {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.0)
    }
}

impl From<&str> for RuntimeEventId {
    fn from(s: &str) -> Self {
        Self::new(s)
    }
}

impl From<String> for RuntimeEventId {
    fn from(s: String) -> Self {
        Self::new(s)
    }
}
