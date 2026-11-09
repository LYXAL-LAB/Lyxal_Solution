use async_trait::async_trait;
use lyxal_error::{LyxalCallError, LyxalResult};
use surrealdb::engine::any::Any;
use surrealdb::types::SurrealValue;
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
    /// Les paramètres et le résultat traversent la frontière Rust ↔ SurrealDB via le trait natif
    /// `SurrealValue` (`#[derive(SurrealValue)]` sur les `XxxParams` / `XxxResult`).
    /// Désérialise et retourne le contrat universel `LyxalResult<T>`.
    async fn call_fn<T, P>(
        &self,
        function_name: &'static str,
        params: P,
    ) -> Result<T, LyxalSurrealError>
    where
        T: SurrealValue + Send,
        P: SurrealValue + Send + 'static,
    {
        if !validate_function_name(function_name) {
            return Err(LyxalSurrealError::InvalidFunctionName {
                function: function_name,
            });
        }

        let query = format!("RETURN fn::{}($params);", function_name);

        let executed = async {
            let mut response = self
                .surreal_client()
                .query(query)
                .bind(("params", params))
                .await?;
            response.take::<Option<LyxalResult<T>>>(0)
        }
        .await;
        let raw = match executed {
            Ok(raw) => raw,
            Err(error) => return Err(self.resolve_thrown(error, function_name).await),
        };
        let result = raw.ok_or(LyxalCallError::InvalidContract {
            function: function_name,
        })?;
        Ok(result.into_result(function_name)?)
    }

    /// Erreur levée par `THROW "<CODE>"` ou `THROW "<CODE>: …"` (annulation d'une écriture
    /// multiple, garde `DEFINE EVENT`) : le code de module est résolu par `fn::error_result`
    /// (master data de `lyxal_error`) et renvoyé en erreur métier. Toute autre erreur, ou une
    /// résolution impossible, reste l'erreur de base d'origine.
    async fn resolve_thrown(
        &self,
        error: surrealdb::Error,
        function_name: &'static str,
    ) -> LyxalSurrealError {
        let Some(code) = thrown_code(error.is_thrown(), error.message()) else {
            return error.into();
        };
        let resolved = async {
            let mut response = self
                .surreal_client()
                .query("RETURN fn::error_result($code, NONE, {});")
                .bind(("code", code.to_string()))
                .await?;
            response.take::<Option<LyxalResult<surrealdb::types::Value>>>(0)
        }
        .await;
        match resolved {
            Ok(Some(result)) => match result.into_result(function_name) {
                Err(business @ LyxalCallError::Business(_)) => business.into(),
                _ => error.into(),
            },
            _ => error.into(),
        }
    }
}

/// Code de module levé par `THROW` : `<CODE>` ou `<CODE>: texte`, où `<CODE>` est en
/// majuscules et contient au moins un `_` (`AUTH_WRITE_FORBIDDEN`).
///
/// SurrealDB marque l'erreur comme levée (`thrown`) et préfixe son message par
/// `An error occurred: `. Levée dans un `DEFINE EVENT`, elle arrive en erreur interne au message
/// `Error while processing event <nom>: An error occurred: <CODE>…`, reconnue seulement avec ce
/// marqueur de `THROW`.
pub fn thrown_code(thrown: bool, message: &str) -> Option<&str> {
    let text = if let Some(event) = message.strip_prefix("Error while processing event ") {
        event
            .split_once(": ")?
            .1
            .strip_prefix("An error occurred: ")?
    } else if thrown {
        message
            .strip_prefix("An error occurred: ")
            .unwrap_or(message)
    } else {
        return None;
    };
    let end = text
        .find(|c: char| c == ':' || c.is_whitespace())
        .unwrap_or(text.len());
    let (code, rest) = text.split_at(end);
    let well_formed = code.contains('_')
        && code.starts_with(|c: char| c.is_ascii_uppercase())
        && !code.starts_with('_')
        && !code.ends_with('_')
        && !code.contains("__")
        && code
            .bytes()
            .all(|b| b.is_ascii_uppercase() || b.is_ascii_digit() || b == b'_');
    (well_formed && (rest.is_empty() || rest.starts_with(':'))).then_some(code)
}

#[cfg(test)]
mod tests {
    use super::thrown_code;

    #[test]
    fn thrown_code_reads_the_module_code() {
        assert_eq!(
            thrown_code(true, "An error occurred: AUTH_WRITE_FORBIDDEN"),
            Some("AUTH_WRITE_FORBIDDEN")
        );
        assert_eq!(
            thrown_code(
                true,
                "An error occurred: CATALOGUE_ITEM_TENANT_REQUIRED: Organisation requise."
            ),
            Some("CATALOGUE_ITEM_TENANT_REQUIRED")
        );
        assert_eq!(
            thrown_code(true, "AUTH_IDENTITY_INACTIVE"),
            Some("AUTH_IDENTITY_INACTIVE")
        );
        // Levée dans un DEFINE EVENT : erreur interne, marqueur de THROW obligatoire
        assert_eq!(
            thrown_code(
                false,
                "Error while processing event guard: An error occurred: AUTH_ROLE_SCOPE_MISMATCH"
            ),
            Some("AUTH_ROLE_SCOPE_MISMATCH")
        );
    }

    #[test]
    fn thrown_code_refuses_free_text() {
        for message in [
            "An error occurred: something went wrong",
            "An error occurred: AUTH",
            "An error occurred: Auth_Write",
            "An error occurred: AUTH_WRITE forbidden",
            "An error occurred: _AUTH_X",
            "An error occurred: AUTH__X",
            "An error occurred: AUTH_X_",
            "",
        ] {
            assert_eq!(thrown_code(true, message), None, "{message}");
        }
        // Erreur non levée par THROW : jamais interprétée
        assert_eq!(thrown_code(false, "AUTH_WRITE_FORBIDDEN"), None);
        assert_eq!(
            thrown_code(
                false,
                "Error while processing event guard: Found AUTH_X for field `state`"
            ),
            None
        );
    }
}
