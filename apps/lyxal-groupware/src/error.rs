// SPDX-License-Identifier: AGPL-3.0-only

//! Erreurs de l'hôte. Chaque code `GROUPWARE_*` a une définition identique dans
//! `error/groupware.surql` (vérifié par test) ; une erreur du runtime garde son propre code
//! `RUNTIME_*`. Une réponse HTTP suit le contrat `LyxalResult` (`{ ok, data, error }`) : le
//! client reçoit le message générique du code, le détail interne est journalisé.

use axum::http::StatusCode;
use axum::response::{IntoResponse, Response};
use axum::Json;
use lyxal_error::{LyxalError, LyxalResult};
use lyxal_host::HostError;
use serde_json::json;
use thiserror::Error;

/// Erreur de l'hôte `lyxal-groupware`.
#[derive(Debug, Error)]
pub enum GroupwareError {
    /// Configuration absente, illisible ou incohérente.
    #[error("configuration invalide : {message}")]
    Configuration { message: String },

    /// Base injoignable ou sonde en échec.
    #[error("base de données indisponible : {message}")]
    Database { message: String },

    /// Erreur du runtime (code `RUNTIME_*`).
    #[error("erreur du runtime : {0}")]
    Runtime(#[from] lyxal_runtime::RuntimeError),

    /// Installation d'un module hébergé impossible.
    #[error("installation du module `{module}` impossible : {message}")]
    ModuleInstall { module: String, message: String },

    /// Adresse d'écoute indisponible (port de courrier ou port HTTP).
    #[error("adresse d'écoute `{address}` indisponible : {message}")]
    Bind { address: String, message: String },

    /// Attente du signal d'arrêt impossible.
    #[error("signal d'arrêt indisponible : {message}")]
    ShutdownSignal { message: String },

    /// Journal non initialisé.
    #[error("journalisation non initialisée : {message}")]
    Telemetry { message: String },
}

/// Erreur du code commun des hôtes (`lyxal_host`), traduite dans le code `GROUPWARE_*`
/// correspondant ; une erreur du runtime garde son code `RUNTIME_*`.
impl From<HostError> for GroupwareError {
    fn from(error: HostError) -> Self {
        match error {
            HostError::Configuration { message } => Self::Configuration { message },
            HostError::Database { message } => Self::Database { message },
            HostError::ModuleInstall { module, message } => Self::ModuleInstall { module, message },
            HostError::Bind { address, message } => Self::Bind { address, message },
            HostError::ShutdownSignal { message } => Self::ShutdownSignal { message },
            HostError::Telemetry { message } => Self::Telemetry { message },
            HostError::Runtime(error) => Self::Runtime(error),
        }
    }
}

/// Description d'une erreur de l'hôte, identique à sa définition dans `error/groupware.surql`.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct GroupwareErrorInfo {
    pub code: &'static str,
    pub category: &'static str,
    pub http_status: u16,
    pub retryable: bool,
    /// Message générique (anglais), champ `message` de la définition.
    pub message: &'static str,
    /// Libellé français, champ `translations.fr.label` de la définition.
    pub label: &'static str,
}

const CONFIGURATION_INVALID: GroupwareErrorInfo = GroupwareErrorInfo {
    code: "GROUPWARE_CONFIGURATION_INVALID",
    category: "internal",
    http_status: 500,
    retryable: false,
    message: "Groupware host configuration is invalid",
    label: "Configuration de l'hôte groupware invalide",
};

const DATABASE_UNAVAILABLE: GroupwareErrorInfo = GroupwareErrorInfo {
    code: "GROUPWARE_DATABASE_UNAVAILABLE",
    category: "dependency",
    http_status: 503,
    retryable: true,
    message: "Database is unavailable",
    label: "Base de données indisponible",
};

const MODULE_INSTALL_FAILED: GroupwareErrorInfo = GroupwareErrorInfo {
    code: "GROUPWARE_MODULE_INSTALL_FAILED",
    category: "internal",
    http_status: 500,
    retryable: false,
    message: "A hosted module could not be installed",
    label: "Installation d'un module impossible",
};

