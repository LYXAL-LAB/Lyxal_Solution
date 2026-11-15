//! Erreurs des services Rust de `lyxal_scheduler`. Les erreurs métier viennent des fonctions
//! SurrealQL (codes `SCHEDULER_*` de la master data), portées par `LyxalSurrealError` ; le calcul
//! des dates refuse des règles par [`SpecError`] (code `SCHEDULER_SPEC_INVALID`).

use lyxal_surreal::{LyxalCallError, LyxalSurrealError};
use std::fmt;
use thiserror::Error;

/// Code d'erreur des règles de dates refusées (master data du lot 1).
pub const SPEC_INVALID: &str = "SCHEDULER_SPEC_INVALID";

/// Raison du refus de règles de dates.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum SpecReason {
    /// Expression cron illisible (syntaxe, champ hors bornes, nombre de champs).
    CronSyntax,
    /// Fuseau horaire inconnu de la base IANA.
    Timezone,
    /// Deux échéances à moins d'une minute (U1), ou intervalle de moins d'une minute.
    MinInterval,
    /// Décalage aléatoire au-delà d'une heure ou de la moitié du plus petit écart (U5).
    Jitter,
    /// Règle de calendrier illisible (date impossible, plage horaire mal formée).
    CalendarRule,
    /// Aucune règle, ou début après la fin.
    Range,
    /// Aucune échéance trouvée en 5 ans et 10 000 essais (U4), ou aucune échéance future.
    NoFutureFire,
    /// Date hors de l'intervalle représentable.
    OutOfRange,
}

impl SpecReason {
    /// Nom stable de la raison (détail `reason` de `SCHEDULER_SPEC_INVALID`).
    pub fn as_str(self) -> &'static str {
        match self {
            Self::CronSyntax => "cron_syntax",
            Self::Timezone => "timezone",
            Self::MinInterval => "min_interval",
            Self::Jitter => "jitter",
            Self::CalendarRule => "calendar_rule",
            Self::Range => "range",
            Self::NoFutureFire => "no_future_fire",
            Self::OutOfRange => "out_of_range",
        }
    }
}

impl fmt::Display for SpecReason {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(self.as_str())
    }
}

/// Règles de dates refusées par le calcul : la règle fautive (`cron[0]`, `timezone`,
/// `calendars[1].rules[2]`…), la raison et un message lisible.
#[derive(Debug, Clone, PartialEq, Eq, Error)]
#[error("règle de dates refusée ({rule}, {reason}) : {message}")]
pub struct SpecError {
    /// Règle fautive.
    pub rule: String,
    /// Raison.
    pub reason: SpecReason,
    /// Message lisible (jamais d'argument de tâche).
    pub message: String,
}

impl SpecError {
    /// Refus de la règle `rule` pour la raison `reason`.
    pub fn new(rule: impl Into<String>, reason: SpecReason, message: impl Into<String>) -> Self {
        Self {
            rule: rule.into(),
            reason,
            message: message.into(),
        }
    }

    /// Motif d'invalidité écrit sur la planification par le moteur
    /// (`fn::scheduler_schedule_next_set`, 1000 caractères au plus).
    pub fn invalid_reason(&self) -> String {
        let text = format!("{}: {} ({})", self.reason, self.rule, self.message);
        text.chars().take(1000).collect()
    }
}

/// Erreur d'un service de `lyxal_scheduler`.
#[derive(Debug, Error)]
pub enum SchedulerError {
    /// Échec d'une fonction SurrealQL (code `SCHEDULER_*`) ou du transport.
    #[error("{0}")]
    Surreal(Box<LyxalSurrealError>),
    /// Règles de dates refusées par le calcul (`SCHEDULER_SPEC_INVALID`).
    #[error("{0}")]
    Spec(SpecError),
}

impl SchedulerError {
    /// Code stable de l'erreur.
    pub fn code(&self) -> String {
        match self {
            Self::Surreal(error) => match error.as_ref() {
                LyxalSurrealError::Call(LyxalCallError::Business(business)) => {
                    business.code.clone()
                }
                other => other
                    .transport_info()
                    .map(|info| info.code.to_string())
                    .unwrap_or_else(|| "ERROR_INVALID_FUNCTION_RESPONSE".to_string()),
            },
            Self::Spec(_) => SPEC_INVALID.to_string(),
        }
    }

    /// Vrai si l'erreur métier porte ce code.
    pub fn is_code(&self, code: &str) -> bool {
        match self {
            Self::Surreal(error) => {
                matches!(error.as_ref(), LyxalSurrealError::Call(call) if call.is_business_code(code))
            }
            Self::Spec(_) => code == SPEC_INVALID,
        }
    }

    /// Vrai si l'opération peut réussir plus tard sans changement (base indisponible).
    pub fn is_retryable(&self) -> bool {
        match self {
            Self::Surreal(error) => match error.as_ref() {
                LyxalSurrealError::Call(LyxalCallError::Business(business)) => business.retryable,
                LyxalSurrealError::Call(_) => false,
                other => other.transport_info().is_some_and(|info| info.retryable),
            },
            Self::Spec(_) => false,
        }
    }
}

impl From<LyxalSurrealError> for SchedulerError {
    fn from(error: LyxalSurrealError) -> Self {
        Self::Surreal(Box::new(error))
    }
}

impl From<SpecError> for SchedulerError {
    fn from(error: SpecError) -> Self {
        Self::Spec(error)
    }
}

/// Résultat d'un service de `lyxal_scheduler`.
pub type SchedulerResult<T> = Result<T, SchedulerError>;
