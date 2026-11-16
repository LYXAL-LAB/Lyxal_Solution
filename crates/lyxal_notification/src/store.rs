//! Accès aux fonctions SurrealQL de `lyxal_notification` : un appel typé d'une ligne par fonction
//! (`LyxalSurrealCall::call_fn`). Les règles restent dans SurrealQL ; la session SurrealDB du
//! client détermine l'appelant (session système de l'hôte, compte du worker, ou personne
//! connectée pour ses propres préférences).

use async_trait::async_trait;
use lyxal_surreal::{LyxalSurrealCall, LyxalSurrealError, SurrealValue};
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

use crate::models::{
    BroadcastClaim, BroadcastClaimParams, BroadcastCompleteParams, BroadcastCompleted,
    BroadcastStep, BroadcastStepParams, CancelParams, CancelResult, Category, CategoryRefParams,
    CategorySaveParams, ClaimedJob, Deleted, JobClaimParams, JobCompleteParams, JobCompleted,
    JobFailParams, JobFailed, JobReleaseParams, JobReleased, JobRenewParams, JobRenewed,
    MyPreferenceGetParams, MyPreferenceSetParams, Preference, PreferenceGetParams,
    PreferenceOverview, PreferenceSetParams, PurgeParams, PurgeResult, ScopeParams, Settings,
    SettingsGetParams, StepPreviewParams, StepPreviewResult, Subscriber, SubscriberImportParams,
    SubscriberImportResult, SubscriberListParams, SubscriberRefParams, SubscriberUpsertParams,
    SubscriberUpsertResult, TestSendParams, Topic, TopicListParams, TopicMember,
    TopicMembersParams, TopicRefParams, TopicSaveParams, TopicSubscribeParams, TopicSubscribed,
    TopicUnsubscribeParams, TopicUnsubscribed, TriggerBulkParams, TriggerBulkResult, TriggerParams,
    TriggerResult, UnsubscribeParams, Unsubscribed, WaitScheduleParams, WaitScheduleResult,
};

/// Store de `lyxal_notification` sur un client SurrealDB (`Surreal<Any>`).
#[derive(Clone)]
pub struct NotificationStore {
    db: Surreal<Any>,
}

#[async_trait]
impl LyxalSurrealCall for NotificationStore {
    fn surreal_client(&self) -> &Surreal<Any> {
        &self.db
    }
}

/// Rejeux d'un appel du worker après un conflit d'écriture transitoire.
const CONFLICT_RETRIES: u32 = 12;

impl NotificationStore {
    /// Store sur un client déjà connecté (espace de noms et base choisis).
    pub fn new(db: Surreal<Any>) -> Self {
        Self { db }
    }

    /// Appel d'une fonction des workers, rejoué après un conflit d'écriture transitoire de
    /// SurrealDB (contrôle de concurrence optimiste : la transaction n'a pas été validée, le
    /// rejeu est sûr). L'issue d'un envoi doit être enregistrée même quand un déclenchement ou
    /// un autre worker écrit au même moment : sinon la réservation expirerait et le message
    /// repartirait. Toute autre erreur est rendue telle quelle.
    async fn worker_call<T, P>(&self, function: &str, params: P) -> Result<T, LyxalSurrealError>
    where
        T: SurrealValue + Send,
        P: SurrealValue + Clone + Send + 'static,
    {
        let mut attempt = 0;
        loop {
            match self.call_fn(function, params.clone()).await {
                Err(error) if error.is_transient_conflict() && attempt < CONFLICT_RETRIES => {
                    attempt += 1;
                    // Attente croissante (10 ms à 200 ms) tirée au hasard : deux transactions en
                    // conflit ne se rejouent pas en même temps
                    let ceiling = (5u64 << attempt).min(200);
                    let pause = ceiling / 2 + fastrand::u64(0..=ceiling / 2);
                    tokio::time::sleep(std::time::Duration::from_millis(pause)).await;
                }
                other => return other,
            }
        }
    }

