//! Rotation d'une clé d'organisation et rescellement ; rotation de la clé maîtresse du
//! coffre-fort et rescellement des clés d'organisation ; organisation supprimée.

use lyxal_runtime::worker::CancellationToken;
use lyxal_secrets::{MaintenanceReport, MasterKeys, SecretsMaintenanceWorker};
use std::time::Duration;

use crate::support::{bench, code, master_key, reveal, Bench, ALPHA, BETA};

fn worker(bench: &Bench, master: Option<MasterKeys>) -> SecretsMaintenanceWorker {
    SecretsMaintenanceWorker::new(bench.store.clone(), master, Duration::from_secs(3600), 2)
        .expect("worker")
}

async fn pass(bench: &Bench, master: Option<MasterKeys>) -> MaintenanceReport {
    worker(bench, master)
        .run_once(&CancellationToken::new())
        .await
        .expect("passage")
}

#[tokio::test]
async fn tenant_key_rotation_reseals_every_version_then_destroys_the_old_key() {
    let bench = bench().await;
    let mut secrets = Vec::new();
    for index in 0..3 {
        let secret = bench.secret(Some(ALPHA), &format!("api/{index}")).await;
        bench
            .put(&secret, format!("valeur {index}").as_bytes())
            .await;
        bench
            .put(&secret, format!("valeur {index} bis").as_bytes())
            .await;
        secrets.push(secret);
    }
    let beta = bench.secret(Some(BETA), "api/beta").await;
    bench.put(&beta, b"valeur beta").await;
    let old: String = bench
        .value("SELECT VALUE key_id FROM ONLY secrets_tenant_key WHERE scope_key = 'alpha' LIMIT 1")
        .await;

    let rotated = bench
        .service
        .rotate_tenant_key(Some(ALPHA.to_string()))
        .await
        .expect("rotation");
    assert_eq!(rotated.retired.as_deref(), Some(old.as_str()));
    assert_ne!(rotated.key_id, old);
    // Avant le rescellement : anciennes versions lisibles, nouvelles scellées par la nouvelle clé
    assert_eq!(bench.read(&secrets[0]).await, b"valeur 0 bis");
    let added = bench
        .service
        .put(crate::support::put(&secrets[0], b"valeur 0 ter"))
        .await
        .expect("écriture");
    assert_eq!(
        added.version.key_id.as_deref(),
        Some(rotated.key_id.as_str())
    );

    // Paquets de deux : le passage enchaîne les paquets, puis détruit l'ancienne clé
    let report = pass(&bench, Some(bench.master.clone())).await;
    assert_eq!(report.resealed, 6, "{report:?}");
    assert_eq!(report.destroyed_keys, 1, "{report:?}");
    assert_eq!(report.failed, 0, "{report:?}");
    let states: Vec<String> = bench
        .values(&format!(
            "SELECT VALUE state FROM secrets_tenant_key WHERE key_id = '{old}'"
        ))
        .await;
    assert_eq!(states, vec!["destroyed".to_string()]);
    let erased: bool = bench
        .value(&format!(
            "RETURN (SELECT VALUE wrapped FROM ONLY secrets_tenant_key WHERE key_id = '{old}' LIMIT 1) IS NONE"
        ))
        .await;
    assert!(erased, "matière effacée");
    let remaining: i64 = bench
        .value(&format!(
            "RETURN count(SELECT id FROM secrets_version WHERE key_id = '{old}')"
        ))
        .await;
    assert_eq!(remaining, 0);

    // Toutes les valeurs restent lisibles, versions anciennes comprises
    for (index, secret) in secrets.iter().enumerate() {
        let first = bench
            .service
            .reveal(lyxal_secrets::RevealRequest {
                number: Some(1),
                ..reveal(secret)
            })
            .await
            .expect("version 1");
        assert_eq!(
            first.value.expose_secret(),
            format!("valeur {index}").as_bytes()
        );
    }
    assert_eq!(bench.read(&beta).await, b"valeur beta");
    // Rien à refaire ; la rotation et la destruction sont journalisées
    assert_eq!(
        pass(&bench, Some(bench.master.clone())).await,
        MaintenanceReport::default()
    );
    let actions: Vec<String> = bench
        .journal(Some(ALPHA))
        .await
        .iter()
        .filter_map(|item| item.event["action"].as_str().map(str::to_string))
        .collect();
    assert!(
        actions.iter().any(|a| a.contains("key")),
        "journal des clés : {actions:?}"
    );
}

