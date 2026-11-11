//! Contrats publics des fonctions SurrealQL `fn::storage_*` : paramètres (`XxxParams`) et
//! résultats. Les identifiants transmis sont des textes `table:clé` (règle `record` de
//! `lyxal_core`).

mod bucket;
mod object;
mod settings;
mod types;
mod worker;

pub use bucket::{
    Bucket, BucketCreateParams, BucketDeleted, BucketDetails, BucketList, BucketListParams,
    BucketRefParams, BucketUpdateParams, BucketUsage,
};
pub use object::{
    BegunObject, ObjectBeginParams, ObjectCommitParams, ObjectGetParams, ObjectList,
    ObjectListParams, ObjectRefParams, ObjectState, ObjectUsageParams, ScopeUsage, StoredObject,
};
pub use settings::{
    EffectiveSettings, SettingsGetParams, SettingsSetParams, SettingsView, StoredSettings,
};
pub use types::{StorageDatetime, StorageRecordId};
pub use worker::{
    BatchParams, Expired, PurgeItem, PurgeList, Purged, QuarantineParams, ReclaimDone,
    ReclaimDoneParams, ReclaimItem, ReclaimList,
};
