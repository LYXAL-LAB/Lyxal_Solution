//! Erreurs de l'hôte. Chaque code `SERVER_*` a une définition identique dans
//! `error/server.surql` (vérifié par test) ; une erreur du runtime garde son propre code
//! `RUNTIME_*`. Une réponse HTTP suit le contrat `LyxalResult` (`{ ok, data, error }`) : le
//! client reçoit le message générique du code et l'identifiant de requête, le détail interne
//! est journalisé.

use crate::http::request_id;
use axum::{
    http::StatusCode,
    response::{IntoResponse, Response},
    Json,
};
use lyxal_error::{LyxalError, LyxalResult};
use serde_json::json;
use thiserror::Error;

#[derive(Debug, Error)]
pub enum ServerError {
    #[error("configuration invalide : {message}")]
    Configuration { message: String },

    #[error("base de données indisponible : {message}")]
    Database { message: String },

    #[error("erreur du runtime : {0}")]
    Runtime(#[from] lyxal_runtime::RuntimeError),

    #[error("installation du module `{module}` impossible : {message}")]
    ModuleInstall { module: String, message: String },

    #[error("adresse d'écoute `{address}` indisponible : {message}")]
    Bind { address: String, message: String },

    #[error("arrêt du serveur HTTP sur erreur : {message}")]
    HttpServe { message: String },

    #[error("signal d'arrêt indisponible : {message}")]
    ShutdownSignal { message: String },

    #[error("journalisation non initialisée : {message}")]
    Telemetry { message: String },

    #[error("authentification désactivée : clé applicative ou auth.public_url absente")]
    AuthDisabled,
}

/// Description d'une erreur de l'hôte, identique à sa définition dans `error/server.surql`.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct ServerErrorInfo {
    pub code: &'static str,
    pub category: &'static str,
    pub http_status: u16,
    pub retryable: bool,
    /// Message générique (anglais), champ `message` de la définition.
    pub message: &'static str,
    /// Libellé français, champ `translations.fr.label` de la définition.
    pub label: &'static str,
}

const CONFIGURATION_INVALID: ServerErrorInfo = ServerErrorInfo {
    code: "SERVER_CONFIGURATION_INVALID",
    category: "internal",
    http_status: 500,
    retryable: false,
    message: "Server configuration is invalid",
    label: "Configuration du serveur invalide",
};

const DATABASE_UNAVAILABLE: ServerErrorInfo = ServerErrorInfo {
    code: "SERVER_DATABASE_UNAVAILABLE",
    category: "dependency",
    http_status: 503,
    retryable: true,
    message: "Database is unavailable",
    label: "Base de données indisponible",
};

const MODULE_INSTALL_FAILED: ServerErrorInfo = ServerErrorInfo {
    code: "SERVER_MODULE_INSTALL_FAILED",
    category: "internal",
    http_status: 500,
    retryable: false,
    message: "A hosted module could not be installed",
    label: "Installation d'un module impossible",
};

const BIND_FAILED: ServerErrorInfo = ServerErrorInfo {
    code: "SERVER_BIND_FAILED",
    category: "internal",
    http_status: 500,
    retryable: false,
    message: "Server address could not be bound",
    label: "Adresse d'écoute indisponible",
};

const HTTP_SERVE_FAILED: ServerErrorInfo = ServerErrorInfo {
    code: "SERVER_HTTP_SERVE_FAILED",
    category: "internal",
    http_status: 500,
    retryable: false,
    message: "HTTP server stopped on an error",
    label: "Arrêt du serveur HTTP sur erreur",
};

const SHUTDOWN_SIGNAL_FAILED: ServerErrorInfo = ServerErrorInfo {
    code: "SERVER_SHUTDOWN_SIGNAL_FAILED",
    category: "internal",
    http_status: 500,
    retryable: false,
    message: "Shutdown signal handler could not be installed",
    label: "Signal d'arrêt indisponible",
};

const TELEMETRY_INIT_FAILED: ServerErrorInfo = ServerErrorInfo {
    code: "SERVER_TELEMETRY_INIT_FAILED",
    category: "internal",
    http_status: 500,
    retryable: false,
    message: "Logging could not be initialized",
    label: "Journalisation non initialisée",
};

const AUTH_DISABLED: ServerErrorInfo = ServerErrorInfo {
    code: "SERVER_AUTH_DISABLED",
    category: "dependency",
    http_status: 503,
    retryable: false,
    message: "Authentication is disabled on this server",
    label: "Authentification désactivée",
};

/// Toutes les erreurs de l'hôte.
pub const SERVER_ERROR_CATALOG: &[ServerErrorInfo] = &[
    CONFIGURATION_INVALID,
    DATABASE_UNAVAILABLE,
    MODULE_INSTALL_FAILED,
    BIND_FAILED,
    HTTP_SERVE_FAILED,
    SHUTDOWN_SIGNAL_FAILED,
    TELEMETRY_INIT_FAILED,
    AUTH_DISABLED,
];

