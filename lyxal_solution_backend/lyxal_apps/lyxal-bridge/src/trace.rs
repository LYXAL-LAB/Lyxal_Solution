//! Traçabilité complète du Lyxal Bridge.
//!
//! Ce module fournit un système de trace **end-to-end** pour chaque appel
//! `bridge::call()`. Chaque exécution génère un `BridgeTrace` qui capture :
//!
//! - L'identifiant unique de la trace (trace_id)
//! - Le provider et l'opération appelés
//! - Chaque phase d'exécution avec son timing
//! - La requête HTTP construite (URL, méthode, headers sans secrets)
//! - La réponse reçue (status, taille du body)
//! - Les erreurs rencontrées et les retries effectués
//! - Les hooks appliqués
//!
//! ## Utilisation depuis SurrealQL
//!
//! ```sql
//! -- L'appel retourne le résultat + la trace est loguée automatiquement
//! LET $result = bridge::call("airtable", "list_records", { baseId: "appXYZ" });
//!
//! -- Pour récupérer les traces (si persistance activée)
//! SELECT * FROM bridge_execution_logs ORDER BY timestamp.started_at DESC LIMIT 10;
//! ```

use std::time::Instant;

use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};

// =========================================================================
// BridgeTrace — Trace complète d'un appel
// =========================================================================

/// Trace complète d'un appel `bridge::call()`.
///
/// Capturée tout au long du pipeline d'exécution et optionnellement
/// persistée dans `bridge_execution_logs` après l'exécution.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BridgeTrace {
    /// Identifiant unique de la trace (UUID v7 pour tri chronologique)
    pub trace_id: String,

    /// Contexte de l'appel
    pub context: TraceContext,

    /// Phases d'exécution chronologiques
    pub phases: Vec<TracePhase>,

    /// Détails de la requête HTTP construite
    pub request: Option<TraceRequest>,

    /// Détails de la réponse HTTP reçue
    pub response: Option<TraceResponse>,

    /// Erreurs rencontrées
    pub errors: Vec<TraceError>,

    /// Timestamps globaux
    pub timestamp: TraceTimestamp,

    /// Métriques de performance
    pub metrics: TraceMetrics,

    /// Résultat final
    pub outcome: TraceOutcome,
}

/// Contexte de l'appel Bridge.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TraceContext {
    /// Nom du provider (ex: "airtable")
    pub provider: String,
    /// Nom de l'opération (ex: "list_records")
    pub operation: String,
    /// Source de l'appel (ex: "surrealql", "api", "webhook")
    #[serde(default = "default_source")]
    pub source: String,
    /// ID de session SurrealDB (si disponible)
    pub session_id: Option<String>,
    /// Namespace + database
    pub namespace: Option<String>,
    pub database: Option<String>,
}

fn default_source() -> String {
    "surrealql".to_string()
}

/// Une phase d'exécution dans le pipeline Bridge.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TracePhase {
    /// Nom de la phase
    pub name: String,
    /// Durée en microsecondes
    pub duration_us: u64,
    /// Statut : "ok", "error", "skipped"
    pub status: String,
    /// Détails additionnels
    #[serde(default)]
    pub details: Option<String>,
}

/// Détails de la requête HTTP (sans secrets).
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TraceRequest {
    /// Méthode HTTP
    pub method: String,
    /// URL complète (masquée si nécessaire)
    pub url: String,
    /// Headers (avec valeurs sensibles masquées)
    pub headers: Vec<(String, String)>,
    /// Taille du body en octets
    pub body_size: Option<usize>,
    /// Content-Type du body
    pub content_type: Option<String>,
}

/// Détails de la réponse HTTP.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TraceResponse {
    /// Code de status HTTP
    pub status: u16,
    /// Headers de la réponse
    pub headers: Vec<(String, String)>,
    /// Taille du body en octets
    pub body_size: usize,
    /// Content-Type de la réponse
    pub content_type: Option<String>,
    /// Durée du round-trip HTTP en ms
    pub round_trip_ms: u64,
}

/// Erreur capturée pendant l'exécution.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TraceError {
    /// Phase où l'erreur s'est produite
    pub phase: String,
    /// Type d'erreur
    pub error_type: String,
    /// Message d'erreur
    pub message: String,
    /// Numéro de tentative (pour les retries)
    pub attempt: Option<u32>,
    /// Timestamp de l'erreur
    pub at: DateTime<Utc>,
}

/// Timestamps de la trace.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TraceTimestamp {
    /// Début de l'exécution
    pub started_at: DateTime<Utc>,
    /// Fin de l'exécution
    pub completed_at: Option<DateTime<Utc>>,
}

