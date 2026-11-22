// SPDX-License-Identifier: AGPL-3.0-only

//! Maintenance du courrier, une opération rendue à l'appelant avec son bilan (l'hôte
//! `lyxal-groupware` la fait exécuter par `lyxal_scheduler`, tâche `mail.maintenance`) :
//!
//! 1. contenus abandonnés (dépôt interrompu) et libérés (plus aucun message) retirés avec leur
//!    fichier (`fn::mail_content_expire`) ;
//! 2. pierres tombales plus anciennes que la conservation de leur organisation
//!    (`fn::mail_tombstone_purge`) ;
//! 3. comptes en suppression purgés par étapes (`fn::mail_account_purge_step`).
//!
//! Chaque appel est une transaction ; l'arrêt du serveur interrompt la maintenance entre deux
//! appels (le reste est fait au passage suivant). Un passage s'arrête aussi après un nombre
//! borné d'appels par étape, pour rendre la main au planificateur.

use lyxal_runtime::worker::CancellationToken;

use crate::error::MailResult;
use crate::ingest::retry_conflicts;
use crate::models::MaintenanceParams;
use crate::store::MailStore;

/// Appels au plus par étape et par passage.
const MAX_ROUNDS: u32 = 50;

/// Bilan d'un passage de la maintenance.
#[derive(Debug, Clone, Copy, Default, PartialEq, Eq)]
pub struct MaintenanceReport {
    /// Contenus abandonnés retirés avec leur fichier.
    pub expired: u64,
    /// Contenus libérés retirés avec leur fichier.
    pub released: u64,
    /// Pierres tombales retirées.
    pub tombstones: u64,
    /// Comptes purgés.
    pub accounts: u64,
    /// Messages retirés des comptes purgés.
    pub messages: u64,
}

/// Maintenance du courrier.
#[derive(Clone)]
pub struct MailMaintenance {
    store: MailStore,
    batch: i64,
}

fn count(value: i64) -> u64 {
    u64::try_from(value).unwrap_or(0)
}

impl MailMaintenance {
    /// Maintenance par paquets de `batch` éléments (1 à 1 000) sur la session du store (session
    /// système de l'hôte, ou compte de service qui a `mail.worker` et `storage.worker`).
    pub fn new(store: MailStore, batch: u32) -> Self {
        Self {
            store,
            batch: i64::from(batch.clamp(1, 1_000)),
        }
    }

    /// Un passage complet, interrompu entre deux appels si `cancellation` est déclenché.
    pub async fn run(&self, cancellation: &CancellationToken) -> MailResult<MaintenanceReport> {
        let mut report = MaintenanceReport::default();
        let params = MaintenanceParams {
            limit: Some(self.batch),
        };
        for _ in 0..MAX_ROUNDS {
            if cancellation.is_cancelled() {
                return Ok(report);
            }
            let done = retry_conflicts(|| self.store.content_expire(params)).await?;
            report.expired += count(done.expired);
            report.released += count(done.released);
            if done.expired + done.released < self.batch {
                break;
            }
        }
        for _ in 0..MAX_ROUNDS {
            if cancellation.is_cancelled() {
                return Ok(report);
            }
            let done = retry_conflicts(|| self.store.tombstone_purge(params)).await?;
            report.tombstones += count(done.purged);
            if done.purged < self.batch {
                break;
            }
        }
        for _ in 0..MAX_ROUNDS {
            if cancellation.is_cancelled() {
                return Ok(report);
            }
            let step = retry_conflicts(|| self.store.account_purge_step(params)).await?;
            report.accounts += count(step.accounts);
            report.messages += count(step.messages);
            if step.done {
                break;
            }
        }
        Ok(report)
    }
}
