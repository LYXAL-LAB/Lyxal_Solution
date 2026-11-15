//! Alias des types natifs SurrealDB utilisés par les modèles de `lyxal_scheduler`.

/// Identifiant d'enregistrement SurrealDB.
pub type SchedulerRecordId = lyxal_surreal::RecordId;
/// Horodatage SurrealDB.
pub type SchedulerDatetime = lyxal_surreal::Datetime;
/// Durée SurrealDB (intervalles, fenêtres, délais).
pub type SchedulerDuration = surrealdb::types::Duration;
/// Valeur SurrealDB quelconque (arguments, résultats, détails dont le schéma dépend de la tâche).
pub type SchedulerValue = lyxal_surreal::Value;
