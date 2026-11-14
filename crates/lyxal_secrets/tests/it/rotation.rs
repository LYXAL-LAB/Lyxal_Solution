//! Cycle de vie : rotation en quatre étapes sans coupure, nouveaux essais et échec définitif,
//! reprise d'une rotation interrompue, urgence avec et sans rotateur, alertes et rotations dues
//! traitées par le worker, essai sans bascule, rotation planifiée des clés d'organisation,
//! réservation périmée reprise par un autre worker, arrêt du worker pendant une rotation,
//! aucune valeur dans les erreurs ni les `Debug`.

use async_trait::async_trait;
use lyxal_crypto::SecretBytes;
use lyxal_runtime::worker::{CancellationToken, LyxalWorker, WorkerContext};
use lyxal_runtime::ModuleContext;
use lyxal_secrets::models::{
    RotationBeginParams, RotationClaimParams, RotationGetParams, RotationRecord, RotationState,
    RotationStep, RotationStepParams, SecretCreateParams, SecretGetParams, SecretRecord, Stage,
};
use lyxal_secrets::{
    MaintenanceReport, PutValue, RevealRequest, RotateRequest, RotationOutcome, RotationRunner,
    RotatorError, RotatorRegistry, SecretRotator, SecretsMaintenanceWorker, SecretsService,
};
use lyxal_surreal::ToSql;
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::{Arc, Mutex};
use std::time::Duration;

use crate::support::{bench, code, put, reveal, Bench, ALPHA};

/// Rotateur de test en mémoire : valeurs générées (`nouvelle-<n>`), compteurs, échecs
/// programmables, et relecture de la valeur en service pendant chaque étape (sonde).
#[derive(Default)]
struct TestRotator {
    creates: AtomicUsize,
    installs: AtomicUsize,
    tests: AtomicUsize,
    /// Échecs restants de `test` (passagers).
    failing_tests: AtomicUsize,
    /// Valeur en service reçue par `create`.
    seen_current: Mutex<Vec<Option<Vec<u8>>>>,
    /// Valeurs retirées.
    retired: Mutex<Vec<Vec<u8>>>,
    /// Valeur en service relue pendant `install` et `test`.
    probe: Mutex<Option<(SecretsService, String)>>,
    observed: Mutex<Vec<Vec<u8>>>,
}

impl TestRotator {
    fn failing(times: usize) -> Self {
        let rotator = Self::default();
        rotator.failing_tests.store(times, Ordering::SeqCst);
        rotator
    }

    fn watch(&self, service: &SecretsService, secret: &str) {
        *self.probe.lock().expect("sonde") = Some((service.clone(), secret.to_string()));
    }

    async fn observe(&self) {
        let probe = self.probe.lock().expect("sonde").clone();
        if let Some((service, secret)) = probe {
            let value = service
                .reveal(reveal(&secret))
                .await
                .expect("valeur en service");
            self.observed
                .lock()
                .expect("relevés")
                .push(value.value.expose_secret().to_vec());
        }
    }

    fn count(counter: &AtomicUsize) -> usize {
        counter.load(Ordering::SeqCst)
    }
}

#[async_trait]
impl SecretRotator for TestRotator {
    fn name(&self) -> &str {
        "lyxal_test_rotator"
    }

    fn handles(&self, secret: &SecretRecord) -> bool {
        secret.path.starts_with("rot/")
    }

    async fn create(
        &self,
        _secret: &SecretRecord,
        current: Option<&SecretBytes>,
    ) -> Result<SecretBytes, RotatorError> {
        let n = self.creates.fetch_add(1, Ordering::SeqCst) + 1;
        self.seen_current
            .lock()
            .expect("valeurs vues")
            .push(current.map(|value| value.expose_secret().to_vec()));
        SecretBytes::new(format!("nouvelle-{n}").into_bytes())
            .map_err(|_| RotatorError::terminal("TEST_VALUE"))
    }

    async fn install(
        &self,
        _secret: &SecretRecord,
        _new: &SecretBytes,
    ) -> Result<(), RotatorError> {
        self.installs.fetch_add(1, Ordering::SeqCst);
        self.observe().await;
        Ok(())
    }

