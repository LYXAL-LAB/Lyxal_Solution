use crate::manifest::ModuleManifest;
use crate::migration::MigrationPlan;
use crate::schema::SchemaImportPlan;
use crate::types::ModuleId;
use serde::{Deserialize, Serialize};

/// Nature qualitative de l'installation planifiée.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum InstallationNature {
    /// Première installation du module sur le système.
    FreshInstall,
    /// Installation d'une nouvelle version alors qu'une version précédente existe déjà.
    UpgradeCandidate { current_version: String },
    /// La release demandée est déjà installée et cohérente (aucun travail mutationnel requis).
    AlreadyInstalled,
    /// Reprise après un échec lors du hook `install()` (schéma et migrations déjà appliqués).
    HookRecovery,
}

/// Plan d'installation immuable résultant de la phase d'inspection statique et de dry-run.
#[derive(Debug, Clone)]
pub struct ModuleInstallationPlan {
    /// Identifiant du module.
    pub module_id: ModuleId,
    /// Version ciblée pour l'installation.
    pub version: semver::Version,
    /// Nature de l'opération planifiée.
    pub nature: InstallationNature,
    /// Manifeste validé du module.
    pub manifest: ModuleManifest,
    /// Indique si l'exécution de l'importation de schéma baseline est requise.
    pub schema_required: bool,
    /// Plan d'importation de schéma calculé.
    pub schema_plan: Option<SchemaImportPlan>,
    /// Plan d'exécution des migrations calculé.
    pub migration_plan: MigrationPlan,
}

impl ModuleInstallationPlan {
    /// Indique si des modifications d'état (schéma, migrations ou hooks) sont nécessaires.
    pub fn is_mutation_required(&self) -> bool {
        match &self.nature {
            InstallationNature::AlreadyInstalled => false,
            InstallationNature::FreshInstall
            | InstallationNature::UpgradeCandidate { .. }
            | InstallationNature::HookRecovery => true,
        }
    }

    /// Résumé textuel synthétique du plan d'installation.
    pub fn summary(&self) -> String {
        format!(
            "Installation plan for '{}:{}' ({:?}, schema_required: {}, migrations to apply: {})",
            self.module_id,
            self.version,
            self.nature,
            self.schema_required,
            self.migration_plan.to_apply().len()
        )
    }
}
