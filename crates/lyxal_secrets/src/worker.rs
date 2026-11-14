//! Worker supervisé de maintenance du coffre-fort :
//!
//! 1. purge des secrets supprimés dont la date de purge est passée (et des tickets échus) ;
//! 2. rescellement, par la clé active de leur organisation, des versions scellées par une clé
//!    retirée (rotation de clé d'organisation) ;
//! 3. rescellement, par la clé maîtresse active, des clés d'organisation scellées par l'ancienne
//!    (rotation de la clé maîtresse du coffre-fort) ;
//! 4. destruction des clés d'organisation retirées que plus aucune version n'utilise ;
//! 5. échéances signalées une seule fois (échéance proche, passée, rotation due) ;
//! 6. rotations : démarrage des rotations dues des secrets qu'un rotateur gère (le rappel n'est
//!    posé qu'une fois la rotation démarrée, ou si le démarrage échoue sans espoir de nouvel
//!    essai), puis avancée des rotations en cours dont l'essai est échu, réservées une à une
//!    juste avant d'être traitées (reprise à l'étape atteinte) ;
//! 7. rotation des clés d'organisation plus anciennes que la période de leur portée (avant le
//!    rescellement, qui suit au même passage).
//!
//! Sans clé maîtresse, seules la purge et les alertes ont lieu. Un élément en échec est journalisé
//! et laissé pour le passage suivant : il n'interrompt pas les autres.
//!
//! Arrêt : l'annulation est vérifiée avant chaque élément, et l'avancée d'une rotation (qui attend
//! un service extérieur) est mise en course avec elle. Une rotation interrompue est abandonnée en
//! l'état : sa réservation expire et un passage ultérieur la reprend à l'étape enregistrée.

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
    DueKind, DueListParams, DueMarkParams, PurgeDueParams, RewrapListParams, RewrapVersion,
    RotationBeginParams, RotationClaimParams, RotationState, SecretGetParams,
    TenantKeyDestroyParams, VersionResealParams,
};
use crate::module::MODULE_ID;
use crate::rotation::{RotationOutcome, RotationRunner, RotatorRegistry};
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
    /// Alertes signalées (échéance proche, échéance passée, rotation due).
    pub alerts: u64,
    /// Rotations réussies.
    pub rotations_succeeded: u64,
    /// Rotations en échec définitif.
    pub rotations_failed: u64,
    /// Clés d'organisation remplacées à échéance.
    pub tenant_keys_rotated: u64,
}

/// Worker de maintenance du coffre-fort.
pub struct SecretsMaintenanceWorker {
    descriptor: WorkerDescriptor,
    keys: TenantKeys,
    runner: RotationRunner,
    interval: Duration,
    batch: u32,
}