    async fn test(&self, _secret: &SecretRecord, _value: &SecretBytes) -> Result<(), RotatorError> {
        self.tests.fetch_add(1, Ordering::SeqCst);
        self.observe().await;
        let failing = self.failing_tests.load(Ordering::SeqCst);
        if failing > 0 {
            self.failing_tests.store(failing - 1, Ordering::SeqCst);
            return Err(RotatorError::retryable("TEST_SERVICE_REFUSED"));
        }
        Ok(())
    }

    async fn retire(&self, _secret: &SecretRecord, old: &SecretBytes) -> Result<(), RotatorError> {
        self.retired
            .lock()
            .expect("retraits")
            .push(old.expose_secret().to_vec());
        Ok(())
    }
}

fn registry(rotator: &Arc<TestRotator>) -> RotatorRegistry {
    let mut registry = RotatorRegistry::new();
    registry.register(rotator.clone());
    registry
}

fn service(bench: &Bench, rotator: &Arc<TestRotator>) -> SecretsService {
    bench.service.clone().with_rotators(registry(rotator))
}

fn worker(bench: &Bench, rotators: RotatorRegistry) -> SecretsMaintenanceWorker {
    SecretsMaintenanceWorker::new(
        bench.store.clone(),
        Some(bench.master.clone()),
        rotators,
        Duration::from_secs(3600),
        10,
    )
    .expect("worker")
}

async fn pass(bench: &Bench, rotators: RotatorRegistry) -> MaintenanceReport {
    worker(bench, rotators)
        .run_once(&CancellationToken::new())
        .await
        .expect("passage")
}

fn rotate(secret: &str, emergency: bool) -> RotateRequest {
    RotateRequest {
        secret: secret.to_string(),
        emergency,
        reason: Some("test".to_string()),
    }
}

async fn fiche(bench: &Bench, secret: &str) -> SecretRecord {
    bench
        .store
        .secret_get(SecretGetParams::by_id(secret))
        .await
        .expect("fiche")
}

async fn rotations(bench: &Bench, secret: &str) -> Vec<RotationRecord> {
    bench
        .store
        .rotation_get(RotationGetParams {
            secret: secret.to_string(),
            limit: None,
        })
        .await
        .expect("rotations")
        .items
}

/// Essai planifié avancé à maintenant (comme si le délai était écoulé).
async fn due_now(bench: &Bench, rotation: &RotationRecord) {
    bench
        .run(&format!(
            "UPDATE {} SET next_attempt_at = time::now() - 1s, locked_until = NONE",
            rotation.id.to_sql()
        ))
        .await;
}

#[tokio::test]
async fn a_full_rotation_keeps_the_old_value_in_service_until_the_switch() {
    let bench = bench().await;
    let secret = bench.secret(Some(ALPHA), "rot/api").await;
    bench.put(&secret, b"ancienne").await;
    let rotator = Arc::new(TestRotator::default());
    rotator.watch(&bench.service, &secret);
    let service = service(&bench, &rotator);

    let done = service
        .rotate_now(rotate(&secret, false))
        .await
        .expect("rotation");
    assert_eq!(done.state, RotationState::Succeeded, "{done:?}");
    assert_eq!(done.pending_number, Some(2));
    assert_eq!(done.previous_number, Some(1));
    let labels = done.labels.clone().expect("étiquettes");
    assert_eq!(labels.get("current"), Some(&2));
    assert_eq!(labels.get("previous"), Some(&1));
    assert!(!labels.contains_key("pending"));
    // Aucune coupure : la valeur en service est restée l'ancienne à chaque étape
    assert_eq!(
        *rotator.observed.lock().expect("relevés"),
        vec![b"ancienne".to_vec(), b"ancienne".to_vec()]
    );
    assert_eq!(
        *rotator.seen_current.lock().expect("vues"),
        vec![Some(b"ancienne".to_vec())]
    );
    assert_eq!(bench.read(&secret).await, b"nouvelle-1");
    let previous = bench
        .service
        .reveal(RevealRequest {
            label: Some("previous".into()),
            ..reveal(&secret)
        })
        .await
        .expect("previous");
    assert_eq!(previous.value.expose_secret(), b"ancienne");
    assert!(fiche(&bench, &secret).await.last_rotated_at.is_some());
    // Rien à retirer au premier cycle : l'ancienne reste valide jusqu'au cycle suivant
    assert!(rotator.retired.lock().expect("retraits").is_empty());

    // Second cycle : l'avant-dernière valeur (l'ancienne) est retirée chez le service
    let again = service
        .rotate_now(rotate(&secret, false))
        .await
        .expect("rotation");
    assert_eq!(again.state, RotationState::Succeeded);
    assert_eq!(bench.read(&secret).await, b"nouvelle-2");
    assert_eq!(
        *rotator.retired.lock().expect("retraits"),
        vec![b"ancienne".to_vec()]
    );
}

