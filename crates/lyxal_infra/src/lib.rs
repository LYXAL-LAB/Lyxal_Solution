#![forbid(unsafe_code)]
#![deny(missing_docs)]
//! `lyxal_infra` : pilotage de l'hébergeur par API (Scaleway en premier) — comptes, zones DNS,
//! état désiré déclaré par les modules, réconciliation sans jamais toucher ce qu'un humain a
//! créé, journal chaîné, vérification de la publication.
//!
//! Les règles vivent dans les fonctions SurrealQL `fn::infra_*` (installées par `lyxal_runtime`
//! depuis `manifest.toml`) ; ce crate fournit leurs appels typés ([`InfraStore`]) et leurs
//! contrats ([`models`]). Les fournisseurs, le client HTTP, la passe de réconciliation, la
//! vérification DNS, les tâches du planificateur et la sonde de santé arrivent au lot 1b
//! (`ROADMAP.md`).

// `LyxalSurrealError` (erreur commune de `lyxal_surreal`) est rendue par les fonctions de ce
// crate ; même règle que `lyxal_storage` : réduire cette erreur serait un changement de contrat.
#![allow(clippy::result_large_err)]

pub mod models;
pub mod store;

pub use store::InfraStore;

/// Identifiant du module (égal à `id` de `manifest.toml`).
pub const MODULE_ID: &str = "lyxal_infra";
