//! Buckets chiffrés : fichier relu à l'identique, octets stockés chiffrés et empreinte du
//! chiffré, plages à cheval sur des segments, altérations détectées au bon segment, refus sans
//! service de clés, antivirus et type réel sur le clair, rescellement après la rotation de la
//! clé « fichiers » puis destruction de l'ancienne clé, compteurs de volume, écritures
//! simultanées.

use bytes::Bytes;
use futures::StreamExt;
use lyxal_crypto::{stream_ciphertext_len, EncryptionKey, KeyId, ResolvedKey};
use lyxal_runtime::worker::CancellationToken;
use lyxal_secrets::{FileKeys, MasterKeys, RotatorRegistry, SecretsMaintenance, SecretsStore};
use lyxal_storage::models::{
    BucketCreateParams, BucketRefParams, ObjectBeginParams, ObjectGetParams, ObjectRefParams,
    ObjectUsageParams, SettingsSetParams, UsageVerifyParams,
};
use lyxal_storage::{ByteRange, PutRequest, StorageCleanup, StorageService};
use lyxal_surreal::{SurrealValue, ToSql};
use object_store::ObjectStoreExt;
use std::sync::Arc;

use crate::support::{bench, chunks, load_bench, read_all, request, Bench, Kind, KINDS};

/// Contenu de quatre segments (le dernier incomplet), sans motif répété.
fn content(len: usize) -> Vec<u8> {
    (0..len)
        .map(|i| ((i * 7919 + i / 251) % 251) as u8)
        .collect()
}

fn master() -> MasterKeys {
    MasterKeys::from_keys(
        ResolvedKey::new(
            KeyId::parse("vault-1").expect("identifiant"),
            Arc::new(EncryptionKey::generate().expect("clé")),
        ),
        None,
    )
    .expect("trousseau")
}

fn file_keys(bench: &Bench, master: &MasterKeys) -> FileKeys {
    FileKeys::new(
        SecretsStore::new(bench.client.clone()),
        Some(master.clone()),
    )
}

/// Service avec le service de clés (clé maîtresse `master`).
fn encrypting(bench: &Bench, master: &MasterKeys) -> StorageService {
    bench
        .service
        .clone()
        .with_file_keys(file_keys(bench, master), bench.store.clone())
}

/// Organisation alpha et son bucket chiffré `courrier` ; rend l'identifiant du bucket.
async fn encrypted_bucket(bench: &Bench) -> String {
    bench
        .run("CREATE auth_organization:alpha CONTENT { slug: 'alpha', name: 'Alpha BTP' };")
        .await;
    bench
        .store
        .bucket_create(BucketCreateParams {
            encrypted: true,
            ..BucketCreateParams::named(Some("auth_organization:alpha".to_string()), "courrier")
        })
        .await
        .expect("bucket chiffré")
        .id
        .to_sql()
}

async fn stored_bytes(bench: &Bench, path: &str) -> Bytes {
    let backend = bench.backends.get("default").expect("support").store();
    backend
        .get(&object_store::path::Path::from(path))
        .await
        .expect("octets")
        .bytes()
        .await
        .expect("octets")
}

async fn overwrite(bench: &Bench, path: &str, bytes: Vec<u8>) {
    let backend = bench.backends.get("default").expect("support").store();
    backend
        .put(
            &object_store::path::Path::from(path),
            Bytes::from(bytes).into(),
        )
        .await
        .expect("réécriture");
}

async fn put(
    service: &StorageService,
    bucket: &str,
    key: &str,
    body: &[u8],
) -> lyxal_storage::models::StoredObject {
    service
        .put(
            PutRequest {
                size: Some(body.len() as u64),
                ..request(bucket, key)
            },
            chunks(&[&body[..body.len() / 3], &body[body.len() / 3..]]),
        )
        .await
        .expect("écriture chiffrée")
}

async fn range(service: &StorageService, object: &str, range: ByteRange) -> Vec<u8> {
    read_all(
        service
            .open(ObjectGetParams::by_id(object), Some(range))
            .await
            .expect("plage"),
    )
    .await
}