#[tokio::test]
async fn a_failed_test_schedules_a_new_attempt_and_keeps_the_value_in_service() {
    let bench = bench().await;
    let secret = bench.secret(Some(ALPHA), "rot/retry").await;
    bench.put(&secret, b"ancienne").await;
    let rotator = Arc::new(TestRotator::failing(1));
    let service = service(&bench, &rotator);

    let waiting = service
        .rotate_now(rotate(&secret, false))
        .await
        .expect("rotation");
    assert_eq!(waiting.state, RotationState::Installed, "{waiting:?}");
    assert_eq!(waiting.attempts, 1);
    assert_eq!(waiting.last_error.as_deref(), Some("TEST_SERVICE_REFUSED"));
    assert!(waiting.next_attempt_at.is_some());
    assert_eq!(bench.read(&secret).await, b"ancienne");
    // Essai pas encore échu : le worker n'y touche pas
    let report = pass(&bench, registry(&rotator)).await;
    assert_eq!(report.rotations_succeeded, 0, "{report:?}");

    due_now(&bench, &waiting).await;
    let report = pass(&bench, registry(&rotator)).await;
    assert_eq!(report.rotations_succeeded, 1, "{report:?}");
    assert_eq!(report.failed, 0, "{report:?}");
    // Reprise à l'étape atteinte : rien n'est recréé ni réinstallé
    assert_eq!(TestRotator::count(&rotator.creates), 1);
    assert_eq!(TestRotator::count(&rotator.installs), 1);
    assert_eq!(TestRotator::count(&rotator.tests), 2);
    assert_eq!(bench.read(&secret).await, b"nouvelle-1");
}

#[tokio::test]
async fn a_rotation_fails_for_good_after_four_failures() {
    let bench = bench().await;
    let secret = bench.secret(Some(ALPHA), "rot/echec").await;
    bench.put(&secret, b"ancienne").await;
    let rotator = Arc::new(TestRotator::failing(usize::MAX));
    let service = service(&bench, &rotator);

    let mut rotation = service
        .rotate_now(rotate(&secret, false))
        .await
        .expect("rotation");
    let mut failed = 0;
    for _ in 0..3 {
        assert_eq!(rotation.state, RotationState::Installed, "{rotation:?}");
        due_now(&bench, &rotation).await;
        let report = pass(&bench, registry(&rotator)).await;
        failed += report.rotations_failed;
        rotation = rotations(&bench, &secret).await.remove(0);
    }
    assert_eq!(rotation.state, RotationState::Failed, "{rotation:?}");
    assert_eq!(rotation.attempts, 4);
    assert_eq!(failed, 1);
    assert_eq!(TestRotator::count(&rotator.tests), 4);
    // Version courante inchangée, nouvelle valeur jamais mise en service
    let labels = fiche(&bench, &secret).await.labels;
    assert_eq!(labels.get("current"), Some(&1));
    assert!(!labels.contains_key("pending"), "{labels:?}");
    assert_eq!(bench.read(&secret).await, b"ancienne");
    // Rotation terminée : plus rien à reprendre
    assert_eq!(pass(&bench, registry(&rotator)).await.rotations_failed, 0);
}

