//! Contrats publics des fonctions SurrealQL `fn::notification_*` : paramètres (`XxxParams`) et
//! résultats. Les fonctions de gestion des parcours, gabarits et mises en page sont appelées
//! directement par la console ; la forme de leurs étapes est décrite par `WorkflowStep`.

mod broadcast;
mod endpoint;
mod feed;
mod integration;
mod preference;
mod queue;
mod subscriber;
mod topic;
mod trigger;
mod types;
mod workflow;

pub use broadcast::{
    BroadcastClaim, BroadcastClaimParams, BroadcastCompleteParams, BroadcastCompleted,
    BroadcastStep, BroadcastStepParams,
};
pub use endpoint::{
    ClaimedEndpoint, Endpoint, EndpointCreateParams, EndpointListParams, EndpointOutcome,
    EndpointRefParams, EndpointResolveParams, EndpointResult, EndpointRotateParams,
    EndpointUpdateParams, MyEndpointCreateParams, MyEndpointListParams,
};
pub use feed::{
    FeedActionParams, FeedCounts, FeedCountsParams, FeedDeleteParams, FeedDeleted, FeedFilter,
    FeedItem, FeedItemAction, FeedItemRefParams, FeedListParams, FeedMarkParams, FeedMarked,
    FeedPage, FeedSnoozeParams, InboxAction, InboxDeliverParams, InboxDelivered, TemplateAction,
};
pub use integration::{
    ClaimedIntegration, Integration, IntegrationGetParams, IntegrationListParams,
    IntegrationRefParams, IntegrationSaveParams, IntegrationSelectParams, IntegrationSettings,
    IntegrationTestParams, IntegrationTestRecordParams, IntegrationTestResult,
    IntegrationTestTarget, ProviderEventParams, ProviderEventRecorded,
};
pub use preference::{
    ChannelDecision, ChannelDecisions, Channels, GlobalPreference, MyPreferenceGetParams,
    MyPreferenceSetParams, Preference, PreferenceGetParams, PreferenceOverview,
    PreferenceSetParams, QuietHours, QuietHoursRule, QuietRange, ResolvedPreferences,
    TargetPreference, UnsubscribeParams, Unsubscribed,
};
pub use queue::{
    ClaimedJob, EffectiveSettings, FailureClass, JobClaimParams, JobCompleteParams, JobCompleted,
    JobFailParams, JobFailed, JobReleaseParams, JobReleased, JobRenewParams, JobRenewed, PurgeArgs,
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
pub use workflow::{
    BulkEntry, BulkError, CancelParams, CancelResult, DigestVars, SpanUnit, StepOverride,
    StepPreviewParams, StepPreviewResult, StepSpan, TestSendParams, TriggerBulkParams,
    TriggerBulkResult, TriggerOverrides, WaitScheduleParams, WaitScheduleResult, WorkflowStep,
};
