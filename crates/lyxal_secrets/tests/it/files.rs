//! Clés de fichiers (`FileKeys`) : clé « fichiers » de l'organisation distincte de sa clé
//! « secrets », scellement et ouverture liés au contexte du fichier, sans clé maîtresse,
//! rotation et rescellement, destruction sur l'avis de l'hôte, rotation de la clé maîtresse.

use lyxal_crypto::{SecretContext, StreamDecryptor, StreamEncryptor, StreamKey};
use lyxal_runtime::worker::CancellationToken;
use lyxal_secrets::{FileKeys, MasterKeys, RotatorRegistry, SecretsMaintenance};
use lyxal_surreal::RecordId;

use crate::support::{bench, Bench, ALPHA};

fn alpha() -> RecordId {
    RecordId::parse_simple(ALPHA).expect("organisation")
}

fn context(record: &str) -> SecretContext {
    SecretContext::with_tenant(
        "alpha",
        "lyxal_storage",
        "storage_object",
        record,
        "content_key",
    )
    .expect("contexte")
}

fn keys(bench: &Bench, master: Option<MasterKeys>) -> FileKeys {
    FileKeys::new(bench.store.clone(), master)
}

/// Chiffre avec une clé, déchiffre avec l'autre : vrai si elles sont égales.
fn same_key(sealing: &StreamKey, opened: &StreamKey, context: &SecretContext) -> bool {
    let (mut encryptor, header) = StreamEncryptor::new(sealing, context).expect("chiffrement");
    let mut out = Vec::new();
    encryptor
        .update(b"contenu du fichier", &mut out)
        .expect("chiffrement");
    encryptor.finish(&mut out).expect("chiffrement");
    let total = (header.len() + out.len()) as u64;
    let decryptor = StreamDecryptor::new(opened, context, &header, total).expect("en-tête");
    decryptor
        .decrypt_segment(0, &out)
        .is_ok_and(|plain| plain.expose_secret() == b"contenu du fichier")
}

async fn key_rows(bench: &Bench) -> Vec<(String, String, String)> {
    bench
        .values::<Vec<String>>(
            "SELECT VALUE [purpose, key_id, state] FROM secrets_tenant_key WHERE scope_key = 'alpha' ORDER BY created_at",
        )
        .await
        .into_iter()
        .map(|row| (row[0].clone(), row[1].clone(), row[2].clone()))
        .collect()
}

#[tokio::test]
async fn a_file_key_is_sealed_by_the_files_key_of_its_organization() {
    let bench = bench().await;
    let files = keys(&bench, Some(bench.master.clone()));
    assert!(files.is_available());
    let key = StreamKey::generate().expect("clé de fichier");
    let sealed = files
        .seal(Some(&alpha()), &key, &context("o1"))
        .await
        .expect("scellement");
    assert!(sealed.key_id().starts_with("alpha-files-"), "{sealed:?}");
    assert!(sealed.as_str().starts_with("enc:v2:"));
    assert!(!format!("{sealed:?}").contains(&sealed.as_str()[20..]));
    assert!(!format!("{files:?}").contains("enc:v2"));

    // Clé « fichiers » créée au premier fichier, sans clé « secrets »
    let rows = key_rows(&bench).await;
    assert_eq!(rows.len(), 1);
    assert_eq!(
        (rows[0].0.as_str(), rows[0].2.as_str()),
        ("files", "active")
    );

    let opened = files
        .open(Some(&alpha()), &sealed, &context("o1"))
        .await
        .expect("ouverture");
    assert!(same_key(&key, &opened, &context("o1")));
    // Le scellement suivant réutilise la clé active
    let other = files
        .seal(
            Some(&alpha()),
            &StreamKey::generate().expect("clé"),
            &context("o2"),
        )
        .await
        .expect("scellement");
    assert_eq!(other.key_id(), sealed.key_id());

    // Une valeur de secret crée la clé « secrets », distincte
    let secret = bench.secret(Some(ALPHA), "api/alpha").await;
    bench.put(&secret, b"valeur").await;
    let rows = key_rows(&bench).await;
    assert_eq!(rows.len(), 2);
    assert_eq!(rows[1].0, "secrets");
    assert_ne!(rows[1].1, rows[0].1);

    // Autre fiche, autre organisation : la clé ne s'ouvre pas
    let error = files
        .open(Some(&alpha()), &sealed, &context("o2"))
        .await
        .expect_err("autre fiche");
    assert_eq!(error.code(), "SECRETS_VALUE_CORRUPTED");
    let beta = RecordId::parse_simple("auth_organization:beta").expect("organisation");
    let error = files
        .open(Some(&beta), &sealed, &context("o1"))
        .await
        .expect_err("autre organisation");
    assert_eq!(error.code(), "SECRETS_TENANT_KEY_UNAVAILABLE");
    assert_eq!(
        FileKeys::context_tenant(Some(&alpha())).expect("organisation"),
        "alpha"
    );
    assert_eq!(
        FileKeys::context_tenant(None).expect("installation"),
        "lyxal_installation"
    );
}

