//! Alias des types natifs SurrealDB utilisés par les modèles de `lyxal_secrets`.

/// Identifiant d'enregistrement SurrealDB.
pub type SecretsRecordId = lyxal_surreal::RecordId;
/// Horodatage SurrealDB.
pub type SecretsDatetime = lyxal_surreal::Datetime;
/// Durée SurrealDB (période de rotation).
pub type SecretsDuration = surrealdb::types::Duration;
/// Valeur SurrealDB quelconque (métadonnées libres d'une fiche).
pub type SecretsValue = lyxal_surreal::Value;
