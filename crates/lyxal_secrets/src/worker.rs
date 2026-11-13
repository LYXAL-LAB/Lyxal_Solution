//! Worker supervisé de maintenance du coffre-fort :
//!
//! 1. purge des secrets supprimés dont la date de purge est passée (et des tickets échus) ;
//! 2. rescellement, par la clé active de leur organisation, des versions scellées par une clé
//!    retirée (rotation de clé d'organisation) ;
//! 3. rescellement, par la clé maîtresse active, des clés d'organisation scellées par l'ancienne
//!    (rotation de la clé maîtresse du coffre-fort) ;
//! 4. destruction des clés d'organisation retirées que plus aucune version n'utilise.
//!
//! Sans clé maîtresse, seule la purge a lieu. Un élément en échec est journalisé et laissé pour
//! le passage suivant : il n'interrompt pas les autres.

use async_trait::async_trait;
use lyxal_runtime::types::ModuleId;
use lyxal_runtime::worker::{
    CancellationToken, LyxalWorker, WorkerContext, WorkerCriticality, WorkerDescriptor, WorkerId,
};
use lyxal_runtime::RuntimeError;
use lyxal_surreal::ToSql;
use std::collections::HashMap;
use std::time::Duration;

use crate::error::{SecretsError, SecretsResult};
use crate::keys::{MasterKeys, Scope, TenantKeys, TenantRing};
use crate::models::{
    PurgeDueParams, RewrapListParams, RewrapVersion, TenantKeyDestroyParams, VersionResealParams,
};
use crate::module::MODULE_ID;
use crate::store::SecretsStore;

/// Bilan d'un passage du worker.
#[derive(Debug, Clone, Copy, Default, PartialEq, Eq)]
pub struct MaintenanceReport {
    /// Secrets purgés à échéance.
    pub purged: u64,
    /// Versions rescellées par la clé active de leur organisation.
    pub resealed: u64,
    /// Clés d'organisation rescellées par la clé maîtresse active.
    pub rewrapped: u64,
    /// Clés d'organisation retirées détruites.
    pub destroyed_keys: u64,
    /// Éléments en échec, laissés pour le passage suivant.
    pub failed: u64,
}

/// Worker de maintenance du coffre-fort.
pub struct SecretsMaintenanceWorker {
    descriptor: WorkerDescriptor,
    keys: TenantKeys,
    interval: Duration,
    batch: u32,
}

impl SecretsMaintenanceWorker {
    /// Maintenance toutes les `interval`, par paquets de `batch` éléments (1 à 1000), sur la
    /// session système de l'hôte, avec le trousseau maître du coffre-fort (absent : purge
    /// seulement).
    pub fn new(
        system: SecretsStore,
        master: Option<MasterKeys>,
        interval: Duration,
        batch: u32,
    ) -> Result<Self, RuntimeError> {
        let module_id = ModuleId::new(MODULE_ID);
        let mut descriptor = WorkerDescriptor::new(
            WorkerId::new(&module_id, "maintenance")?,
            module_id,
            "Lyxal Secrets Maintenance",
        );
        descriptor.description = Some(
            "Purge des secrets supprimés à échéance ; rescellement après rotation d'une clé d'organisation ou de la clé maîtresse ; destruction des anciennes clés"
                .to_string(),
        );
        descriptor.criticality = WorkerCriticality::Optional;
        // Le rescellement en cours (une version, une clé) se termine avant l'arrêt
        descriptor.shutdown_timeout = Duration::from_secs(30);
        Ok(Self {
            descriptor,
            keys: TenantKeys::new(system, master),
            interval,
            batch: batch.clamp(1, 1000),
        })
    }

