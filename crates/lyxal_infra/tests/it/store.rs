//! Appels typés du store : réglages, comptes, zones, contrat public, passe complète du worker,
//! conflit, approbation, journal, purge, sonde, détachement.

use lyxal_infra::models::{
    AccountCreateParams, AccountListParams, AccountRefParams, AccountState,
    AccountTestResultParams, AccountUpdateParams, ApplyBeginParams, ApplyOutcome,
    ApplyResultParams, ChangeAction, ChangeListParams, ChangeVerifyParams, ConflictAction,
    ConflictResolveParams, DeclaredRecord, DiscoveredZone, HealthParams, HealthStatus, InfraUuid,
    ObservedRecord, PassOutcome, PlanReason, ProviderZoneStatus, RecordListParams, RecordMode,
    RecordRefParams, RecordState, RecordType, RecordsDeclareParams, RecordsReleaseParams,
    RecordsStatusParams, RecordsSubjectsParams, ScalewaySettings, SettingsGetParams,
    SettingsUpdateParams, VerifyResultParams, WorkerBatchParams, ZoneAttachParams, ZoneClaimParams,
    ZoneClaimRefParams, ZoneDetachParams, ZoneListParams, ZoneMode, ZoneObserveParams,
    ZonePlanApproveParams, ZoneRecordsParams, ZoneRefParams, ZoneReleaseParams, ZoneRenewParams,
    ZoneState, ZoneUpdateParams,
};
use lyxal_infra::InfraStore;
use lyxal_surreal::{RecordId, ToSql};

use crate::support::{bench, run};

const PROJECT: &str = "0b3a6f1e-3c1d-4f2a-9a55-6f3f0a7b2c11";

fn project() -> InfraUuid {
    PROJECT.parse().expect("UUID")
}

fn declared(fqdn: &str, kind: RecordType, value: &str, mode: RecordMode) -> DeclaredRecord {
    DeclaredRecord {
        fqdn: fqdn.to_string(),
        r#type: kind,
        values: vec![value.to_string()],
        ttl: None,
        mode,
        singleton_prefix: None,
    }
}

fn observed(
    id: &str,
    fqdn: &str,
    kind: &str,
    value: &str,
    comment: Option<String>,
) -> ObservedRecord {
    ObservedRecord {
        provider_id: id.to_string(),
        fqdn: fqdn.to_string(),
        r#type: kind.to_string(),
        value: value.to_string(),
        ttl: 3600,
        comment,
    }
}

/// Compte Scaleway essayé (zone `exemple.fr` visible) et zone rattachée en observation.
async fn account_and_zone(
    store: &InfraStore,
    client: &surrealdb::Surreal<surrealdb::engine::any::Any>,
) -> RecordId {
    run(
        client,
        r#"fn::secrets_secret_create({ path: "infra/scaleway", kind: "api_key" });"#,
    )
    .await;
    store
        .account_create(AccountCreateParams {
            key: "scw".to_string(),
            name: "Scaleway".to_string(),
            provider: None,
            credentials_path: "infra/scaleway".to_string(),
            settings: ScalewaySettings {
                project_id: Some(project()),
                ..ScalewaySettings::default()
            },
            language: None,
        })
        .await
        .expect("compte");
    store
        .account_test_result(AccountTestResultParams {
            account: "infra_account:scw".to_string(),
            ok: true,
            code: None,
            zones: vec![DiscoveredZone {
                name: "exemple.fr".to_string(),
                status: "active".to_string(),
            }],
            language: None,
        })
        .await
        .expect("essai");
    store
        .zone_attach(ZoneAttachParams {
            account: "infra_account:scw".to_string(),
            name: "exemple.fr".to_string(),
            mode: None,
            tenants: Vec::new(),
            language: None,
        })
        .await
        .expect("zone")
        .id
}

