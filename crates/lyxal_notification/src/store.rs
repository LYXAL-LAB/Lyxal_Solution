//! Accès aux fonctions SurrealQL de `lyxal_notification` : un appel typé d'une ligne par fonction
//! (`LyxalSurrealCall::call_fn`). Les règles restent dans SurrealQL ; la session SurrealDB du
//! client détermine l'appelant (session système de l'hôte, ou compte du worker).

use async_trait::async_trait;
use lyxal_surreal::{LyxalSurrealCall, LyxalSurrealError};
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

use crate::models::{
    ClaimedJob, JobClaimParams, JobCompleteParams, JobCompleted, JobFailParams, JobFailed,
    PurgeParams, PurgeResult, Settings, SettingsGetParams, TriggerParams, TriggerResult,
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

impl NotificationStore {
    /// Store sur un client déjà connecté (espace de noms et base choisis).
    pub fn new(db: Surreal<Any>) -> Self {
        Self { db }
    }

    /// Client SurrealDB sous-jacent.
    pub fn client(&self) -> &Surreal<Any> {
        &self.db
    }

    /// `fn::notification_trigger` : déclenchement idempotent.
    pub async fn trigger(&self, params: TriggerParams) -> Result<TriggerResult, LyxalSurrealError> {
        self.call_fn("notification_trigger", params).await
    }

    /// `fn::notification_job_claim` : réservation des étapes dues.
    pub async fn job_claim(
        &self,
        params: JobClaimParams,
    ) -> Result<Vec<ClaimedJob>, LyxalSurrealError> {
        self.call_fn("notification_job_claim", params).await
    }

    /// `fn::notification_job_complete` : étape envoyée.
    pub async fn job_complete(
        &self,
        params: JobCompleteParams,
    ) -> Result<JobCompleted, LyxalSurrealError> {
        self.call_fn("notification_job_complete", params).await
    }

    /// `fn::notification_job_fail` : échec d'envoi.
    pub async fn job_fail(&self, params: JobFailParams) -> Result<JobFailed, LyxalSurrealError> {
        self.call_fn("notification_job_fail", params).await
    }

    /// `fn::notification_purge` : purge par paquets.
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
