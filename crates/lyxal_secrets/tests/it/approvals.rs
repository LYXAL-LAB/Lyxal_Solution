//! Accès avancés : lecture permise par un accès temporaire (personne, programme) puis refusée
//! après son retrait ; valeur proposée sur un secret protégé, servie seulement après les
//! approbations et l'application ; écriture directe refusée ; urgence ; worker.

use lyxal_crypto::SecretBytes;
use lyxal_runtime::worker::CancellationToken;
use lyxal_secrets::models::{
    AccessAction, EmergencyAccessParams, GrantCreateParams, GrantListParams, GrantRevokeParams,
    PolicyListParams, PolicySetParams, RequestApplyParams, RequestDecisionParams, RequestKind,
    RequestRefParams, RequestState, SecretCreateParams, SecretGetParams, SecretsDuration,
    VersionListParams,
};
use lyxal_secrets::{
    ProposeRequest, RotatorRegistry, SecretsMaintenanceWorker, SecretsService, SecretsStore,
};
use lyxal_surreal::ToSql;
use std::time::Duration;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

use crate::support::{bench, code, put, reveal, Bench, ALPHA};

const WRITER: &[&str] = &["secrets.secret.list", "secrets.secret.write"];
const MANAGER: &[&str] = &["secrets.secret.list", "secrets.access.manage"];

/// Secret révélable d'alpha, avec une première valeur écrite par la session système.
async fn revealable(bench: &Bench, path: &str, consumers: Vec<String>) -> String {
    let secret = bench
        .secret_with(SecretCreateParams {
            visibility: Some("revealable".into()),
            consumers,
            ..SecretCreateParams::new(Some(ALPHA.into()), path, "api_key")
        })
        .await;
    bench.put(&secret, b"valeur initiale").await;
    secret
}

/// Protection du dossier `infra` d'alpha (deux approbations), posée par la session système.
async fn protect(bench: &Bench) {
    let policy = bench
        .store
        .policy_set(PolicySetParams {
            tenant: ALPHA.into(),
            path: "infra".into(),
            folder: true,
            required_approvals: Some(2),
            operations: None,
            max_grant_duration: None,
        })
        .await
        .expect("protection");
    assert_eq!(policy.required_approvals, 2);
    let listed = bench
        .store
        .policy_list(PolicyListParams {
            tenant: ALPHA.into(),
            path: Some("infra/db".into()),
        })
        .await
        .expect("protections");
    let effective = listed.effective.expect("protection effective");
    assert!(effective.protected);
    assert_eq!(effective.required_approvals, 2);
}

fn proposal(secret: &str, value: &[u8]) -> ProposeRequest {
    ProposeRequest {
        secret: secret.to_string(),
        value: SecretBytes::new(value.to_vec()).expect("valeur"),
        reason: "nouveau mot de passe".into(),
    }
}

async fn approve(user: &Surreal<Any>, request: &str) -> RequestState {
    SecretsStore::new(user.clone())
        .request_approve(RequestDecisionParams {
            request: request.to_string(),
            comment: Some("vu".into()),
        })
        .await
        .expect("approbation")
        .state
}

/// Seconde proposition pendant une demande ouverte : `SECRETS_CHANGE_IN_PROGRESS`, aucune
/// version écrite, étiquette `proposed` inchangée.
async fn second_proposal_refused(bench: &Bench, writer: &Surreal<Any>, secret: &str) {
    assert_eq!(
        code(
            service(bench, writer)
                .propose(proposal(secret, b"autre"))
                .await
        ),
        "SECRETS_CHANGE_IN_PROGRESS"
    );
    let versions = bench
        .store
        .version_list(VersionListParams {
            secret: secret.to_string(),
            state: None,
            limit: None,
            start: None,
        })
        .await
        .expect("versions");
    assert_eq!(versions.total, 2);
    let labels = bench
        .store
        .secret_get(SecretGetParams::by_id(secret))
        .await
        .expect("fiche")
        .labels;
    assert_eq!(labels.get("proposed"), Some(&2));
    assert_eq!(bench.read(secret).await, b"ancien mot de passe");
}