#[tokio::test]
async fn an_interrupted_rotation_resumes_at_the_step_reached() {
    let bench = bench().await;
    let secret = bench.secret(Some(ALPHA), "rot/reprise").await;
    bench.put(&secret, b"ancienne").await;
    // Un worker démarre la rotation, écrit la nouvelle valeur, enregistre l'étape, puis s'arrête
    let started = bench
        .store
        .rotation_begin(RotationBeginParams {
            secret: secret.clone(),
            emergency: None,
            reason: None,
        })
        .await
        .expect("démarrage");
    let claimed = bench
        .store
        .rotation_claim(RotationClaimParams {
            rotation: Some(started.id.to_sql()),
            ..RotationClaimParams::default()
        })
        .await
        .expect("réservation");
    assert_eq!(claimed.items.len(), 1);
    let pending = bench
        .service
        .put(PutValue {
            stage: Stage::Pending,
            ..put(&secret, b"ecrite-avant-arret")
        })
        .await
        .expect("version pending")
        .version
        .number;
    bench
        .store
        .rotation_step(RotationStepParams {
            rotation: started.id.to_sql(),
            lease: claimed.items[0].lease.clone().expect("jeton"),
            step: RotationStep::Created,
            pending_number: Some(pending),
        })
        .await
        .expect("étape created");
    // Bail encore valide : personne ne la reprend
    let rotator = Arc::new(TestRotator::default());
    assert_eq!(
        pass(&bench, registry(&rotator)).await.rotations_succeeded,
        0
    );

    due_now(&bench, &started).await;
    let report = pass(&bench, registry(&rotator)).await;
    assert_eq!(report.rotations_succeeded, 1, "{report:?}");
    assert_eq!(TestRotator::count(&rotator.creates), 0);
    assert_eq!(TestRotator::count(&rotator.installs), 1);
    assert_eq!(bench.read(&secret).await, b"ecrite-avant-arret");
}

#[tokio::test]
async fn an_emergency_rotation_cuts_the_value_then_puts_a_new_one_in_service() {
    let bench = bench().await;
    let secret = bench.secret(Some(ALPHA), "rot/fuite").await;
    bench.put(&secret, b"compromise").await;
    let rotator = Arc::new(TestRotator::default());
    let service = service(&bench, &rotator);

    let done = service
        .rotate_now(rotate(&secret, true))
        .await
        .expect("urgence");
    assert_eq!(done.state, RotationState::Succeeded, "{done:?}");
    assert!(done.emergency);
    // La valeur compromise n'est pas relue pour créer la nouvelle
    assert_eq!(*rotator.seen_current.lock().expect("vues"), vec![None]);
    assert_eq!(bench.read(&secret).await, b"nouvelle-1");
    // L'ancienne version reste coupée
    assert_eq!(
        code(
            bench
                .service
                .reveal(RevealRequest {
                    number: Some(1),
                    ..reveal(&secret)
                })
                .await
        ),
        "SECRETS_VERSION_STATE_INVALID"
    );
}

#[tokio::test]
async fn an_emergency_without_rotator_leaves_the_secret_unreadable() {
    let bench = bench().await;
    let secret = bench.secret(Some(ALPHA), "manuel/fuite").await;
    bench.put(&secret, b"compromise").await;

    // Hors urgence, sans rotateur : rien ne démarre
    assert_eq!(
        code(bench.service.rotate_now(rotate(&secret, false)).await),
        "SECRETS_ROTATOR_UNAVAILABLE"
    );
    assert!(rotations(&bench, &secret).await.is_empty());

    let failed = bench
        .service
        .rotate_now(rotate(&secret, true))
        .await
        .expect("urgence");
    assert_eq!(failed.state, RotationState::Failed, "{failed:?}");
    assert_eq!(
        failed.last_error.as_deref(),
        Some("SECRETS_ROTATOR_UNAVAILABLE")
    );
    let refused = code(bench.service.reveal(reveal(&secret)).await);
    assert_eq!(refused, "SECRETS_VERSION_STATE_INVALID");
    // Une personne écrit la nouvelle valeur : le secret est de nouveau lisible
    bench.put(&secret, b"remplacee").await;
    assert_eq!(bench.read(&secret).await, b"remplacee");
}