#[tokio::test]
async fn an_encrypted_file_is_stored_encrypted_and_read_back_identical() {
    for kind in KINDS {
        let bench = bench(kind).await;
        let master = master();
        let service = encrypting(&bench, &master);
        let bucket = encrypted_bucket(&bench).await;
        let body = content(200_000);
        let stored = put(&service, &bucket, "a/m1.eml", &body).await;

        assert_eq!(stored.size, Some(200_000), "{kind:?}");
        let expected_stored = stream_ciphertext_len(200_000).expect("taille");
        assert_eq!(stored.stored_size, Some(expected_stored as i64));
        let key_id = stored.content_key_id.clone().expect("clé scellée");
        assert!(key_id.starts_with("alpha-files-"), "{key_id}");
        assert!(!format!("{stored:?}").contains("enc:v2"));

        // Octets rangés : le flux chiffré, jamais le clair ; empreinte du chiffré
        let raw = stored_bytes(&bench, &stored.path).await;
        assert_eq!(raw.len() as u64, expected_stored);
        assert_eq!(&raw[..4], b"LXS1");
        assert!(!raw.windows(64).any(|window| window == &body[1000..1064]));
        assert_eq!(
            stored.blake3.as_deref(),
            Some(lyxal_crypto::hash::blake3_hex(&raw).as_str())
        );
        assert_ne!(
            stored.blake3.as_deref(),
            Some(lyxal_crypto::hash::blake3_hex(&body).as_str())
        );

        let id = stored.id.to_sql();
        let opened = service
            .open(ObjectGetParams::by_id(&id), None)
            .await
            .expect("ouverture");
        assert_eq!(opened.range, 0..200_000);
        assert_eq!(read_all(opened).await, body);
        // Plages : à cheval sur deux segments, dans le dernier, la fin, un seul octet
        assert_eq!(
            range(&service, &id, ByteRange::FromTo(65_530, 65_545)).await,
            &body[65_530..65_546]
        );
        assert_eq!(
            range(&service, &id, ByteRange::FromTo(60_000, 140_000)).await,
            &body[60_000..140_001]
        );
        assert_eq!(
            range(&service, &id, ByteRange::From(199_990)).await,
            &body[199_990..]
        );
        assert_eq!(
            range(&service, &id, ByteRange::Last(10)).await,
            &body[199_990..]
        );
        assert_eq!(
            range(&service, &id, ByteRange::FromTo(0, 0)).await,
            &body[..1]
        );
        let refused = service
            .open(ObjectGetParams::by_id(&id), Some(ByteRange::From(200_000)))
            .await
            .err()
            .expect("plage hors du fichier");
        assert_eq!(refused.code(), "STORAGE_RANGE_NOT_SATISFIABLE");

        // Vérification sur les octets stockés, sans clé
        bench.service.verify(&id).await.expect("intégrité");

        // Fichier vide et fichier d'un segment exact
        for size in [0usize, 65_536] {
            let body = content(size);
            let stored = put(&service, &bucket, &format!("a/{size}.eml"), &body).await;
            let opened = service
                .open(ObjectGetParams::by_id(stored.id.to_sql()), None)
                .await
                .expect("ouverture");
            assert_eq!(read_all(opened).await, body, "{kind:?} {size}");
            assert_eq!(
                stored.stored_size,
                Some(stream_ciphertext_len(size as u64).expect("taille") as i64)
            );
        }
    }
}

#[tokio::test]
async fn an_altered_encrypted_file_fails_at_the_altered_segment() {
    let bench = bench(Kind::Memory).await;
    let master = master();
    let service = encrypting(&bench, &master);
    let bucket = encrypted_bucket(&bench).await;
    let body = content(3 * 65_536 + 100);
    let first = put(&service, &bucket, "a/m1.eml", &body).await;
    let second = put(&service, &bucket, "a/m2.eml", &body).await;
    let original = stored_bytes(&bench, &first.path).await.to_vec();

    // Segment 1 altéré : le segment 0 est rendu, puis le flux s'interrompt par une erreur
    let mut altered = original.clone();
    altered[47 + 65_552 + 10] ^= 0x01;
    overwrite(&bench, &first.path, altered).await;
    let mut opened = service
        .open(ObjectGetParams::by_id(first.id.to_sql()), None)
        .await
        .expect("ouverture");
    let segment = opened
        .content
        .next()
        .await
        .expect("segment 0")
        .expect("segment 0 authentique");
    assert_eq!(&segment[..], &body[..65_536]);
    let error = opened
        .content
        .next()
        .await
        .expect("erreur")
        .expect_err("segment 1 altéré");
    assert_eq!(error.code(), "STORAGE_INTEGRITY_FAILED");
    assert!(
        opened.content.next().await.is_none(),
        "aucune fin normale après l'erreur"
    );
    assert_eq!(
        bench
            .service
            .verify(&first.id.to_sql())
            .await
            .expect_err("vérification")
            .code(),
        "STORAGE_INTEGRITY_FAILED"
    );

    // Fichier tronqué : erreur à la fin, jamais une fin normale
    overwrite(
        &bench,
        &first.path,
        original[..original.len() - 20].to_vec(),
    )
    .await;
    let opened = service
        .open(
            ObjectGetParams::by_id(first.id.to_sql()),
            Some(ByteRange::From(3 * 65_536)),
        )
        .await;
    let failed = match opened {
        Err(error) => error,
        Ok(mut opened) => {
            let mut last = None;
            while let Some(chunk) = opened.content.next().await {
                if let Err(error) = chunk {
                    last = Some(error);
                }
            }
            last.expect("fichier tronqué")
        }
    };
    assert_eq!(failed.code(), "STORAGE_INTEGRITY_FAILED");

    // Octets d'un autre fichier recopiés sous cette fiche : autre clé, autre contexte
    overwrite(
        &bench,
        &first.path,
        stored_bytes(&bench, &second.path).await.to_vec(),
    )
    .await;
    let mut opened = service
        .open(ObjectGetParams::by_id(first.id.to_sql()), None)
        .await
        .expect("ouverture");
    let error = opened
        .content
        .next()
        .await
        .expect("erreur")
        .expect_err("fichier recopié");
    assert_eq!(error.code(), "STORAGE_INTEGRITY_FAILED");
}

