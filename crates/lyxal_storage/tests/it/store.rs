//! Appels typés du store : réglages, buckets, listes, volume.

use lyxal_storage::models::{
    BucketCreateParams, BucketListParams, BucketRefParams, BucketUpdateParams, ObjectGetParams,
    ObjectListParams, ObjectState, ObjectUsageParams, ReclaimDoneParams, SettingsGetParams,
    SettingsSetParams,
};
use lyxal_surreal::ToSql;

use crate::support::{bench, chunks, request, Kind};

#[tokio::test]
async fn settings_buckets_and_usage_go_through_typed_calls() {
    let bench = bench(Kind::Memory).await;
    let store = &bench.store;

    let defaults = store
        .settings_get(SettingsGetParams::default())
        .await
        .expect("réglages");
    assert!(defaults.own.is_none());
    assert_eq!(defaults.effective.max_object_size, 104_857_600);
    let saved = store
        .settings_set(SettingsSetParams {
            quota_bytes: Some(1000),
            ..SettingsSetParams::default()
        })
        .await
        .expect("réglages");
    assert_eq!(saved.scope_key, "installation");
    assert_eq!(saved.quota_bytes, Some(1000));

    let created = store
        .bucket_create(BucketCreateParams {
            description: Some("Plans de chantier".to_string()),
            allowed_types: vec!["application/pdf".to_string()],
            ..BucketCreateParams::named(None, "plans")
        })
        .await
        .expect("bucket");
    assert_eq!(created.backend, "default");
    let bucket = created.id.to_sql();
    let updated = store
        .bucket_update(BucketUpdateParams {
            bucket: bucket.clone(),
            description: None,
            max_object_size: Some(500),
            allowed_types: Some(Vec::new()),
            readonly: None,
            clear: vec!["description".to_string()],
        })
        .await
        .expect("bucket");
    assert_eq!(updated.description, None);
    assert_eq!(updated.max_object_size, Some(500));
    assert!(updated.allowed_types.is_empty());

    let stored = bench
        .service
        .put(request(&bucket, "a.bin"), chunks(&[b"abcde"]))
        .await
        .expect("écriture");
    let details = store
        .bucket_get(BucketRefParams {
            bucket: bucket.clone(),
        })
        .await
        .expect("bucket");
    assert_eq!((details.usage.objects, details.usage.bytes), (1, 5));
    let listed = store
        .bucket_list(BucketListParams {
            tenant: None,
            limit: 10,
            start: 0,
        })
        .await
        .expect("buckets");
    assert_eq!(listed.total, 1);
    assert_eq!(listed.items[0].name, "plans");

    let objects = store
        .object_list(ObjectListParams {
            bucket: bucket.clone(),
            prefix: None,
            state: ObjectState::Available,
            limit: 10,
            start: 0,
        })
        .await
        .expect("fichiers");
    assert_eq!(objects.total, 1);
    assert_eq!(objects.items[0].id, stored.id);
    let read = store
        .object_get(ObjectGetParams::by_address(&bucket, "a.bin"))
        .await
        .expect("fiche");
    assert_eq!(read.path, stored.path);
    let usage = store
        .object_usage(ObjectUsageParams::default())
        .await
        .expect("volume");
    assert_eq!(
        (
            usage.objects,
            usage.bytes,
            usage.reserved_bytes,
            usage.quota_bytes
        ),
        (1, 5, 0, Some(1000))
    );

    // Un bucket non vide ne se supprime pas ; l'erreur garde son code
    let error = store
        .bucket_delete(BucketRefParams {
            bucket: bucket.clone(),
        })
        .await
        .expect_err("bucket non vide");
    assert_eq!(
        lyxal_storage::StorageError::from(error).code(),
        "STORAGE_BUCKET_NOT_EMPTY"
    );

    // Bucket vide supprimé : son préfixe est à retirer, puis la ligne est retirée
    let empty = store
        .bucket_create(BucketCreateParams::named(None, "vide"))
        .await
        .expect("bucket");
    let deleted = store
        .bucket_delete(BucketRefParams {
            bucket: empty.id.to_sql(),
        })
        .await
        .expect("suppression");
    assert!(deleted.deleted);
    let reclaim = store
        .reclaim_list(lyxal_storage::models::PageParams {
            limit: 10,
            start: 0,
        })
        .await
        .expect("préfixes");
    assert_eq!(reclaim.items.len(), 1);
    assert!(reclaim.items[0].prefix.starts_with("installation/"));
    let done = store
        .reclaim_done(ReclaimDoneParams {
            reclaim: reclaim.items[0].id.to_sql(),
        })
        .await
        .expect("ligne retirée");
    assert!(done.done);
}