#[tokio::test]
async fn the_worker_signals_due_secrets_and_rotates_only_those_with_a_rotator() {
    let bench = bench().await;
    let mut manual = SecretCreateParams::new(Some(ALPHA.to_string()), "manuel/api", "api_key");
    manual.rotation_period = Some(Duration::from_secs(3600).into());
    let manual = bench.secret_with(manual).await;
    bench.put(&manual, b"manuelle").await;
    let mut automatic = SecretCreateParams::new(Some(ALPHA.to_string()), "rot/auto", "api_key");
    automatic.rotation_period = Some(Duration::from_secs(3600).into());
    let automatic = bench.secret_with(automatic).await;
    bench.put(&automatic, b"auto").await;
    let mut expiring = SecretCreateParams::new(Some(ALPHA.to_string()), "manuel/expire", "token");
    expiring.expires_at = Some(
        bench
            .value::<lyxal_surreal::Datetime>("RETURN time::now() + 10d")
            .await,
    );
    let expiring = bench.secret_with(expiring).await;
    bench
        .run(&format!(
            "UPDATE {manual}, {automatic} SET next_rotation_at = time::now() - 1m"
        ))
        .await;

    let rotator = Arc::new(TestRotator::default());
    let report = pass(&bench, registry(&rotator)).await;
    // Deux rappels de rotation et une alerte d'échéance ; une seule rotation (rotateur)
    assert_eq!(report.alerts, 3, "{report:?}");
    assert_eq!(report.rotations_succeeded, 1, "{report:?}");
    assert_eq!(report.failed, 0, "{report:?}");
    assert!(rotations(&bench, &manual).await.is_empty());
    assert_eq!(bench.read(&manual).await, b"manuelle");
    assert_eq!(bench.read(&automatic).await, b"nouvelle-1");
    assert!(fiche(&bench, &manual).await.rotation_notified_at.is_some());
    assert!(fiche(&bench, &expiring).await.expiry_warned_at.is_some());
    // Une seule fois
    let again = pass(&bench, registry(&rotator)).await;
    assert_eq!(again.alerts, 0, "{again:?}");
    assert_eq!(again.rotations_succeeded, 0, "{again:?}");
}

#[tokio::test]
async fn a_check_tests_the_value_in_service_without_switching() {
    let bench = bench().await;
    let secret = bench.secret(Some(ALPHA), "rot/essai").await;
    bench.put(&secret, b"en-service").await;
    let rotator = Arc::new(TestRotator::default());
    let service = service(&bench, &rotator);

    let ok = service.check_rotation(&secret).await.expect("essai");
    assert!(ok.ok);
    assert_eq!(ok.code, None);
    rotator.failing_tests.store(1, Ordering::SeqCst);
    let refused = service.check_rotation(&secret).await.expect("essai");
    assert!(!refused.ok);
    assert_eq!(refused.code.as_deref(), Some("TEST_SERVICE_REFUSED"));
    let record = fiche(&bench, &secret).await;
    assert_eq!(record.last_check_ok, Some(false));
    assert_eq!(
        record.last_check_code.as_deref(),
        Some("TEST_SERVICE_REFUSED")
    );
    // Rien n'a changé
    assert_eq!(TestRotator::count(&rotator.creates), 0);
    assert_eq!(record.latest_version, 1);
    assert!(rotations(&bench, &secret).await.is_empty());

    let manual = bench.secret(Some(ALPHA), "manuel/essai").await;
    bench.put(&manual, b"x").await;
    assert_eq!(
        code(service.check_rotation(&manual).await),
        "SECRETS_ROTATOR_UNAVAILABLE"
    );
}

#[tokio::test]
async fn the_worker_rotates_old_tenant_keys() {
    let bench = bench().await;
    // Première clé de l'organisation, vieillie de 400 jours (date de création en lecture seule :
    // la ligne est recréée telle quelle avec une date ancienne)
    bench
        .service
        .rotate_tenant_key(Some(ALPHA.to_string()))
        .await
        .expect("première clé");
    bench
        .run(
            "LET $k = (SELECT * FROM ONLY secrets_tenant_key WHERE scope_key = 'alpha' LIMIT 1);
             DELETE $k.id;
             CREATE secrets_tenant_key CONTENT object::extend(object::remove($k, 'id'), { created_at: time::now() - 400d });",
        )
        .await;
    let secret = bench.secret(Some(ALPHA), "api/cle").await;
    bench.put(&secret, b"valeur").await;
    let old: String = bench
        .value("SELECT VALUE key_id FROM ONLY secrets_tenant_key WHERE scope_key = 'alpha' LIMIT 1")
        .await;

    let report = pass(&bench, RotatorRegistry::new()).await;
    assert_eq!(report.tenant_keys_rotated, 1, "{report:?}");
    assert_eq!(report.resealed, 1, "{report:?}");
    assert_eq!(report.destroyed_keys, 1, "{report:?}");
    assert_eq!(report.failed, 0, "{report:?}");
    let active: String = bench
        .value("SELECT VALUE key_id FROM ONLY secrets_tenant_key WHERE scope_key = 'alpha' AND state = 'active' LIMIT 1")
        .await;
    assert_ne!(active, old);
    assert_eq!(bench.read(&secret).await, b"valeur");
    // La nouvelle clé est récente : rien à refaire
    assert_eq!(
        pass(&bench, RotatorRegistry::new())
            .await
            .tenant_keys_rotated,
        0
    );
    // Rotation désactivée par les réglages : une clé ancienne reste
    bench
        .store
        .settings_set(lyxal_secrets::models::SettingsSetParams {
            tenant: Some(ALPHA.to_string()),
            tenant_key_rotation_days: Some(0),
            ..Default::default()
        })
        .await
        .expect("réglages");
    let effective = bench
        .store
        .settings_get(lyxal_secrets::models::SettingsGetParams {
            tenant: Some(ALPHA.to_string()),
        })
        .await
        .expect("réglages")
        .effective;
    assert_eq!(effective.tenant_key_rotation_days, 0);
}