/// Métriques de performance.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TraceMetrics {
    /// Durée totale en millisecondes
    pub total_duration_ms: u64,
    /// Nombre de tentatives HTTP effectuées
    pub attempts: u32,
    /// Durée de la résolution depuis la DB (cache hit = 0)
    pub resolve_duration_us: u64,
    /// Durée de la construction de la requête
    pub request_build_duration_us: u64,
    /// Durée du round-trip HTTP
    pub http_round_trip_ms: u64,
    /// Est-ce que les métadonnées venaient du cache ?
    pub cache_hit: bool,
}

/// Résultat final de l'appel.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum TraceOutcome {
    /// Succès — code HTTP 2xx
    Success { status: u16 },
    /// Erreur HTTP — code 4xx ou 5xx
    HttpError { status: u16, message: String },
    /// Erreur bridge (résolution, auth, timeout, circuit breaker...)
    BridgeError { error_type: String, message: String },
}

// =========================================================================
// TraceBuilder — Construction incrémentale
// =========================================================================

/// Constructeur incrémental pour BridgeTrace.
///
/// Utilisé pendant l'exécution pour capturer chaque phase au fur et à mesure.
pub struct TraceBuilder {
    trace_id: String,
    context: TraceContext,
    phases: Vec<TracePhase>,
    request: Option<TraceRequest>,
    response: Option<TraceResponse>,
    errors: Vec<TraceError>,
    started_at: Instant,
    started_at_utc: DateTime<Utc>,
    phase_start: Option<(String, Instant)>,
    metrics: TraceMetrics,
}

impl TraceBuilder {
    /// Crée un nouveau TraceBuilder.
    pub fn new(provider: &str, operation: &str) -> Self {
        let trace_id = generate_trace_id();

        tracing::info_span!("bridge_call",
            trace_id = %trace_id,
            provider = %provider,
            operation = %operation,
        );

        tracing::info!(
            trace_id = %trace_id,
            provider = %provider,
            operation = %operation,
            "🚀 Bridge call initiated"
        );

        Self {
            trace_id,
            context: TraceContext {
                provider: provider.to_string(),
                operation: operation.to_string(),
                source: "surrealql".to_string(),
                session_id: None,
                namespace: None,
                database: None,
            },
            phases: Vec::new(),
            request: None,
            response: None,
            errors: Vec::new(),
            started_at: Instant::now(),
            started_at_utc: Utc::now(),
            phase_start: None,
            metrics: TraceMetrics {
                total_duration_ms: 0,
                attempts: 0,
                resolve_duration_us: 0,
                request_build_duration_us: 0,
                http_round_trip_ms: 0,
                cache_hit: false,
            },
        }
    }

    /// Retourne le trace_id.
    pub fn trace_id(&self) -> &str {
        &self.trace_id
    }

    // ── Phases ──

    /// Démarre une nouvelle phase.
    pub fn start_phase(&mut self, name: &str) {
        tracing::debug!(
            trace_id = %self.trace_id,
            phase = %name,
            "▶ Phase started"
        );
        self.phase_start = Some((name.to_string(), Instant::now()));
    }

    /// Termine la phase courante avec succès.
    pub fn end_phase(&mut self, details: Option<&str>) {
        if let Some((name, start)) = self.phase_start.take() {
            let duration_us = start.elapsed().as_micros() as u64;
            tracing::debug!(
                trace_id = %self.trace_id,
                phase = %name,
                duration_us = duration_us,
                "✓ Phase completed"
            );
            self.phases.push(TracePhase {
                name,
                duration_us,
                status: "ok".to_string(),
                details: details.map(|s| s.to_string()),
            });
        }
    }

    /// Termine la phase courante avec une erreur.
    pub fn fail_phase(&mut self, error: &str) {
        if let Some((name, start)) = self.phase_start.take() {
            let duration_us = start.elapsed().as_micros() as u64;
            tracing::warn!(
                trace_id = %self.trace_id,
                phase = %name,
                duration_us = duration_us,
                error = %error,
                "✗ Phase failed"
            );
            self.phases.push(TracePhase {
                name,
                duration_us,
                status: "error".to_string(),
                details: Some(error.to_string()),
            });
        }
    }

    // ── Métriques ──

    /// Enregistre un cache hit/miss.
    pub fn set_cache_hit(&mut self, hit: bool) {
        self.metrics.cache_hit = hit;
        if hit {
            tracing::debug!(trace_id = %self.trace_id, "📦 Cache HIT");
        } else {
            tracing::debug!(trace_id = %self.trace_id, "📦 Cache MISS");
        }
    }

    /// Enregistre la durée de résolution.
    pub fn set_resolve_duration(&mut self, us: u64) {
        self.metrics.resolve_duration_us = us;
    }

