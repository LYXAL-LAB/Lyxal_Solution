#![forbid(unsafe_code)]
#![deny(missing_docs)]
//! `lyxal_i18n` : langues, traductions et formats régionaux de Lyxal OS (référentiel des
//! langues, choix de la langue, clés, traductions et rendu).
//!
//! Les règles vivent dans les fonctions SurrealQL `fn::i18n_*` (installées par `lyxal_runtime`
//! depuis `manifest.toml`) ; ce crate fournit les appels typés (`I18nStore`), la lecture de
//! l'en-tête HTTP `Accept-Language` (`accept_language::candidates`), le rendu selon la langue
//! (`Formatter` : messages, nombres, dates, montants ; SurrealDB n'a pas ICU), la traduction
//! d'une clé en une étape (`Translator`), le module `LyxalModule` et sa sonde de santé.

pub mod accept_language;
pub mod format;
pub mod models;
pub mod module;
pub mod store;
pub mod translator;

pub use format::{
    parse_decimal, ArgValue, DateStyle, Decimal, FormatError, Formatter, Length, MessageArgs,
    Syntax, ICU_CLDR_VERSION,
};
pub use models::*;
pub use module::{timezone_database_origin, I18nHealthCheck, I18nModule};
pub use store::I18nStore;
pub use translator::{TranslateError, TranslateRequest, Translated, Translator};

/// Identifiant du module (`manifest.toml`).
pub const MODULE_ID: &str = "lyxal_i18n";
