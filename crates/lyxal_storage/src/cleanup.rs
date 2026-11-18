//! Nettoyage du stockage, une opération rendue à l'appelant avec son bilan (l'hôte la fait
//! exécuter par `lyxal_scheduler`, tâche `storage.cleanup`) : écritures abandonnées, envois reprenables complets restés
//! sans assemblage, fichiers supprimés hors délai, octets des buckets supprimés et des parties
//! d'envois terminés.
//!
//! Ordre des retraits : les octets d'abord, la fiche ou la ligne ensuite. Un arrêt entre les
//! deux est repris au passage suivant ; des octets déjà absents ne sont pas une erreur. Un
//! élément en échec (support inconnu ou injoignable) est journalisé et laissé pour le passage
//! suivant : il n'interrompt pas les autres.

use lyxal_runtime::worker::CancellationToken;
use lyxal_surreal::ToSql;
use std::sync::Arc;

use crate::backend::{location, Backends};
use crate::error::{StorageError, StorageResult};
use crate::models::{
    BatchParams, ObjectRefParams, PageParams, PurgeItem, ReclaimDoneParams, ReclaimItem,
};
use crate::scanner::ContentScanner;
use crate::service::StorageService;
use crate::store::StorageStore;

/// Bilan d'un passage du nettoyage.
#[derive(Debug, Clone, Copy, Default, PartialEq, Eq)]
pub struct CleanupReport {
    /// Écritures en attente abandonnées.
    pub expired: u64,
    /// Envois reprenables complets assemblés (assemblage interrompu par un arrêt ou un échec).
    pub assembled: u64,
    /// Fichiers supprimés dont les octets et la fiche ont été retirés.
    pub purged: u64,
    /// Préfixes dont les octets ont été retirés (buckets supprimés, parties d'envois terminés).
    pub reclaimed: u64,
    /// Éléments en échec, laissés pour le passage suivant.
    pub failed: u64,
}

/// Nettoyage du stockage.
pub struct StorageCleanup {
    store: StorageStore,
    backends: Arc<Backends>,
    scanner: Option<Arc<dyn ContentScanner>>,
    batch: u32,
}

impl StorageCleanup {
    /// Nettoyage par paquets de `batch` éléments (1 à 1000), sur la session du store (session
    /// système de l'hôte ou compte de service du stockage).
    pub fn new(store: StorageStore, backends: Arc<Backends>, batch: u32) -> Self {
        Self {
            store,
            backends,
            scanner: None,
            batch: batch.clamp(1, 1000),
        }
    }

    /// Fait analyser par cet antivirus les envois reprenables que le nettoyage assemble.
    pub fn with_scanner(mut self, scanner: Arc<dyn ContentScanner>) -> Self {
        self.scanner = Some(scanner);
        self
    }

    /// Un passage : paquets successifs tant qu'un paquet est plein, ou jusqu'à l'annulation.
    /// Un élément en échec reste en tête de liste : les paquets suivants le passent (`start`),
    /// pour qu'il ne retienne pas les autres.
    pub async fn run(&self, cancellation: &CancellationToken) -> StorageResult<CleanupReport> {
        let limit = i64::from(self.batch);
        let mut report = CleanupReport::default();

        while !cancellation.is_cancelled() {
            let expired = self
                .store
                .object_expire(BatchParams { limit })
                .await?
                .expired;
            report.expired += u64::try_from(expired).unwrap_or(0);
            if expired < limit {
                break;
            }
        }

        // Envois reprenables complets dont l'assemblage n'a pas abouti : un paquet par passage,
        // un envoi en échec passager revient au passage suivant
        let mut service = StorageService::new(self.store.clone(), self.backends.clone());
        if let Some(scanner) = &self.scanner {
            service = service.with_scanner(scanner.clone());
        }
        let ready = self
            .store
            .upload_ready_list(BatchParams { limit })
            .await?
            .items;
        for upload in &ready {
            if cancellation.is_cancelled() {
                return Ok(report);
            }
            match service
                .upload_complete_until(&upload.to_sql(), cancellation)
                .await
            {
                Ok(_) => report.assembled += 1,
                // Arrêt du serveur pendant l'assemblage : l'envoi reste complet, repris au
                // prochain démarrage
                Err(StorageError::Cancelled) => return Ok(report),
                Err(error) => {
                    report.failed += 1;
                    tracing::warn!(object = %upload.to_sql(), code = %error.code(), error = %error, "envoi reprenable non assemblé");
                }
            }
        }

        let mut start = 0;
        while !cancellation.is_cancelled() {
            let page = PageParams { limit, start };
            let items = self.store.object_purge_list(page).await?.items;
            for item in &items {
                if cancellation.is_cancelled() {
                    return Ok(report);
                }
                match self.purge(item).await {
                    Ok(()) => report.purged += 1,
                    Err(error) => {
                        start += 1;
                        report.failed += 1;
                        tracing::warn!(object = %item.id.to_sql(), code = %error.code(), error = %error, "fichier supprimé non purgé");
                    }
                }
            }
            if items.len() < self.batch as usize {
                break;
            }
        }

        let mut start = 0;
        while !cancellation.is_cancelled() {
            let page = PageParams { limit, start };
            let items = self.store.reclaim_list(page).await?.items;
            for item in &items {
                match self.reclaim(item, cancellation).await {
                    Ok(true) => report.reclaimed += 1,
                    // Annulation pendant le retrait : la ligne reste, reprise au passage suivant
                    Ok(false) => return Ok(report),
                    Err(error) => {
                        start += 1;
                        report.failed += 1;
                        tracing::warn!(prefix = %item.prefix, code = %error.code(), error = %error, "octets à retirer non retirés");
                    }
                }
            }
            if items.len() < self.batch as usize {
                break;
            }
        }
        Ok(report)
    }

    /// Octets retirés, puis fiche.
    async fn purge(&self, item: &PurgeItem) -> StorageResult<()> {
        let backend = self.backends.get(&item.backend)?;
        backend.remove(&location(&item.path)?).await?;
        self.store
            .object_purge(ObjectRefParams {
                object: item.id.to_sql(),
            })
            .await?;
        Ok(())
    }

    /// Octets du préfixe retirés, puis ligne ; faux si l'annulation a interrompu le retrait.
    async fn reclaim(
        &self,
        item: &ReclaimItem,
        cancellation: &CancellationToken,
    ) -> StorageResult<bool> {
        let backend = self.backends.get(&item.backend)?;
        if !backend
            .remove_prefix(&location(&item.prefix)?, cancellation)
            .await?
        {
            return Ok(false);
        }
        self.store
            .reclaim_done(ReclaimDoneParams {
                reclaim: item.id.to_sql(),
            })
            .await?;
        Ok(true)
    }
}
