//! Contrats des fonctions SurrealQL `fn::secrets_*` : paramètres (`XxxParams`) et résultats.
//! Les identifiants transmis sont des textes `table:clé` (règle `record` de `lyxal_core`).
//! Enveloppes et clés scellées restent dans des types internes au crate (`pub(crate)`), sans
//! `Serialize` et au `Debug` masqué.

mod audit;
mod caller;
mod keys;
mod read;
mod rotation;
mod secret;
mod settings;
mod types;
mod version;
mod worker;

pub use audit::{
    AuditDenied, AuditDeniedParams, AuditItem, AuditList, AuditListParams, AuditReport,
    AuditVerifyParams,
};
pub use caller::{CallerContext, CallerContextParams};
pub(crate) use keys::{
    RewrapKey, RewrapList, RewrapVersion, TenantKeyCreateParams, TenantKeyRewrapParams,
    TenantKeyRing,
};
pub use keys::{
    RewrapListParams, RotateAllowed, TenantKeyCreated, TenantKeyDestroyParams, TenantKeyDestroyed,
    TenantKeyRewrapped, TenantKeyState, TenantRef,
};
pub(crate) use read::ReadEnvelope;
pub use read::{ReadBeginParams, ReadTicket, ReadTicketRef};
pub use rotation::{
    DueKind, DueList, DueListParams, DueMarkParams, DueMarkResult, DueRotation, DueSecret,
    DueTenantKey, RotationBeginParams, RotationCheckParams, RotationCheckResult,
    RotationClaimParams, RotationClaimed, RotationFailParams, RotationGetParams, RotationList,
    RotationRecord, RotationRefParams, RotationState, RotationStep, RotationStepParams,
};
pub use secret::{
    SecretCreateParams, SecretGetParams, SecretList, SecretListParams, SecretPurged, SecretRecord,
    SecretRefParams, SecretState, SecretUpdateParams,
};
pub use settings::{
    EffectiveSettings, SettingsGetParams, SettingsSetParams, SettingsView, StoredSettings,
};
pub use types::{SecretsDatetime, SecretsDuration, SecretsRecordId, SecretsValue};
pub use version::{
    LabelsResult, Resealed, SecretVersion, Stage, VersionAdded, VersionLabelParams, VersionList,
    VersionListParams, VersionRefParams, VersionState, VersionSummary,
};
pub(crate) use version::{VersionAddParams, VersionResealParams};
pub use worker::{PurgeDueParams, PurgeReport};
