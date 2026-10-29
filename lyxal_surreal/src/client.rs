use surrealdb::engine::any::{self, Any};
use surrealdb::opt::auth::Root;
use surrealdb::Surreal;

use crate::error::LyxalSurrealError;

/// Identifiants de connexion d'administration Root pour instance distante SurrealDB.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct RootCredentials {
    pub username: String,
    pub password: String,
}

impl RootCredentials {
    pub fn new(username: impl Into<String>, password: impl Into<String>) -> Self {
        Self {
            username: username.into(),
            password: password.into(),
        }
    }
}

/// Normalise la chaîne de point de terminaison en retirant les barres obliques de fin et le suffixe `/rpc`.
pub fn normalize_endpoint(endpoint: &str) -> String {
    let trimmed = endpoint.trim();
    if trimmed == "memory" || trimmed == "mem://" {
        return trimmed.to_owned();
    }
    if let Some(rest) = trimmed.strip_prefix("mem://") {
        let clean = rest.trim_matches('/');
        if clean.is_empty() {
            return "mem://".to_owned();
        }
        return format!("mem://{}", clean);
    }
    let without_slash = trimmed.trim_end_matches('/');
    without_slash
        .strip_suffix("/rpc")
        .unwrap_or(without_slash)
        .trim_end_matches('/')
        .to_owned()
}

/// Valide que le schéma d'URL correspond strictement aux protocoles autorisés par la Charte Lyxal OS (§11.2) :
/// `ws://`, `wss://`, `mem://` ou `memory`.
pub fn validate_endpoint_scheme(endpoint: &str) -> Result<(), LyxalSurrealError> {
    let ep = endpoint.trim();
    if ep.starts_with("ws://")
        || ep.starts_with("wss://")
        || ep.starts_with("mem://")
        || ep == "memory"
    {
        Ok(())
    } else {
        Err(LyxalSurrealError::UnsupportedEndpoint {
            endpoint: ep.to_owned(),
        })
    }
}

/// Initialise et connecte un client unifié `Surreal<Any>` conformément à la Charte Lyxal OS (§11.2).
///
/// # Règles d'authentification
/// - **Connexions distantes (`ws://`, `wss://`)** : requièrent obligatoirement des identifiants `Root`.
///   Lève `LyxalSurrealError::MissingCredentials` si omis ou vides.
/// - **Connexions embarquées (`mem://`, `memory`)** : ne tentent **JAMAIS** d'authentification Root
///   pour éviter les erreurs de session mémoire.
pub async fn create_surreal_client(
    endpoint: &str,
    credentials: Option<RootCredentials>,
) -> Result<Surreal<Any>, LyxalSurrealError> {
    let normalized = normalize_endpoint(endpoint);
    validate_endpoint_scheme(&normalized)?;

    let embedded = normalized == "memory" || normalized.starts_with("mem://");

    if !embedded {
        let creds_valid = credentials
            .as_ref()
            .map(|c| !c.username.trim().is_empty() && !c.password.trim().is_empty())
            .unwrap_or(false);

        if !creds_valid {
            return Err(LyxalSurrealError::MissingCredentials {
                endpoint: normalized,
            });
        }
    }

    let db = any::connect(normalized.clone()).await?;

    if !embedded {
        if let Some(creds) = credentials {
            db.signin(Root {
                username: &creds.username,
                password: &creds.password,
            })
            .await?;
        }
    }

    Ok(db)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_normalize_endpoint() {
        assert_eq!(normalize_endpoint("ws://127.0.0.1:8000/"), "ws://127.0.0.1:8000");
        assert_eq!(normalize_endpoint("ws://127.0.0.1:8000/rpc"), "ws://127.0.0.1:8000");
        assert_eq!(normalize_endpoint("ws://127.0.0.1:8000/rpc/"), "ws://127.0.0.1:8000");
        assert_eq!(normalize_endpoint("mem://"), "mem://");
        assert_eq!(normalize_endpoint("memory"), "memory");
    }

    #[test]
    fn test_validate_endpoint_scheme_valid() {
        assert!(validate_endpoint_scheme("ws://127.0.0.1:8000").is_ok());
        assert!(validate_endpoint_scheme("wss://cluster.lyxal.dev").is_ok());
        assert!(validate_endpoint_scheme("mem://").is_ok());
        assert!(validate_endpoint_scheme("memory").is_ok());
    }

    #[test]
    fn test_validate_endpoint_scheme_invalid() {
        let res = validate_endpoint_scheme("http://127.0.0.1:8000");
        assert!(matches!(res, Err(LyxalSurrealError::UnsupportedEndpoint { .. })));

        let res = validate_endpoint_scheme("tcp://127.0.0.1:8000");
        assert!(matches!(res, Err(LyxalSurrealError::UnsupportedEndpoint { .. })));

        let res = validate_endpoint_scheme("invalid");
        assert!(matches!(res, Err(LyxalSurrealError::UnsupportedEndpoint { .. })));
    }

    #[tokio::test]
    async fn test_create_surreal_client_mem_success() {
        let db = create_surreal_client("mem://", None).await;
        assert!(db.is_ok(), "mem:// connection without credentials must succeed");
        let client = db.unwrap();
        client.use_ns("test_ns").use_db("test_db").await.expect("Select NS/DB");
    }

    #[tokio::test]
    async fn test_create_surreal_client_rejects_missing_credentials_on_ws() {
        let res = create_surreal_client("ws://127.0.0.1:9999", None).await;
        assert!(matches!(res, Err(LyxalSurrealError::MissingCredentials { .. })));

        let empty_cred = Some(RootCredentials::new("", ""));
        let res2 = create_surreal_client("ws://127.0.0.1:9999", empty_cred).await;
        assert!(matches!(res2, Err(LyxalSurrealError::MissingCredentials { .. })));
    }

    #[tokio::test]
    async fn test_create_surreal_client_rejects_unsupported_endpoint() {
        let res = create_surreal_client("http://127.0.0.1:8000", None).await;
        assert!(matches!(res, Err(LyxalSurrealError::UnsupportedEndpoint { .. })));
    }
}