#[tokio::test]
async fn no_value_appears_in_errors_or_debug() {
    let bench = bench().await;
    let secret = bench.secret(Some(ALPHA), "rot/debug").await;
    bench.put(&secret, b"valeur-tres-secrete").await;
    let rotator = Arc::new(TestRotator::failing(1));
    let service = service(&bench, &rotator);
    let rotation = service
        .rotate_now(rotate(&secret, false))
        .await
        .expect("rotation");
    let error = RotatorError::retryable("TEST_SERVICE_REFUSED");
    let debug = [
        format!("{rotation:?}"),
        format!("{error:?}"),
        error.to_string(),
        format!("{:?}", registry(&rotator)),
        format!("{:?}", rotations(&bench, &secret).await),
        format!("{:?}", fiche(&bench, &secret).await),
    ];
    for text in &debug {
        assert!(!text.contains("valeur-tres-secrete"), "{text}");
        assert!(!text.contains("nouvelle-1"), "{text}");
    }
    assert!(debug[3].contains("lyxal_test_rotator"));
}

/// Rotation démarrée par la session système, en attente d'un worker.
async fn started(bench: &Bench, secret: &str) -> RotationRecord {
    bench
        .store
        .rotation_begin(RotationBeginParams {
            secret: secret.to_string(),
            emergency: None,
            reason: None,
        })
        .await
        .expect("démarrage")
}

async fn claim(bench: &Bench, rotation: &RotationRecord) -> RotationRecord {
    bench
        .store
        .rotation_claim(RotationClaimParams {
            rotation: Some(rotation.id.to_sql()),
            ..RotationClaimParams::default()
        })
        .await
        .expect("réservation")
        .items
        .pop()
        .expect("rotation réservée")
}

#[tokio::test]
async fn a_stale_reservation_taken_over_no_longer_advances_the_rotation() {
    let bench = bench().await;
    let secret = bench.secret(Some(ALPHA), "rot/bail").await;
    bench.put(&secret, b"ancienne").await;
    let rotation = started(&bench, &secret).await;
    let stale = claim(&bench, &rotation).await;
    // La réservation du premier worker expire ; un second la reprend
    bench
        .run(&format!(
            "UPDATE {} SET locked_until = time::now() - 1s",
            rotation.id.to_sql()
        ))
        .await;
    let current = claim(&bench, &rotation).await;
    assert_ne!(stale.lease, current.lease);

    // Le premier worker se réveille avec son ancien jeton : il crée sa valeur, mais l'étape est
    // refusée ; il s'arrête sans enregistrer d'échec
    let rotator = Arc::new(TestRotator::default());
    let runner = RotationRunner::new(
        bench.store.clone(),
        Some(bench.master.clone()),
        registry(&rotator),
    );
    let outcome = runner.advance(stale).await.expect("avancée");
    assert!(matches!(outcome, RotationOutcome::LeaseLost), "{outcome:?}");
    let after = rotations(&bench, &secret).await.remove(0);
    assert_eq!(after.state, RotationState::Started, "{after:?}");
    assert_eq!(after.attempts, 0, "fail non appelé : {after:?}");
    assert_eq!(after.last_error, None);
    assert_eq!(after.lease, current.lease);
    assert_eq!(bench.read(&secret).await, b"ancienne");

    // Le détenteur actuel termine, en reprenant la valeur déjà écrite
    match runner.advance(current).await.expect("avancée") {
        RotationOutcome::Advanced(done) => {
            assert_eq!(done.state, RotationState::Succeeded, "{done:?}")
        }
        other => panic!("rotation non terminée : {other:?}"),
    }
    assert_eq!(TestRotator::count(&rotator.creates), 1);
    assert_eq!(bench.read(&secret).await, b"nouvelle-1");
}

