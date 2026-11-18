//! Sans clé maîtresse : chiffrement indisponible, fiches consultables, module dégradé (R5).
//! Sonde de santé et maintenance arrêtée par l'annulation.

use lyxal_runtime::health::{HealthStatus, ModuleHealthCheck};
use lyxal_runtime::worker::CancellationToken;
use lyxal_runtime::ModuleContext;
use lyxal_secrets::models::{SecretGetParams, SecretListParams};
use lyxal_secrets::{
    MaintenanceReport, MasterKeys, RotatorRegistry, SecretsHealthCheck, SecretsMaintenance,
    MODULE_ID,
};

use crate::support::{bench, code, master_key, put, reveal, ALPHA};

#[tokio::test]
async fn without_a_master_key_values_are_refused_and_records_stay_readable() {
    let bench = bench().await;
    let secret = bench.secret(Some(ALPHA), "api/sans-cle").await;
    bench.put(&secret, b"valeur").await;
    let without = bench.service_with(None);
    assert_eq!(
        code(without.put(put(&secret, b"autre")).await),
        "SECRETS_CRYPTO_UNAVAILABLE"
    );
    assert_eq!(
        code(without.reveal(reveal(&secret)).await),
        "SECRETS_CRYPTO_UNAVAILABLE"
    );
    assert_eq!(
        code(without.rotate_tenant_key(Some(ALPHA.into())).await),
        "SECRETS_CRYPTO_UNAVAILABLE"
    );
    // Fiches et versions consultables
    let record = without
        .store()
        .secret_get(SecretGetParams::by_id(secret.clone()))
        .await
        .expect("fiche");
    assert_eq!(record.latest_version, 1);
    let list = without
        .store()
        .secret_list(SecretListParams {
            tenant: Some(ALPHA.into()),
            ..SecretListParams::default()
        })
        .await
        .expect("liste");
    assert_eq!(list.total, 1);

    // Sonde dégradée ; le worker se contente de la purge
    let context = ModuleContext::new(MODULE_ID);
    let probe = SecretsHealthCheck::new(bench.store.clone(), None)
        .check(&context)
        .await
        .expect("sonde");
    assert_eq!(probe.status, HealthStatus::Degraded, "{probe:?}");
    assert!(probe
        .message
        .as_deref()
        .is_some_and(|m| m.contains("SECRETS_CRYPTO_UNAVAILABLE")));
    let report = SecretsMaintenance::new(bench.store.clone(), None, RotatorRegistry::new(), 10)
        .run(&CancellationToken::new())
        .await
        .expect("passage");
    assert_eq!(report, MaintenanceReport::default());
}

#[tokio::test]
async fn the_probe_follows_the_master_key_and_pending_reseals() {
    let bench = bench().await;
    let context = ModuleContext::new(MODULE_ID);
    let secret = bench.secret(Some(ALPHA), "api/sonde").await;
    bench.put(&secret, b"valeur").await;

    let healthy = SecretsHealthCheck::new(bench.store.clone(), Some(bench.master.clone()))
        .check(&context)
        .await
        .expect("sonde");
    assert_eq!(healthy.status, HealthStatus::Healthy, "{healthy:?}");
    assert!(healthy
        .message
        .as_deref()
        .is_some_and(|m| m.contains("aucun rescellement en attente")));

    // Rotation de la clé maîtresse : rescellement annoncé, puis sa fin
    let rotated =
        MasterKeys::from_keys(master_key("vault-2"), Some(bench.master_key())).expect("trousseau");
    let pending = SecretsHealthCheck::new(bench.store.clone(), Some(rotated.clone()))
        .check(&context)
        .await
        .expect("sonde");
    assert!(
        pending
            .message
            .as_deref()
            .is_some_and(|m| m.contains("rescellement en attente : 1 clé")),
        "{pending:?}"
    );
    // Clé maîtresse de ces clés absente du trousseau : dégradé
    let lost = MasterKeys::from_keys(master_key("vault-3"), None).expect("trousseau");
    let missing = SecretsHealthCheck::new(bench.store.clone(), Some(lost))
        .check(&context)
        .await
        .expect("sonde");
    assert_eq!(missing.status, HealthStatus::Degraded, "{missing:?}");

    SecretsMaintenance::new(
        bench.store.clone(),
        Some(rotated.clone()),
        RotatorRegistry::new(),
        10,
    )
    .run(&CancellationToken::new())
    .await
    .expect("passage");
    let done = SecretsHealthCheck::new(bench.store.clone(), Some(rotated))
        .check(&context)
        .await
        .expect("sonde");
    assert_eq!(done.status, HealthStatus::Healthy);
    assert!(
        done.message
            .as_deref()
            .is_some_and(|m| m.contains("ancienne clé maîtresse vault-1 peut être retirée")),
        "{done:?}"
    );
}

#[tokio::test]
async fn the_maintenance_stops_on_cancellation() {
    let bench = bench().await;
    let worker = SecretsMaintenance::new(
        bench.store.clone(),
        Some(bench.master.clone()),
        RotatorRegistry::new(),
        10,
    );
    // Annulation avant le passage : rien n'est fait
    let cancelled = CancellationToken::new();
    cancelled.cancel();
    assert_eq!(
        worker.run(&cancelled).await.expect("passage"),
        MaintenanceReport::default()
    );
}
