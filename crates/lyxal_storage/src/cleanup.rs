//! Nettoyage du stockage, une opération rendue à l'appelant avec son bilan (l'hôte la fait
//! exécuter par `lyxal_scheduler`, tâche `storage.cleanup`) : écritures abandonnées, envois reprenables complets restés
//! sans assemblage, fichiers supprimés hors délai, octets des buckets supprimés et des parties
//! d'envois terminés ; avec les clés de fichiers (`with_file_keys`), rescellement des clés de
//! fichiers scellées par une clé « fichiers » retirée (rotation, aucun octet réécrit), puis
//! destruction de cette clé quand plus rien ne l'utilise.
//!
//! Ordre des retraits : les octets d'abord, la fiche ou la ligne ensuite. Un arrêt entre les
//! deux est repris au passage suivant ; des octets déjà absents ne sont pas une erreur. Un
//! élément en échec (support inconnu ou injoignable) est journalisé et laissé pour le passage
//! suivant : il n'interrompt pas les autres.

use lyxal_runtime::worker::CancellationToken;
use lyxal_secrets::models::RetiredKey;
use lyxal_secrets::{FileKeys, SealedFileKey};
use lyxal_surreal::ToSql;
use std::sync::Arc;

use crate::backend::{location, Backends};
use crate::encryption::{key_error, object_context};
use crate::error::{StorageError, StorageResult};
use crate::models::{
    BatchParams, ObjectRefParams, PageParams, PurgeItem, ReclaimDoneParams, ReclaimItem, RekeyItem,
    RekeyListParams, RekeyParams,
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
    /// Clés de fichiers rescellées par la clé « fichiers » active de leur organisation.
    pub rekeyed: u64,
    /// Clés « fichiers » retirées détruites, plus rien ne les utilisant.
    pub retired_keys_destroyed: u64,
    /// Éléments en échec, laissés pour le passage suivant.
    pub failed: u64,
}

/// Nettoyage du stockage.
pub struct StorageCleanup {
    store: StorageStore,
    backends: Arc<Backends>,
    scanner: Option<Arc<dyn ContentScanner>>,
    file_keys: Option<FileKeys>,
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
            file_keys: None,
            batch: batch.clamp(1, 1000),
        }
    }

    /// Rescelle aussi les clés de fichiers des buckets chiffrés après la rotation de la clé
    /// « fichiers » d'une organisation, puis fait détruire l'ancienne clé quand plus rien ne
    /// l'utilise. Sans clé maîtresse du coffre-fort, rien n'est fait.
    pub fn with_file_keys(mut self, keys: FileKeys) -> Self {
        self.file_keys = Some(keys);
        self
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

        // Clés de fichiers après une rotation : un échec est journalisé, le reste du passage a
        // déjà eu lieu
        if let Some(keys) = self.file_keys.as_ref().filter(|keys| keys.is_available()) {
            if let Err(error) = self.rekey(keys, cancellation, &mut report).await {
                report.failed += 1;
                tracing::warn!(code = %error.code(), error = %error, "clés de fichiers non rescellées");
            }
        }
        Ok(report)
    }

    /// Clés « fichiers » retirées, une à une : les clés de fichiers qu'elle scelle sont
    /// rescellées, puis elle est détruite si plus aucune fiche ni écriture en attente ne peut s'en
    /// servir. Une clé en échec est passée.
    async fn rekey(
        &self,
        keys: &FileKeys,
        cancellation: &CancellationToken,
        report: &mut CleanupReport,
    ) -> StorageResult<()> {
        let mut start = 0;
        while !cancellation.is_cancelled() {
            let retired = keys.retired(self.batch, start).await.map_err(key_error)?;
            for key in &retired {
                if cancellation.is_cancelled() {
                    return Ok(());
                }
                match self.retire(keys, key, cancellation, report).await {
                    Ok(true) => report.retired_keys_destroyed += 1,
                    Ok(false) => start += 1,
                    Err(error) => {
                        start += 1;
                        report.failed += 1;
                        tracing::warn!(key_id = %key.key_id, code = %error.code(), error = %error, "clé « fichiers » retirée non traitée");
                    }
                }
            }
            if retired.len() < self.batch as usize {
                break;
            }
        }
        Ok(())
    }

    /// Fiches d'une clé retirée rescellées par paquets ; vrai si la clé, devenue inutile, est
    /// détruite.
    async fn retire(
        &self,
        keys: &FileKeys,
        key: &RetiredKey,
        cancellation: &CancellationToken,
        report: &mut CleanupReport,
    ) -> StorageResult<bool> {
        let limit = i64::from(self.batch);
        let page = |start: i64, limit: i64| RekeyListParams {
            key_id: key.key_id.clone(),
            tenant: key.tenant.as_ref().map(ToSql::to_sql),
            retired_at: key.retired_at,
            limit,
            start,
        };
        let mut start = 0;
        loop {
            let items = self
                .store
                .object_rekey_list(page(start, limit))
                .await?
                .items;
            for item in &items {
                if cancellation.is_cancelled() {
                    return Ok(false);
                }
                match self.reseal(keys, item).await {
                    Ok(true) => report.rekeyed += 1,
                    // Déjà scellée par la clé active (rangée entre-temps) : passée
                    Ok(false) => start += 1,
                    Err(error) => {
                        start += 1;
                        report.failed += 1;
                        tracing::warn!(object = %item.id.to_sql(), key_id = %key.key_id, code = %error.code(), error = %error, "clé de fichier non rescellée");
                    }
                }
            }
            if (items.len() as i64) < limit {
                break;
            }
        }
        // Plus aucune fiche, et aucune écriture ouverte avant le retrait encore en attente :
        // la clé ne peut plus servir
        let remaining = self.store.object_rekey_list(page(0, 1)).await?;
        if !remaining.items.is_empty() || remaining.pending_writes {
            return Ok(false);
        }
        keys.destroy(&key.key_id, false).await.map_err(key_error)
    }

    /// Clé d'un fichier rescellée par la clé active et rangée ; aucun octet n'est réécrit. Faux
    /// si elle l'était déjà.
    async fn reseal(&self, keys: &FileKeys, item: &RekeyItem) -> StorageResult<bool> {
        let sealed = SealedFileKey::parse(&item.content_key).map_err(key_error)?;
        let context = object_context(item.tenant.as_ref(), &item.id)?;
        let Some(resealed) = keys
            .reseal(item.tenant.as_ref(), &sealed, &context)
            .await
            .map_err(key_error)?
        else {
            return Ok(false);
        };
        self.store
            .object_rekey(RekeyParams {
                object: item.id.to_sql(),
                expected_key_id: sealed.key_id().to_string(),
                content_key: resealed.as_str().to_string(),
            })
            .await?;
        Ok(true)
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
