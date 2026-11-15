#![forbid(unsafe_code)]
#![deny(missing_docs)]
//! `lyxal_scheduler` : planificateur de Lyxal OS, partie Rust.
//!
//! Les règles (tâches, files, calendriers, planifications, exécutions, droits, chevauchement,
//! rattrapage) vivent dans les fonctions SurrealQL `fn::scheduler_*` (installées par
//! `lyxal_runtime` depuis `manifest.toml`) ; ce crate fournit les appels typés de chacune
//! (`SchedulerStore`), le calcul des dates que SurrealDB ne sait pas faire (`spec` : expressions
//! cron, intervalles, date unique, fuseaux et changements d'heure, exclusions, calendriers,
//! bornes, décalage aléatoire, prévision) et le contrôle des planifications avant écriture
//! (`SchedulerService`).

pub mod error;
pub mod models;
pub mod service;
pub mod spec;
pub mod store;

pub use error::{SchedulerError, SchedulerResult, SpecError, SpecReason};
pub use service::{ForecastEntry, SchedulerService};
pub use spec::{CalendarSet, FireTimes, Spec};
pub use store::SchedulerStore;