#[tokio::test]
async fn without_master_key_no_file_key_is_sealed_or_opened() {
    let bench = bench().await;
    let files = keys(&bench, None);
    assert!(!files.is_available());
    let key = StreamKey::generate().expect("clé");
    let error = files
        .seal(Some(&alpha()), &key, &context("o1"))
        .await
        .expect_err("refus");
    assert_eq!(error.code(), "SECRETS_CRYPTO_UNAVAILABLE");
    assert!(key_rows(&bench).await.is_empty());
}

#[tokio::test]
async fn a_files_key_rotation_reseals_then_destroys_on_the_host_advice() {
    let bench = bench().await;
    let files = keys(&bench, Some(bench.master.clone()));
    let key = StreamKey::generate().expect("clé");
    let sealed = files
        .seal(Some(&alpha()), &key, &context("o1"))
        .await
        .expect("scellement");
    // Rien à resceller tant que la clé est active
    assert!(files
        .reseal(Some(&alpha()), &sealed, &context("o1"))
        .await
        .expect("rescellement")
        .is_none());
    assert!(files.retired(10, 0).await.expect("retirées").is_empty());

    // Clé « fichiers » vieillie au-delà de sa période (365 jours) : la maintenance la remplace
    bench
        .run(&format!(
            "LET $k = (SELECT * FROM ONLY secrets_tenant_key WHERE key_id = '{}' LIMIT 1);
             DELETE $k.id;
             CREATE secrets_tenant_key CONTENT {{ tenant: $k.tenant, purpose: 'files', key_id: $k.key_id, wrapped: $k.wrapped, created_at: time::now() - 400d }};",
            sealed.key_id()
        ))
        .await;
    let report = SecretsMaintenance::new(
        bench.store.clone(),
        Some(bench.master.clone()),
        RotatorRegistry::new(),
        10,
    )
    .run(&CancellationToken::new())
    .await
    .expect("maintenance");
    assert_eq!(report.tenant_keys_rotated, 1, "{report:?}");
    // La maintenance du coffre-fort ne détruit pas une clé « fichiers » : seul l'hôte sait
    assert_eq!(report.destroyed_keys, 0);
    let retired = files.retired(10, 0).await.expect("retirées");
    assert_eq!(retired.len(), 1);
    assert_eq!(retired[0].key_id, sealed.key_id());

    let resealed = files
        .reseal(Some(&alpha()), &sealed, &context("o1"))
        .await
        .expect("rescellement")
        .expect("clé rescellée");
    assert_ne!(resealed.key_id(), sealed.key_id());
    let opened = files
        .open(Some(&alpha()), &resealed, &context("o1"))
        .await
        .expect("ouverture");
    assert!(same_key(&key, &opened, &context("o1")));

    // Destruction : refusée tant que l'hôte dit la clé utilisée
    let error = files
        .destroy(sealed.key_id(), true)
        .await
        .expect_err("clé utilisée");
    assert_eq!(error.code(), "SECRETS_TENANT_KEY_CONFLICT");
    assert!(files
        .destroy(sealed.key_id(), false)
        .await
        .expect("destruction"));
    assert!(files.retired(10, 0).await.expect("retirées").is_empty());
    let error = files
        .open(Some(&alpha()), &sealed, &context("o1"))
        .await
        .expect_err("ancienne clé détruite");
    assert_eq!(error.code(), "SECRETS_TENANT_KEY_UNAVAILABLE");
}

#[tokio::test]
async fn a_master_key_rotation_rewraps_files_keys_too() {
    let bench = bench().await;
    let files = keys(&bench, Some(bench.master.clone()));
    let key = StreamKey::generate().expect("clé");
    let sealed = files
        .seal(Some(&alpha()), &key, &context("o1"))
        .await
        .expect("scellement");
    let material = std::sync::Arc::new(lyxal_crypto::EncryptionKey::generate().expect("clé"));
    let vault_2 = || {
        lyxal_crypto::ResolvedKey::new(
            lyxal_crypto::KeyId::parse("vault-2").expect("identifiant"),
            material.clone(),
        )
    };
    let rotated = MasterKeys::from_keys(vault_2(), Some(bench.master_key())).expect("trousseau");
    let report = SecretsMaintenance::new(
        bench.store.clone(),
        Some(rotated),
        RotatorRegistry::new(),
        10,
    )
    .run(&CancellationToken::new())
    .await
    .expect("maintenance");
    assert_eq!((report.rewrapped, report.failed), (1, 0), "{report:?}");
    // La nouvelle clé maîtresse seule suffit
    let only_new = MasterKeys::from_keys(vault_2(), None).expect("trousseau");
    let opened = keys(&bench, Some(only_new))
        .open(Some(&alpha()), &sealed, &context("o1"))
        .await
        .expect("ouverture");
    assert!(same_key(&key, &opened, &context("o1")));
}

