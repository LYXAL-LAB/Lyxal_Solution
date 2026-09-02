use serde::de::DeserializeOwned;
use serde::Serialize;

/// Trait marqueur pour les événements de domaine fortement typés.
pub trait Event: Serialize + DeserializeOwned + Send + Sync + 'static {
    /// Nom de domaine qualifié unique identifiant le type d'événement (ex: "booking.created").
    const EVENT_TYPE: &'static str;
}
