//! Fonctions des exécuteurs : réservation sous bail, battement, fin, reprise, élagage
//! (`fn::scheduler_run_claim`, `_heartbeat`, `_complete`, `_fail`, `_rescue`, `_prune`).

use lyxal_surreal::SurrealValue;
use std::fmt;
use surrealdb::types::{Error as SurrealTypeError, Kind, Value};

use super::enums::{RunOrigin, RunState};
use super::types::{SchedulerDatetime, SchedulerDuration, SchedulerRecordId, SchedulerValue};

/// Jeton du bail d'une exécution réservée : exigé par chaque battement et chaque fin de
/// tentative. Opaque (aucun accès sans [`LeaseToken::expose`]) et masqué dans `Debug`.
#[derive(Clone, PartialEq, Eq)]
pub struct LeaseToken(String);

impl LeaseToken {
    /// Texte du jeton, pour un usage intentionnel seulement.
    pub fn expose(&self) -> &str {
        &self.0
    }
}

impl fmt::Debug for LeaseToken {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str("LeaseToken([REDACTED])")
    }
}

impl SurrealValue for LeaseToken {
    fn kind_of() -> Kind {
        String::kind_of()
    }

    fn into_value(self) -> Value {
        Value::String(self.0)
    }

    fn from_value(value: Value) -> Result<Self, SurrealTypeError> {
        String::from_value(value).map(Self)
    }
}

/// Paramètres de `fn::scheduler_run_claim`.
#[derive(Debug, Clone, SurrealValue)]
pub struct RunClaimParams {
    /// File.
    pub queue: String,
    /// Nœud qui réserve.
    pub node: String,
    /// Nombre maximal d'exécutions réservées (100 au plus).
    pub limit: Option<i64>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Exécution réservée sous bail.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct ClaimedRun {
    /// Exécution.
    pub id: SchedulerRecordId,
    /// Jeton du bail.
    pub lease: LeaseToken,
    /// Nœud qui détient le bail.
    pub lease_node: String,
    /// Échéance du bail.
    pub locked_until: SchedulerDatetime,
    /// Délai maximal de la tentative.
    pub timeout: SchedulerDuration,
    /// Organisation (absente : installation).
    pub tenant: Option<SchedulerRecordId>,
    /// Planification d'origine.
    pub schedule: Option<SchedulerRecordId>,
    /// Tâche.
    pub task: SchedulerRecordId,
    /// Arguments.
    pub args: SchedulerValue,
    /// Origine.
    pub origin: RunOrigin,
    /// Date prévue.
    pub scheduled_for: SchedulerDatetime,
    /// Tentative en cours.
    pub attempt: i64,
    /// Tentatives permises.
    pub max_attempts: i64,
}

/// Résultat de `fn::scheduler_run_claim`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct ClaimResult {
    /// Exécutions réservées.
    pub items: Vec<ClaimedRun>,
    /// File en pause : rien n'est réservé.
    pub paused: bool,
}

/// Paramètres de `fn::scheduler_run_heartbeat`.
#[derive(Debug, Clone, SurrealValue)]
pub struct RunHeartbeatParams {
    /// Exécution.
    pub run: SchedulerRecordId,
    /// Jeton du bail.
    pub lease: LeaseToken,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Résultat de `fn::scheduler_run_heartbeat`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct Heartbeat {
    /// Exécution.
    pub run: SchedulerRecordId,
    /// Nouvelle échéance du bail.
    pub locked_until: SchedulerDatetime,
    /// Annulation demandée.
    pub cancel_requested: bool,
}

/// Paramètres de `fn::scheduler_run_complete`.
#[derive(Debug, Clone, SurrealValue)]
pub struct RunCompleteParams {
    /// Exécution.
    pub run: SchedulerRecordId,
    /// Jeton du bail.
    pub lease: LeaseToken,
    /// Résultat court (objet de 4 Kio au plus).
    pub result: Option<SchedulerValue>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Erreur d'une tentative remise par l'exécuteur.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct RunFailure {
    /// Code de l'erreur.
    pub code: String,
    /// Message (tronqué à 1000 caractères).
    pub message: Option<String>,
}

/// Paramètres de `fn::scheduler_run_fail`.
#[derive(Debug, Clone, SurrealValue)]
pub struct RunFailParams {
    /// Exécution.
    pub run: SchedulerRecordId,
    /// Jeton du bail.
    pub lease: LeaseToken,
    /// Erreur de la tentative.
    pub error: RunFailure,
    /// Erreur retentable (défaut SurrealQL : oui).
    pub retryable: Option<bool>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Paramètres de `fn::scheduler_run_rescue`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct RunRescueParams {
    /// Nombre maximal d'exécutions reprises (1000 au plus).
    pub limit: Option<i64>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Exécution reprise après l'expiration de son bail.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct RescuedRun {
    /// Exécution.
    pub id: SchedulerRecordId,
    /// Nouvel état (`retrying`, `cancelled` ou `dead`).
    pub state: RunState,
}

/// Résultat de `fn::scheduler_run_rescue`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct RescueResult {
    /// Exécutions reprises.
    pub rescued: Vec<RescuedRun>,
    /// Compteurs de places corrigés.
    pub reconciled: i64,
}

/// Paramètres de `fn::scheduler_run_prune`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct RunPruneParams {
    /// Nombre maximal d'exécutions supprimées (10000 au plus).
    pub limit: Option<i64>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Résultat de `fn::scheduler_run_prune`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct PruneResult {
    /// Exécutions supprimées.
    pub deleted: i64,
}
