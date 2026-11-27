// SPDX-License-Identifier: AGPL-3.0-only

//! Envoi dans l'hôte (sous-lot 6d) : configuration `[outbound]` validée ; STARTTLS réel vers un
//! faux MX par le connecteur TLS de l'hôte (`tokio-rustls` sur `lyxal_crypto::
//! tls_client_config`) : opportuniste accepté avec le certificat d'essai non vérifié, vérifié
//! (relais) refusé ; hôte démarré avec l'envoi actif : worker, mesures, tâche
//! `mail.dkim_provision`, échec définitif d'un domaine inexistant (`5.1.2`, DNS d'essai), route
//! locale vers une boîte de l'installation.

use bytes::Bytes;
use lyxal_groupware::net::certificates::Certificates;
use lyxal_groupware::net::tls::{HostTlsConnector, ListenerTls};
use lyxal_groupware::services::{MAIL_DKIM_SCHEDULE, MAIL_DKIM_TASK};
use lyxal_mail::models::{
    DomainUpdateParams, RecipientState, SubmissionBeginParams, SubmissionCommitParams,
    SubmissionOrigin, SubmissionRecipient, SubmissionRefParams,
};
use lyxal_mail::outbound::{ConnectTarget, OutboundConfig, SmtpConnection, TargetTls};
use lyxal_mail::MAIL_BUCKET;
use lyxal_mail_proto::smtp::Domain;
use lyxal_scheduler::models::{
    Overlap, RunRefParams, RunState, ScheduleListParams, ScheduleTriggerParams,
};
use lyxal_scheduler::SchedulerStore;
use lyxal_storage::models::BucketCreateParams;
use lyxal_storage::{PutRequest, StorageStore};
use lyxal_surreal::ToSql;
use std::convert::Infallible;
use std::fs;
use std::time::Duration;
use tokio::io::{AsyncBufReadExt, AsyncWriteExt, BufReader};
use tokio::net::TcpListener;

use crate::mail_service::{account, start, test_master_key, MASTER_KEY_VAR};
use crate::support::{fake_dns, toml, try_config, TestCertificates};

const MESSAGE: &str =
    "From: <noreply@alpha.test>\r\nTo: <x@ailleurs.test>\r\nSubject: Essai\r\n\r\nBonjour.\r\n";

#[test]
fn the_outbound_section_is_validated() {
    let ok = try_config(&toml(
        "o_ok",
        "[outbound]\nenabled = true\nsmtp_port = 2525\nallow_private_networks = true\n[[outbound.destinations]]\ndomain = \"gmail.com\"\nmessages_per_minute = 10\n",
    ))
    .expect("valide");
    assert!(ok.outbound.enabled);
    let without_hostname = toml("o_host", "[outbound]\nenabled = true\n")
        .replace("[smtp]\nhostname = \"mx.lyxal.test\"\n", "");
    assert!(
        try_config(&without_hostname).is_err(),
        "smtp.hostname exigé"
    );
    for extra in [
        "[outbound]\nmax_connections = 0\n",
        "[outbound]\ntls = \"none\"\n",
        "[outbound]\nip_families = [\"ipx\"]\n",
        "[outbound]\ninconnu = 1\n",
        "[outbound]\nlease_seconds = 10\n",
        "[outbound.relay]\nhost = \"relais.example.test\"\nport = 587\ntls = \"none\"\n",
    ] {
        assert!(try_config(&toml("o_bad", extra)).is_err(), "{extra}");
    }
}

/// Faux MX à STARTTLS réel : accueil, `EHLO` (STARTTLS annoncé), `STARTTLS`, poignée de main
/// par l'écoute TLS de l'hôte, `EHLO` chiffré, puis `QUIT`.
async fn starttls_mx(tls: ListenerTls) -> u16 {
    let listener = TcpListener::bind("127.0.0.1:0").await.unwrap();
    let port = listener.local_addr().unwrap().port();
    tokio::spawn(async move {
        while let Ok((stream, _)) = listener.accept().await {
            let tls = tls.clone();
            tokio::spawn(async move {
                let mut stream = BufReader::new(stream);
                stream
                    .get_mut()
                    .write_all(b"220 mx ESMTP\r\n")
                    .await
                    .unwrap();
                let mut line = String::new();
                stream.read_line(&mut line).await.unwrap();
                stream
                    .get_mut()
                    .write_all(b"250-mx\r\n250 STARTTLS\r\n")
                    .await
                    .unwrap();
                line.clear();
                stream.read_line(&mut line).await.unwrap();
                assert!(line.starts_with("STARTTLS"));
                stream.get_mut().write_all(b"220 go\r\n").await.unwrap();
                let Ok((secured, _)) = tls.accept(stream.into_inner()).await else {
                    return;
                };
                let mut secured = BufReader::new(secured);
                line.clear();
                if secured.read_line(&mut line).await.is_err() {
                    return;
                }
                let _ = secured.get_mut().write_all(b"250 mx\r\n").await;
                line.clear();
                let _ = secured.read_line(&mut line).await;
                let _ = secured.get_mut().write_all(b"221 bye\r\n").await;
            });
        }
    });
    port
}