#[tokio::test]
async fn an_encrypted_bucket_is_never_written_or_read_without_keys() {
    let bench = bench(Kind::Memory).await;
    let master = master();
    let bucket = encrypted_bucket(&bench).await;
    let without_master = bench.service.clone().with_file_keys(
        FileKeys::new(SecretsStore::new(bench.client.clone()), None),
        bench.store.clone(),
    );
    for service in [&bench.service, &without_master] {
        let error = service
            .put(
                request(&bucket, "a/clair.eml"),
                chunks(&[b"From: a\r\n\r\nbonjour"]),
            )
            .await
            .expect_err("refus");
        assert_eq!(error.code(), "STORAGE_ENCRYPTION_UNAVAILABLE");
        assert!(error.is_retryable());
    }
    // Rien n'est rangé, en clair ou autrement ; l'adresse est libérée
    assert!(bench.stored_paths().await.is_empty());
    let service = encrypting(&bench, &master);
    let stored = put(&service, &bucket, "a/clair.eml", b"From: a\r\n\r\nbonjour").await;
    for refused in [&bench.service, &without_master] {
        let error = refused
            .open(ObjectGetParams::by_id(stored.id.to_sql()), None)
            .await
            .err()
            .expect("refus");
        assert_eq!(error.code(), "STORAGE_ENCRYPTION_UNAVAILABLE");
    }
    // Envoi reprenable refusé dans un bucket chiffré (parties rangées en clair)
    let error = service
        .upload_create(lyxal_storage::UploadRequest {
            bucket: bucket.clone(),
            key: "a/reprise.eml".to_string(),
            filename: "reprise.eml".to_string(),
            content_type: None,
            size: 10,
        })
        .await
        .expect_err("refus");
    assert_eq!(error.code(), "STORAGE_INVALID_PARAMETERS");
    // Un bucket en clair n'a besoin d'aucune clé
    let plain = bench.bucket("plans").await;
    let stored = put(&bench.service, &plain, "p.txt", b"plan").await;
    assert_eq!(stored.content_key_id, None);
    assert_eq!(stored.stored_size, Some(4));
}

#[tokio::test]
async fn the_antivirus_and_the_real_type_see_the_clear_content() {
    let bench = bench(Kind::Memory).await;
    let master = master();
    let bucket = encrypted_bucket(&bench).await;
    let address = crate::support::clamd(crate::support::Clamd::Scanning {
        stream_max_length: 1 << 20,
    })
    .await;
    let service =
        encrypting(&bench, &master).with_scanner(Arc::new(lyxal_storage::ClamAvScanner::new(
            lyxal_storage::ScannerConfig::Tcp { address },
            std::time::Duration::from_secs(10),
        )));
    let error = service
        .put(
            request(&bucket, "a/virus.eml"),
            chunks(&[&crate::content::eicar()]),
        )
        .await
        .expect_err("menace");
    assert_eq!(error.code(), "STORAGE_OBJECT_INFECTED");
    let stored = put(
        &service,
        &bucket,
        "a/plan.pdf",
        b"%PDF-1.4\n%plan de chantier\n",
    )
    .await;
    assert_eq!(stored.content_type.as_deref(), Some("application/pdf"));
}

