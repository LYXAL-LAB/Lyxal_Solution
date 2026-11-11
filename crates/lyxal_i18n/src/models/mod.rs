//! Contrats publics des fonctions SurrealQL `fn::i18n_*` : paramètres (`XxxParams`) et
//! résultats.

mod exchange;
mod locale;
mod translation;
mod types;

pub use exchange::{
    ExportPage, ExportParams, ExportRow, ImportEntry, ImportInvalid, ImportParams, ImportResult,
    ImportSkipped, MessageProblem, ScanPage, ScanRow,
};
pub use locale::{
    Locale, LocaleGetParams, LocaleList, LocaleListParams, LocaleResolveParams, ResolvedLocale,
    Settings, SettingsGetParams, SettingsUpdateParams,
};
pub use translation::{
    KeyCreateParams, KeyCreated, KeyDeleteParams, KeyDeleted, KeyList, KeyListParams, KeyParam,
    KeyUpdateParams, MessageIssue, MissingKey, MissingKeyList, Namespace, NamespaceCreateParams,
    NamespaceList, PageParams, ResolveManyParams, ResolveParams, ResolvedText, Translation,
    TranslationDeleteParams, TranslationDeleted, TranslationKey, TranslationList,
    TranslationListParams, TranslationReviewParams, TranslationRow, TranslationSet,
    TranslationSetParams,
};
pub use types::{I18nDatetime, I18nRecordId};
