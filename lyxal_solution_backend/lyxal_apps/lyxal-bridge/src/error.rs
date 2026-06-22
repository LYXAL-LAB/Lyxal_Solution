//! Types d'erreurs du Lyxal Bridge.
//!
//! Toutes les erreurs du Bridge sont centralisées ici avec `thiserror`
//! pour une intégration propre avec `anyhow::Result`.

use thiserror::Error;

/// Erreurs spécifiques au Lyxal Bridge.
#[derive(Debug, Error)]
pub enum BridgeError {
    // ── Résolution ──

    /// Le provider demandé n'existe pas ou est inactif.
    #[error("Bridge: provider '{name}' introuvable ou inactif")]
    ProviderNotFound { name: String },

    /// L'opération demandée n'existe pas pour ce provider.
    #[error("Bridge: opération '{operation}' introuvable pour le provider '{provider}'")]
    OperationNotFound { provider: String, operation: String },

    /// Aucun credential trouvé pour ce provider.
    #[error("Bridge: aucun credential trouvé pour le provider '{provider}'")]
    CredentialNotFound { provider: String },

    // ── Construction de requête ──

    /// Un paramètre requis est manquant.
    #[error("Bridge: paramètre requis '{param}' manquant pour {provider}::{operation}")]
    MissingParameter {
        provider: String,
        operation: String,
        param: String,
    },

    /// Placeholder non résolu dans le path URL.
    #[error("Bridge: placeholder '{{{placeholder}}}' non résolu dans le path de {provider}::{operation}")]
    UnresolvedPlaceholder {
        provider: String,
        operation: String,
        placeholder: String,
    },

    /// URL de base invalide pour le provider.
    #[error("Bridge: URL de base invalide pour le provider '{provider}': {url}")]
    InvalidBaseUrl { provider: String, url: String },

    // ── Exécution HTTP ──

    /// La requête HTTP a échoué (erreur réseau, DNS, timeout...).
    #[error("Bridge: requête HTTP échouée vers {url}: {message}")]
    HttpRequestFailed { url: String, message: String },

    /// Réponse HTTP avec un code d'erreur (4xx, 5xx).
    #[error("Bridge: HTTP {status} depuis {provider}: {message}")]
    HttpResponseError {
        provider: String,
        status: u16,
        message: String,
    },

    /// Timeout de la requête HTTP.
    #[error("Bridge: timeout après {timeout_ms}ms pour {provider}::{operation}")]
    Timeout {
        provider: String,
        operation: String,
        timeout_ms: u64,
    },

    // ── Résilience ──

    /// Rate limit dépassé pour ce provider.
    #[error("Bridge: rate limit dépassé pour '{provider}' ({limit} requêtes / {per_ms}ms)")]
    RateLimitExceeded {
        provider: String,
        limit: u32,
        per_ms: u64,
    },

    /// Tous les retries sont épuisés.
    #[error("Bridge: {attempts} tentatives épuisées pour {provider}::{operation}")]
    RetriesExhausted {
        provider: String,
        operation: String,
        attempts: u32,
    },

    /// Circuit breaker ouvert — provider temporairement bloqué.
    #[error("Bridge: circuit breaker ouvert pour '{provider}', réessayer plus tard")]
    CircuitBreakerOpen { provider: String },

    // ── Error mapping (bridge_errors) ──

    /// Erreur mappée par une règle bridge_errors (action: "map").
    #[error("Bridge: {message}")]
    MappedError { message: String },

    /// Erreur stoppée par une règle bridge_errors (action: "stop").
    #[error("Bridge: arrêt forcé par règle d'erreur — HTTP {status}: {message}")]
    StoppedByRule { status: u16, message: String },

    // ── Hooks ──

    /// Un hook a échoué.
    #[error("Bridge: hook '{hook_name}' a échoué: {message}")]
    HookFailed { hook_name: String, message: String },

    // ── Interne ──

    /// Erreur interne (catch-all).
    #[error("Bridge: erreur interne — {0}")]
    Internal(String),

    /// Erreur de base de données.
    #[error("Bridge: erreur DB — {0}")]
    Database(String),
}

impl From<reqwest::Error> for BridgeError {
    fn from(e: reqwest::Error) -> Self {
        let url = e.url().map(|u| u.to_string()).unwrap_or_default();
        if e.is_timeout() {
            BridgeError::HttpRequestFailed {
                url,
                message: "Connection timeout".to_string(),
            }
        } else if e.is_connect() {
            BridgeError::HttpRequestFailed {
                url,
                message: format!("Connection failed: {}", e),
            }
        } else {
            BridgeError::HttpRequestFailed {
                url,
                message: e.to_string(),
            }
        }
    }
}