#[tokio::test]
async fn starttls_through_the_host_connector_is_opportunistic_and_refuses_unverified_relays() {
    let certificates = TestCertificates::new();
    let config = crate::support::config("o_tls", &certificates.tls_section());
    let store = Certificates::load(&config.tls)
        .expect("certificats")
        .expect("certificats déclarés")
        .store();
    let tls = ListenerTls::new(
        store,
        "essai",
        &[],
        lyxal_groupware::config::TlsMinVersion::Tls12,
        Duration::from_secs(5),
    )
    .unwrap();
    let port = starttls_mx(tls).await;
    let connector = HostTlsConnector::new().unwrap();
    let timeouts = OutboundConfig::new("mx.lyxal.test", "n").timeouts;
    let ehlo = Domain::parse("mx.lyxal.test").unwrap();
    let mut target = ConnectTarget {
        host: "mail.example.test".into(),
        ip: "127.0.0.1".parse().unwrap(),
        port,
        tls: TargetTls::Opportunistic,
        source: None,
    };
    let connection = SmtpConnection::open(&target, &ehlo, Some(&connector), None, &timeouts)
        .await
        .expect("STARTTLS opportuniste");
    let info = connection.tls.expect("TLS négocié");
    assert!(!info.verified, "certificat d'essai non vérifié (RFC 7435)");
    assert!(info.version.starts_with("TLSv1."));
    connection.quit().await;

    // Relais : TLS vérifié par webpki-roots, l'autorité d'essai n'y est pas
    target.tls = TargetTls::RequiredStartTls;
    let refused = SmtpConnection::open(&target, &ehlo, Some(&connector), None, &timeouts)
        .await
        .expect_err("certificat non vérifié refusé");
    assert_eq!(refused.stage, lyxal_mail::models::AttemptStage::Tls);
    assert!(!refused.tls_failed, "aucun repli en clair vers un relais");
}

