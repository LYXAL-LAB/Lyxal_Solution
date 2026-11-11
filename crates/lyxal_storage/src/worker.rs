//! Worker supervisé de nettoyage : écritures abandonnées, fichiers supprimés hors délai,
//! octets des buckets supprimés.
//!
//! Ordre des retraits : les octets d'abord, la fiche ou la ligne ensuite. Un arrêt entre les
//! deux est repris au passage suivant ; des octets déjà absents ne sont pas une erreur. Un
//! élément en échec (support inconnu ou injoignable) est journalisé et laissé pour le passage
//! suivant : il n'interrompt pas les autres.

use async_trait::async_trait;
use futures::StreamExt;
use lyxal_runtime::types::ModuleId;
use lyxal_runtime::worker::{
    CancellationToken, LyxalWorker, WorkerContext, WorkerCriticality, WorkerDescriptor, WorkerId,
};
use lyxal_runtime::RuntimeError;
use lyxal_surreal::ToSql;
use std::collections::HashSet;
use std::sync::Arc;
use std::time::Duration;

use crate::backend::{location, remove, Backends};
use crate::error::StorageResult;
use crate::models::{BatchParams, ObjectRefParams, PurgeItem, ReclaimDoneParams, ReclaimItem};
use crate::module::MODULE_ID;
use crate::store::StorageStore;

/// Bilan d'un passage du worker.
#[derive(Debug, Clone, Copy, Default, PartialEq, Eq)]
pub struct CleanupReport {
    /// Écritures en attente abandonnées.
    pub expired: u64,
    /// Fichiers supprimés dont les octets et la fiche ont été retirés.
    pub purged: u64,
    /// Préfixes de buckets supprimés dont les octets ont été retirés.
    pub reclaimed: u64,
    /// Éléments en échec, laissés pour le passage suivant.
    pub failed: u64,
}

/// Worker de nettoyage du stockage.
pub struct StorageCleanupWorker {
    descriptor: WorkerDescriptor,
    store: StorageStore,
    backends: Arc<Backends>,
    interval: Duration,
    batch: u32,
}

impl StorageCleanupWorker {
    /// Nettoyage toutes les `interval`, par paquets de `batch` éléments (1 à 1000), sur la
    /// session du store (session système de l'hôte ou compte du worker).
    pub fn new(
        store: StorageStore,
        backends: Arc<Backends>,
        interval: Duration,
        batch: u32,
    ) -> Result<Self, RuntimeError> {
        let module_id = ModuleId::new(MODULE_ID);
        let mut descriptor = WorkerDescriptor::new(
            WorkerId::new(&module_id, "cleanup")?,
            module_id,
            "Lyxal Storage Cleanup",
        );
        descriptor.description = Some(
            "Retrait des écritures abandonnées, des fichiers supprimés et des octets des buckets supprimés"
                .to_string(),
        );
        descriptor.criticality = WorkerCriticality::Optional;
        Ok(Self {
            descriptor,
            store,
            backends,
            interval,
            batch: batch.clamp(1, 1000),
        })
    }

    /// Un passage : paquets successifs tant qu'un paquet est plein et avance, ou jusqu'à
    /// l'annulation.
    pub async fn run_once(&self, cancellation: &CancellationToken) -> StorageResult<CleanupReport> {
        let params = BatchParams {
            limit: i64::from(self.batch),
        };
        let full = |count: usize| count >= self.batch as usize;
        let mut report = CleanupReport::default();
        // Éléments en échec pendant ce passage : ni retentés ni recomptés avant le suivant
        let mut failed: HashSet<String> = HashSet::new();

        while !cancellation.is_cancelled() {
            let expired = self.store.object_expire(params).await?.expired;
            report.expired += u64::try_from(expired).unwrap_or(0);
            if expired < params.limit {
                break;
            }
        }

        while !cancellation.is_cancelled() {
            let items = self.store.object_purge_list(params).await?.items;
            let mut purged = 0;
            for item in &items {
                if cancellation.is_cancelled() {
                    break;
                }
                if failed.contains(&item.id.to_sql()) {
                    continue;
                }
                match self.purge(item).await {
                    Ok(()) => purged += 1,
                    Err(error) => {
                        failed.insert(item.id.to_sql());
                        report.failed += 1;
                        tracing::warn!(object = %item.id.to_sql(), code = %error.code(), error = %error, "fichier supprimé non purgé");
                    }
                }
            }
            report.purged += purged;
            if !full(items.len()) || purged == 0 {
                break;
            }
        }

        while !cancellation.is_cancelled() {
            let items = self.store.reclaim_list(params).await?.items;
            let mut reclaimed = 0;
            for item in &items {
                if cancellation.is_cancelled() {
                    break;
                }
                if failed.contains(&item.id.to_sql()) {
                    continue;
                }
                match self.reclaim(item).await {
                    Ok(()) => reclaimed += 1,
                    Err(error) => {
                        failed.insert(item.id.to_sql());
                        report.failed += 1;
                        tracing::warn!(prefix = %item.prefix, code = %error.code(), error = %error, "octets d'un bucket supprimé non retirés");
                    }
                }
            }
            report.reclaimed += reclaimed;
            if !full(items.len()) || reclaimed == 0 {
                break;
            }
        }
        Ok(report)
    }

    /// Octets retirés, puis fiche.
    async fn purge(&self, item: &PurgeItem) -> StorageResult<()> {
        let backend = self.backends.get(&item.backend)?;
        remove(backend.as_ref(), &location(&item.path)?).await?;
        self.store
            .object_purge(ObjectRefParams {
                object: item.id.to_sql(),
            })
            .await?;
        Ok(())
    }

    /// Octets du préfixe retirés, puis ligne.
    async fn reclaim(&self, item: &ReclaimItem) -> StorageResult<()> {
        let backend = self.backends.get(&item.backend)?;
        let prefix = location(&item.prefix)?;
        let mut listed = backend.list(Some(&prefix));
        while let Some(meta) = listed.next().await {
            remove(backend.as_ref(), &meta?.location).await?;
        }
        self.store
            .reclaim_done(ReclaimDoneParams {
                reclaim: item.id.to_sql(),
            })
            .await?;
        Ok(())
    }
}

#[async_trait]
impl LyxalWorker for StorageCleanupWorker {
    fn descriptor(&self) -> &WorkerDescriptor {
        &self.descriptor
    }

    async fn run(&self, ctx: WorkerContext) -> Result<(), RuntimeError> {
        while !ctx.is_cancelled() {
            match self.run_once(&ctx.cancellation).await {
                Ok(report) if report != CleanupReport::default() => {
                    tracing::info!(
                        expired = report.expired,
                        purged = report.purged,
                        reclaimed = report.reclaimed,
                        failed = report.failed,
                        "nettoyage du stockage"
                    );
                }
                Ok(_) => {}
                Err(error) => {
                    tracing::warn!(code = %error.code(), error = %error, "nettoyage du stockage impossible");
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
