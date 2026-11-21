#![forbid(unsafe_code)]
#![deny(missing_docs)]
//! `lyxal_scheduler` : planificateur de Lyxal OS, partie Rust.
//!
//! Les règles (tâches, files, calendriers, planifications, exécutions, droits, chevauchement,
//! rattrapage) vivent dans les fonctions SurrealQL `fn::scheduler_*` (installées par
//! `lyxal_runtime` depuis `manifest.toml`) ; ce crate fournit les appels typés de chacune
//! (`SchedulerStore`), le calcul des dates que SurrealDB ne sait pas faire (`spec` : expressions
//! cron, intervalles, date unique, fuseaux et changements d'heure, exclusions, calendriers,
//! bornes, décalage aléatoire, prévision), le contrôle des planifications avant écriture
//! (`SchedulerService`) et le moteur (`engine`) : planificateur élu sous bail, exécuteurs par
//! file, handlers Rust inscrits par les modules (`TaskHandler`), façade `SchedulerClient`, module
//! `LyxalModule`, sonde de santé et forme texte des identifiants d'exécution (`RunRef`).

// `LyxalSurrealError` (erreur commune de `lyxal_surreal`, 272 octets) est rendue par les
// fonctions de ce crate ; Clippy de Rust 1.98 les signale (`result_large_err`), 1.97 ne le
// faisait pas. Même règle que `lyxal_surreal` et `lyxal_error` : réduire cette erreur serait un
// changement de contrat.
#![allow(clippy::result_large_err)]

pub mod client;
pub mod engine;
pub mod error;
pub mod handler;
pub mod health;
pub mod models;
pub mod module;
pub mod run_ref;
pub mod service;
pub mod spec;
pub mod store;

pub use client::SchedulerClient;
pub use engine::{
    ExecutorSet, ExecutorTiming, LeaderReport, LeaderTiming, SchedulerEngine,
    SchedulerExecutorWorker, SchedulerLeaderWorker, DEFAULT_WORKERS, LEADER_KEY, MAX_WORKERS,
};
pub use error::{SchedulerError, SchedulerResult, SpecError, SpecReason};
pub use handler::{HandlerRegistry, RunContext, TaskFailure, TaskHandler, TaskOutput};
pub use health::SchedulerHealthCheck;
pub use module::{SchedulerModule, MODULE_ID};
pub use run_ref::RunRef;
pub use service::{ForecastEntry, SchedulerService};
pub use spec::{CalendarSet, FireTimes, Spec};
pub use store::SchedulerStore;
