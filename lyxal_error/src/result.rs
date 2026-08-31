use crate::error::{LyxalCallError, LyxalError};
use serde::{Deserialize, Serialize};

/// Contrat universel de réponse pour toutes les fonctions SurrealQL de l'écosystème Lyxal OS.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LyxalResult<T> {
    pub ok: bool,
    pub data: Option<T>,
    pub error: Option<LyxalError>,
}

impl<T: serde::de::DeserializeOwned> LyxalResult<T> {
    /// Convertit le contrat universel `LyxalResult<T>` en un `Result<T, LyxalCallError>` Rust typé.
    ///
    /// Rejette strictement tous les états incohérents (ex: ok=true avec data non convertible ou ok=false avec data=Some).
    pub fn into_result(self, function: &'static str) -> Result<T, LyxalCallError> {
        match (self.ok, self.data, self.error) {
            (true, Some(data), None) => Ok(data),
            (true, None, None) => {
                if let Ok(val) = serde_json::from_value::<T>(serde_json::Value::Null) {
                    Ok(val)
                } else {
                    Err(LyxalCallError::InvalidContract { function })
                }
            }
            (false, None, Some(error)) => Err(LyxalCallError::Business(error)),
            _ => Err(LyxalCallError::InvalidContract { function }),
        }
    }
}