fn service(bench: &Bench, user: &Surreal<Any>) -> SecretsService {
    bench.service_for(user)
}

#[tokio::test]
async fn a_temporary_access_lets_a_person_read_until_it_is_revoked() {
    let bench = bench().await;
    let secret = revealable(&bench, "api/brevo", vec![]).await;
    // Aucune permission lyxal_auth : seulement l'accès temporaire
    let member = bench.person("membre", ALPHA, &[]).await;
    // Sans droit ni accès, le secret n'est même pas visible
    assert_eq!(
        code(service(&bench, &member).reveal(reveal(&secret)).await),
        "SECRETS_SECRET_NOT_FOUND"
    );

    // Accès au dossier `api`, d'une demi-heure
    let grant = bench
        .store
        .grant_create(GrantCreateParams {
            folder: true,
            duration: Some(SecretsDuration::from(Duration::from_secs(1800))),
            ..GrantCreateParams::for_identity(
                ALPHA,
                "auth_identity:membre",
                "api",
                vec![AccessAction::ReadValue],
                "dépannage",
            )
        })
        .await
        .expect("accès");
    assert!(grant.active);
    assert!(grant.folder);
    assert_eq!(grant.actions, vec![AccessAction::ReadValue]);
    let read = service(&bench, &member)
        .reveal(reveal(&secret))
        .await
        .expect("lecture permise par l'accès");
    assert_eq!(read.value.expose_secret(), b"valeur initiale");

    // Le bénéficiaire voit son accès
    let mine = SecretsStore::new(member.clone())
        .grant_list(GrantListParams {
            tenant: ALPHA.into(),
            ..GrantListParams::default()
        })
        .await
        .expect("accès du membre");
    assert_eq!(mine.total, 1);

    let revoked = bench
        .store
        .grant_revoke(GrantRevokeParams {
            grant: grant.id.to_sql(),
        })
        .await
        .expect("retrait");
    assert!(!revoked.active);
    assert!(revoked.revoked_at.is_some());
    assert_eq!(
        code(service(&bench, &member).reveal(reveal(&secret)).await),
        "SECRETS_SECRET_NOT_FOUND"
    );
}

#[tokio::test]
async fn a_temporary_access_lets_a_program_read_until_it_is_revoked() {
    let bench = bench().await;
    let secret = revealable(
        &bench,
        "api/stripe",
        vec!["auth_application:robot".to_string()],
    )
    .await;
    let robot = bench.program("robot", ALPHA, &[]).await;
    assert_eq!(
        code(service(&bench, &robot).reveal(reveal(&secret)).await),
        "SECRETS_SECRET_NOT_FOUND"
    );
    let grant = bench
        .store
        .grant_create(GrantCreateParams::for_application(
            ALPHA,
            "auth_application:robot",
            "api/stripe",
            vec![AccessAction::ReadValue],
            "intégration",
        ))
        .await
        .expect("accès");
    assert_eq!(
        grant.subject_application.as_ref().map(ToSql::to_sql),
        Some("auth_application:robot".to_string())
    );
    let read = service(&bench, &robot)
        .reveal(reveal(&secret))
        .await
        .expect("lecture permise par l'accès");
    assert_eq!(read.value.expose_secret(), b"valeur initiale");

    bench
        .store
        .grant_revoke(GrantRevokeParams {
            grant: grant.id.to_sql(),
        })
        .await
        .expect("retrait");
    assert_eq!(
        code(service(&bench, &robot).reveal(reveal(&secret)).await),
        "SECRETS_SECRET_NOT_FOUND"
    );
}

