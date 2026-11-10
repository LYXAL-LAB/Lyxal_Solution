#![forbid(unsafe_code)]
#![deny(missing_docs)]
//! `lyxal_i18n` : langues, traductions et formats régionaux de Lyxal OS (référentiel des
//! langues, choix de la langue, clés et traductions).
//!
//! Les règles vivent dans les fonctions SurrealQL `fn::i18n_*` (installées par `lyxal_runtime`
//! depuis `manifest.toml`) ; ce crate fournit les appels typés (`I18nStore`) et la lecture de
//! l'en-tête HTTP `Accept-Language` (`accept_language::candidates`).

pub mod accept_language;
pub mod models;
pub mod store;

pub use models::*;
pub use store::I18nStore;

/// Identifiant du module (`manifest.toml`).
pub const MODULE_ID: &str = "lyxal_i18n";
