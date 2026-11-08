//! Module `lyxal_auth` pour `lyxal_runtime` et sonde de santé.

use async_trait::async_trait;
use lyxal_runtime::descriptor::{ModuleDescriptor, ModuleDescriptorBuilder};
use lyxal_runtime::health::{HealthCheckResult, ModuleHealthCheck};
use lyxal_runtime::types::ModuleId;
use lyxal_runtime::{LyxalModule, ModuleContext, RuntimeError};
use std::time::Instant;

use crate::models::PolicyGetParams;
use crate::store::AuthStore;

/// Identifiant du module.
pub const MODULE_ID: &str = "lyxal_auth";

/// Module `lyxal_auth` : ses ressources SurrealQL sont installées par le runtime depuis le
/// manifeste ; aucun worker en lot 2 (la purge arrive au lot 3).
pub struct AuthModule {
    descriptor: ModuleDescriptor,
}

impl Default for AuthModule {
    fn default() -> Self {
        Self::new()
    }
}

impl AuthModule {
    /// Descripteur conforme au manifeste.
    pub fn new() -> Self {
        let descriptor = ModuleDescriptorBuilder::new(ModuleId::new(MODULE_ID), "0.1.0")
            .name("Lyxal Auth")
            .description(
                "Identités, organisations, rôles, permissions, invitations et contrôle des droits",
            )
            .capability("database")
            .capability("events")
            .dependency(ModuleId::new("lyxal_core"))
            .dependency(ModuleId::new("lyxal_error"))
            .dependency(ModuleId::new("lyxal_event"))
            .build();
        Self { descriptor }
    }
}

#[async_trait]
impl LyxalModule for AuthModule {
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

/// Sonde de santé : la politique de l'installation est lisible (module installé, base joignable).
pub struct AuthHealthCheck {
    module_id: ModuleId,
    store: AuthStore,
}

impl AuthHealthCheck {
    /// Sonde sur le store de la session système de l'hôte.
    pub fn new(store: AuthStore) -> Self {
        Self {
            module_id: ModuleId::new(MODULE_ID),
            store,
        }
    }
}

#[async_trait]
impl ModuleHealthCheck for AuthHealthCheck {
    fn module_id(&self) -> &ModuleId {
        &self.module_id
    }

    async fn check(&self, _ctx: &ModuleContext) -> Result<HealthCheckResult, RuntimeError> {
        let started = Instant::now();
        let outcome = self.store.policy_get(PolicyGetParams::default()).await;
        let latency = u64::try_from(started.elapsed().as_millis()).unwrap_or(u64::MAX);
        Ok(match outcome {
            Ok(_) => HealthCheckResult::healthy(
                self.module_id.clone(),
                latency,
                Some("politique de l'installation lisible".to_string()),
            ),
            Err(error) => HealthCheckResult::unhealthy(
                self.module_id.clone(),
                Some(latency),
                Some(format!("politique illisible : {error}")),
            ),
        })
    }
}
