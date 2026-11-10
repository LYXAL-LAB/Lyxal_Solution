//! Tests d'intégration de `lyxal_i18n` sur le moteur SurrealDB embarqué : chaque appel typé de
//! `I18nStore` désérialise le résultat de sa fonction SurrealQL (session système) ; `Translator`
//! et sonde de santé.

mod store;
mod support;
mod translator;