    /// Enregistre la durée de construction de la requête.
    pub fn set_request_build_duration(&mut self, us: u64) {
        self.metrics.request_build_duration_us = us;
    }

    /// Incrémente le compteur de tentatives.
    pub fn increment_attempts(&mut self) {
        self.metrics.attempts += 1;
    }

    // ── Requête ──

    /// Enregistre les détails de la requête HTTP construite.
    pub fn set_request(
        &mut self,
        method: &str,
        url: &str,
        headers: &std::collections::HashMap<String, String>,
        body: &Option<serde_json::Value>,
    ) {
        let sanitized_headers: Vec<(String, String)> = headers
            .iter()
            .map(|(k, v)| (k.clone(), sanitize_header_value(k, v)))
            .collect();

        let body_size = body
            .as_ref()
            .map(|b| serde_json::to_string(b).unwrap_or_default().len());

        tracing::info!(
            trace_id = %self.trace_id,
            method = %method,
            url = %url,
            headers_count = sanitized_headers.len(),
            body_size = ?body_size,
            "📤 HTTP Request built"
        );

        self.request = Some(TraceRequest {
            method: method.to_string(),
            url: url.to_string(),
            headers: sanitized_headers,
            body_size,
            content_type: headers.get("Content-Type").cloned(),
        });
    }

    // ── Réponse ──

    /// Enregistre les détails de la réponse HTTP.
    pub fn set_response(
        &mut self,
        status: u16,
        headers: &std::collections::HashMap<String, String>,
        body_size: usize,
        round_trip_ms: u64,
    ) {
        self.metrics.http_round_trip_ms = round_trip_ms;

        let resp_headers: Vec<(String, String)> = headers
            .iter()
            .map(|(k, v)| (k.clone(), v.clone()))
            .collect();

        let content_type = headers.get("content-type").cloned();

        if status < 400 {
            tracing::info!(
                trace_id = %self.trace_id,
                status = status,
                body_size = body_size,
                round_trip_ms = round_trip_ms,
                "📥 HTTP Response received"
            );
        } else {
            tracing::warn!(
                trace_id = %self.trace_id,
                status = status,
                body_size = body_size,
                round_trip_ms = round_trip_ms,
                "⚠ HTTP Error response"
            );
        }

        self.response = Some(TraceResponse {
            status,
            headers: resp_headers,
            body_size,
            content_type,
            round_trip_ms,
        });
    }

    // ── Erreurs ──

    /// Enregistre une erreur.
    pub fn record_error(&mut self, phase: &str, error_type: &str, message: &str, attempt: Option<u32>) {
        tracing::error!(
            trace_id = %self.trace_id,
            phase = %phase,
            error_type = %error_type,
            attempt = ?attempt,
            "❌ {}", message
        );

        self.errors.push(TraceError {
            phase: phase.to_string(),
            error_type: error_type.to_string(),
            message: message.to_string(),
            attempt,
            at: Utc::now(),
        });
    }

    // ── Finalisation ──

    /// Finalise la trace avec un succès.
    pub fn finish_success(mut self, status: u16) -> BridgeTrace {
        self.metrics.total_duration_ms = self.started_at.elapsed().as_millis() as u64;

        tracing::info!(
            trace_id = %self.trace_id,
            provider = %self.context.provider,
            operation = %self.context.operation,
            status = status,
            total_ms = self.metrics.total_duration_ms,
            attempts = self.metrics.attempts,
            cache_hit = self.metrics.cache_hit,
            "✅ Bridge call completed successfully"
        );

        self.build(TraceOutcome::Success { status })
    }

    /// Finalise la trace avec une erreur HTTP.
    pub fn finish_http_error(mut self, status: u16, message: &str) -> BridgeTrace {
        self.metrics.total_duration_ms = self.started_at.elapsed().as_millis() as u64;

        tracing::error!(
            trace_id = %self.trace_id,
            provider = %self.context.provider,
            operation = %self.context.operation,
            status = status,
            total_ms = self.metrics.total_duration_ms,
            "❌ Bridge call failed with HTTP {}: {}", status, message
        );

        self.build(TraceOutcome::HttpError {
            status,
            message: message.to_string(),
        })
    }

    /// Finalise la trace avec une erreur Bridge interne.
    pub fn finish_bridge_error(mut self, error: &crate::error::BridgeError) -> BridgeTrace {
        self.metrics.total_duration_ms = self.started_at.elapsed().as_millis() as u64;

        let error_type = error_type_name(error);

        tracing::error!(
            trace_id = %self.trace_id,
            provider = %self.context.provider,
            operation = %self.context.operation,
            error_type = %error_type,
            total_ms = self.metrics.total_duration_ms,
            "❌ Bridge call failed: {}", error
        );

        self.build(TraceOutcome::BridgeError {
            error_type,
            message: error.to_string(),
        })
    }