/// Rotation de la clé « fichiers » active d'alpha par la maintenance du coffre-fort (clé vieillie
/// au-delà de sa période).
async fn rotate_files_key(bench: &Bench, key_id: &str) {
    bench
        .run(&format!(
            "LET $k = (SELECT * FROM ONLY secrets_tenant_key WHERE key_id = '{key_id}' LIMIT 1);
             DELETE $k.id;
             CREATE secrets_tenant_key CONTENT {{ tenant: $k.tenant, purpose: 'files', key_id: $k.key_id, wrapped: $k.wrapped, created_at: time::now() - 400d }};"
        ))
        .await;
    let report = SecretsMaintenance::new(
        bench.store.clone(),
        Some(bench.master.clone()),
        RotatorRegistry::new(),
        10,
    )
    .run(&CancellationToken::new())
    .await
    .expect("maintenance");
    assert_eq!(report.tenant_keys_rotated, 1, "{report:?}");
}

#[tokio::test]
async fn the_cache_serves_openings_only_and_never_seals() {
    let bench = bench().await;
    let cached = keys(&bench, Some(bench.master.clone())).with_cache();
    assert_eq!(keys(&bench, Some(bench.master.clone())).cache_stats(), None);
    let key = StreamKey::generate().expect("clé");
    let sealed = cached
        .seal(Some(&alpha()), &key, &context("o1"))
        .await
        .expect("scellement");
    // Un scellement ne garde rien : la première ouverture relit le trousseau, la suivante non
    let stats = |files: &FileKeys| files.cache_stats().expect("cache");
    assert_eq!((stats(&cached).hits, stats(&cached).entries), (0, 0));
    for _ in 0..3 {
        let opened = cached
            .open(Some(&alpha()), &sealed, &context("o1"))
            .await
            .expect("ouverture");
        assert!(same_key(&key, &opened, &context("o1")));
    }
    assert_eq!(
        (
            stats(&cached).hits,
            stats(&cached).misses,
            stats(&cached).entries
        ),
        (2, 1, 1)
    );
    // Une copie partage le cache ; une enveloppe recopiée d'un autre fichier reste refusée
    let copy = cached.clone();
    let error = copy
        .open(Some(&alpha()), &sealed, &context("o2"))
        .await
        .expect_err("autre fichier");
    assert_eq!(error.code(), "SECRETS_VALUE_CORRUPTED");
    assert_eq!(stats(&cached).hits, 3);

    // Rotation faite ailleurs (maintenance du coffre-fort) : la clé gardée n'est plus active.
    // Le scellement relit le trousseau et prend la nouvelle clé, jamais celle du cache
    rotate_files_key(&bench, sealed.key_id()).await;
    let after = cached
        .seal(Some(&alpha()), &key, &context("o3"))
        .await
        .expect("scellement après rotation");
    assert_ne!(after.key_id(), sealed.key_id());
    assert!(cached
        .reseal(Some(&alpha()), &sealed, &context("o1"))
        .await
        .expect("rescellement")
        .is_some_and(|resealed| resealed.key_id() == after.key_id()));
    // L'ancienne clé, decrypt_only, s'ouvre encore depuis le cache
    let hits = stats(&cached).hits;
    cached
        .open(Some(&alpha()), &sealed, &context("o1"))
        .await
        .expect("ouverture par la clé retirée");
    assert_eq!(stats(&cached).hits, hits + 1);

    // Destruction par un autre nœud : l'entrée vit jusqu'à son expiration (60 s au plus) sur ce
    // nœud ; le nœud qui détruit l'oublie aussitôt
    let other_node = keys(&bench, Some(bench.master.clone())).with_cache();
    other_node
        .open(Some(&alpha()), &sealed, &context("o1"))
        .await
        .expect("ouverture sur l'autre nœud");
    assert!(other_node
        .destroy(sealed.key_id(), false)
        .await
        .expect("destruction"));
    let error = other_node
        .open(Some(&alpha()), &sealed, &context("o1"))
        .await
        .expect_err("clé détruite, oubliée aussitôt");
    assert_eq!(error.code(), "SECRETS_TENANT_KEY_UNAVAILABLE");
    cached
        .open(Some(&alpha()), &sealed, &context("o1"))
        .await
        .expect("entrée encore gardée sur le premier nœud");
    // Une clé jamais gardée et détruite : relue en base, refusée
    let fresh = keys(&bench, Some(bench.master.clone())).with_cache();
    let error = fresh
        .open(Some(&alpha()), &sealed, &context("o1"))
        .await
        .expect_err("clé détruite");
    assert_eq!(error.code(), "SECRETS_TENANT_KEY_UNAVAILABLE");
}

#[tokio::test]
async fn the_cache_opens_nothing_without_the_master_key() {
    let bench = bench().await;
    let files = keys(&bench, Some(bench.master.clone())).with_cache();
    let key = StreamKey::generate().expect("clé");
    let sealed = files
        .seal(Some(&alpha()), &key, &context("o1"))
        .await
        .expect("scellement");
    let error = keys(&bench, None)
        .with_cache()
        .open(Some(&alpha()), &sealed, &context("o1"))
        .await
        .expect_err("sans clé maîtresse");
    assert_eq!(error.code(), "SECRETS_CRYPTO_UNAVAILABLE");
}