const BIND_FAILED: GroupwareErrorInfo = GroupwareErrorInfo {
    code: "GROUPWARE_BIND_FAILED",
    category: "internal",
    http_status: 500,
    retryable: false,
    message: "A listening address could not be bound",
    label: "Adresse d'écoute indisponible",
};

const SHUTDOWN_SIGNAL_FAILED: GroupwareErrorInfo = GroupwareErrorInfo {
    code: "GROUPWARE_SHUTDOWN_SIGNAL_FAILED",
    category: "internal",
    http_status: 500,
    retryable: false,
    message: "Shutdown signal handler could not be installed",
    label: "Signal d'arrêt indisponible",
};

const TELEMETRY_INIT_FAILED: GroupwareErrorInfo = GroupwareErrorInfo {
    code: "GROUPWARE_TELEMETRY_INIT_FAILED",
    category: "internal",
    http_status: 500,
    retryable: false,
    message: "Logging could not be initialized",
    label: "Journalisation non initialisée",
};

/// Toutes les erreurs de l'hôte.
pub const GROUPWARE_ERROR_CATALOG: &[GroupwareErrorInfo] = &[
    CONFIGURATION_INVALID,
    DATABASE_UNAVAILABLE,
    MODULE_INSTALL_FAILED,
    BIND_FAILED,
    SHUTDOWN_SIGNAL_FAILED,
    TELEMETRY_INIT_FAILED,
];

impl GroupwareError {
    /// Description de l'erreur : celle du catalogue de l'hôte, ou celle du runtime pour une
    /// erreur du runtime (code `RUNTIME_*`).
    pub fn info(&self) -> GroupwareErrorInfo {
        match self {
            Self::Runtime(error) => {
                let info = error.info();
                GroupwareErrorInfo {
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
            Self::ShutdownSignal { .. } => SHUTDOWN_SIGNAL_FAILED,
            Self::Telemetry { .. } => TELEMETRY_INIT_FAILED,
        }
    }

    /// Code de l'erreur.
    pub fn code(&self) -> &'static str {
        self.info().code
    }

    /// Erreur au format `LyxalError`, sans détail interne : message générique du code.
    pub fn to_lyxal_error(&self) -> LyxalError {
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
            details: json!({}),
        }
    }
}

impl IntoResponse for GroupwareError {
    fn into_response(self) -> Response {
        tracing::error!(code = self.code(), error = %self, "requête en échec");
        let error = self.to_lyxal_error();
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
#[allow(clippy::expect_used, clippy::unwrap_used, clippy::panic)]
mod tests {
    use super::*;

    /// Chaque entrée du catalogue est définie à l'identique dans `error/groupware.surql`, sans
    /// code en plus ni en double.
    #[test]
    fn catalog_matches_master_data() {
        let definitions = include_str!("../error/groupware.surql");
        for info in GROUPWARE_ERROR_CATALOG {
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
            assert!(
                definitions.contains(&format!(
                    "IF !record::exists(error_definition:{}) THEN (",
                    info.code
                )),
                "{} : forme rejouable",
                info.code
            );
        }
        assert_eq!(
            definitions.matches("CREATE error_definition:").count(),
            GROUPWARE_ERROR_CATALOG.len()
        );
    }

    #[test]
    fn host_errors_are_translated_to_groupware_codes() {
        let error: GroupwareError = HostError::Bind {
            address: "127.0.0.1:25".into(),
            message: "occupé".into(),
        }
        .into();
        assert_eq!(error.code(), "GROUPWARE_BIND_FAILED");
        let error: GroupwareError = HostError::Configuration {
            message: "x".into(),
        }
        .into();
        assert_eq!(error.code(), "GROUPWARE_CONFIGURATION_INVALID");
        assert_eq!(error.to_lyxal_error().details, json!({}));
    }
}
