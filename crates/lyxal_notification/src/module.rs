//! Module `lyxal_notification` pour `lyxal_runtime` et sonde de santé.

use async_trait::async_trait;
use lyxal_runtime::descriptor::{ModuleDescriptor, ModuleDescriptorBuilder};
use lyxal_runtime::health::{HealthCheckResult, ModuleHealthCheck};
use lyxal_runtime::types::ModuleId;
use lyxal_runtime::{LyxalModule, ModuleContext, RuntimeError};
use std::sync::Arc;
use std::time::Instant;

use crate::models::SettingsGetParams;
use crate::smtp::EmailTransport;
use crate::store::NotificationStore;

/// Identifiant du module.
pub const MODULE_ID: &str = "lyxal_notification";

/// Module `lyxal_notification` : ses ressources SurrealQL sont installées par le runtime depuis le
/// manifeste ; consommateur, workers et sonde sont enregistrés par l'hôte.
pub struct NotificationModule {
    descriptor: ModuleDescriptor,
}

impl Default for NotificationModule {
    fn default() -> Self {
        Self::new()
    }
}

impl NotificationModule {
    /// Descripteur conforme au manifeste.
    pub fn new() -> Self {
        let descriptor = ModuleDescriptorBuilder::new(ModuleId::new(MODULE_ID), "0.1.0")
            .name("Lyxal Notification")
            .description(
                "Notifications sortantes : parcours, gabarits, file d'envoi e-mail, journal et liste de suppression",
            )
            .capability("database")
            .capability("events")
            .capability("email")
            .dependency(ModuleId::new("lyxal_core"))
            .dependency(ModuleId::new("lyxal_error"))
            .dependency(ModuleId::new("lyxal_event"))
            .dependency(ModuleId::new("lyxal_auth"))
            .build();
        Self { descriptor }
    }
}

#[async_trait]
impl LyxalModule for NotificationModule {
    fn descriptor(&self) -> &ModuleDescriptor {
        &self.descriptor
    }

    async fn install(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        Ok(())
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