impl SecretsMaintenanceWorker {
    /// Maintenance toutes les `interval`, par paquets de `batch` éléments (1 à 1000), sur la
    /// session système de l'hôte, avec le trousseau maître du coffre-fort (absent : purge et
    /// alertes seulement) et les rotateurs inscrits par l'hôte.
    pub fn new(
        system: SecretsStore,
        master: Option<MasterKeys>,
        rotators: RotatorRegistry,
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
            "Purge des secrets supprimés à échéance ; alertes d'échéance ; rotation des secrets et des clés d'organisation ; rescellement après rotation d'une clé d'organisation ou de la clé maîtresse ; destruction des anciennes clés"
                .to_string(),
        );
        descriptor.criticality = WorkerCriticality::Optional;
        // Le rescellement en cours (une version, une clé) se termine avant l'arrêt
        descriptor.shutdown_timeout = Duration::from_secs(30);
        Ok(Self {
            descriptor,
            runner: RotationRunner::new(system.clone(), master.clone(), rotators),
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

        // Échéances et rotations en échec : journalisées, le rescellement a lieu quand même
        if let Err(error) = self.lifecycle(cancellation, &mut report).await {
            report.failed += 1;
            tracing::warn!(code = %error.code(), error = %error, "échéances et rotations non traitées");
        }

        let Ok(master) = self.keys.master() else {
            return Ok(report);
        };
        let master_key_id = master.active_id().as_str().to_string();
        // Éléments en échec de ce passage : passés aux paquets suivants, pour qu'une version
        // illisible ou une clé non rescellable n'arrête pas le travail des autres organisations
        let mut skip_versions: i64 = 0;
        let mut skip_keys: i64 = 0;
        while !cancellation.is_cancelled() {
            let work = system
                .rewrap_list(RewrapListParams {
                    master_key_id: master_key_id.clone(),
                    limit: Some(limit),
                    skip_versions: Some(skip_versions),
                    skip_keys: Some(skip_keys),
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
                    Ok(false) => skip_keys += 1,
                    Err(error) => {
                        report.failed += 1;
                        skip_keys += 1;
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
                    Ok(false) => skip_versions += 1,
                    Err(error) => {
                        report.failed += 1;
                        skip_versions += 1;
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
            // Un paquet plein en échec est passé : le paquet suivant commence après lui
            let full = work.versions.len() as i64 >= limit || work.keys.len() as i64 >= limit;
            if !progressed && !full {
                break;
            }
        }
        Ok(report)
    }

    /// Échéances, rotations des secrets et des clés d'organisation. Sans clé maîtresse : alertes
    /// seulement.
    async fn lifecycle(
        &self,
        cancellation: &CancellationToken,
        report: &mut MaintenanceReport,
    ) -> SecretsResult<()> {
        let limit = i64::from(self.batch);
        let system = self.keys.system();
        let crypto = self.keys.master().is_ok();
        while !cancellation.is_cancelled() {
            let due = system
                .due_list(DueListParams { limit: Some(limit) })
                .await?;
            let before = *report;
            let alerts = due
                .expiring
                .iter()
                .map(|item| (&item.id, DueKind::Expiring))
                .chain(due.expired.iter().map(|item| (&item.id, DueKind::Expired)));
            for (secret, kind) in alerts {
                if cancellation.is_cancelled() {
                    return Ok(());
                }
                self.mark(&secret.to_sql(), kind, report).await;
            }
            for item in &due.rotation_due {
                if cancellation.is_cancelled() {
                    return Ok(());
                }
                let secret = item.id.to_sql();
                if !crypto || self.begin(&secret, report).await {
                    self.mark(&secret, DueKind::RotationDue, report).await;
                }
            }
            if crypto {
                for key in &due.tenant_keys_due {
                    if cancellation.is_cancelled() {
                        return Ok(());
                    }
                    let rotated = match Scope::from_record(key.tenant.as_ref()) {
                        Ok(scope) => self.keys.rotate(&scope, None).await,
                        Err(error) => Err(error),
                    };
                    match rotated {
                        Ok(_) => report.tenant_keys_rotated += 1,
                        Err(error) => {
                            report.failed += 1;
                            tracing::warn!(key_id = %key.key_id, scope = %key.scope_key, code = %error.code(), error = %error, "clé d'organisation non remplacée à échéance");
                        }
                    }
                }
            }
            // Un paquet plein qui a avancé est suivi d'un autre ; sans avancée, les éléments en
            // échec attendent le passage suivant
            let progressed = report.alerts > before.alerts
                || report.tenant_keys_rotated > before.tenant_keys_rotated;
            let full = [
                due.expiring.len(),
                due.expired.len(),
                due.rotation_due.len(),
                due.tenant_keys_due.len(),
            ]
            .iter()
            .any(|len| *len as i64 >= limit);
            if !progressed || !full {
                break;
            }
        }
        if crypto {
            self.advance_rotations(cancellation, report).await?;
        }
        Ok(())
    }

    /// Échéance signalée ; vrai si l'alerte vient d'être posée.
    async fn mark(&self, secret: &str, kind: DueKind, report: &mut MaintenanceReport) -> bool {
        match self
            .keys
            .system()
            .due_mark(DueMarkParams {
                secret: secret.to_string(),
                kind,
            })
            .await
        {
            Ok(result) => {
                if result.marked {
                    report.alerts += 1;
                }
                result.marked
            }
            Err(error) => {
                let error = SecretsError::from(error);
                report.failed += 1;
                tracing::warn!(secret = %secret, kind = ?kind, code = %error.code(), error = %error, "échéance non signalée");
                false
            }
        }
    }

    /// Rotation due démarrée si un rotateur gère le secret ; sinon le rappel suffit (une
    /// personne écrira la nouvelle valeur). Vrai si le rappel peut être posé : rotation
    /// démarrée ou déjà en cours, aucun rotateur, ou échec sans nouvel essai possible ; faux
    /// pour un échec passager, que le passage suivant réessaiera.
    async fn begin(&self, secret: &str, report: &mut MaintenanceReport) -> bool {
        if self.runner.rotators().is_empty() {
            return true;
        }
        let system = self.keys.system();
        let started = async {
            let record = system
                .secret_get(SecretGetParams::by_id(secret.to_string()))
                .await?;
            if self.runner.rotators().find(&record).is_none() {
                return Ok(());
            }
            system
                .rotation_begin(RotationBeginParams {
                    secret: secret.to_string(),
                    emergency: None,
                    reason: None,
                })
                .await?;
            Ok::<(), SecretsError>(())
        }
        .await;
        match started {
            Ok(()) => true,
            Err(error) if error.is_code("SECRETS_ROTATION_IN_PROGRESS") => true,
            Err(error) => {
                report.failed += 1;
                let retry = error.is_retryable();
                tracing::warn!(secret = %secret, code = %error.code(), retry, error = %error, "rotation due non démarrée");
                !retry
            }
        }
    }

    /// Rotations en cours dont l'essai est échu : réservées une à une juste avant d'être
    /// avancées, jusqu'à `batch` rotations par passage. L'avancée est en course avec l'arrêt :
    /// une rotation interrompue garde son étape enregistrée et sa réservation expire.
    async fn advance_rotations(
        &self,
        cancellation: &CancellationToken,
        report: &mut MaintenanceReport,
    ) -> SecretsResult<()> {
        for _ in 0..self.batch {
            if cancellation.is_cancelled() {
                return Ok(());
            }
            let Some(rotation) = self
                .keys
                .system()
                .rotation_claim(RotationClaimParams {
                    limit: Some(1),
                    ..RotationClaimParams::default()
                })
                .await?
                .items
                .into_iter()
                .next()
            else {
                return Ok(());
            };
            let id = rotation.id.to_sql();
            let advanced = tokio::select! {
                _ = cancellation.cancelled() => {
                    tracing::info!(rotation = %id, "arrêt demandé : rotation laissée à l'étape enregistrée, reprise après expiration de sa réservation");
                    return Ok(());
                }
                advanced = self.runner.advance(rotation) => advanced,
            };
            match advanced {
                Ok(RotationOutcome::Advanced(done)) => match done.state {
                    RotationState::Succeeded => report.rotations_succeeded += 1,
                    RotationState::Failed => report.rotations_failed += 1,
                    _ => {}
                },
                Ok(RotationOutcome::LeaseLost) => {}
                Err(error) => {
                    report.failed += 1;
                    tracing::warn!(rotation = %id, code = %error.code(), error = %error, "rotation non avancée");
                }
            }
        }
        Ok(())
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
                        alerts = report.alerts,
                        rotations_succeeded = report.rotations_succeeded,
                        rotations_failed = report.rotations_failed,
                        tenant_keys_rotated = report.tenant_keys_rotated,
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
