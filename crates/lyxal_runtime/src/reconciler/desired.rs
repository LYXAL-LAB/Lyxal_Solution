use crate::types::ModuleId;
use semver::VersionReq;
use serde::{Deserialize, Serialize};
use std::fmt;

/// Cible d'état déclarative pour un module dans l'architecture DRA de Lyxal OS.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum ModuleTargetState {
    /// Le module doit être installé et actif en cours d'exécution (`Running`).
    Running,
    /// Le module doit être installé, mais pas nécessairement actif (non `Running`).
    Installed,
    /// Le module doit être explicitement arrêté (`Stopped` / non `Running`).
    Stopped,
    /// Le module ne doit pas être actif (arrêt si `Running`, pas de suppression destructive).
    Absent,
}

impl ModuleTargetState {
    /// Indique si la cible exige que le module soit en cours d'exécution.
    pub fn is_running(&self) -> bool {
        matches!(self, Self::Running)
    }

    /// Indique si la cible exige au minimum l'installation.
    pub fn is_installed_or_stopped(&self) -> bool {
        matches!(self, Self::Installed | Self::Stopped)
    }

    /// Indique si la cible est Absent.
    pub fn is_absent(&self) -> bool {
        matches!(self, Self::Absent)
    }

    /// Calcule la cible requise pour une dépendance directe selon le contrat CTO V1.6 :
    /// - Parent `Running`   -> Dépendance requise `Running`
    /// - Parent `Installed` -> Dépendance requise `Installed`
    /// - Parent `Stopped`   -> Dépendance requise `Installed` (satisfaite sans être démarrée)
    /// - Parent `Absent`    -> Aucune propagation
    pub fn required_dependency_target(&self) -> Option<Self> {
        match self {
            Self::Running => Some(Self::Running),
            Self::Installed => Some(Self::Installed),
            Self::Stopped => Some(Self::Installed),
            Self::Absent => None,
        }
    }
}

impl fmt::Display for ModuleTargetState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::Running => write!(f, "Running"),
            Self::Installed => write!(f, "Installed"),
            Self::Stopped => write!(f, "Stopped"),
            Self::Absent => write!(f, "Absent"),
        }
    }
}

/// Origine de la déclaration d'un état désiré (explicite vs closure transitive).
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum DesiredStateOrigin {
    /// Déclaré explicitement par l'utilisateur ou la configuration.
    Explicit,
    /// Ajouté implicitement par la fermeture transitive des dépendances (Dependency Closure).
    ImplicitDependency { required_by: ModuleId },
}

impl DesiredStateOrigin {
    /// Indique si l'état est explicite.
    pub fn is_explicit(&self) -> bool {
        matches!(self, Self::Explicit)
    }

    /// Indique si l'état provient d'une dépendance implicite.
    pub fn is_implicit(&self) -> bool {
        matches!(self, Self::ImplicitDependency { .. })
    }
}

/// Déclaration d'état souhaité pour un module individuel.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct DesiredModuleState {
    /// Identifiant canonique du module.
    pub module_id: ModuleId,
    /// Contrainte SemVer optionnelle (None = toute version installée satisfaisante).
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub version_req: Option<VersionReq>,
    /// Cible d'état souhaitée.
    pub target: ModuleTargetState,
    /// Origine de la contrainte (explicite ou dépendance implicite).
    #[serde(default = "default_origin")]
    pub origin: DesiredStateOrigin,
}

fn default_origin() -> DesiredStateOrigin {
    DesiredStateOrigin::Explicit
}

impl DesiredModuleState {
    /// Crée une nouvelle déclaration d'état souhaité explicite.
    pub fn new(module_id: impl Into<ModuleId>, target: ModuleTargetState) -> Self {
        Self {
            module_id: module_id.into(),
            version_req: None,
            target,
            origin: DesiredStateOrigin::Explicit,
        }
    }

    /// Associe une contrainte de version SemVer.
    pub fn with_version_req(mut self, req: VersionReq) -> Self {
        self.version_req = Some(req);
        self
    }

    /// Définit l'origine de l'état désiré.
    pub fn with_origin(mut self, origin: DesiredStateOrigin) -> Self {
        self.origin = origin;
        self
    }
}

/// État global souhaité du runtime Lyxal OS (Node-Local Desired State).
#[derive(Debug, Clone, Default, PartialEq, Eq, Serialize, Deserialize)]
pub struct DesiredRuntimeState {
    /// Ensemble des états souhaités pour les modules déclarés.
    pub modules: Vec<DesiredModuleState>,
    /// Mode strict : si true, tout module non spécifié est implicitement considéré `Absent`.
    /// Par défaut false (les modules non spécifiés restent non gérés / inchangés).
    #[serde(default)]
    pub strict: bool,
}

impl DesiredRuntimeState {
    /// Crée un état désiré vide.
    pub fn new() -> Self {
        Self {
            modules: Vec::new(),
            strict: false,
        }
    }

    /// Active le mode strict.
    pub fn with_strict(mut self, strict: bool) -> Self {
        self.strict = strict;
        self
    }

    /// Ajoute un état de module souhaité.
    pub fn add_module(mut self, state: DesiredModuleState) -> Self {
        self.modules.push(state);
        self
    }

    /// Raccourci pour déclarer un module Running.
    pub fn running(self, module_id: impl Into<ModuleId>) -> Self {
        self.add_module(DesiredModuleState::new(
            module_id,
            ModuleTargetState::Running,
        ))
    }

    /// Raccourci pour déclarer un module Running avec contrainte SemVer.
    pub fn running_version(self, module_id: impl Into<ModuleId>, req: VersionReq) -> Self {
        self.add_module(
            DesiredModuleState::new(module_id, ModuleTargetState::Running).with_version_req(req),
        )
    }

    /// Raccourci pour déclarer un module Installed.
    pub fn installed(self, module_id: impl Into<ModuleId>) -> Self {
        self.add_module(DesiredModuleState::new(
            module_id,
            ModuleTargetState::Installed,
        ))
    }

    /// Raccourci pour déclarer un module Stopped.
    pub fn stopped(self, module_id: impl Into<ModuleId>) -> Self {
        self.add_module(DesiredModuleState::new(
            module_id,
            ModuleTargetState::Stopped,
        ))
    }

    /// Raccourci pour déclarer un module Absent.
    pub fn absent(self, module_id: impl Into<ModuleId>) -> Self {
        self.add_module(DesiredModuleState::new(
            module_id,
            ModuleTargetState::Absent,
        ))
    }
}