#[tokio::test]
async fn the_host_runs_the_outbound_worker_and_the_dkim_task() {
    let root = tempfile::tempdir().unwrap();
    let directory = tempfile::tempdir().unwrap();
    let key = test_master_key();
    std::env::set_var(MASTER_KEY_VAR, &key);
    let mut variables = config::Map::new();
    variables.insert(MASTER_KEY_VAR.to_string(), key);
    let extra = format!(
        "[storage.disk]\nroot = \"{}\"\n[secrets]\nmaster_key_id = \"vault-1\"\n[outbound]\nenabled = true\nallow_private_networks = true\n{}",
        root.path().display().to_string().replace('\\', "/"),
        fake_dns().await
    );
    fs::write(
        directory.path().join("default.toml"),
        toml("o_host_run", &extra),
    )
    .unwrap();
    let config = lyxal_groupware::config::GroupwareConfig::load_with_environment(
        directory.path(),
        Some(variables),
    )
    .expect("configuration");
    let client = crate::support::database("o_host_run").await;
    let started = start(&config, &client).await;
    assert!(
        started.services.outbound.is_some(),
        "worker d'envoi inscrit"
    );
    let snapshot = started
        .mail
        .snapshot()
        .outbound
        .expect("mesures de l'envoi");
    assert!(snapshot.contains_key("recipients_delivered"));
    assert!(snapshot.keys().all(|key| !key.contains('@')));

    let (_account, inbox) = account(&client, &started).await;
    let system = started.services.system.clone();
    let domains: Vec<surrealdb::types::RecordId> = client
        .query("SELECT VALUE id FROM mail_domain;")
        .await
        .unwrap()
        .take(0)
        .unwrap();
    let domain = domains[0].to_sql();
    system
        .domain_update(DomainUpdateParams {
            domain,
            state: None,
            subaddress_separator: None,
            catch_all: None,
            postmaster: None,
            module_senders: Some(vec!["noreply".into()]),
            backscatter_protection: None,
            clear: Vec::new(),
        })
        .await
        .unwrap();

    // Tâche mail.dkim_provision : deux clés créées, en attente (le DNS d'essai ne les montre pas)
    let scheduler = SchedulerStore::new(client.clone());
    let page = scheduler
        .schedule_list(ScheduleListParams {
            task: Some(MAIL_DKIM_TASK.to_string()),
            ..ScheduleListParams::default()
        })
        .await
        .unwrap();
    assert_eq!(page.items[0].name, MAIL_DKIM_SCHEDULE);
    let run = scheduler
        .schedule_trigger(ScheduleTriggerParams {
            schedule: page.items[0].id.clone(),
            overlap: Some(Overlap::AllowAll),
            language: None,
        })
        .await
        .unwrap();
    let mut result = serde_json::Value::Null;
    for _ in 0..300 {
        let current = scheduler
            .run_get(RunRefParams {
                run: run.id.clone(),
                language: None,
            })
            .await
            .unwrap();
        if current.state == RunState::Completed {
            result = current
                .result
                .map(|v| v.into_json_value())
                .unwrap_or_default();
            break;
        }
        assert!(
            !matches!(current.state, RunState::Dead | RunState::Cancelled),
            "{:?}",
            current.error
        );
        tokio::time::sleep(Duration::from_millis(100)).await;
    }
    assert_eq!(result["created"], 2, "{result}");
    assert_eq!(result["pending"], 0);

    // Dépôt d'un module : domaine inexistant (DNS d'essai : NXDOMAIN) et boîte de l'installation
    let mut params = BucketCreateParams::named(Some("auth_organization:alpha".into()), MAIL_BUCKET);
    params.encrypted = true;
    params.emit_events = false;
    let bucket = StorageStore::new(client.clone())
        .bucket_create(params)
        .await
        .unwrap()
        .id
        .to_sql();
    let reserved = system
        .submission_begin(SubmissionBeginParams {
            origin: Some(SubmissionOrigin::Module),
            from: "noreply@alpha.test".into(),
            header_from: vec!["noreply@alpha.test".into()],
            recipients: vec![
                SubmissionRecipient {
                    address: "x@ailleurs.test".into(),
                    notify: None,
                    orcpt: None,
                },
                SubmissionRecipient {
                    address: "jean@alpha.test".into(),
                    notify: None,
                    orcpt: None,
                },
            ],
            size: MESSAGE.len() as i64,
            smtputf8: None,
            eight_bit: None,
            dsn: None,
            client_reference: Some("essai".into()),
            return_token: None,
            prefix: None,
            forward: None,
            tenant: None,
        })
        .await
        .unwrap();
    let object = started
        .services
        .storage
        .put(
            PutRequest {
                bucket,
                key: reserved.key.clone(),
                filename: "message.eml".into(),
                content_type: None,
                size: Some(MESSAGE.len() as u64),
            },
            futures::stream::iter([Ok::<Bytes, Infallible>(Bytes::from_static(
                MESSAGE.as_bytes(),
            ))]),
        )
        .await
        .unwrap()
        .id
        .to_sql();
    system
        .submission_commit(SubmissionCommitParams {
            submission: reserved.submission.to_sql(),
            object,
        })
        .await
        .unwrap();
    let mut states = Vec::new();
    for _ in 0..300 {
        states = system
            .submission_get(SubmissionRefParams {
                submission: reserved.submission.to_sql(),
            })
            .await
            .unwrap()
            .recipients
            .into_iter()
            .map(|r| (r.state, r.last_result.and_then(|l| l.enhanced)))
            .collect::<Vec<_>>();
        if states
            .iter()
            .all(|(state, _)| !matches!(state, RecipientState::Scheduled | RecipientState::Running))
        {
            break;
        }
        tokio::time::sleep(Duration::from_millis(100)).await;
    }
    assert_eq!(
        states[0],
        (RecipientState::Failed, Some("5.1.2".to_string()))
    );
    assert_eq!(states[1].0, RecipientState::Delivered, "route locale");
    let messages: Vec<surrealdb::types::Value> = client
        .query(format!(
            "SELECT VALUE id FROM mail_message WHERE mailbox = {inbox};"
        ))
        .await
        .unwrap()
        .take(0)
        .unwrap();
    assert_eq!(messages.len(), 1);
    started.runtime.stop_all().await.expect("arrêt");
}
