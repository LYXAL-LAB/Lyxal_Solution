use crate::error::RuntimeError;
use crate::migration::checksum::MigrationChecksum;
use crate::migration::definition::{MigrationDefinition, MigrationRecord};
use crate::migration::status::MigrationStatus;
use crate::store::traits::RuntimeStore;
use crate::types::ModuleId;
use serde::{Deserialize, Serialize};

/// Action décidée pour une migration lors de l'établissement du plan.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum MigrationPlanAction {
    /// La migration n'a jamais été appliquée et doit être exécutée.
    Apply,
    /// La migration a déjà été appliquée avec un checksum identique, elle est ignorée.
    Skip,
    /// La migration a précédemment échoué et va être réessayée.
    Retry,
    /// Écart de checksum détecté : la migration a été altérée après application.
    FailDrift {
        expected: MigrationChecksum,
        actual: MigrationChecksum,
    },
    /// La migration a été interrompue lors d'une exécution précédente (état 'Applying').
    FailInterrupted,
}

/// Élément individuel d'un plan de migration.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct MigrationPlanItem {
    pub definition: MigrationDefinition,
    pub action: MigrationPlanAction,
    pub existing_record: Option<MigrationRecord>,
}

/// Plan déterministe d'exécution des migrations pour un module donné.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct MigrationPlan {
    pub module_id: ModuleId,
    pub module_version: String,
    pub items: Vec<MigrationPlanItem>,
}

impl MigrationPlan {
    /// Crée directement une instance de `MigrationPlan`.
    pub fn new(
        module_id: ModuleId,
        module_version: impl Into<String>,
        items: Vec<MigrationPlanItem>,
    ) -> Self {
        Self {
            module_id,
            module_version: module_version.into(),
            items,
        }
    }

    /// Retourne la liste des éléments de migration nécessitant une exécution (`Apply` ou `Retry`).
    pub fn to_apply(&self) -> Vec<&MigrationPlanItem> {
        self.items
            .iter()
            .filter(|i| {
                matches!(
                    i.action,
                    MigrationPlanAction::Apply | MigrationPlanAction::Retry
                )
            })
            .collect()
    }

    /// Construit le plan de migration en confrontant les définitions découvertes avec l'état dans `RuntimeStore`.
    pub async fn from_definitions_and_store(
        module_id: &ModuleId,
        module_version: &str,
        definitions: &[MigrationDefinition],
        store: &dyn RuntimeStore,
    ) -> Result<Self, RuntimeError> {
        let mut items = Vec::new();

        for def in definitions {
            let record = store.get_migration(module_id, &def.id).await?;

            let action = match &record {
                None => MigrationPlanAction::Apply,
                Some(r) => match r.status {
                    MigrationStatus::Applied => {
                        if r.checksum == def.checksum {
                            MigrationPlanAction::Skip
                        } else {
                            MigrationPlanAction::FailDrift {
                                expected: r.checksum.clone(),
                                actual: def.checksum.clone(),
                            }
                        }
                    }
                    MigrationStatus::Failed => {
                        if r.checksum == def.checksum {
                            MigrationPlanAction::Retry
                        } else {
                            MigrationPlanAction::FailDrift {
                                expected: r.checksum.clone(),
                                actual: def.checksum.clone(),
                            }
                        }
                    }
                    MigrationStatus::Applying => MigrationPlanAction::FailInterrupted,
                    MigrationStatus::Pending => MigrationPlanAction::Apply,
                    MigrationStatus::RolledBack => MigrationPlanAction::Apply,
                    MigrationStatus::Skipped => MigrationPlanAction::Skip,
                },
            };

            items.push(MigrationPlanItem {
                definition: def.clone(),
                action,
                existing_record: record,
            });
        }

        Ok(Self {
            module_id: module_id.clone(),
            module_version: module_version.to_string(),
            items,
        })
    }

    /// Nombre de migrations devant être appliquées (nouvelles ou retries).
    pub fn executable_count(&self) -> usize {
        self.items
            .iter()
            .filter(|i| {
                matches!(
                    i.action,
                    MigrationPlanAction::Apply | MigrationPlanAction::Retry
                )
            })
            .count()
    }

    /// Nombre de migrations déjà appliquées et ignorées.
    pub fn skipped_count(&self) -> usize {
        self.items
            .iter()
            .filter(|i| matches!(i.action, MigrationPlanAction::Skip))
            .count()
    }

    /// Indique si le plan contient au moins une altération de checksum (drift).
    pub fn has_drift(&self) -> bool {
        self.items
            .iter()
            .any(|i| matches!(i.action, MigrationPlanAction::FailDrift { .. }))
    }

    /// Indique si le plan contient une migration interrompue en cours de route.
    pub fn has_interrupted(&self) -> bool {
        self.items
            .iter()
            .any(|i| matches!(i.action, MigrationPlanAction::FailInterrupted))
    }

    /// Retourne la liste des éléments du plan.
    pub fn items(&self) -> &[MigrationPlanItem] {
        &self.items
    }
}