#[tokio::test]
async fn settings_and_accounts_go_through_typed_calls() {
    let bench = bench().await;
    let store = &bench.store;

    let settings = store
        .settings_get(SettingsGetParams::default())
        .await
        .expect("réglages");
    assert_eq!(settings.default_ttl, 3600);
    let updated = store
        .settings_update(SettingsUpdateParams {
            max_deletions: Some(5),
            ..SettingsUpdateParams::default()
        })
        .await
        .expect("réglages");
    assert_eq!(updated.max_deletions, 5);
    let refused = store
        .settings_update(SettingsUpdateParams {
            min_ttl: Some(7200),
            ..SettingsUpdateParams::default()
        })
        .await
        .expect_err("min_ttl au-delà de default_ttl");
    assert!(
        refused.is_business_code("INFRA_SETTINGS_INVALID"),
        "{refused:?}"
    );

    run(
        &bench.client,
        r#"fn::secrets_secret_create({ path: "infra/scaleway", kind: "api_key" });"#,
    )
    .await;
    let created = store
        .account_create(AccountCreateParams {
            key: "scw".to_string(),
            name: "Scaleway".to_string(),
            provider: None,
            credentials_path: "infra/scaleway".to_string(),
            settings: ScalewaySettings {
                project_id: Some(project()),
                ..ScalewaySettings::default()
            },
            language: None,
        })
        .await
        .expect("compte");
    assert_eq!(created.provider, "scaleway");
    assert_eq!(created.state, AccountState::Active);
    assert_eq!(created.settings.default_zone.as_deref(), Some("fr-par-1"));
    assert!(created.test_requested_at.is_some());

    let renamed = store
        .account_update(AccountUpdateParams {
            account: created.id.to_sql(),
            name: Some("Scaleway Paris".to_string()),
            ..AccountUpdateParams::default()
        })
        .await
        .expect("modification");
    assert_eq!(renamed.name, "Scaleway Paris");

    let due = store
        .account_due(WorkerBatchParams::default())
        .await
        .expect("essais dus");
    assert_eq!(due.items.len(), 1);
    assert_eq!(due.items[0].credentials_path, "infra/scaleway");
    assert_eq!(due.items[0].settings.project_id, Some(project()));

    let outcome = store
        .account_test_result(AccountTestResultParams {
            account: created.id.to_sql(),
            ok: false,
            code: Some("INFRA_PROVIDER_AUTH".to_string()),
            zones: Vec::new(),
            language: None,
        })
        .await
        .expect("essai");
    assert_eq!(outcome.state, AccountState::Failing);

    let requested = store
        .account_test_request(AccountRefParams::new(created.id.to_sql()))
        .await
        .expect("demande d'essai");
    assert!(requested.test_requested_at.is_some());
    let read = store
        .account_get(AccountRefParams::new(created.id.to_sql()))
        .await
        .expect("lecture");
    assert_eq!(read.zones, Some(0));
    assert_eq!(read.last_test.map(|t| t.ok), Some(false));
    let list = store
        .account_list(AccountListParams {
            state: Some(AccountState::Failing),
            language: None,
        })
        .await
        .expect("liste");
    assert_eq!(list.items.len(), 1);

    let deleted = store
        .account_delete(AccountRefParams::new(created.id.to_sql()))
        .await
        .expect("suppression");
    assert_eq!(deleted.deleted, created.id);
    let missing = store
        .account_get(AccountRefParams::new("infra_account:scw"))
        .await
        .expect_err("compte supprimé");
    assert!(
        missing.is_business_code("INFRA_ACCOUNT_NOT_FOUND"),
        "{missing:?}"
    );
}