    /// Construit la BridgeTrace finale.
    fn build(self, outcome: TraceOutcome) -> BridgeTrace {
        BridgeTrace {
            trace_id: self.trace_id,
            context: self.context,
            phases: self.phases,
            request: self.request,
            response: self.response,
            errors: self.errors,
            timestamp: TraceTimestamp {
                started_at: self.started_at_utc,
                completed_at: Some(Utc::now()),
            },
            metrics: self.metrics,
            outcome,
        }
    }
}

// =========================================================================
// Helpers
// =========================================================================

/// Génère un trace_id unique (format: brg-{timestamp_hex}-{random_hex}).
fn generate_trace_id() -> String {
    let ts = Utc::now().timestamp_millis();
    let random: u32 = rand_u32();
    format!("brg-{:x}-{:08x}", ts, random)
}

/// Simple random u32 sans dépendance externe.
fn rand_u32() -> u32 {
    use std::collections::hash_map::DefaultHasher;
    use std::hash::{Hash, Hasher};
    use std::time::SystemTime;

    let mut hasher = DefaultHasher::new();
    SystemTime::now().hash(&mut hasher);
    std::thread::current().id().hash(&mut hasher);
    hasher.finish() as u32
}

/// Masque les valeurs sensibles dans les headers.
fn sanitize_header_value(key: &str, value: &str) -> String {
    let key_lower = key.to_lowercase();
    let sensitive_keys = [
        "authorization",
        "x-api-key",
        "api-key",
        "cookie",
        "set-cookie",
        "x-token",
        "x-secret",
        "x-auth",
    ];

    if sensitive_keys.iter().any(|&sk| key_lower.contains(sk)) {
        // Montrer le type d'auth mais masquer la valeur
        if value.starts_with("Bearer ") {
            format!("Bearer {}***", &value[7..std::cmp::min(11, value.len())])
        } else if value.starts_with("Basic ") {
            "Basic ***".to_string()
        } else if value.len() > 8 {
            format!("{}***{}", &value[..4], &value[value.len() - 4..])
        } else {
            "***".to_string()
        }
    } else {
        value.to_string()
    }
}

/// Extrait le nom du type d'erreur Bridge.
fn error_type_name(error: &crate::error::BridgeError) -> String {
    use crate::error::BridgeError;
    match error {
        BridgeError::ProviderNotFound { .. } => "ProviderNotFound",
        BridgeError::OperationNotFound { .. } => "OperationNotFound",
        BridgeError::CredentialNotFound { .. } => "CredentialNotFound",
        BridgeError::MissingParameter { .. } => "MissingParameter",
        BridgeError::UnresolvedPlaceholder { .. } => "UnresolvedPlaceholder",
        BridgeError::InvalidBaseUrl { .. } => "InvalidBaseUrl",
        BridgeError::HttpRequestFailed { .. } => "HttpRequestFailed",
        BridgeError::HttpResponseError { .. } => "HttpResponseError",
        BridgeError::Timeout { .. } => "Timeout",
        BridgeError::RateLimitExceeded { .. } => "RateLimitExceeded",
        BridgeError::RetriesExhausted { .. } => "RetriesExhausted",
        BridgeError::CircuitBreakerOpen { .. } => "CircuitBreakerOpen",
        BridgeError::MappedError { .. } => "MappedError",
        BridgeError::StoppedByRule { .. } => "StoppedByRule",
        BridgeError::HookFailed { .. } => "HookFailed",
        BridgeError::Internal(_) => "Internal",
        BridgeError::Database(_) => "Database",
    }
    .to_string()
}

/// Convertit un `BridgeTrace` en JSON pour la persistance.
impl BridgeTrace {
    /// Sérialise la trace en `serde_json::Value`.
    pub fn to_json(&self) -> serde_json::Value {
        serde_json::to_value(self).unwrap_or(serde_json::json!({
            "error": "Failed to serialize trace"
        }))
    }

    /// Génère un résumé compact (une ligne) pour les logs.
    pub fn summary(&self) -> String {
        let outcome = match &self.outcome {
            TraceOutcome::Success { status } => format!("✅ HTTP {}", status),
            TraceOutcome::HttpError { status, .. } => format!("❌ HTTP {}", status),
            TraceOutcome::BridgeError { error_type, .. } => format!("❌ {}", error_type),
        };

        format!(
            "[{}] {}::{} → {} ({}ms, {} attempts, cache:{})",
            self.trace_id,
            self.context.provider,
            self.context.operation,
            outcome,
            self.metrics.total_duration_ms,
            self.metrics.attempts,
            if self.metrics.cache_hit { "hit" } else { "miss" },
        )
    }
}
