//! Contrats publics des fonctions SurrealQL `fn::notification_*` appelées par le Rust :
//! paramètres (`XxxParams`) et résultats. Les fonctions de gestion (parcours, gabarits, mises en
//! page, liste de suppression) sont appelées directement par la console.

mod queue;
mod trigger;
mod types;

pub use queue::{
    ClaimedJob, EffectiveSettings, FailureClass, JobClaimParams, JobCompleteParams, JobCompleted,
    JobFailParams, JobFailed, PurgeParams, PurgeResult, Settings, SettingsGetParams,
};
pub use trigger::{Recipient, TriggerParams, TriggerResult, TriggerStatus};
pub use types::{NotificationDatetime, NotificationRecordId};