#[tokio::test]
async fn a_full_worker_pass_writes_lyxal_records_only() {
    let bench = bench().await;
    let store = &bench.store;
    let zone = account_and_zone(store, &bench.client).await;
    let zone_text = zone.to_sql();

    let managed = store
        .zone_update(ZoneUpdateParams {
            zone: zone_text.clone(),
            mode: Some(ZoneMode::Managed),
            tenants: None,
            language: None,
        })
        .await
        .expect("zone gérée");
    assert_eq!(managed.mode, ZoneMode::Managed);

    // Contrat public : le courrier déclare MX et SPF ; un SPF humain existe déjà
    let declared_set = store
        .records_declare(RecordsDeclareParams {
            owner: "lyxal_mail".to_string(),
            subject: "mail_domain:d1".to_string(),
            tenant: None,
            records: vec![
                declared(
                    "exemple.fr",
                    RecordType::Mx,
                    "10 MX.exemple.fr.",
                    RecordMode::Exclusive,
                ),
                DeclaredRecord {
                    singleton_prefix: Some("v=spf1".to_string()),
                    ..declared(
                        "exemple.fr",
                        RecordType::Txt,
                        "v=spf1 a:mx.exemple.fr -all",
                        RecordMode::Shared,
                    )
                },
            ],
            language: None,
        })
        .await
        .expect("déclaration");
    assert!(declared_set.changed);
    assert_eq!(declared_set.items.len(), 2);
    assert!(declared_set
        .items
        .iter()
        .all(|i| i.state == RecordState::Pending && i.managed));
    let mx = declared_set.items[0].record.clone();
    let spf = declared_set.items[1].record.clone();

    let due = store
        .zone_due(WorkerBatchParams::default())
        .await
        .expect("zones dues");
    assert_eq!(due.items.len(), 1);
    assert_eq!(due.items[0].zone, zone);

    let claim = store
        .zone_claim(ZoneClaimParams {
            zone: zone_text.clone(),
            ttl_seconds: None,
            language: None,
        })
        .await
        .expect("réservation");
    assert_eq!(claim.name, "exemple.fr");
    assert_eq!(claim.account.credentials_path, "infra/scaleway");
    let renewed = store
        .zone_renew(ZoneRenewParams {
            zone: zone_text.clone(),
            claim: claim.claim.clone(),
            ttl_seconds: Some(600),
            language: None,
        })
        .await
        .expect("renouvellement");
    assert_eq!(renewed.zone, zone);

    let seen = store
        .zone_observe(ZoneObserveParams {
            zone: zone_text.clone(),
            claim: claim.claim.clone(),
            status: ProviderZoneStatus::Active,
            nameservers: vec![
                "ns0.dom.scw.cloud".to_string(),
                "ns1.dom.scw.cloud".to_string(),
            ],
            delegated: Some(true),
            records: vec![
                observed("h-ns", "exemple.fr", "NS", "ns0.dom.scw.cloud", None),
                observed(
                    "h-spf",
                    "exemple.fr",
                    "TXT",
                    "v=spf1 include:_spf.google.com -all",
                    None,
                ),
            ],
            language: None,
        })
        .await
        .expect("lecture de la zone");
    assert_eq!((seen.total, seen.written, seen.owned), (2, 2, 0));
    assert_eq!(seen.state, ZoneState::Ok);

    let plan = store
        .zone_plan(ZoneClaimRefParams {
            zone: zone_text.clone(),
            claim: claim.claim.clone(),
            language: None,
        })
        .await
        .expect("plan");
    assert_eq!(plan.reason, PlanReason::Apply);
    assert_eq!(plan.changes.len(), 1, "le SPF humain n'est jamais touché");
    assert_eq!(plan.changes[0].action, ChangeAction::Add);
    assert_eq!(plan.changes[0].value, "10 mx.exemple.fr");
    assert_eq!(plan.conflicts.len(), 1);
    assert_eq!(plan.conflicts[0].reason, "foreign_singleton");

    let begun = store
        .zone_apply_begin(ApplyBeginParams {
            zone: zone_text.clone(),
            claim: claim.claim.clone(),
            plan_hash: plan.hash.clone(),
            language: None,
        })
        .await
        .expect("début de l'écriture");
    assert_eq!(begun.changes.len(), 1);
    let sent = &begun.changes[0];
    assert!(sent.comment.starts_with("lyxal:"));
    let applied = store
        .zone_apply_result(ApplyResultParams {
            zone: zone_text.clone(),
            claim: claim.claim.clone(),
            results: vec![ApplyOutcome {
                change: sent.change.to_sql(),
                ok: true,
                provider_id: Some("p-mx".to_string()),
                provider_status: Some(200),
                code: None,
                retryable: false,
            }],
            language: None,
        })
        .await
        .expect("issue de l'écriture");
    assert_eq!((applied.done, applied.failed), (1, 0));
    assert_eq!(applied.records[0].state, RecordState::Written);

    let released = store
        .zone_release(ZoneReleaseParams {
            zone: zone_text.clone(),
            claim: claim.claim.clone(),
            outcome: PassOutcome::Applied,
            code: None,
            language: None,
        })
        .await
        .expect("fin de passe");
    assert_eq!(released.state, ZoneState::Ok);

    // Vérification de la publication
    run(
        &bench.client,
        "UPDATE infra_record SET next_verify_at = time::now() - 1s WHERE state = 'written';",
    )
    .await;
    let to_verify = store
        .records_to_verify(WorkerBatchParams::default())
        .await
        .expect("vérifications dues");
    assert_eq!(to_verify.items.len(), 1);
    assert_eq!(to_verify.items[0].nameservers.len(), 2);
    let verified = store
        .record_verify_result(VerifyResultParams {
            record: to_verify.items[0].record.to_sql(),
            written_at: to_verify.items[0].written_at,
            published: true,
            code: None,
            language: None,
        })
        .await
        .expect("vérification");
    assert_eq!(verified.state, RecordState::Published);
    assert!(!verified.skipped);

    // Contrat public : état et sujets
    let status = store
        .records_status(RecordsStatusParams {
            owner: "lyxal_mail".to_string(),
            subjects: vec!["mail_domain:d1".to_string()],
            language: None,
        })
        .await
        .expect("état");
    let mx_status = status.items.iter().find(|s| s.record == mx).expect("MX");
    assert_eq!(mx_status.state, RecordState::Published);
    let spf_status = status.items.iter().find(|s| s.record == spf).expect("SPF");
    assert_eq!(spf_status.state, RecordState::Conflict);
    assert_eq!(
        spf_status.conflict_reason.as_deref(),
        Some("foreign_singleton")
    );
    let subjects = store
        .records_subjects(RecordsSubjectsParams {
            owner: "lyxal_mail".to_string(),
            after: None,
            limit: None,
            language: None,
        })
        .await
        .expect("sujets");
    assert_eq!(subjects.subjects, vec!["mail_domain:d1".to_string()]);
    assert_eq!(subjects.next, None);

    // Administration : photo, enregistrements, conflit levé (yield)
    let photo = store
        .zone_records(ZoneRecordsParams {
            zone: zone_text.clone(),
            owner: Some("human".to_string()),
            limit: None,
            start: None,
            language: None,
        })
        .await
        .expect("photo");
    assert_eq!(photo.total, 2);
    let records = store
        .record_list(RecordListParams {
            zone: Some(zone_text.clone()),
            ..RecordListParams::default()
        })
        .await
        .expect("enregistrements");
    assert_eq!(records.total, 2);
    let spf_record = store
        .record_get(RecordRefParams {
            record: spf.to_sql(),
            language: None,
        })
        .await
        .expect("SPF");
    assert_eq!(spf_record.observed.as_ref().map(Vec::len), Some(1));
    let yielded = store
        .record_conflict_resolve(ConflictResolveParams {
            record: spf.to_sql(),
            action: ConflictAction::Yield,
            language: None,
        })
        .await
        .expect("yield");
    assert_eq!(yielded.state, RecordState::Yielded);

    // Retrait : le MX écrit passe en releasing
    let release = store
        .records_release(RecordsReleaseParams {
            owner: "lyxal_mail".to_string(),
            subject: "mail_domain:d1".to_string(),
            keep_at_provider: false,
            language: None,
        })
        .await
        .expect("retrait");
    assert_eq!((release.released, release.releasing), (1, 1));

    // Journal intact, sonde, purge
    let journal = store
        .change_list(ChangeListParams::default())
        .await
        .expect("journal");
    assert!(journal.items.iter().any(|e| e.action == ChangeAction::Add));
    let verify = store
        .change_verify(ChangeVerifyParams::default())
        .await
        .expect("chaîne");
    assert!(verify.valid && verify.complete);
    let health = store.health(HealthParams::default()).await.expect("sonde");
    assert_eq!(health.status, HealthStatus::Healthy);
    let purged = store
        .purge(WorkerBatchParams::default())
        .await
        .expect("purge");
    assert_eq!(purged.changes, 0);
}