/// Rotateur dont la création n'aboutit jamais (service extérieur muet).
struct BlockingRotator {
    entered: tokio::sync::Notify,
}

#[async_trait]
impl SecretRotator for BlockingRotator {
    fn name(&self) -> &str {
        "lyxal_test_blocking"
    }

    fn handles(&self, _secret: &SecretRecord) -> bool {
        true
    }

    async fn create(
        &self,
        _secret: &SecretRecord,
        _current: Option<&SecretBytes>,
    ) -> Result<SecretBytes, RotatorError> {
        self.entered.notify_one();
        std::future::pending().await
    }

    async fn install(
        &self,
        _secret: &SecretRecord,
        _new: &SecretBytes,
    ) -> Result<(), RotatorError> {
        Ok(())
    }

    async fn test(&self, _secret: &SecretRecord, _value: &SecretBytes) -> Result<(), RotatorError> {
        Ok(())
    }
}

#[tokio::test]
async fn the_worker_stops_while_a_rotator_hangs_and_leaves_the_rotation_as_recorded() {
    let bench = bench().await;
    let secret = bench.secret(Some(ALPHA), "rot/muet").await;
    bench.put(&secret, b"ancienne").await;
    started(&bench, &secret).await;
    let rotator = Arc::new(BlockingRotator {
        entered: tokio::sync::Notify::new(),
    });
    let mut rotators = RotatorRegistry::new();
    rotators.register(rotator.clone());
    let worker = worker(&bench, rotators);
    let descriptor = worker.descriptor().clone();
    let cancellation = CancellationToken::new();
    let context = WorkerContext::new(
        descriptor.module_id.clone(),
        descriptor.id.clone(),
        ModuleContext::new(descriptor.module_id.clone()),
        cancellation.clone(),
    );
    let stopper = async {
        tokio::time::timeout(Duration::from_secs(30), rotator.entered.notified())
            .await
            .expect("rotateur atteint");
        let asked = tokio::time::Instant::now();
        cancellation.cancel();
        asked
    };
    let (ran, asked) = tokio::join!(
        async {
            let ran = worker.run(context).await;
            (ran, tokio::time::Instant::now())
        },
        stopper
    );
    let (ran, stopped) = ran;
    ran.expect("arrêt propre");
    assert!(
        stopped.duration_since(asked) < Duration::from_secs(2),
        "arrêt en {:?}",
        stopped.duration_since(asked)
    );
    let rotation = rotations(&bench, &secret).await.remove(0);
    assert_eq!(rotation.state, RotationState::Started, "{rotation:?}");
    assert_eq!(rotation.attempts, 0);
    assert_eq!(bench.read(&secret).await, b"ancienne");
}

#[tokio::test]
async fn a_passing_begin_failure_leaves_the_reminder_for_the_next_pass() {
    let bench = bench().await;
    let mut params = SecretCreateParams::new(Some(ALPHA.to_string()), "rot/plus-tard", "api_key");
    params.rotation_period = Some(Duration::from_secs(3600).into());
    let secret = bench.secret_with(params).await;
    bench.put(&secret, b"valeur").await;
    bench
        .run(&format!(
            "UPDATE {secret} SET next_rotation_at = time::now() - 1m"
        ))
        .await;
    // Démarrage indisponible pour ce test : erreur passagère (master data retentable)
    bench
        .run(
            "DEFINE FUNCTION OVERWRITE fn::secrets_rotation_begin($params: object) {
                RETURN fn::error_result('SECRETS_ROTATION_TEST_FAILED', 'fr', {});
            };",
        )
        .await;
    let rotator = Arc::new(TestRotator::default());
    let report = pass(&bench, registry(&rotator)).await;
    assert_eq!(report.alerts, 0, "{report:?}");
    assert_eq!(report.failed, 1, "{report:?}");
    assert!(fiche(&bench, &secret).await.rotation_notified_at.is_none());
    assert!(rotations(&bench, &secret).await.is_empty());
}