#[derive(SurrealValue)]
struct KeyRow {
    key_id: String,
    state: String,
}

async fn file_key_rows(bench: &Bench) -> Vec<KeyRow> {
    bench
        .client
        .query("SELECT key_id, state FROM secrets_tenant_key WHERE purpose = 'files' ORDER BY created_at")
        .await
        .expect("clés")
        .take(0)
        .expect("clés")
}

#[tokio::test]
async fn a_files_key_rotation_reseals_file_keys_then_destroys_the_old_key() {
    let bench = bench(Kind::Disk).await;
    let master = master();
    let service = encrypting(&bench, &master);
    let bucket = encrypted_bucket(&bench).await;
    let body = content(70_000);
    let stored = put(&service, &bucket, "a/m1.eml", &body).await;
    let raw = stored_bytes(&bench, &stored.path).await;
    let old_key = stored.content_key_id.clone().expect("clé");
    // Écriture ouverte avant la rotation, encore en attente
    let pending = bench
        .store
        .object_begin(ObjectBeginParams {
            bucket: bucket.clone(),
            key: "a/attente.eml".to_string(),
            filename: "attente.eml".to_string(),
            declared_type: None,
            declared_size: Some(10),
            resumable: false,
        })
        .await
        .expect("écriture en attente");

    // Clé « fichiers » d'alpha vieillie au-delà de sa période : la maintenance la remplace
    bench
        .run(&format!(
            "LET $k = (SELECT * FROM ONLY secrets_tenant_key WHERE key_id = '{old_key}' LIMIT 1);
             DELETE $k.id;
             CREATE secrets_tenant_key CONTENT {{ tenant: $k.tenant, purpose: 'files', key_id: $k.key_id, wrapped: $k.wrapped, created_at: time::now() - 400d }};"
        ))
        .await;
    let maintenance = SecretsMaintenance::new(
        SecretsStore::new(bench.client.clone()),
        Some(master.clone()),
        RotatorRegistry::new(),
        100,
    );
    let report = maintenance
        .run(&CancellationToken::new())
        .await
        .expect("maintenance");
    assert_eq!(report.tenant_keys_rotated, 1);
    let rows = file_key_rows(&bench).await;
    assert_eq!(rows.len(), 2);
    assert_eq!(
        (rows[0].key_id.as_str(), rows[0].state.as_str()),
        (old_key.as_str(), "decrypt_only")
    );
    assert_eq!(rows[1].state, "active");

    // Nettoyage : clé du fichier rescellée sans réécrire ses octets ; l'ancienne clé est gardée
    // tant que l'écriture ouverte avant le retrait est en attente
    let cleanup = StorageCleanup::new(bench.store.clone(), bench.backends.clone(), 100)
        .with_file_keys(file_keys(&bench, &master));
    let report = cleanup
        .run(&CancellationToken::new())
        .await
        .expect("nettoyage");
    assert_eq!(
        (report.rekeyed, report.retired_keys_destroyed, report.failed),
        (1, 0, 0)
    );
    let resealed = bench
        .store
        .object_get(ObjectGetParams::by_id(stored.id.to_sql()))
        .await
        .expect("fiche");
    assert_eq!(
        resealed.content_key_id.as_deref(),
        Some(rows[1].key_id.as_str())
    );
    assert_eq!(stored_bytes(&bench, &stored.path).await, raw);
    assert_eq!(resealed.blake3, stored.blake3);
    let opened = service
        .open(ObjectGetParams::by_id(stored.id.to_sql()), None)
        .await
        .expect("ouverture");
    assert_eq!(read_all(opened).await, body);

    // L'écriture en attente partie, l'ancienne clé est détruite
    bench
        .store
        .object_delete(ObjectRefParams {
            object: pending.id.to_sql(),
        })
        .await
        .expect("abandon");
    let report = cleanup
        .run(&CancellationToken::new())
        .await
        .expect("nettoyage");
    assert_eq!(
        (report.rekeyed, report.retired_keys_destroyed, report.failed),
        (0, 1, 0)
    );
    assert_eq!(file_key_rows(&bench).await[0].state, "destroyed");
    let opened = service
        .open(
            ObjectGetParams::by_id(stored.id.to_sql()),
            Some(ByteRange::Last(5)),
        )
        .await
        .expect("ouverture");
    assert_eq!(read_all(opened).await, &body[69_995..]);
}

