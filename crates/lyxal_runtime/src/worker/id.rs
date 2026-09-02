use crate::error::RuntimeError;
use crate::types::ModuleId;
use serde::{Deserialize, Serialize};
use std::fmt;

/// Identifiant canonique et fortement typé d'un worker d'arrière-plan.
///
/// Format canonique obligatoire : `<module-id>:<worker-name>` (ex: `lyxal-notification:delivery`).
#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord, Hash, Serialize, Deserialize)]
pub struct WorkerId(String);

impl WorkerId {
    /// Crée un nouvel `WorkerId` à partir d'un `ModuleId` et d'un nom de worker.
    pub fn new(module_id: &ModuleId, name: impl Into<String>) -> Result<Self, RuntimeError> {
        let name_str = name.into().trim().to_string();
        if name_str.is_empty() {
            return Err(RuntimeError::Internal {
                code: "RUNTIME_WORKER_INVALID_ID",
                message: format!(
                    "Worker name cannot be empty for module '{}'",
                    module_id.as_str()
                ),
            });
        }

        let canonical = format!("{}:{}", module_id.as_str(), name_str);
        Ok(Self(canonical))
    }

    /// Analyse et valide une chaîne au format `<module-id>:<worker-name>`.
    pub fn parse(s: &str) -> Result<Self, RuntimeError> {
        let s = s.trim();
        let parts: Vec<&str> = s.splitn(2, ':').collect();
        if parts.len() != 2 || parts[0].trim().is_empty() || parts[1].trim().is_empty() {
            return Err(RuntimeError::Internal {
                code: "RUNTIME_WORKER_INVALID_ID",
                message: format!(
                    "Invalid canonical worker id '{}': expected format '<module-id>:<worker-name>'",
                    s
                ),
            });
        }

        let module_id = ModuleId::new(parts[0].trim());
        let name = parts[1].trim();
        Self::new(&module_id, name)
    }

    /// Extrait le `ModuleId` propriétaire de ce worker.
    pub fn module_id(&self) -> ModuleId {
        let parts: Vec<&str> = self.0.splitn(2, ':').collect();
        ModuleId::new(parts[0])
    }

    /// Retourne le nom du worker (sans le préfixe de module).
    pub fn name(&self) -> &str {
        let parts: Vec<&str> = self.0.splitn(2, ':').collect();
        if parts.len() > 1 {
            parts[1]
        } else {
            &self.0
        }
    }

    /// Retourne la représentation textuelle canonique (`<module-id>:<worker-name>`).
    pub fn as_str(&self) -> &str {
        &self.0
    }
}

impl fmt::Display for WorkerId {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.0)
    }
}

impl AsRef<str> for WorkerId {
    fn as_ref(&self) -> &str {
        &self.0
    }
}