#[tokio::test]
async fn vault_master_key_rotation_rewraps_tenant_keys() {
    let bench = bench().await;
    let installation = bench.secret(None, "smtp/password").await;
    let alpha = bench.secret(Some(ALPHA), "api/alpha").await;
    bench.put(&installation, b"valeur installation").await;
    bench.put(&alpha, b"valeur alpha").await;

    // Nouvelle clé maîtresse ; l'ancienne fournie en lecture seule (R1)
    let rotated =
        MasterKeys::from_keys(master_key("vault-2"), Some(bench.master_key())).expect("trousseau");
    // Une ancienne clé de même identifiant mais d'un autre matériel n'ouvre rien
    let impostor = MasterKeys::from_keys(master_key("vault-2"), Some(master_key("vault-1")))
        .expect("trousseau");
    let report = pass(&bench, Some(impostor)).await;
    assert_eq!((report.rewrapped, report.failed), (0, 2), "{report:?}");

    let report = pass(&bench, Some(rotated.clone())).await;
    assert_eq!(report.rewrapped, 2, "{report:?}");
    assert_eq!(report.failed, 0, "{report:?}");
    let masters: Vec<String> = bench
        .values("SELECT VALUE master_key_id FROM secrets_tenant_key")
        .await;
    assert_eq!(masters, vec!["vault-2".to_string(), "vault-2".to_string()]);

    // La nouvelle clé seule suffit ; l'ancienne seule ne lit plus rien
    let only_new = bench.service_with(Some(rotated.clone()));
    assert_eq!(
        only_new
            .reveal(reveal(&alpha))
            .await
            .expect("lecture")
            .value
            .expose_secret(),
        b"valeur alpha"
    );
    assert_eq!(
        code(bench.service.reveal(reveal(&installation)).await),
        "SECRETS_TENANT_KEY_UNAVAILABLE"
    );
    assert_eq!(pass(&bench, Some(rotated)).await.rewrapped, 0);
}

#[tokio::test]
async fn a_deleted_organization_takes_its_keys_and_secrets_with_it() {
    let bench = bench().await;
    let beta = bench.secret(Some(BETA), "api/beta").await;
    bench.put(&beta, b"valeur beta").await;
    let alpha = bench.secret(Some(ALPHA), "api/alpha").await;
    bench.put(&alpha, b"valeur alpha").await;

    bench.run("DELETE auth_organization:beta").await;
    let keys: i64 = bench
        .value("RETURN count(SELECT id FROM secrets_tenant_key WHERE scope_key = 'beta')")
        .await;
    assert_eq!(keys, 0, "clés supprimées avec l'organisation");
    let versions: i64 = bench
        .value("RETURN count(SELECT id FROM secrets_version WHERE scope_key = 'beta')")
        .await;
    assert_eq!(versions, 0);
    assert_eq!(
        code(bench.service.reveal(reveal(&beta)).await),
        "SECRETS_SECRET_NOT_FOUND"
    );
    // Les autres organisations ne sont pas touchées
    assert_eq!(bench.read(&alpha).await, b"valeur alpha");
}

/// Versions de secrets supprimés : rescellées comme les autres (la valeur ne change pas), sans
/// bloquer le reste du travail ; l'ancienne clé est détruite au même passage.
#[tokio::test]
async fn versions_of_deleted_secrets_are_resealed_without_blocking_the_others() {
    let bench = bench().await;
    let mut deleted = Vec::new();
    for index in 0..3 {
        let secret = bench
            .secret(Some(ALPHA), &format!("supprime/{index}"))
            .await;
        bench.put(&secret, b"ancienne").await;
        deleted.push(secret);
    }
    let live = bench.secret(Some(ALPHA), "vivant").await;
    bench.put(&live, b"vivante").await;
    for secret in &deleted {
        bench
            .run(&format!(
                "RETURN fn::secrets_secret_delete({{ secret: '{secret}' }})"
            ))
            .await;
    }
    bench
        .service
        .rotate_tenant_key(Some(ALPHA.to_string()))
        .await
        .expect("rotation");

    // Paquets de 2 : les trois versions supprimées passent avant la version vivante
    let report = pass(&bench, Some(bench.master.clone())).await;
    assert_eq!(report.failed, 0, "{report:?}");
    assert_eq!(report.resealed, 4, "{report:?}");
    assert_eq!(report.destroyed_keys, 1, "{report:?}");
    assert_eq!(bench.read(&live).await, b"vivante");
    let retired: Vec<String> = bench
        .values("SELECT VALUE key_id FROM secrets_tenant_key WHERE scope_key = 'alpha' AND state = 'decrypt_only'")
        .await;
    assert!(retired.is_empty(), "{retired:?}");
}