#[tokio::test]
async fn simultaneous_writes_keep_the_counters_exact() {
    let bench = bench(Kind::Memory).await;
    let master = master();
    let service = encrypting(&bench, &master);
    let bucket = encrypted_bucket(&bench).await;
    let writes = (0..6).map(|i| {
        let service = service.clone();
        let bucket = bucket.clone();
        async move {
            service
                .put(
                    request(&bucket, &format!("a/{i}.eml")),
                    chunks(&[&content(1_000 + i)]),
                )
                .await
        }
    });
    let results = futures::future::join_all(writes).await;
    for result in &results {
        if let Err(error) = result {
            panic!("écriture simultanée : {error}");
        }
    }
    let usage = bench
        .store
        .object_usage(lyxal_storage::models::ObjectUsageParams {
            tenant: Some("auth_organization:alpha".to_string()),
        })
        .await
        .expect("volume");
    assert_eq!(
        (usage.objects, usage.bytes, usage.reserved_bytes),
        (6, 6_015, 0)
    );
    let report = bench
        .store
        .usage_verify(UsageVerifyParams {
            tenant: Some("auth_organization:alpha".to_string()),
        })
        .await
        .expect("contrôle");
    assert!(report.valid, "{report:?}");
    assert_eq!(report.checked, 2);
}

/// Lignes de compteurs comptées par une requête de la session système.
async fn usage_lines(bench: &Bench, filter: &str) -> usize {
    let lines: Option<i64> = bench
        .client
        .query(format!(
            "RETURN count(SELECT VALUE id FROM storage_usage WHERE {filter});"
        ))
        .await
        .expect("requête")
        .take(0)
        .expect("nombre de lignes");
    usize::try_from(lines.expect("nombre")).expect("nombre positif")
}

