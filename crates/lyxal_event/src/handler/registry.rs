use super::erased::{ErasedHandler, TypedHandler};
use super::event::Event;
use super::handler::Handler;
use crate::error::LyxalEventError;
use std::collections::HashMap;
use std::sync::Arc;

/// Registre dynamique associant chaque `event_type` à son handler effacé `ErasedHandler`.
#[derive(Default, Clone)]
pub struct HandlerRegistry {
    handlers: HashMap<String, Arc<dyn ErasedHandler>>,
}

impl HandlerRegistry {
    /// Crée un nouveau registre de handlers vide.
    #[must_use]
    pub fn new() -> Self {
        Self {
            handlers: HashMap::new(),
        }
    }

    /// Enregistre un handler fortement typé pour l'événement `E`.
    ///
    /// # Errors
    /// Retourne une erreur si un handler est déjà enregistré pour ce type d'événement.
    pub fn register<E, H>(&mut self, handler: H) -> Result<&mut Self, LyxalEventError>
    where
        E: Event,
        H: Handler<E>,
    {
        let event_type = E::EVENT_TYPE.to_string();
        if self.handlers.contains_key(&event_type) {
            return Err(LyxalEventError::Internal(format!(
                "Handler already registered for event type '{event_type}'"
            )));
        }

        let erased = Arc::new(TypedHandler::<E, H>::new(handler));
        self.handlers.insert(event_type, erased);
        Ok(self)
    }

    /// Récupère le handler associé à un nom de type d'événement.
    #[must_use]
    pub fn get(&self, event_type: &str) -> Option<Arc<dyn ErasedHandler>> {
        self.handlers.get(event_type).cloned()
    }

    /// Vérifie si un handler est enregistré pour un type d'événement donné.
    #[must_use]
    pub fn contains(&self, event_type: &str) -> bool {
        self.handlers.contains_key(event_type)
    }

    /// Retourne le nombre de handlers enregistrés.
    #[must_use]
    pub fn len(&self) -> usize {
        self.handlers.len()
    }

    /// Indique si le registre est vide.
    #[must_use]
    pub fn is_empty(&self) -> bool {
        self.handlers.is_empty()
    }
}
