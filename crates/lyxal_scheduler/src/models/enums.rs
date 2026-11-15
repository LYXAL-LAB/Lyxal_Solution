//! Énumérations des valeurs fermées du planificateur, encodées en chaînes comme dans SurrealQL.

use lyxal_surreal::SurrealValue;

/// Chevauchement d'une exécution avec une exécution non terminée de la même planification.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "snake_case")]
pub enum Overlap {
    /// Échéance ignorée (exécution `skipped`).
    Skip,
    /// Une seule exécution en attente (`waiting`), remplacée par la plus récente.
    BufferOne,
    /// Toutes les exécutions en attente, dans l'ordre.
    BufferAll,
    /// L'exécution en cours reçoit une demande d'annulation.
    CancelOther,
    /// Exécutions simultanées permises.
    AllowAll,
}

/// Rattrapage des échéances manquées.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "snake_case")]
pub enum Catchup {
    /// La plus récente de la fenêtre de rattrapage.
    Last,
    /// Toutes celles de la fenêtre de rattrapage.
    All,
    /// Aucune (seule l'échéance courante, de moins d'une minute de retard).
    None,
}

/// État d'une exécution.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "snake_case")]
pub enum RunState {
    /// En attente d'une place libérée par une autre exécution de la planification.
    Waiting,
    /// Prête à être réservée à partir de `available_at`.
    Queued,
    /// Réservée par un nœud, sous bail.
    Running,
    /// En attente de la tentative suivante.
    Retrying,
    /// Terminée avec succès.
    Completed,
    /// Terminée en échec, sans nouvelle tentative.
    Dead,
    /// Annulée.
    Cancelled,
    /// Ignorée (chevauchement).
    Skipped,
}

/// État d'une planification.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "snake_case")]
pub enum ScheduleState {
    /// Active.
    Active,
    /// Terminée : plus d'échéance.
    Completed,
    /// Règles refusées par le calcul des dates (`invalid_reason`).
    Invalid,
}

/// État d'une tâche déclarée.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "snake_case")]
pub enum TaskState {
    /// Planifiable et exécutable.
    Active,
    /// Ni planification ni exécution nouvelle ; rien n'est réservé.
    Disabled,
}

/// Exécuteur d'une tâche.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "snake_case")]
pub enum Executor {
    /// Code Rust inscrit par le module.
    Handler,
    /// Fonction SurrealQL du module.
    Function,
    /// Publication différée d'un événement.
    Event,
}

/// Portée d'une tâche.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "snake_case")]
pub enum TaskScope {
    /// Planifiée pour une organisation.
    Organization,
    /// Planifiée pour l'installation.
    Installation,
}

/// Origine d'une exécution.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "snake_case")]
pub enum RunOrigin {
    /// Échéance d'une planification.
    Schedule,
    /// Rejeu d'une période passée.
    Backfill,
    /// Déclenchement immédiat d'une planification.
    Trigger,
    /// Exécution différée ou immédiate d'une tâche.
    Enqueue,
    /// Relance d'une exécution terminée.
    Retry,
}

/// Mode d'une règle de calendrier.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "snake_case")]
pub enum RuleMode {
    /// La date doit correspondre à la règle.
    Include,
    /// La date ne doit pas correspondre à la règle.
    Exclude,
}

/// Sorte d'une règle de calendrier.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "snake_case")]
pub enum RuleKind {
    /// Dates `AAAA-MM-JJ`.
    Dates,
    /// Dates de chaque année `MM-JJ`.
    Annual,
    /// Jours de la semaine ISO (1 : lundi … 7 : dimanche).
    Weekdays,
    /// Jours du mois (1 à 31).
    Monthdays,
    /// Plages horaires `HH:MM-HH:MM` (fin exclue ; une fin avant le début passe minuit).
    TimeRange,
}

/// Stratégie des délais entre deux tentatives.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "snake_case")]
pub enum RetryStrategy {
    /// Délai fixe.
    Fixed,
    /// Délai initial × tentative.
    Linear,
    /// Délai initial × 2^(tentative − 1).
    Exponential,
}

/// État d'un rejeu de période.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "snake_case")]
pub enum BackfillState {
    /// Demandé.
    Pending,
    /// Échéances en cours de création.
    Running,
    /// Terminé.
    Done,
    /// Annulé.
    Cancelled,
}
