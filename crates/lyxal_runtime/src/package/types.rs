use crate::error::RuntimeError;
use crate::types::ModuleId;
use serde::{Deserialize, Serialize};

/// Phase d'exécution du pipeline d'installation pour le diagnostic et les checkpoints de reprise.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Hash, Serialize, Deserialize)]
pub enum InstallationPhase {
    /// Validation statique du manifeste et de sa structure.
    Validation,
    /// Vérification de la compatibilité avec la version du Runtime Lyxal.
    Compatibility,
    /// Résolution et vérification des contraintes de dépendances (SemVer).
    Dependencies,
    /// Acquisition du bail distribué d'installation.
    LeaseAcquisition,
    /// Enregistrement persistant de l'identité du module et de la release (`Installing`).
    Registration,
    /// Importation du schéma baseline (`schema/`).
    Schema,
    /// Planification et exécution des migrations séquentielles (`migrations/`).
    Migration,
    /// Exécution du hook Rust du module `LyxalModule::install()`.
    InstallHook,
    /// Finalisation et marquage de la release en `Installed`.
    Complete,
}

impl InstallationPhase {
    /// Représentation textuelle de la phase.
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Validation => "Validation",
            Self::Compatibility => "Compatibility",
            Self::Dependencies => "Dependencies",
            Self::LeaseAcquisition => "LeaseAcquisition",
            Self::Registration => "Registration",
            Self::Schema => "Schema",
            Self::Migration => "Migration",
            Self::InstallHook => "InstallHook",
            Self::Complete => "Complete",
        }
    }
}

impl std::fmt::Display for InstallationPhase {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

/// Résultat qualitatif de l'exécution d'une installation de module.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum ModuleInstallationOutcome {
    /// Nouvelle release installée avec succès pour la première fois.
    Installed,
    /// La release était déjà installée avec succès ; aucune mutation réexécutée (idempotence).
    AlreadyInstalled,
    /// Mise à jour réussie depuis une release précédemment installée.
    Updated { previous_version: String },
    /// Reprise et finalisation réussie d'une release précédemment en échec.
    Recovered,
}

/// Statut de cycle de vie persistant d'une release de module dans `system_module_release`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum ModuleReleaseStatus {
    /// Découverte et déclarée mais non encore traitée.
    Discovered,
    /// En cours de traitement par le pipeline d'installation.
    Installing,
    /// Installée avec succès (schéma, migrations et hooks terminés).
    Installed,
    /// Active et en cours d'exécution dans le Runtime.
    Active,
    /// Désactivée ou mise en sommeil.
    Inactive,
    /// Échec survenu pendant l'installation.
    Failed,
}

impl ModuleReleaseStatus {
    /// Représentation textuelle conforme au standard persistant.
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Discovered => "Discovered",
            Self::Installing => "Installing",
            Self::Installed => "Installed",
            Self::Active => "Active",
            Self::Inactive => "Inactive",
            Self::Failed => "Failed",
        }
    }

    /// Valide si une transition d'état de release est autorisée par la charte d'architecture.
    pub fn can_transition_to(&self, next: ModuleReleaseStatus) -> bool {
        match (self, next) {
            (Self::Discovered, Self::Installing) => true,
            (Self::Installing, Self::Installed) => true,
            (Self::Installing, Self::Failed) => true,
            (Self::Failed, Self::Installing) => true, // Autorisation explicite de reprise (recovery)
            (Self::Installed, Self::Active) => true,
            (Self::Installed, Self::Inactive) => true,
            (Self::Active, Self::Inactive) => true,
            (Self::Inactive, Self::Active) => true,
            (s1, s2) if s1 == &s2 => true, // Idempotence
            _ => false,
        }
    }
}

impl std::fmt::Display for ModuleReleaseStatus {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl std::str::FromStr for ModuleReleaseStatus {
    type Err = RuntimeError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s.trim() {
            "Discovered" => Ok(Self::Discovered),
            "Installing" => Ok(Self::Installing),
            "Installed" => Ok(Self::Installed),
            "Active" => Ok(Self::Active),
            "Inactive" => Ok(Self::Inactive),
            "Failed" => Ok(Self::Failed),
            other => Err(RuntimeError::Internal {
                code: "INVALID_RELEASE_STATUS",
                message: format!("Unknown ModuleReleaseStatus '{}'", other),
            }),
        }
    }
}

/// Rapport complet d'exécution de l'installation d'un module individuel.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ModuleInstallationReport {
    /// Identifiant du module concerné.
    pub module_id: ModuleId,
    /// Version de la release traitée.
    pub version: String,
    /// Résultat de l'installation.
    pub outcome: ModuleInstallationOutcome,
    /// Durée totale de l'opération en millisecondes.
    pub duration_ms: u64,
    /// Nombre de ressources de schéma traitées.
    pub schema_resources_count: usize,
    /// Nombre de migrations appliquées avec succès.
    pub migrations_applied: usize,
    /// Nombre de migrations ignorées (déjà appliquées).
    pub migrations_skipped: usize,
    /// Phase atteinte à l'issue de l'opération.
    pub phase: InstallationPhase,
}

/// Rapport d'exécution d'une opération d'installation groupée en batch (DAG).
#[derive(Debug)]
pub struct ModuleBatchInstallationResult {
    /// Modules installés avec succès (ordonnés topologiquement).
    pub installed: Vec<ModuleId>,
    /// Modules qui étaient déjà installés (idempotence).
    pub already_installed: Vec<ModuleId>,
    /// Modules dont l'installation a échoué avec l'erreur associée.
    pub failed: Vec<(ModuleId, RuntimeError)>,
    /// Modules dont l'installation n'a pas été tentée suite à l'échec d'une dépendance en amont.
    pub not_attempted: Vec<(ModuleId, ModuleId)>,
}

impl ModuleBatchInstallationResult {
    /// Crée un nouveau résultat vide.
    pub fn new() -> Self {
        Self {
            installed: Vec::new(),
            already_installed: Vec::new(),
            failed: Vec::new(),
            not_attempted: Vec::new(),
        }
    }

    /// Indique si l'ensemble des modules demandés dans le batch a été installé sans aucun échec.
    pub fn is_success(&self) -> bool {
        self.failed.is_empty() && self.not_attempted.is_empty()
    }
}

impl Default for ModuleBatchInstallationResult {
    fn default() -> Self {
        Self::new()
    }
}
