//! Contrats publics des fonctions SurrealQL `fn::notification_*` : paramètres (`XxxParams`) et
//! résultats. Les fonctions de gestion des parcours, gabarits et mises en page sont appelées
//! directement par la console.

mod broadcast;
mod preference;
mod queue;
mod subscriber;
mod topic;
mod trigger;
mod types;

pub use broadcast::{
    BroadcastClaim, BroadcastClaimParams, BroadcastCompleteParams, BroadcastCompleted,
    BroadcastStep, BroadcastStepParams,
};
pub use preference::{
    ChannelDecision, ChannelDecisions, Channels, GlobalPreference, MyPreferenceGetParams,
    MyPreferenceSetParams, Preference, PreferenceGetParams, PreferenceOverview,
    PreferenceSetParams, QuietHours, QuietHoursRule, QuietRange, ResolvedPreferences,
    TargetPreference, UnsubscribeParams, Unsubscribed,
};
pub use queue::{
    ClaimedJob, EffectiveSettings, FailureClass, JobClaimParams, JobCompleteParams, JobCompleted,
    JobFailParams, JobFailed, JobReleaseParams, JobReleased, JobRenewParams, JobRenewed,
    PurgeParams, PurgeResult, Settings, SettingsGetParams, UnsubscribeTarget,
};
pub use subscriber::{
    Deleted, ImportRejection, Subscriber, SubscriberImportParams, SubscriberImportResult,
    SubscriberInput, SubscriberListParams, SubscriberRefParams, SubscriberUpsertParams,
    SubscriberUpsertResult,
};
pub use topic::{
    Category, CategoryRefParams, CategorySaveParams, ScopeParams, Topic, TopicListParams,
    TopicMember, TopicMembersParams, TopicRefParams, TopicSaveParams, TopicSubscribeParams,
    TopicSubscribed, TopicUnsubscribeParams, TopicUnsubscribed,
};
pub use trigger::{
    ListRun, Recipient, TriggerKind, TriggerParams, TriggerResult, TriggerStatus, TriggerTarget,
};
pub use types::{NotificationDatetime, NotificationRecordId};
