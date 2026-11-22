// SPDX-License-Identifier: AGPL-3.0-only

//! Alias des types natifs SurrealDB utilisés par les modèles de `lyxal_mail`.

/// Identifiant d'enregistrement SurrealDB.
pub type MailRecordId = lyxal_surreal::RecordId;
/// Horodatage SurrealDB.
pub type MailDatetime = lyxal_surreal::Datetime;
/// Valeur SurrealDB libre (structure MIME, rangée telle quelle).
pub type MailValue = lyxal_surreal::Value;