    /// Client SurrealDB sous-jacent.
    pub fn client(&self) -> &Surreal<Any> {
        &self.db
    }

    /// `fn::notification_trigger` : déclenchement idempotent (abonné, liste, sujet ou tous).
    pub async fn trigger(&self, params: TriggerParams) -> Result<TriggerResult, LyxalSurrealError> {
        self.call_fn("notification_trigger", params).await
    }

    /// `fn::notification_trigger_bulk` : 1 à 100 déclenchements, rapport par entrée.
    pub async fn trigger_bulk(
        &self,
        params: TriggerBulkParams,
    ) -> Result<TriggerBulkResult, LyxalSurrealError> {
        self.call_fn("notification_trigger_bulk", params).await
    }

    /// `fn::notification_cancel` : annulation des déclenchements en cours d'une clé.
    pub async fn cancel(&self, params: CancelParams) -> Result<CancelResult, LyxalSurrealError> {
        self.call_fn("notification_cancel", params).await
    }

    /// `fn::notification_test_send` : envoi de test d'un parcours à un abonné.
    pub async fn test_send(
        &self,
        params: TestSendParams,
    ) -> Result<TriggerResult, LyxalSurrealError> {
        self.call_fn("notification_test_send", params).await
    }

    /// `fn::notification_step_preview` : données de l'aperçu d'une étape (sans écriture).
    pub async fn step_preview(
        &self,
        params: StepPreviewParams,
    ) -> Result<StepPreviewResult, LyxalSurrealError> {
        self.call_fn("notification_step_preview", params).await
    }

    /// `fn::notification_wait_schedule` : attentes confiées au planificateur (rejoué après un
    /// conflit d'écriture transitoire).
    pub async fn wait_schedule(
        &self,
        params: WaitScheduleParams,
    ) -> Result<WaitScheduleResult, LyxalSurrealError> {
        self.worker_call("notification_wait_schedule", params).await
    }

    // ------------------------------------------------------------------------------------------
    // Abonnés
    // ------------------------------------------------------------------------------------------

    /// `fn::notification_subscriber_upsert` : création ou mise à jour d'un abonné.
    pub async fn subscriber_upsert(
        &self,
        params: SubscriberUpsertParams,
    ) -> Result<SubscriberUpsertResult, LyxalSurrealError> {
        self.call_fn("notification_subscriber_upsert", params).await
    }

    /// `fn::notification_subscriber_get` : abonné et ses sujets.
    pub async fn subscriber_get(
        &self,
        params: SubscriberRefParams,
    ) -> Result<Subscriber, LyxalSurrealError> {
        self.call_fn("notification_subscriber_get", params).await
    }

    /// `fn::notification_subscriber_list` : abonnés d'une portée, avec recherche.
    pub async fn subscriber_list(
        &self,
        params: SubscriberListParams,
    ) -> Result<Vec<Subscriber>, LyxalSurrealError> {
        self.call_fn("notification_subscriber_list", params).await
    }

    /// `fn::notification_subscriber_delete` : abonné supprimé avec ses préférences et abonnements.
    pub async fn subscriber_delete(
        &self,
        params: SubscriberRefParams,
    ) -> Result<Deleted, LyxalSurrealError> {
        self.call_fn("notification_subscriber_delete", params).await
    }

    /// `fn::notification_subscriber_import` : import de 500 abonnés au plus.
    pub async fn subscriber_import(
        &self,
        params: SubscriberImportParams,
    ) -> Result<SubscriberImportResult, LyxalSurrealError> {
        self.call_fn("notification_subscriber_import", params).await
    }

    // ------------------------------------------------------------------------------------------
    // Sujets
    // ------------------------------------------------------------------------------------------

    /// `fn::notification_topic_create`.
    pub async fn topic_create(&self, params: TopicSaveParams) -> Result<Topic, LyxalSurrealError> {
        self.call_fn("notification_topic_create", params).await
    }