/// Compteurs répartis sous charge : 1 000 écritures, 50 à la fois, dans une organisation et un
/// bucket, sans aucun ordre imposé par l'appelant. Les sommes des lignes sont égales aux fiches,
/// le quota refuse au dépassement, un bucket puis l'organisation emportent leurs lignes. Sur le
/// serveur désigné par `LYXAL_SURREAL_WS_URL` (pool de `LYXAL_SURREAL_CONNECTIONS` connexions)
/// s'il est posé, sinon sur la base embarquée.
///
/// Une écriture peut encore être refusée : deux écritures qui tirent la même ligne parmi 64 se
/// heurtent, et le service ne rejoue que six fois. Sur la base embarquée d'un binaire d'essai
/// non optimisé (transactions dix fois plus longues que sur un serveur), environ une écriture
/// sur 1 000 épuise ses essais à 50 écritures à la fois. Le test admet donc 1 % d'écritures
/// refusées, pour conflit de transaction seulement, et exige que les compteurs soient exacts
/// pour les fichiers acceptés : une écriture refusée ne laisse rien.
#[tokio::test(flavor = "multi_thread", worker_threads = 4)]
async fn thousand_simultaneous_writes_keep_the_counters_exact() {
    const TOTAL: usize = 1_000;
    const CLIENTS: usize = 50;
    const ALPHA: &str = "auth_organization:alpha";
    let (bench, engine) = load_bench(Kind::Memory).await;
    bench
        .run("CREATE auth_organization:alpha CONTENT { slug: 'alpha', name: 'Alpha BTP' };")
        .await;
    let bucket_of = |name: &'static str| {
        let store = bench.store.clone();
        async move {
            store
                .bucket_create(BucketCreateParams::named(Some(ALPHA.to_string()), name))
                .await
                .expect("bucket")
                .id
                .to_sql()
        }
    };
    let bucket = bucket_of("volume").await;
    let started = std::time::Instant::now();
    let results: Vec<(usize, Result<_, _>)> = futures::stream::iter(0..TOTAL)
        .map(|i| {
            let service = bench.service.clone();
            let bucket = bucket.clone();
            async move {
                let written = service
                    .put(
                        request(&bucket, &format!("a/{i}.txt")),
                        chunks(&[&content(100 + i % 7)]),
                    )
                    .await;
                (i, written)
            }
        })
        .buffer_unordered(CLIENTS)
        .collect()
        .await;
    let refused: Vec<String> = results
        .iter()
        .filter_map(|(_, result)| result.as_ref().err().map(ToString::to_string))
        .collect();
    println!(
        "{TOTAL} écritures, {CLIENTS} à la fois, {engine} : {:.1} s, {} refusée(s) {refused:?}",
        started.elapsed().as_secs_f64(),
        refused.len()
    );
    assert!(
        refused.len() * 100 <= TOTAL
            && refused
                .iter()
                .all(|error| error.contains("Transaction conflict")),
        "écritures refusées : {refused:?}"
    );
    let accepted: Vec<usize> = results
        .iter()
        .filter_map(|(i, result)| result.is_ok().then_some(*i))
        .collect();
    let objects = i64::try_from(accepted.len()).expect("nombre");
    let bytes: i64 = accepted
        .iter()
        .map(|i| i64::try_from(100 + i % 7).expect("taille"))
        .sum();
    let usage_of = || async {
        bench
            .store
            .object_usage(ObjectUsageParams {
                tenant: Some(ALPHA.to_string()),
            })
            .await
            .expect("volume")
    };
    let verify = || async {
        bench
            .store
            .usage_verify(UsageVerifyParams {
                tenant: Some(ALPHA.to_string()),
            })
            .await
            .expect("contrôle")
    };
    let usage = usage_of().await;
    assert_eq!(
        (usage.objects, usage.bytes, usage.reserved_bytes),
        (objects, bytes, 0)
    );
    let report = verify().await;
    assert!(report.valid, "{report:?}");
    assert_eq!(report.checked, 2);
    // Répartition : plusieurs lignes, 64 au plus pour la portée et autant pour le bucket
    let scope_lines = usage_lines(&bench, "scope_key = 'alpha' AND bucket IS NONE").await;
    let bucket_lines = usage_lines(&bench, "scope_key = 'alpha' AND bucket IS NOT NONE").await;
    assert!((32..=64).contains(&scope_lines), "{scope_lines} lignes");
    assert_eq!(scope_lines, bucket_lines);

    // Quota : 10 octets libres ; 11 octets refusés, 10 acceptés, puis plus rien
    bench
        .store
        .settings_set(SettingsSetParams {
            tenant: Some(ALPHA.to_string()),
            quota_bytes: Some(bytes + 10),
            ..SettingsSetParams::default()
        })
        .await
        .expect("quota");
    let put = |key: &'static str, len: usize| {
        let service = bench.service.clone();
        let bucket = bucket.clone();
        async move {
            service
                .put(request(&bucket, key), chunks(&[&content(len)]))
                .await
        }
    };
    let over = put("q/onze.txt", 11).await.expect_err("au-delà du quota");
    assert_eq!(over.code(), "STORAGE_QUOTA_EXCEEDED");
    put("q/dix.txt", 10).await.expect("au quota");
    let full = put("q/un.txt", 1).await.expect_err("quota atteint");
    assert_eq!(full.code(), "STORAGE_QUOTA_EXCEEDED");
    // Les écritures refusées n'ont rien laissé dans les compteurs
    let usage = usage_of().await;
    assert_eq!(
        (usage.objects, usage.bytes, usage.reserved_bytes),
        (objects + 1, bytes + 10, 0)
    );
    assert!(verify().await.valid);

    // Un bucket vidé puis supprimé emporte ses lignes ; celles de la portée restent
    let other = bucket_of("passage").await;
    bench
        .store
        .settings_set(SettingsSetParams {
            tenant: Some(ALPHA.to_string()),
            clear: vec!["quota_bytes".to_string()],
            ..SettingsSetParams::default()
        })
        .await
        .expect("quota retiré");
    bench
        .service
        .put(request(&other, "p/1.txt"), chunks(&[&content(40)]))
        .await
        .expect("écriture");
    let key = other.trim_start_matches("storage_bucket:");
    let of_other = format!("bucket = storage_bucket:{key}");
    assert!(usage_lines(&bench, &of_other).await >= 1);
    bench
        .run(&format!("DELETE storage_object WHERE {of_other};"))
        .await;
    bench
        .store
        .bucket_delete(BucketRefParams { bucket: other })
        .await
        .expect("bucket supprimé");
    assert_eq!(usage_lines(&bench, &of_other).await, 0);
    let usage = usage_of().await;
    assert_eq!((usage.objects, usage.bytes), (objects + 1, bytes + 10));
    assert!(verify().await.valid);

    // L'organisation supprimée emporte ses 64 lignes et celles de ses buckets
    bench.run("DELETE auth_organization:alpha;").await;
    assert_eq!(usage_lines(&bench, "scope_key = 'alpha'").await, 0);
}