#[tokio::test]
async fn zone_administration_goes_through_typed_calls() {
    let bench = bench().await;
    let store = &bench.store;
    let zone = account_and_zone(store, &bench.client).await;
    let zone_text = zone.to_sql();

    let read = store
        .zone_get(ZoneRefParams::new(zone_text.clone()))
        .await
        .expect("zone");
    assert_eq!(read.mode, ZoneMode::Observe);
    assert_eq!(read.counts.map(|c| c.pending), Some(0));
    let list = store
        .zone_list(ZoneListParams::default())
        .await
        .expect("zones");
    assert_eq!(list.items.len(), 1);
    let requested = store
        .zone_reconcile_request(ZoneRefParams::new(zone_text.clone()))
        .await
        .expect("passe demandée");
    assert_eq!(requested.queued, 1);

    // Plan bloqué (seuil de prudence) puis approuvé par son empreinte
    let hash = "b".repeat(64);
    run(
        &bench.client,
        &format!(
            "UPDATE {zone_text} SET state = 'blocked', last_plan = {{ hash: '{hash}', at: time::now(), changes: [], conflicts: [], deletions: 12, owned: 20 }};"
        ),
    )
    .await;
    let stale = store
        .zone_plan_approve(ZonePlanApproveParams {
            zone: zone_text.clone(),
            plan_hash: "c".repeat(64),
            language: None,
        })
        .await
        .expect_err("empreinte différente");
    assert!(stale.is_business_code("INFRA_ZONE_PLAN_STALE"), "{stale:?}");
    let approved = store
        .zone_plan_approve(ZonePlanApproveParams {
            zone: zone_text.clone(),
            plan_hash: hash.clone(),
            language: None,
        })
        .await
        .expect("approbation");
    assert_eq!(approved.state, ZoneState::Ok);
    assert_eq!(approved.approved_plan_hash, Some(hash));

    let detached = store
        .zone_detach(ZoneDetachParams {
            zone: zone_text,
            forget: false,
            language: None,
        })
        .await
        .expect("détachement");
    assert_eq!(detached.detached, zone);
    assert_eq!(detached.records, 0);
}