    /// `fn::notification_topic_update`.
    pub async fn topic_update(&self, params: TopicSaveParams) -> Result<Topic, LyxalSurrealError> {
        self.call_fn("notification_topic_update", params).await
    }

    /// `fn::notification_topic_get` : sujet et nombre d'abonnés.
    pub async fn topic_get(&self, params: TopicRefParams) -> Result<Topic, LyxalSurrealError> {
        self.call_fn("notification_topic_get", params).await
    }

    /// `fn::notification_topic_list`.
    pub async fn topic_list(
        &self,
        params: TopicListParams,
    ) -> Result<Vec<Topic>, LyxalSurrealError> {
        self.call_fn("notification_topic_list", params).await
    }

    /// `fn::notification_topic_delete` : sujet supprimé avec ses abonnements.
    pub async fn topic_delete(&self, params: TopicRefParams) -> Result<Deleted, LyxalSurrealError> {
        self.call_fn("notification_topic_delete", params).await
    }

    /// `fn::notification_topic_subscribe` : abonnements, condition facultative.
    pub async fn topic_subscribe(
        &self,
        params: TopicSubscribeParams,
    ) -> Result<TopicSubscribed, LyxalSurrealError> {
        self.call_fn("notification_topic_subscribe", params).await
    }

    /// `fn::notification_topic_unsubscribe`.
    pub async fn topic_unsubscribe(
        &self,
        params: TopicUnsubscribeParams,
    ) -> Result<TopicUnsubscribed, LyxalSurrealError> {
        self.call_fn("notification_topic_unsubscribe", params).await
    }

    /// `fn::notification_topic_members`.
    pub async fn topic_members(
        &self,
        params: TopicMembersParams,
    ) -> Result<Vec<TopicMember>, LyxalSurrealError> {
        self.call_fn("notification_topic_members", params).await
    }

    // ------------------------------------------------------------------------------------------
    // Catégories
    // ------------------------------------------------------------------------------------------

    /// `fn::notification_category_create`.
    pub async fn category_create(
        &self,
        params: CategorySaveParams,
    ) -> Result<Category, LyxalSurrealError> {
        self.call_fn("notification_category_create", params).await
    }

    /// `fn::notification_category_update`.
    pub async fn category_update(
        &self,
        params: CategorySaveParams,
    ) -> Result<Category, LyxalSurrealError> {
        self.call_fn("notification_category_update", params).await
    }

    /// `fn::notification_category_list` : catégories de la portée et de l'installation.
    pub async fn category_list(
        &self,
        params: ScopeParams,
    ) -> Result<Vec<Category>, LyxalSurrealError> {
        self.call_fn("notification_category_list", params).await
    }

    /// `fn::notification_category_delete` : refusée si un parcours l'utilise.
    pub async fn category_delete(
        &self,
        params: CategoryRefParams,
    ) -> Result<Deleted, LyxalSurrealError> {
        self.call_fn("notification_category_delete", params).await
    }

    // ------------------------------------------------------------------------------------------
    // Préférences et désabonnement
    // ------------------------------------------------------------------------------------------

    /// `fn::notification_preference_get` : préférences par niveau et résultat calculé.
    pub async fn preference_get(
        &self,
        params: PreferenceGetParams,
    ) -> Result<PreferenceOverview, LyxalSurrealError> {
        self.call_fn("notification_preference_get", params).await
    }

    /// `fn::notification_preference_set` : préférence de l'organisation ou d'un abonné.
    pub async fn preference_set(
        &self,
        params: PreferenceSetParams,
    ) -> Result<Preference, LyxalSurrealError> {
        self.call_fn("notification_preference_set", params).await
    }

    /// `fn::notification_my_preference_get` : préférences de la personne connectée.
    pub async fn my_preference_get(
        &self,
        params: MyPreferenceGetParams,
    ) -> Result<PreferenceOverview, LyxalSurrealError> {
        self.call_fn("notification_my_preference_get", params).await
    }

