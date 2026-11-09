//! Référentiel des langues, réglages et choix de la langue.

use lyxal_surreal::SurrealValue;

use super::types::{I18nDatetime, I18nRecordId};

/// Langue du référentiel (données Unicode CLDR).
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct Locale {
    /// Identifiant (`i18n_locale:⟨fr-CA⟩`).
    pub id: I18nRecordId,
    /// Étiquette BCP 47 canonique.
    pub tag: String,
    /// Langue seule (ISO 639).
    pub language: String,
    /// Script (ISO 15924).
    pub script: Option<String>,
    /// Région (ISO 3166 ou UN M.49).
    pub region: Option<String>,
    /// Nom en anglais.
    pub name_en: String,
    /// Nom dans la langue elle-même.
    pub name_native: String,
    /// Sens d'écriture : `ltr` ou `rtl`.
    pub direction: String,
    /// Catégories de pluriel cardinal.
    pub plural_cardinal: Vec<String>,
    /// Catégories de pluriel ordinal.
    pub plural_ordinal: Vec<String>,
    /// Chaîne de repli CLDR, sans l'étiquette elle-même.
    pub fallback: Vec<String>,
    /// Langue active sur l'installation.
    pub active: bool,
    /// Version de CLDR des données.
    pub cldr_version: String,
    /// Dernière modification.
    pub updated_at: I18nDatetime,
}

/// Paramètres de `fn::i18n_locale_list`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct LocaleListParams {
    /// Filtre sur l'état actif.
    pub active: Option<bool>,
    /// Début de l'étiquette ou partie d'un nom.
    pub search: Option<String>,
    /// Nombre maximal de langues (1 à 1000, 100 par défaut).
    pub limit: Option<i64>,
    /// Décalage.
    pub start: Option<i64>,
}

/// Résultat de `fn::i18n_locale_list`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct LocaleList {
    /// Langues de la page.
    pub items: Vec<Locale>,
    /// Nombre total de langues correspondantes.
    pub total: i64,
}

/// Paramètres de `fn::i18n_locale_get`, `fn::i18n_locale_activate` et
/// `fn::i18n_locale_deactivate`.
#[derive(Debug, Clone, SurrealValue)]
pub struct LocaleGetParams {
    /// Étiquette BCP 47.
    pub locale: String,
}

/// Paramètres de `fn::i18n_settings_get`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct SettingsGetParams {}

/// Réglages des langues de l'installation.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct Settings {
    /// Langue par défaut.
    pub default_locale: String,
    /// Langue des textes sources.
    pub source_locale: String,
}

/// Paramètres de `fn::i18n_settings_update`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct SettingsUpdateParams {
    /// Nouvelle langue par défaut (active).
    pub default_locale: Option<String>,
    /// Nouvelle langue source (active).
    pub source_locale: Option<String>,
}

/// Paramètres de `fn::i18n_locale_resolve`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct LocaleResolveParams {
    /// Étiquettes candidates par ordre de préférence (20 au plus).
    pub candidates: Vec<String>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Résultat de `fn::i18n_locale_resolve`.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct ResolvedLocale {
    /// Étiquette retenue.
    pub locale: String,
    /// Langue seule, pour le paramètre `language` des fonctions des modules.
    pub language: String,
    /// Chaîne de repli jusqu'à la langue par défaut.
    pub fallback: Vec<String>,
    /// Faux si aucun candidat ne correspond (langue par défaut).
    pub matched: bool,
}
