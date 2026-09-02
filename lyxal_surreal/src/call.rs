use async_trait::async_trait;
use lyxal_error::{LyxalCallError, LyxalResult};
use serde::de::DeserializeOwned;
use serde::Serialize;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

use crate::error::LyxalSurrealError;

/// Valide que le nom de la fonction ne contient que des minuscules alphanumériques et des underscores ASCII.
pub fn validate_function_name(name: &str) -> bool {
    !name.is_empty()
        && name
            .bytes()
            .all(|byte| byte.is_ascii_lowercase() || byte.is_ascii_digit() || byte == b'_')
}

/// Trait universel fournissant la méthode d'extension `call_fn` à tous les stores de l'écosystème Lyxal OS.
#[async_trait]
pub trait LyxalSurrealCall {
    /// Récupère la référence au client SurrealDB (Transport Any - WS ou Mem).
    fn surreal_client(&self) -> &Surreal<Any>;

    /// Exécute une fonction SurrealQL `fn::<function_name>($params)` en lui transmettant un objet `$params` typé.
    ///
    /// Désérialise et retourne le contrat universel `LyxalResult<T>`.
    async fn call_fn<T, P>(
        &self,
        function_name: &'static str,
        params: P,
    ) -> Result<T, LyxalSurrealError>
    where
        T: DeserializeOwned + Send,
        P: Serialize + Send + 'static,
    {
        if !validate_function_name(function_name) {
            return Err(LyxalSurrealError::InvalidFunctionName {
                function: function_name,
            });
        }

        let query = format!("RETURN fn::{}($params);", function_name);

        let mut response = self
            .surreal_client()
            .query(query)
            .bind(("params", params))
            .await?;

        let raw: Option<LyxalResult<T>> = response.take(0)?;
        let result = raw.ok_or(LyxalCallError::InvalidContract {
            function: function_name,
        })?;
        Ok(result.into_result(function_name)?)
    }
}
