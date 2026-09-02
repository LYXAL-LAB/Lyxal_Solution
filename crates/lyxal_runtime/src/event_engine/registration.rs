use crate::error::RuntimeError;
use lyxal_event::HandlerRegistry;

/// Contrat d'extension optionnel pour les modules de domaine consommant des événements asynchrones.
///
/// Ce trait découple les modules métier consommateurs (ex: `lyxal_notification`) des modules producteurs,
/// et permet d'enregistrer leurs handlers typés sans modifier le trait cœur `LyxalModule`.
pub trait EventConsumerModule: Send + Sync {
    /// Déclare et enregistre l'ensemble des gestionnaires d'événements asynchrones pris en charge par ce module.
    fn register_event_handlers(&self, registry: &mut HandlerRegistry) -> Result<(), RuntimeError>;
}
