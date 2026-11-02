use std::time::Duration;

use lyxal_crypto::SecretString;
use surrealdb::engine::any::{self, Any};
use surrealdb::opt::auth::Root;
use surrealdb::Surreal;

use crate::error::LyxalSurrealError;

/// Identifiants Root d'une instance SurrealDB distante.
///
/// Le mot de passe est un `SecretString` : masqué dans `Debug`, effacé de la mémoire à la
/// libération, lu une seule fois au `signin`.
#[derive(Debug)]
pub struct RootCredentials {
    pub username: String,
    pub password: SecretString,
}

impl RootCredentials {
    pub fn new(username: impl Into<String>, password: SecretString) -> Self {
        Self {
            username: username.into(),
            password,
        }
    }
}

/// Paramètres de connexion de `create_surreal_client`.
#[derive(Debug)]
pub struct SurrealConnectOptions {
    /// `ws://`, `wss://`, `mem://` ou `memory`.
    pub endpoint: String,
    /// Obligatoires en `ws://` / `wss://`, ignorés en mémoire.
    pub credentials: Option<RootCredentials>,
    pub namespace: String,
    pub database: String,
    /// Délai maximal pour la connexion, l'authentification et la sélection namespace/base.
    pub connect_timeout: Duration,
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

/// Connecte un client `Surreal<Any>` et sélectionne le namespace et la base (§11.2).
///
/// * `ws://` / `wss://` : identifiants Root non vides obligatoires (`MissingCredentials`).
/// * `mem://` / `memory` : aucune authentification, même si des identifiants sont fournis.
/// * Au-delà de `connect_timeout` : `ConnectTimeout`.
pub async fn create_surreal_client(
    options: SurrealConnectOptions,
) -> Result<Surreal<Any>, LyxalSurrealError> {
    let endpoint = normalize_endpoint(&options.endpoint);
    validate_endpoint_scheme(&endpoint)?;

    let embedded = endpoint == "memory" || endpoint.starts_with("mem://");
    let credentials = if embedded {
        None
    } else {
        match options.credentials {
            Some(creds)
                if !creds.username.trim().is_empty()
                    && !creds.password.expose_secret().trim().is_empty() =>
            {
                Some(creds)
            }
            _ => return Err(LyxalSurrealError::MissingCredentials { endpoint }),
        }
    };

    let connect = async {
        let db = any::connect(endpoint.clone()).await?;
        if let Some(creds) = credentials {
            db.signin(Root {
                username: creds.username,
                password: creds.password.expose_secret().to_owned(),
            })
            .await?;
        }
        db.use_ns(&options.namespace)
            .use_db(&options.database)
            .await?;
        Ok::<_, LyxalSurrealError>(db)
    };

    tokio::time::timeout(options.connect_timeout, connect)
        .await
        .map_err(|_| LyxalSurrealError::ConnectTimeout {
            endpoint: endpoint.clone(),
        })?
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_normalize_endpoint() {
        assert_eq!(
            normalize_endpoint("ws://127.0.0.1:8000/"),
            "ws://127.0.0.1:8000"
        );
        assert_eq!(
            normalize_endpoint("ws://127.0.0.1:8000/rpc"),
            "ws://127.0.0.1:8000"
        );
        assert_eq!(
            normalize_endpoint("ws://127.0.0.1:8000/rpc/"),
            "ws://127.0.0.1:8000"
        );
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
        assert!(matches!(
            res,
            Err(LyxalSurrealError::UnsupportedEndpoint { .. })
        ));

        let res = validate_endpoint_scheme("tcp://127.0.0.1:8000");
        assert!(matches!(
            res,
            Err(LyxalSurrealError::UnsupportedEndpoint { .. })
        ));

        let res = validate_endpoint_scheme("invalid");
        assert!(matches!(
            res,
            Err(LyxalSurrealError::UnsupportedEndpoint { .. })
        ));
    }

    fn secret(text: &str) -> SecretString {
        SecretString::new(text.to_owned()).expect("secret")
    }

    fn options(endpoint: &str, credentials: Option<RootCredentials>) -> SurrealConnectOptions {
        SurrealConnectOptions {
            endpoint: endpoint.to_owned(),
            credentials,
            namespace: "test_ns".to_owned(),
            database: "test_db".to_owned(),
            connect_timeout: Duration::from_secs(5),
        }
    }

    #[test]
    fn test_root_credentials_debug_hides_password() {
        let creds = RootCredentials::new("root", secret("tres-secret-42"));
        let debug = format!("{creds:?}");
        assert!(!debug.contains("tres-secret-42"), "{debug}");
        assert!(debug.contains("REDACTED"), "{debug}");
    }

    #[tokio::test]
    async fn test_create_surreal_client_mem_selects_namespace_and_database() {
        let db = create_surreal_client(options("mem://", None))
            .await
            .expect("mem:// sans identifiants");
        let mut res = db
            .query("RETURN [session::ns(), session::db()];")
            .await
            .expect("requête");
        let selected: Vec<String> = res.take(0).expect("lecture");
        assert_eq!(selected, vec!["test_ns".to_owned(), "test_db".to_owned()]);
    }

    #[tokio::test]
    async fn test_create_surreal_client_mem_ignores_credentials() {
        // Aucun signin en mémoire : des identifiants fournis ne provoquent pas d'erreur.
        let creds = RootCredentials::new("root", secret("ignored"));
        assert!(create_surreal_client(options("memory", Some(creds)))
            .await
            .is_ok());
    }

    #[tokio::test]
    async fn test_create_surreal_client_rejects_missing_credentials_on_ws() {
        let res = create_surreal_client(options("ws://127.0.0.1:9999", None)).await;
        assert!(matches!(
            res,
            Err(LyxalSurrealError::MissingCredentials { .. })
        ));

        let blank = RootCredentials::new("root", secret("  "));
        let res = create_surreal_client(options("ws://127.0.0.1:9999", Some(blank))).await;
        assert!(matches!(
            res,
            Err(LyxalSurrealError::MissingCredentials { .. })
        ));
    }

    #[tokio::test]
    async fn test_create_surreal_client_rejects_unsupported_endpoint() {
        let res = create_surreal_client(options("http://127.0.0.1:8000", None)).await;
        assert!(matches!(
            res,
            Err(LyxalSurrealError::UnsupportedEndpoint { .. })
        ));
    }

    #[tokio::test]
    async fn test_create_surreal_client_times_out() {
        // Port qui accepte la connexion TCP sans jamais répondre au protocole WebSocket.
        let listener = std::net::TcpListener::bind("127.0.0.1:0").expect("port");
        let port = listener.local_addr().expect("adresse").port();
        let creds = RootCredentials::new("root", secret("root"));
        let mut opts = options(&format!("ws://127.0.0.1:{port}"), Some(creds));
        opts.connect_timeout = Duration::from_millis(300);
        let res = create_surreal_client(opts).await;
        assert!(
            matches!(res, Err(LyxalSurrealError::ConnectTimeout { .. })),
            "{res:?}"
        );
        drop(listener);
    }
}
