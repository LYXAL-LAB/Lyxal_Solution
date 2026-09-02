use crate::event::id::RuntimeEventId;
use crate::event::kind::RuntimeEventKind;
use crate::event::payload::RuntimeEventPayload;
use crate::lock::node_id::NodeId;
use crate::types::ModuleId;
use serde::{Deserialize, Serialize};

/// Événement immuable scellé et séquencé émis par le `RuntimeEventBus`.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct RuntimeEvent {
    /// Identifiant unique et universel de l'événement.
    pub id: RuntimeEventId,
    /// Numéro de séquence strictement monotone local au nœud d'exécution.
    pub sequence: u64,
    /// Identifiant du nœud producteur.
    pub node_id: NodeId,
    /// Timestamp Unix en millisecondes de l'émission.
    pub timestamp_ms: u64,
    /// Catégorie fonctionnelle de l'événement.
    pub kind: RuntimeEventKind,
    /// Identifiant optionnel du module concerné.
    pub module_id: Option<ModuleId>,
    /// Identifiant de corrélation pour le traçage distribué des opérations.
    pub correlation_id: Option<String>,
    /// Identifiant de causalité reliant cet événement à l'événement parent déclencheur.
    pub causation_id: Option<RuntimeEventId>,
    /// Charge utile fortement typée.
    pub payload: RuntimeEventPayload,
}

/// Brouillon d'événement soumis par un producteur au `RuntimeEventBus`.
///
/// Le producteur fournit uniquement le domaine d'événement et le contexte de corrélation.
/// L'identifiant `id`, la `sequence`, le `node_id` et le `timestamp_ms` sont attribués
/// exclusivement par l'infrastructure du bus lors de la publication.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct RuntimeEventDraft {
    /// Catégorie fonctionnelle de l'événement.
    pub kind: RuntimeEventKind,
    /// Identifiant optionnel du module concerné.
    pub module_id: Option<ModuleId>,
    /// Identifiant de corrélation optionnel.
    pub correlation_id: Option<String>,
    /// Identifiant de l'événement causal parent optionnel.
    pub causation_id: Option<RuntimeEventId>,
    /// Charge utile typée.
    pub payload: RuntimeEventPayload,
}

impl RuntimeEventDraft {
    /// Crée un nouveau brouillon d'événement avec le type et la charge utile spécifiés.
    pub fn new(kind: RuntimeEventKind, payload: RuntimeEventPayload) -> Self {
        Self {
            kind,
            module_id: None,
            correlation_id: None,
            causation_id: None,
            payload,
        }
    }

    /// Associe un `ModuleId` au brouillon d'événement.
    pub fn with_module_id(mut self, module_id: impl Into<ModuleId>) -> Self {
        self.module_id = Some(module_id.into());
        self
    }

    /// Associe un identifiant de corrélation.
    pub fn with_correlation_id(mut self, correlation_id: impl Into<String>) -> Self {
        self.correlation_id = Some(correlation_id.into());
        self
    }

    /// Associe un identifiant d'événement causal parent.
    pub fn with_causation_id(mut self, causation_id: impl Into<RuntimeEventId>) -> Self {
        self.causation_id = Some(causation_id.into());
        self
    }
}