    /// `fn::notification_my_preference_set` : préférence de la personne connectée.
    pub async fn my_preference_set(
        &self,
        params: MyPreferenceSetParams,
    ) -> Result<Preference, LyxalSurrealError> {
        self.call_fn("notification_my_preference_set", params).await
    }

    /// `fn::notification_unsubscribe` : désabonnement d'un lien vérifié par l'hôte.
    pub async fn unsubscribe(
        &self,
        params: UnsubscribeParams,
    ) -> Result<Unsubscribed, LyxalSurrealError> {
        self.call_fn("notification_unsubscribe", params).await
    }

    // ------------------------------------------------------------------------------------------
    // Diffusions (worker)
    // ------------------------------------------------------------------------------------------

    /// `fn::notification_broadcast_claim` : réservation d'une diffusion (aucune : `None`).
    pub async fn broadcast_claim(
        &self,
        params: BroadcastClaimParams,
    ) -> Result<Option<BroadcastClaim>, LyxalSurrealError> {
        self.call_fn("notification_broadcast_claim", params).await
    }

    /// `fn::notification_broadcast_step` : paquet suivant d'une diffusion réservée.
    pub async fn broadcast_step(
        &self,
        params: BroadcastStepParams,
    ) -> Result<BroadcastStep, LyxalSurrealError> {
        self.call_fn("notification_broadcast_step", params).await
    }

    /// `fn::notification_broadcast_complete` : diffusion terminée.
    pub async fn broadcast_complete(
        &self,
        params: BroadcastCompleteParams,
    ) -> Result<BroadcastCompleted, LyxalSurrealError> {
        self.call_fn("notification_broadcast_complete", params)
            .await
    }

    // ------------------------------------------------------------------------------------------
    // File d'envoi (worker)
    // ------------------------------------------------------------------------------------------

    /// `fn::notification_job_claim` : réservation des étapes dues.
    pub async fn job_claim(
        &self,
        params: JobClaimParams,
    ) -> Result<Vec<ClaimedJob>, LyxalSurrealError> {
        self.call_fn("notification_job_claim", params).await
    }

    /// `fn::notification_job_renew` : réservation renouvelée avant l'envoi.
    pub async fn job_renew(&self, params: JobRenewParams) -> Result<JobRenewed, LyxalSurrealError> {
        self.call_fn("notification_job_renew", params).await
    }

    /// `fn::notification_job_release` : étape rendue à la file sans tentative (arrêt, heures
    /// calmes).
    pub async fn job_release(
        &self,
        params: JobReleaseParams,
    ) -> Result<JobReleased, LyxalSurrealError> {
        self.call_fn("notification_job_release", params).await
    }

    /// `fn::notification_job_complete` : étape envoyée, étape suivante engagée (rejoué après un
    /// conflit d'écriture transitoire).
    pub async fn job_complete(
        &self,
        params: JobCompleteParams,
    ) -> Result<JobCompleted, LyxalSurrealError> {
        self.worker_call("notification_job_complete", params).await
    }

    /// `fn::notification_job_fail` : échec d'envoi (rejoué après un conflit d'écriture
    /// transitoire).
    pub async fn job_fail(&self, params: JobFailParams) -> Result<JobFailed, LyxalSurrealError> {
        self.worker_call("notification_job_fail", params).await
    }

    /// `fn::notification_purge` : purge par paquets (appelée d'ordinaire par le planificateur,
    /// tâche `notification.purge`).
    pub async fn purge(&self, params: PurgeParams) -> Result<PurgeResult, LyxalSurrealError> {
        self.call_fn("notification_purge", params).await
    }

    /// `fn::notification_settings_get` : réglages effectifs.
    pub async fn settings_get(
        &self,
        params: SettingsGetParams,
    ) -> Result<Settings, LyxalSurrealError> {
        self.call_fn("notification_settings_get", params).await
    }
}
