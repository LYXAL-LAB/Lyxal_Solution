use crate::types::{BatchStatus, ItemQualification, ManifestStatus};

/// Erreur levée lors d'une tentative de transition illégale dans la machine à états.
#[derive(Debug, Clone, PartialEq, Eq, thiserror::Error)]
#[error("Transition d'état illégale de '{from}' vers '{to}' pour l'entité '{entity}'.")]
pub struct IllegalStateTransitionError {
    pub entity: &'static str,
    pub from: String,
    pub to: String,
}

/// Validateur de transitions pour les lots d'ingestion (`ingestion_batch`).
pub struct BatchStateMachine;

impl BatchStateMachine {
    /// Valide si la transition de statut de lot est autorisée.
    pub fn can_transition(from: BatchStatus, to: BatchStatus) -> bool {
        match (from, to) {
            (BatchStatus::Received, BatchStatus::Parsing) => true,
            (BatchStatus::Received, BatchStatus::Failed) => true,
            (BatchStatus::Parsing, BatchStatus::Validating) => true,
            (BatchStatus::Parsing, BatchStatus::Failed) => true,
            (BatchStatus::Validating, BatchStatus::Staged) => true,
            (BatchStatus::Validating, BatchStatus::Failed) => true,
            (BatchStatus::Staged, BatchStatus::Published) => true,
            (BatchStatus::Staged, BatchStatus::Failed) => true,
            // Reprise autorisée après échec
            (BatchStatus::Failed, BatchStatus::Received) => true,
            (BatchStatus::Failed, BatchStatus::Parsing) => true,
            _ => false,
        }
    }

    pub fn validate_transition(from: BatchStatus, to: BatchStatus) -> Result<(), IllegalStateTransitionError> {
        if Self::can_transition(from, to) {
            Ok(())
        } else {
            Err(IllegalStateTransitionError {
                entity: "ingestion_batch",
                from: from.as_str().to_string(),
                to: to.as_str().to_string(),
            })
        }
    }
}

/// Validateur de transitions pour la qualification d'un article en staging (`ingestion_staged_item`).
pub struct StagedItemStateMachine;

impl StagedItemStateMachine {
    pub fn can_transition(from: ItemQualification, to: ItemQualification) -> bool {
        match (from, to) {
            (ItemQualification::ToConfirm, ItemQualification::Verified) => true,
            (ItemQualification::ToConfirm, ItemQualification::Rejected) => true,
            (ItemQualification::Rejected, ItemQualification::ToConfirm) => true,
            (ItemQualification::Verified, ItemQualification::ToConfirm) => true,
            (ItemQualification::Verified, ItemQualification::Rejected) => true,
            _ => false,
        }
    }

    pub fn validate_transition(from: ItemQualification, to: ItemQualification) -> Result<(), IllegalStateTransitionError> {
        if Self::can_transition(from, to) {
            Ok(())
        } else {
            Err(IllegalStateTransitionError {
                entity: "ingestion_staged_item",
                from: from.as_str().to_string(),
                to: to.as_str().to_string(),
            })
        }
    }
}

/// Validateur de transitions pour le manifeste de publication (`ingestion_publication_manifest`).
pub struct ManifestStateMachine;

impl ManifestStateMachine {
    pub fn can_transition(from: ManifestStatus, to: ManifestStatus) -> bool {
        match (from, to) {
            (ManifestStatus::Draft, ManifestStatus::Sealed) => true,
            (ManifestStatus::Draft, ManifestStatus::Failed) => true,
            (ManifestStatus::Sealed, ManifestStatus::Approved) => true,
            (ManifestStatus::Sealed, ManifestStatus::Draft) => true, // Dé-scellement pour correction
            (ManifestStatus::Sealed, ManifestStatus::Failed) => true,
            (ManifestStatus::Approved, ManifestStatus::Executing) => true,
            (ManifestStatus::Approved, ManifestStatus::Failed) => true,
            (ManifestStatus::Executing, ManifestStatus::Committed) => true,
            (ManifestStatus::Executing, ManifestStatus::Failed) => true,
            // Reprise idempotente après interruption/échec d'exécution
            (ManifestStatus::Failed, ManifestStatus::Approved) => true,
            (ManifestStatus::Failed, ManifestStatus::Draft) => true,
            _ => false,
        }
    }

    pub fn validate_transition(from: ManifestStatus, to: ManifestStatus) -> Result<(), IllegalStateTransitionError> {
        if Self::can_transition(from, to) {
            Ok(())
        } else {
            Err(IllegalStateTransitionError {
                entity: "ingestion_publication_manifest",
                from: from.as_str().to_string(),
                to: to.as_str().to_string(),
            })
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_batch_transitions() {
        assert!(BatchStateMachine::validate_transition(BatchStatus::Received, BatchStatus::Parsing).is_ok());
        assert!(BatchStateMachine::validate_transition(BatchStatus::Parsing, BatchStatus::Validating).is_ok());
        assert!(BatchStateMachine::validate_transition(BatchStatus::Validating, BatchStatus::Staged).is_ok());
        assert!(BatchStateMachine::validate_transition(BatchStatus::Staged, BatchStatus::Published).is_ok());
        assert!(BatchStateMachine::validate_transition(BatchStatus::Published, BatchStatus::Received).is_err());
        assert!(BatchStateMachine::validate_transition(BatchStatus::Received, BatchStatus::Published).is_err());
    }

    #[test]
    fn test_manifest_transitions() {
        assert!(ManifestStateMachine::validate_transition(ManifestStatus::Draft, ManifestStatus::Sealed).is_ok());
        assert!(ManifestStateMachine::validate_transition(ManifestStatus::Sealed, ManifestStatus::Approved).is_ok());
        assert!(ManifestStateMachine::validate_transition(ManifestStatus::Approved, ManifestStatus::Executing).is_ok());
        assert!(ManifestStateMachine::validate_transition(ManifestStatus::Executing, ManifestStatus::Committed).is_ok());
        assert!(ManifestStateMachine::validate_transition(ManifestStatus::Draft, ManifestStatus::Approved).is_err());
    }
}
