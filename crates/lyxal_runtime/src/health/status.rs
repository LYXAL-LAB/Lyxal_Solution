use serde::{Deserialize, Serialize};

/// Représente l'état de santé individuel d'un module Lyxal OS.
///
/// La santé d'un module est découplée de son cycle de vie (`Running`, `Stopped`, etc.).
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Hash, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum HealthStatus {
    /// Le module fonctionne de manière nominale.
    Healthy,
    /// Le module fonctionne avec une dégradation partielle n'empêchant pas son usage de base.
    Degraded,
    /// Le module est en panne ou indisponible.
    Unhealthy,
    /// Le module est en cours d'exécution (`Running`) mais ne dispose pas d'un checker enregistré.
    Unknown,
    /// Le module n'est pas en cours d'exécution (ex: `Stopped`, `Installed`) et n'est pas éligible au health check runtime.
    NotApplicable,
}

impl HealthStatus {
    /// Retourne la représentation textuelle canonique du statut de santé.
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Healthy => "healthy",
            Self::Degraded => "degraded",
            Self::Unhealthy => "unhealthy",
            Self::Unknown => "unknown",
            Self::NotApplicable => "not_applicable",
        }
    }

    /// Indique si ce statut de santé est applicable dans l'évaluation de santé globale.
    pub fn is_applicable(&self) -> bool {
        !matches!(self, Self::NotApplicable)
    }
}

impl std::fmt::Display for HealthStatus {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

/// Représente la synthèse de santé globale d'un nœud Lyxal Runtime.
///
/// L'agrégation ne prend en compte que les statuts de santé **applicables**
/// (les modules non `Running` classés `NotApplicable` ne dégradent pas l'état global).
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Hash, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum GlobalHealthStatus {
    /// Tous les modules applicables sont `Healthy` (ou aucun module applicable n'est présent).
    Healthy,
    /// Au moins un module applicable est `Degraded` ou `Unknown`, et aucun n'est `Unhealthy`.
    Degraded,
    /// Au moins un module applicable est `Unhealthy`.
    Unhealthy,
}

impl GlobalHealthStatus {
    /// Retourne la représentation textuelle canonique.
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Healthy => "healthy",
            Self::Degraded => "degraded",
            Self::Unhealthy => "unhealthy",
        }
    }

    /// Calcule le statut global à partir d'une collection de statuts de modules.
    ///
    /// Règles d'agrégation formelles :
    /// - Filtre tous les statuts `NotApplicable`.
    /// - Si la liste filtrée est vide ou si tous sont `Healthy` -> `Healthy`.
    /// - Si au moins un statut est `Unhealthy` -> `Unhealthy`.
    /// - Si au moins un statut est `Degraded` ou `Unknown` -> `Degraded`.
    pub fn from_statuses<'a, I>(statuses: I) -> Self
    where
        I: IntoIterator<Item = &'a HealthStatus>,
    {
        let mut has_unhealthy = false;
        let mut has_degraded_or_unknown = false;

        for status in statuses {
            match status {
                HealthStatus::Unhealthy => has_unhealthy = true,
                HealthStatus::Degraded | HealthStatus::Unknown => has_degraded_or_unknown = true,
                HealthStatus::Healthy | HealthStatus::NotApplicable => {}
            }
        }

        if has_unhealthy {
            Self::Unhealthy
        } else if has_degraded_or_unknown {
            Self::Degraded
        } else {
            Self::Healthy
        }
    }
}

impl std::fmt::Display for GlobalHealthStatus {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}
