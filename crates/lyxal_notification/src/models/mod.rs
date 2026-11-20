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
    ClaimedEndpoint, Device, DeviceListParams, DeviceRegisterParams, DeviceRegistered,
    DeviceRemoveParams, DeviceRemoved, DeviceSummary, Endpoint, EndpointCreateParams,
    EndpointListParams, EndpointOutcome, EndpointRefParams, EndpointResolveParams, EndpointResult,
    EndpointRotateParams, EndpointUpdateParams, MyDeviceListParams, MyEndpointCreateParams,
    MyEndpointListParams, PushLinksChecked, PushLinksParams, VapidKey, VapidKeyParams,
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

#[cfg(test)]
mod tests {
    use super::*;
    use crate::consumer::SecurityAlertPayload;

    /// Les `Debug` des paramètres et charges portant une adresse, une donnée personnelle ou une
    /// valeur scellée ne la montrent jamais.
    #[test]
    fn debug_never_shows_addresses_or_personal_data() {
        let hidden = [
            "https://hooks.slack.com/services/T0/B0/secret",
            "enc:v2:cle:scelle",
            "claire@exemple.fr",
            "+33612345678",
            "Claire",
            "Dupont",
            "-100123",
        ];
        let endpoint = EndpointCreateParams {
            tenant: Some("auth_organization:alpha".into()),
            subscriber_id: "c1".into(),
            endpoint: None,
            channel: "chat".into(),
            provider: "slack".into(),
            name: "Équipe".into(),
            url: Some(hidden[0].into()),
            sealed_url: Some(hidden[1].into()),
            signing_secret: Some(hidden[1].into()),
            chat_id: Some(hidden[6].into()),
            active: None,
        };
        let mine = MyEndpointCreateParams {
            tenant: None,
            endpoint: None,
            channel: "chat".into(),
            provider: "slack".into(),
            name: "Équipe".into(),
            url: Some(hidden[0].into()),
            sealed_url: Some(hidden[1].into()),
            signing_secret: Some(hidden[1].into()),
            chat_id: Some(hidden[6].into()),
            active: None,
        };
        let rotate = EndpointRotateParams {
            tenant: None,
            endpoint: "notification_endpoint:a".into(),
            signing_secret: hidden[1].into(),
        };
        let subscriber = SubscriberUpsertParams {
            tenant: None,
            subscriber_id: "c1".into(),
            email: Some(hidden[2].into()),
            phone: Some(hidden[3].into()),
            first_name: Some(hidden[4].into()),
            last_name: Some(hidden[5].into()),
            locale: Some("fr".into()),
            timezone: None,
            data: None,
            identity: None,
        };
        let test = IntegrationTestParams {
            integration: "notification_integration:a".into(),
            to: hidden[2].into(),
        };
        let alert = SecurityAlertPayload {
            identity_id: "auth_identity:a".into(),
            recipient_email: Some(hidden[2].into()),
            recipient_locale: Some("fr".into()),
            recipient_name: Some(hidden[4].into()),
            method: None,
            label: None,
            name: None,
            reason: None,
            remaining: None,
            first: None,
        };
        for text in [
            format!("{endpoint:?}"),
            format!("{mine:?}"),
            format!("{rotate:?}"),
            format!("{subscriber:?}"),
            format!("{test:?}"),
            format!("{alert:?}"),
        ] {
            assert!(text.contains("[REDACTED]") || text.contains(".."), "{text}");
            for value in hidden {
                assert!(!text.contains(value), "{text}");
            }
        }
    }
}