    /// Un passage : paquets successifs tant qu'ils avancent, ou jusqu'à l'annulation.
    pub async fn run_once(
        &self,
        cancellation: &CancellationToken,
    ) -> SecretsResult<MaintenanceReport> {
        let limit = i64::from(self.batch);
        let mut report = MaintenanceReport::default();
        let system = self.keys.system();

        while !cancellation.is_cancelled() {
            let purged = system
                .purge_due(PurgeDueParams { limit: Some(limit) })
                .await?
                .purged;
            report.purged += u64::try_from(purged).unwrap_or(0);
            if purged < limit {
                break;
            }
        }

        let Ok(master) = self.keys.master() else {
            return Ok(report);
        };
        let master_key_id = master.active_id().as_str().to_string();
        while !cancellation.is_cancelled() {
            let work = system
                .rewrap_list(RewrapListParams {
                    master_key_id: master_key_id.clone(),
                    limit: Some(limit),
                })
                .await?;
            let before = report;

            // Clés d'organisation d'abord : leurs versions s'ouvrent ensuite par la clé active
            for key in &work.keys {
                if cancellation.is_cancelled() {
                    return Ok(report);
                }
                match self.keys.rewrap(key).await {
                    Ok(true) => report.rewrapped += 1,
                    Ok(false) => {}
                    Err(error) => {
                        report.failed += 1;
                        tracing::warn!(key_id = %key.key_id, code = %error.code(), error = %error, "clé d'organisation non rescellée");
                    }
                }
            }

            let mut rings: HashMap<Scope, TenantRing> = HashMap::new();
            for version in &work.versions {
                if cancellation.is_cancelled() {
                    return Ok(report);
                }
                match self.reseal(version, &mut rings).await {
                    Ok(true) => report.resealed += 1,
                    Ok(false) => {}
                    Err(error) => {
                        report.failed += 1;
                        tracing::warn!(secret = %version.secret.to_sql(), number = version.number, code = %error.code(), error = %error, "version non rescellée");
                    }
                }
            }

            for key_id in &work.unused {
                if cancellation.is_cancelled() {
                    return Ok(report);
                }
                match system
                    .tenant_key_destroy(TenantKeyDestroyParams {
                        key_id: key_id.clone(),
                    })
                    .await
                {
                    Ok(_) => report.destroyed_keys += 1,
                    Err(error) => {
                        let error = SecretsError::from(error);
                        report.failed += 1;
                        tracing::warn!(key_id = %key_id, code = %error.code(), error = %error, "ancienne clé d'organisation non détruite");
                    }
                }
            }

            // Un paquet qui a avancé est suivi d'un autre (reste du travail, clés devenues
            // inutilisées) ; sans avancée, les éléments en échec attendent le passage suivant
            let progressed = report.resealed > before.resealed
                || report.rewrapped > before.rewrapped
                || report.destroyed_keys > before.destroyed_keys;
            if !progressed {
                break;
            }
        }
        Ok(report)
    }

    /// Version rescellée par la clé active de son organisation ; faux si elle l'était déjà.
    async fn reseal(
        &self,
        version: &RewrapVersion,
        rings: &mut HashMap<Scope, TenantRing>,
    ) -> SecretsResult<bool> {
        let scope = Scope::from_record(version.tenant.as_ref())?;
        if !rings.contains_key(&scope) {
            let ring = self.keys.ring(&scope).await?.ok_or_else(|| {
                SecretsError::TenantKeyUnavailable("aucune clé pour cette portée".to_string())
            })?;
            rings.insert(scope.clone(), ring);
        }
        let Some(ring) = rings.get(&scope) else {
            return Ok(false);
        };
        let context = scope.version_context(&version.secret, version.number)?;
        let Some(sealed) = ring.reencrypt(&version.envelope, &context)? else {
            return Ok(false);
        };
        self.keys
            .system()
            .version_reseal(VersionResealParams {
                secret: version.secret.to_sql(),
                number: version.number,
                expected_key_id: version.key_id.clone(),
                envelope: sealed.encode(),
                key_id: sealed.key_id().as_str().to_string(),
            })
            .await?;
        Ok(true)
    }
}

#[async_trait]
impl LyxalWorker for SecretsMaintenanceWorker {
    fn descriptor(&self) -> &WorkerDescriptor {
        &self.descriptor
    }

    async fn run(&self, ctx: WorkerContext) -> Result<(), RuntimeError> {
        while !ctx.is_cancelled() {
            match self.run_once(&ctx.cancellation).await {
                Ok(report) if report != MaintenanceReport::default() => {
                    tracing::info!(
                        purged = report.purged,
                        resealed = report.resealed,
                        rewrapped = report.rewrapped,
                        destroyed_keys = report.destroyed_keys,
                        failed = report.failed,
                        "maintenance du coffre-fort"
                    );
                }
                Ok(_) => {}
                Err(error) => {
                    tracing::warn!(code = %error.code(), error = %error, "maintenance du coffre-fort impossible");
                }
            }
            tokio::select! {
                _ = ctx.cancellation.cancelled() => break,
                _ = tokio::time::sleep(self.interval) => {}
            }
        }
        Ok(())
    }
}
