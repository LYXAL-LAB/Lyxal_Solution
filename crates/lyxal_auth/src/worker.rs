//! Worker de purge de `lyxal_auth` (`fn::auth_purge` à intervalle régulier, par paquets).

use async_trait::async_trait;
use lyxal_runtime::types::ModuleId;
use lyxal_runtime::worker::{
    LyxalWorker, WorkerContext, WorkerCriticality, WorkerDescriptor, WorkerId,
};
use lyxal_runtime::RuntimeError;
use std::time::Duration;
use tokio_util::sync::CancellationToken;

use crate::models::AuthPurgeParams;
use crate::store::AuthStore;

/// Purge : sessions expirées, parcours et codes expirés, jetons usés, compteurs d'échecs anciens,
/// invitations expirées.
pub struct AuthPurgeWorker {
    descriptor: WorkerDescriptor,
    store: AuthStore,
    interval: Duration,
    batch: i64,
}

impl AuthPurgeWorker {
    /// Purge toutes les `interval`, par paquets de `batch` éléments.
    pub fn new(store: AuthStore, interval: Duration, batch: i64) -> Result<Self, RuntimeError> {
        let module_id = ModuleId::new(crate::module::MODULE_ID);
        let mut descriptor = WorkerDescriptor::new(
            WorkerId::new(&module_id, "purge")?,
            module_id,
            "Lyxal Auth Purge",
        );
        descriptor.description =
            Some("Purge des sessions, parcours, jetons et compteurs expirés".to_string());
        descriptor.criticality = WorkerCriticality::Optional;
        Ok(Self {
            descriptor,
            store,
            interval,
            batch,
        })
    }

    /// Une purge (paquets successifs tant qu'un paquet est plein), interrompue entre deux
    /// paquets si l'arrêt est demandé.
    pub async fn run_once(
        &self,
        cancellation: &CancellationToken,
    ) -> Result<(), lyxal_surreal::LyxalSurrealError> {
        while !cancellation.is_cancelled() {
            let result = self
                .store
                .purge(AuthPurgeParams {
                    limit: self.batch,
                    session_retention_days: None,
                })
                .await?;
            let largest = [
                result.flows,
                result.refresh_tokens,
                result.sessions,
                result.login_failures,
                result.pending_totp,
                result.invitation_claims,
                result.code_issuances,
                result.identities_purged,
                result.organizations_purged,
            ]
            .into_iter()
            .max()
            .unwrap_or(0);
            if largest < self.batch {
                break;
            }
        }
        Ok(())
    }
}

#[async_trait]
impl LyxalWorker for AuthPurgeWorker {
    fn descriptor(&self) -> &WorkerDescriptor {
        &self.descriptor
    }

    async fn run(&self, ctx: WorkerContext) -> Result<(), RuntimeError> {
        while !ctx.is_cancelled() {
            if let Err(error) = self.run_once(&ctx.cancellation).await {
                tracing::warn!(error = %error, "purge de lyxal_auth impossible");
            }
            tokio::select! {
                _ = ctx.cancellation.cancelled() => break,
                _ = tokio::time::sleep(self.interval) => {}
            }
        }
        Ok(())
    }
}
