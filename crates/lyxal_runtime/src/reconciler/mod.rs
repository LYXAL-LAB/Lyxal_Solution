//! # Module Reconciler (DRA Core)
//!
//! Moteur déclaratif de réconciliation (Declarative Runtime Architecture) de Lyxal OS.
//!
//! Fournit les abstractions et l'orchestration permettant de faire converger
//! l'état réel du Runtime vers un état cible désiré :
//! - [`DesiredRuntimeState`], [`DesiredModuleState`], [`ModuleTargetState`]
//! - [`ActualRuntimeState`], [`ObservedModuleState`]
//! - [`RuntimeObserver`]
//! - [`RuntimeDiffer`]
//! - [`ReconciliationPlan`], [`ReconciliationAction`], [`ReconciliationBlocker`]
//! - [`RuntimeReconciler`]
//! - [`ReconciliationReport`], [`ConvergenceStatus`]

pub mod actual;
pub mod desired;
pub mod differ;
pub mod observer;
pub mod plan;
#[allow(clippy::module_inception)]
pub mod reconciler;
pub mod report;

pub use actual::{ActualRuntimeState, ObservedModuleState};
pub use desired::{DesiredModuleState, DesiredRuntimeState, DesiredStateOrigin, ModuleTargetState};
pub use differ::RuntimeDiffer;
pub use observer::RuntimeObserver;
pub use plan::{
    ActionKind, ActionPrecondition, BlockerKind, ReconciliationAction, ReconciliationBlocker,
    ReconciliationPlan, ReconciliationReason,
};
pub use reconciler::RuntimeReconciler;
pub use report::{
    ActionOutcome, ConvergenceStatus, DriftItem, NotAttemptedAction, ReconciliationActionFailure,
    ReconciliationReport, SkippedRevalidationAction, SkippedRevalidationReason,
};
