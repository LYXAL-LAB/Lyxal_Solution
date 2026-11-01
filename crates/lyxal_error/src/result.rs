use crate::error::{LyxalCallError, LyxalError};
use serde::{Deserialize, Serialize};
use surrealdb_types::{SurrealValue, Value};

/// Contrat universel de réponse pour toutes les fonctions SurrealQL de l'écosystème Lyxal OS.
///
/// Lu depuis SurrealDB via `SurrealValue` et renvoyé tel quel en JSON par l'API HTTP via `serde`.
#[derive(Debug, Clone, Serialize, Deserialize, SurrealValue)]
#[surreal(crate = "surrealdb_types")]
pub struct LyxalResult<T: SurrealValue> {
    pub ok: bool,
    pub data: Option<T>,
    pub error: Option<LyxalError>,
}

impl<T: SurrealValue> LyxalResult<T> {
    /// Convertit le contrat universel `LyxalResult<T>` en un `Result<T, LyxalCallError>` Rust typé.
    ///
    /// Rejette strictement tous les états incohérents (ex: ok=true avec data non convertible ou ok=false avec data=Some).
    /// Un succès sans donnée n'est accepté que si `T` accepte l'absence de valeur (`()` ou `Option<_>`).
    pub fn into_result(self, function: &'static str) -> Result<T, LyxalCallError> {
        match (self.ok, self.data, self.error) {
            (true, Some(data), None) => Ok(data),
            (true, None, None) => {
                T::from_value(Value::None).map_err(|_| LyxalCallError::InvalidContract { function })
            }
            (false, None, Some(error)) => Err(LyxalCallError::Business(error)),
            _ => Err(LyxalCallError::InvalidContract { function }),
        }
    }
}