impl ServerError {
    /// Description de l'erreur : celle du catalogue de l'hôte, ou celle du runtime pour une
    /// erreur du runtime (code `RUNTIME_*`).
    pub fn info(&self) -> ServerErrorInfo {
        match self {
            Self::Runtime(error) => {
                let info = error.info();
                ServerErrorInfo {
                    code: info.code,
                    category: info.category,
                    http_status: info.http_status,
                    retryable: info.retryable,
                    message: info.message,
                    label: info.label,
                }
            }
            Self::Configuration { .. } => CONFIGURATION_INVALID,
            Self::Database { .. } => DATABASE_UNAVAILABLE,
            Self::ModuleInstall { .. } => MODULE_INSTALL_FAILED,
            Self::Bind { .. } => BIND_FAILED,
            Self::HttpServe { .. } => HTTP_SERVE_FAILED,
            Self::ShutdownSignal { .. } => SHUTDOWN_SIGNAL_FAILED,
            Self::Telemetry { .. } => TELEMETRY_INIT_FAILED,
            Self::AuthDisabled => AUTH_DISABLED,
        }
    }

    pub fn code(&self) -> &'static str {
        self.info().code
    }

    /// Erreur au format `LyxalError`, sans détail interne : message générique du code.
    pub fn to_lyxal_error(&self, trace_id: &str) -> LyxalError {
        let info = self.info();
        LyxalError {
            code: info.code.to_string(),
            message: info.message.to_string(),
            label: info.label.to_string(),
            description: None,
            resolution: None,
            category: info.category.to_string(),
            severity: "error".to_string(),
            http_status: Some(info.http_status),
            retryable: info.retryable,
            documentation: json!({}),
            metadata: json!({}),
            details: json!({ "trace_id": trace_id }),
        }
    }
}

impl IntoResponse for ServerError {
    fn into_response(self) -> Response {
        let trace_id = request_id::current();
        tracing::error!(trace_id = %trace_id, code = self.code(), error = %self, "requête en échec");
        let error = self.to_lyxal_error(&trace_id);
        let status = error
            .http_status
            .and_then(|code| StatusCode::from_u16(code).ok())
            .unwrap_or(StatusCode::INTERNAL_SERVER_ERROR);
        let body: LyxalResult<String> = LyxalResult {
            ok: false,
            data: None,
            error: Some(error),
        };
        (status, Json(body)).into_response()
    }
}

#[cfg(test)]
#[allow(clippy::expect_used)]
mod tests {
    use super::*;

    /// Chaque entrée du catalogue est définie à l'identique dans `error/server.surql`, sans code
    /// en plus ni en double.
    #[test]
    fn catalog_matches_master_data() {
        let definitions = include_str!("../error/server.surql");
        for info in SERVER_ERROR_CATALOG {
            let start = definitions
                .find(&format!("CREATE error_definition:{} CONTENT", info.code))
                .unwrap_or_else(|| panic!("{} absent des définitions", info.code));
            let block = &definitions[start..];
            let block = &block[..block.find(") END;").unwrap_or(block.len())];
            for expected in [
                format!("code: \"{}\"", info.code),
                format!("category: \"{}\"", info.category),
                format!("http_status: {}", info.http_status),
                format!("retryable: {}", info.retryable),
                format!("message: \"{}\"", info.message),
                format!("label: \"{}\"", info.label),
            ] {
                assert!(block.contains(&expected), "{} : {expected}", info.code);
            }
        }
        assert_eq!(
            definitions.matches("CREATE error_definition:").count(),
            SERVER_ERROR_CATALOG.len()
        );
    }

    #[tokio::test]
    async fn http_response_follows_lyxal_result() {
        let response = ServerError::Database {
            message: "ws://10.0.0.5:8000 refused".into(),
        }
        .into_response();
        assert_eq!(response.status(), StatusCode::SERVICE_UNAVAILABLE);
        let bytes = axum::body::to_bytes(response.into_body(), 64 * 1024)
            .await
            .expect("corps");
        let body: serde_json::Value = serde_json::from_slice(&bytes).expect("JSON");
        assert_eq!(body["ok"], false);
        assert!(body["data"].is_null());
        assert_eq!(body["error"]["code"], "SERVER_DATABASE_UNAVAILABLE");
        assert_eq!(body["error"]["details"]["trace_id"], "none");
        assert!(!body.to_string().contains("10.0.0.5"));
    }

    #[test]
    fn response_hides_internal_detail() {
        let error = ServerError::Database {
            message: "ws://10.0.0.5:8000 refused".into(),
        };
        let public = error.to_lyxal_error("req-1");
        assert_eq!(public.code, "SERVER_DATABASE_UNAVAILABLE");
        assert_eq!(public.http_status, Some(503));
        assert!(public.retryable);
        assert!(!public.message.contains("10.0.0.5"));
        assert_eq!(public.details["trace_id"], "req-1");
    }
}
