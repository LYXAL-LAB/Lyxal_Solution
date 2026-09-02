use crate::event::event::RuntimeEvent;
use crate::event::kind::RuntimeEventKind;
use crate::types::ModuleId;
use serde::{Deserialize, Serialize};
use std::collections::BTreeSet;

/// Filtre de souscription appliqué par le `RuntimeEventBus` lors de l'acheminement aux abonnés.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, Default)]
pub struct RuntimeEventFilter {
    /// Ensemble optionnel des catégories d'événements retenues (ou `None` pour tout accepter).
    pub kinds: Option<BTreeSet<RuntimeEventKind>>,
    /// Ensemble optionnel des modules ciblés (ou `None` pour tout accepter).
    pub module_ids: Option<BTreeSet<ModuleId>>,
}

impl RuntimeEventFilter {
    /// Crée un filtre acceptant tous les événements sans restriction.
    pub fn all() -> Self {
        Self {
            kinds: None,
            module_ids: None,
        }
    }

    /// Crée un filtre ciblant un ensemble spécifique de catégories d'événements.
    pub fn for_kinds(kinds: impl IntoIterator<Item = RuntimeEventKind>) -> Self {
        Self {
            kinds: Some(kinds.into_iter().collect()),
            module_ids: None,
        }
    }

    /// Crée un filtre ciblant un ensemble spécifique de modules.
    pub fn for_modules(modules: impl IntoIterator<Item = ModuleId>) -> Self {
        Self {
            kinds: None,
            module_ids: Some(modules.into_iter().collect()),
        }
    }

    /// Restreint le filtre aux catégories d'événements indiquées.
    pub fn with_kinds(mut self, kinds: impl IntoIterator<Item = RuntimeEventKind>) -> Self {
        let set: BTreeSet<RuntimeEventKind> = kinds.into_iter().collect();
        self.kinds = Some(set);
        self
    }

    /// Restreint le filtre aux modules indiqués.
    pub fn with_modules(mut self, modules: impl IntoIterator<Item = ModuleId>) -> Self {
        let set: BTreeSet<ModuleId> = modules.into_iter().collect();
        self.module_ids = Some(set);
        self
    }

    /// Évalue si un `RuntimeEvent` satisfait les critères du filtre.
    pub fn matches(&self, event: &RuntimeEvent) -> bool {
        if let Some(kinds) = &self.kinds {
            if !kinds.contains(&event.kind) {
                return false;
            }
        }

        if let Some(module_ids) = &self.module_ids {
            match &event.module_id {
                Some(mod_id) => {
                    if !module_ids.contains(mod_id) {
                        return false;
                    }
                }
                None => return false,
            }
        }

        true
    }
}
