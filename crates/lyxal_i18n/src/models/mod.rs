//! Contrats publics des fonctions SurrealQL `fn::i18n_*` : paramètres (`XxxParams`) et
//! résultats.

mod locale;
mod types;

pub use locale::{
    Locale, LocaleGetParams, LocaleList, LocaleListParams, LocaleResolveParams, ResolvedLocale,
    Settings, SettingsGetParams, SettingsUpdateParams,
};
pub use types::{I18nDatetime, I18nRecordId};
