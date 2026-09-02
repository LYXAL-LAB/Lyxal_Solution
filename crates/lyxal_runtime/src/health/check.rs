use crate::context::ModuleContext;
use crate::error::RuntimeError;
use crate::health::status::HealthStatus;
use crate::types::ModuleId;
use async_trait::async_trait;
use serde::{Deserialize, Serialize};

/// Résultat structuré d'un contrôle de santé individuel d'un module.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct HealthCheckResult {
    /// Identifiant du module audité.
    pub module_id: ModuleId,
    /// Statut de santé déterminé.
    pub status: HealthStatus,
    /// Horodatage de l'évaluation (format RFC3339 / ISO 8601 UTC).
    pub checked_at: String,
    /// Durée d'exécution du contrôle en millisecondes.
    pub latency_ms: Option<u64>,
    /// Message diagnostique (ne doit contenir aucun secret ou payload sensible).
    pub message: Option<String>,
}

impl HealthCheckResult {
    /// Construit un résultat de santé réussi (`Healthy`).
    pub fn healthy(module_id: ModuleId, latency_ms: u64, message: Option<String>) -> Self {
        Self {
            module_id,
            status: HealthStatus::Healthy,
            checked_at: chrono_now_string(),
            latency_ms: Some(latency_ms),
            message,
        }
    }

    /// Construit un résultat de santé dégradé (`Degraded`).
    pub fn degraded(module_id: ModuleId, latency_ms: u64, message: Option<String>) -> Self {
        Self {
            module_id,
            status: HealthStatus::Degraded,
            checked_at: chrono_now_string(),
            latency_ms: Some(latency_ms),
            message,
        }
    }

    /// Construit un résultat de santé défaillant (`Unhealthy`).
    pub fn unhealthy(
        module_id: ModuleId,
        latency_ms: Option<u64>,
        message: Option<String>,
    ) -> Self {
        Self {
            module_id,
            status: HealthStatus::Unhealthy,
            checked_at: chrono_now_string(),
            latency_ms,
            message,
        }
    }

    /// Construit un résultat inconnu (`Unknown`) pour un module Running sans checker.
    pub fn unknown(module_id: ModuleId) -> Self {
        Self {
            module_id,
            status: HealthStatus::Unknown,
            checked_at: chrono_now_string(),
            latency_ms: None,
            message: Some(
                "Module is running without an active health checker registered".to_string(),
            ),
        }
    }

    /// Construit un résultat non applicable (`NotApplicable`) pour un module non Running.
    pub fn not_applicable(module_id: ModuleId, reason: Option<String>) -> Self {
        Self {
            module_id,
            status: HealthStatus::NotApplicable,
            checked_at: chrono_now_string(),
            latency_ms: None,
            message: reason.or_else(|| Some("Module is not currently running".to_string())),
        }
    }
}

/// Contrat officiel permettant à un module d'exposer un contrôle de santé proactif.
#[async_trait]
pub trait ModuleHealthCheck: Send + Sync {
    /// Retourne l'identifiant du module supervisé.
    fn module_id(&self) -> &ModuleId;

    /// Exécute l'évaluation de santé du module.
    async fn check(&self, ctx: &ModuleContext) -> Result<HealthCheckResult, RuntimeError>;
}

/// Helper générant un horodatage ISO 8601 UTC déterministe.
pub fn chrono_now_string() -> String {
    // Si chrono n'est pas importé directement, on utilise un timestamp compatible ISO8601
    // à partir de std::time::SystemTime
    let now = std::time::SystemTime::now();
    let duration = now
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap_or_default();
    let secs = duration.as_secs();
    let millis = duration.subsec_millis();

    // Formatage UTC simple: YYYY-MM-DDTHH:MM:SS.mmmZ
    let days = secs / 86400;
    let day_secs = secs % 86400;
    let hours = day_secs / 3600;
    let minutes = (day_secs % 3600) / 60;
    let seconds = day_secs % 60;

    // Calcul de l'année/mois/jour approximatif ou standardisé
    // Pour un affichage ISO8601 propre
    let (year, month, day) = days_to_ymd(days);
    format!(
        "{:04}-{:02}-{:02}T{:02}:{:02}:{:02}.{:03}Z",
        year, month, day, hours, minutes, seconds, millis
    )
}

fn days_to_ymd(days_since_epoch: u64) -> (u64, u64, u64) {
    let mut days = days_since_epoch;
    let mut year = 1970;

    loop {
        let is_leap = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
        let days_in_year = if is_leap { 366 } else { 365 };
        if days < days_in_year {
            break;
        }
        days -= days_in_year;
        year += 1;
    }

    let is_leap = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
    let month_days = [
        31,
        if is_leap { 29 } else { 28 },
        31,
        30,
        31,
        30,
        31,
        31,
        30,
        31,
        30,
        31,
    ];

    let mut month = 1;
    for &d in &month_days {
        if days < d {
            break;
        }
        days -= d;
        month += 1;
    }

    let day = days + 1;
    (year, month, day)
}