#[tokio::test]
async fn a_proposed_value_is_served_only_after_two_approvals_and_its_application() {
    let bench = bench().await;
    protect(&bench).await;
    let secret = bench.secret(Some(ALPHA), "infra/db").await;
    // Session système : non soumise aux protections
    bench.put(&secret, b"ancien mot de passe").await;
    let writer = bench.person("redacteur", ALPHA, WRITER).await;
    let first = bench.person("gestion", ALPHA, MANAGER).await;
    let second = bench.person("gestion2", ALPHA, MANAGER).await;

    // Écriture directe : refusée, code lisible
    let error = service(&bench, &writer)
        .put(put(&secret, b"pirate"))
        .await
        .expect_err("approbation exigée");
    assert!(error.is_business());
    assert!(error.is_code("SECRETS_APPROVAL_REQUIRED"), "{error:?}");
    assert_eq!(error.code(), "SECRETS_APPROVAL_REQUIRED");
    assert!(!error.to_string().contains("pirate"));
    assert_eq!(bench.read(&secret).await, b"ancien mot de passe");

    let proposed = service(&bench, &writer)
        .propose(proposal(&secret, b"mot de passe neuf"))
        .await
        .expect("proposition");
    assert_eq!(proposed.version.version.number, 2);
    assert_eq!(proposed.version.labels.get("proposed"), Some(&2));
    assert_eq!(proposed.version.labels.get("current"), Some(&1));
    let request = proposed.request;
    assert_eq!(request.kind, RequestKind::Change);
    assert_eq!(request.state, RequestState::Pending);
    assert_eq!(request.required_approvals, 2);
    assert_eq!(request.number, Some(2));
    let id = request.id.to_sql();
    assert!(!format!("{request:?}").contains("mot de passe neuf"));

    // Une seule demande ouverte par secret : une seconde proposition est refusée sans écrire
    // de version
    second_proposal_refused(&bench, &writer, &secret).await;

    // L'auteur ne s'approuve pas ; une approbation ne suffit pas
    assert_eq!(
        code(
            SecretsStore::new(writer.clone())
                .request_approve(RequestDecisionParams {
                    request: id.clone(),
                    comment: None,
                })
                .await
                .map_err(lyxal_secrets::SecretsError::from)
        ),
        "SECRETS_PERMISSION_DENIED"
    );
    assert_eq!(approve(&first, &id).await, RequestState::Pending);
    let apply = RequestApplyParams {
        request: id.clone(),
        emergency: false,
        reason: None,
    };
    let writer_store = SecretsStore::new(writer.clone());
    assert_eq!(
        code(
            writer_store
                .request_apply(apply.clone())
                .await
                .map_err(lyxal_secrets::SecretsError::from)
        ),
        "SECRETS_REQUEST_STATE_INVALID"
    );
    assert_eq!(bench.read(&secret).await, b"ancien mot de passe");

    assert_eq!(approve(&second, &id).await, RequestState::Approved);
    second_proposal_refused(&bench, &writer, &secret).await;
    // Approuvée mais pas encore appliquée : toujours l'ancienne valeur
    assert_eq!(bench.read(&secret).await, b"ancien mot de passe");

    let applied = writer_store
        .request_apply(apply)
        .await
        .expect("application");
    assert_eq!(applied.state, RequestState::Applied);
    assert_eq!(applied.approvals.len(), 2);
    assert!(applied.applied_at.is_some());
    assert_eq!(bench.read(&secret).await, b"mot de passe neuf");
    let fetched = writer_store
        .request_get(RequestRefParams { request: id })
        .await
        .expect("demande");
    assert_eq!(fetched.state, RequestState::Applied);
}

