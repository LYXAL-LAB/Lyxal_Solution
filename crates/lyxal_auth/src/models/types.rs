//! Alias des types natifs SurrealDB utilisés par les modèles de `lyxal_auth`.

use lyxal_surreal::SurrealValue;

/// Identifiant d'enregistrement SurrealDB.
pub type AuthRecordId = lyxal_surreal::RecordId;
/// Horodatage SurrealDB.
pub type AuthDatetime = lyxal_surreal::Datetime;
/// Valeur SurrealDB libre (traits, image de marque, politique).
pub type AuthValue = lyxal_surreal::Value;

/// Paramètres de `fn::auth_policy_get` : organisation (texte `auth_organization:<clé>`), ou
/// politique de l'installation si absente.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct PolicyGetParams {
    /// Organisation dont on veut la politique effective.
    pub organization: Option<String>,
}
