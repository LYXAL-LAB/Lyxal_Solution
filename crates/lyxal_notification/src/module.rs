//! Module `lyxal_notification` pour `lyxal_runtime` et sonde de santé.

use async_trait::async_trait;
use lyxal_runtime::descriptor::{ModuleDescriptor, ModuleDescriptorBuilder};
use lyxal_runtime::health::{HealthCheckResult, ModuleHealthCheck};
use lyxal_runtime::types::ModuleId;
use lyxal_runtime::{LyxalModule, ModuleContext, RuntimeError};
use lyxal_scheduler::models::{Overlap, ScheduleCreateParams, ScheduleSpec};
use lyxal_scheduler::{SchedulerClient, SchedulerResult, SchedulerStore};
use std::sync::Arc;
use std::time::Instant;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

use crate::models::SettingsGetParams;
use crate::smtp::EmailTransport;
use crate::store::NotificationStore;

/// Identifiant du module.
pub const MODULE_ID: &str = "lyxal_notification";

/// Nom de la planification horaire de la purge (un nom de planification est un slug).
pub const PURGE_SCHEDULE: &str = "notification-purge";
/// Tâche `lyxal_scheduler` de la purge, déclarée par le seed du module.
pub const PURGE_TASK: &str = "notification.purge";

/// Crée la planification horaire de la purge (`notification-purge`, tâche
/// `notification.purge`, à la minute 0 de chaque heure, décalage aléatoire de 5 min au plus)
/// si elle n'existe pas déjà : `true` si elle vient d'être créée. Appel au nom de la session du
/// client (la session système de l'hôte à l'installation).
pub async fn ensure_purge_schedule(client: &SchedulerClient) -> SchedulerResult<bool> {
    let mut spec = ScheduleSpec::new("UTC");
    spec.cron = vec!["0 * * * *".to_string()];
    spec.jitter = Some(std::time::Duration::from_secs(300).into());
    let mut params = ScheduleCreateParams::new(PURGE_SCHEDULE, PURGE_TASK, spec);
    params.overlap = Some(Overlap::Skip);
    match client.schedule(params).await {
        Ok(_) => Ok(true),
        Err(error) if error.is_code("SCHEDULER_SCHEDULE_EXISTS") => Ok(false),
        Err(error) => Err(error),
    }
}

/// Module `lyxal_notification` : ses ressources SurrealQL sont installées par le runtime depuis le
/// manifeste ; son installation crée la planification de la purge ; consommateur, workers et
/// sonde sont enregistrés par l'hôte.
pub struct NotificationModule {
    descriptor: ModuleDescriptor,
    client: Surreal<Any>,
}

impl NotificationModule {
    /// Descripteur conforme au manifeste ; `client` : session système de l'hôte (création de la
    /// planification de la purge à l'installation).
    pub fn new(client: Surreal<Any>) -> Self {
        let descriptor = ModuleDescriptorBuilder::new(ModuleId::new(MODULE_ID), "0.1.0")
            .name("Lyxal Notification")
            .description(
                "Notifications sortantes de Lyxal OS : abonnés, sujets, préférences, parcours à étapes (attente, regroupement, limitation, conditions), gabarits, file d'envoi e-mail, diffusions, journal et liste de suppression",
            )
            .capability("database")
            .capability("events")
            .capability("email")
            .dependency(ModuleId::new("lyxal_core"))
            .dependency(ModuleId::new("lyxal_error"))
            .dependency(ModuleId::new("lyxal_event"))
            .dependency(ModuleId::new("lyxal_auth"))
            .dependency(ModuleId::new("lyxal_i18n"))
            .dependency(ModuleId::new("lyxal_scheduler"))
            .build();
        Self { descriptor, client }
    }
}

#[async_trait]
impl LyxalModule for NotificationModule {
    fn descriptor(&self) -> &ModuleDescriptor {
        &self.descriptor
    }

    /// Planification horaire de la purge créée si elle est absente (rejouable).
    async fn install(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        let client = SchedulerClient::new(SchedulerStore::new(self.client.clone()));
        ensure_purge_schedule(&client)
            .await
            .map(|_| ())
            .map_err(|error| RuntimeError::InstallFailure {
                module: ModuleId::new(MODULE_ID),
                message: format!("planification de la purge : {}", error.code()),
            })
    }

    async fn start(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        Ok(())
    }

    async fn stop(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        Ok(())
    }
}

/// Sonde de santé : réglages lisibles et relais SMTP joignable. Sans transport (SMTP ou clé
/// applicative absents) : « dégradé », aucun e-mail n'est envoyé.
pub struct NotificationHealthCheck {
    module_id: ModuleId,
    store: NotificationStore,
    transport: Option<Arc<dyn EmailTransport>>,
}

impl NotificationHealthCheck {
    /// Sonde sur le store de la session système de l'hôte et le transport configuré.
    pub fn new(store: NotificationStore, transport: Option<Arc<dyn EmailTransport>>) -> Self {
        Self {
            module_id: ModuleId::new(MODULE_ID),
            store,
            transport,
        }
    }
}

#[async_trait]
impl ModuleHealthCheck for NotificationHealthCheck {
    fn module_id(&self) -> &ModuleId {
        &self.module_id
    }

    async fn check(&self, _ctx: &ModuleContext) -> Result<HealthCheckResult, RuntimeError> {
        let started = Instant::now();
        let settings = self.store.settings_get(SettingsGetParams::default()).await;
        let elapsed = || u64::try_from(started.elapsed().as_millis()).unwrap_or(u64::MAX);
        if let Err(error) = settings {
            return Ok(HealthCheckResult::unhealthy(
                self.module_id.clone(),
                Some(elapsed()),
                Some(format!("réglages illisibles : {error}")),
            ));
        }
        let Some(transport) = &self.transport else {
            return Ok(HealthCheckResult::degraded(
                self.module_id.clone(),
                elapsed(),
                Some("NOTIFICATION_SMTP_NOT_CONFIGURED : aucun e-mail n'est envoyé".to_string()),
            ));
        };
        Ok(match transport.check().await {
            Ok(()) => HealthCheckResult::healthy(
                self.module_id.clone(),
                elapsed(),
                Some("relais SMTP joignable".to_string()),
            ),
            Err(detail) => HealthCheckResult::degraded(
                self.module_id.clone(),
                elapsed(),
                Some(format!("relais SMTP injoignable : {detail}")),
            ),
        })
    }
}