#[tokio::test]
async fn an_emergency_bypasses_the_approvals_and_grants_access_for_oneself() {
    let bench = bench().await;
    protect(&bench).await;
    let secret = bench.secret(Some(ALPHA), "infra/db").await;
    bench.put(&secret, b"ancien mot de passe").await;
    let responder = bench
        .person(
            "urgentiste",
            ALPHA,
            &[
                "secrets.secret.list",
                "secrets.secret.write",
                "secrets.access.emergency",
            ],
        )
        .await;
    let proposed = service(&bench, &responder)
        .propose(proposal(&secret, b"mot de passe d'urgence"))
        .await
        .expect("proposition");
    let store = SecretsStore::new(responder.clone());
    // Urgence sans motif : refusée
    assert_eq!(
        code(
            store
                .request_apply(RequestApplyParams {
                    request: proposed.request.id.to_sql(),
                    emergency: true,
                    reason: None,
                })
                .await
                .map_err(lyxal_secrets::SecretsError::from)
        ),
        "SECRETS_INVALID_PARAMETERS"
    );
    let applied = store
        .request_apply(RequestApplyParams {
            request: proposed.request.id.to_sql(),
            emergency: true,
            reason: Some("identifiant publié par erreur".into()),
        })
        .await
        .expect("application d'urgence");
    assert_eq!(applied.state, RequestState::Applied);
    assert!(applied.emergency);
    assert!(applied.approvals.is_empty());
    assert_eq!(bench.read(&secret).await, b"mot de passe d'urgence");

    // Accès d'urgence pour soi : lecture d'un secret révélable sans le droit de lecture
    let api = revealable(&bench, "api/brevo", vec![]).await;
    assert_eq!(
        code(service(&bench, &responder).reveal(reveal(&api)).await),
        "SECRETS_PERMISSION_DENIED"
    );
    let grant = store
        .access_emergency(EmergencyAccessParams {
            tenant: ALPHA.into(),
            path: "api/brevo".into(),
            folder: false,
            actions: vec![AccessAction::ReadValue],
            duration: Some(SecretsDuration::from(Duration::from_secs(1800))),
            reason: "panne d'envoi".into(),
        })
        .await
        .expect("accès d'urgence");
    assert!(grant.emergency);
    assert_eq!(
        grant.subject_identity.as_ref().map(ToSql::to_sql),
        Some("auth_identity:urgentiste".to_string())
    );
    let read = service(&bench, &responder)
        .reveal(reveal(&api))
        .await
        .expect("lecture d'urgence");
    assert_eq!(read.value.expose_secret(), b"valeur initiale");
}

#[tokio::test]
async fn the_worker_expires_unanswered_requests_and_removes_old_grants() {
    let bench = bench().await;
    bench.person("lecteur", ALPHA, &[]).await;
    bench
        .run(&format!(
            "CREATE secrets_request:echue CONTENT {{ tenant: {ALPHA}, kind: 'access', requested_identity: auth_identity:lecteur, path: 'api', folder: true, actions: ['list'], duration: 1h, reason: 'x', required_approvals: 1, expires_at: time::now() - 1m }};
             CREATE secrets_grant:vieux CONTENT {{ tenant: {ALPHA}, subject_identity: auth_identity:lecteur, path: 'api', folder: true, actions: ['list'], starts_at: time::now() - 41d, expires_at: time::now() - 40d, reason: 'ancien' }};"
        ))
        .await;
    let worker = SecretsMaintenanceWorker::new(
        bench.store.clone(),
        Some(bench.master.clone()),
        RotatorRegistry::default(),
        Duration::from_secs(3600),
        10,
    )
    .expect("worker");
    let report = worker
        .run_once(&CancellationToken::new())
        .await
        .expect("passage");
    assert_eq!(report.requests_expired, 1, "{report:?}");
    assert_eq!(report.grants_removed, 1, "{report:?}");
    assert_eq!(report.failed, 0, "{report:?}");
    let request = bench
        .store
        .request_get(RequestRefParams {
            request: "secrets_request:echue".into(),
        })
        .await
        .expect("demande");
    assert_eq!(request.state, RequestState::Expired);
    assert!(request.decided_at.is_some());

    // Passage suivant : plus rien à faire
    let again = worker
        .run_once(&CancellationToken::new())
        .await
        .expect("passage");
    assert_eq!((again.requests_expired, again.grants_removed), (0, 0));
}
