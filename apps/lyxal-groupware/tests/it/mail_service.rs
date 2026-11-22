// SPDX-License-Identifier: AGPL-3.0-only

//! Services du courrier dans l'hôte (lot 4d) : démarrage avec la clé maîtresse du coffre-fort et
//! un support disque, sonde de `lyxal_mail`, dépôt puis lecture d'un message chiffré par les
//! services de l'hôte, maintenance exécutée par `lyxal_scheduler` (tâche `mail.maintenance`,
//! planifiée une seule fois) ; sans clé maîtresse : sonde « dégradé », dépôt refusé à réessayer.

use bytes::Bytes;
use lyxal_groupware::config::GroupwareConfig;
use lyxal_groupware::net::bind::bind_listeners;
use lyxal_groupware::runtime::{self, Started};
use lyxal_groupware::services::{MAIL_MAINTENANCE_SCHEDULE, MAIL_MAINTENANCE_TASK};
use lyxal_mail::models::{
    AccountCreateParams, DomainCreateParams, ExpungeParams, MailboxListParams,
};
use lyxal_mail::{Delivery, DeliveryFlags};
use lyxal_runtime::health::HealthStatus;
use lyxal_runtime::{ModuleContext, ModuleId};
use lyxal_scheduler::models::{
    Overlap, Run, RunRefParams, RunState, ScheduleListParams, ScheduleTriggerParams,
};
use lyxal_scheduler::SchedulerStore;
use lyxal_surreal::ToSql;
use serde_json::Value;
use std::fs;
use std::time::Duration;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

/// Variable de la clé maîtresse lue par l'hôte (propre à ces essais : aucun autre essai ne
/// déclare `secrets.master_key`).
const MASTER_KEY_VAR: &str = "LYXAL_GROUPWARE__SECRETS__MASTER_KEY";

const MESSAGE: &str = "From: Paul <paul@ailleurs.test>\r\n\
To: Jean <jean@alpha.test>\r\n\
Subject: Essai\r\n\
Date: Tue, 3 Nov 2026 10:00:00 +0100\r\n\
Message-ID: <essai-1@ailleurs.test>\r\n\
\r\n\
Bonjour.\r\n";

/// Clé AES-256 d'essai en Base64 canonique (44 caractères).
fn test_master_key() -> String {
    const ALPHABET: &[u8; 64] = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    let bytes: Vec<u8> = (0..32u8)
        .map(|i| i.wrapping_mul(37).wrapping_add(11))
        .collect();
    let mut out = String::new();
    for chunk in bytes.chunks(3) {
        let b = [
            chunk[0],
            chunk.get(1).copied().unwrap_or(0),
            chunk.get(2).copied().unwrap_or(0),
        ];
        let n = (u32::from(b[0]) << 16) | (u32::from(b[1]) << 8) | u32::from(b[2]);
        for i in 0..4 {
            if i <= chunk.len() {
                out.push(ALPHABET[((n >> (18 - 6 * i)) & 63) as usize] as char);
            } else {
                out.push('=');
            }
        }
    }
    out
}

/// Configuration de l'hôte avec un support disque, et la clé maîtresse si `with_key`.
fn config(database: &str, root: &std::path::Path, with_key: bool) -> GroupwareConfig {
    let directory = tempfile::tempdir().expect("tempdir");
    let mut extra = format!(
        "[storage.disk]\nroot = \"{}\"\n",
        root.display().to_string().replace('\\', "/")
    );
    let mut variables = config::Map::new();
    if with_key {
        let key = test_master_key();
        std::env::set_var(MASTER_KEY_VAR, &key);
        variables.insert(MASTER_KEY_VAR.to_string(), key);
        extra.push_str("[secrets]\nmaster_key_id = \"vault-1\"\n");
    }
    fs::write(
        directory.path().join("default.toml"),
        crate::support::toml(database, &extra),
    )
    .expect("default.toml");
    GroupwareConfig::load_with_environment(directory.path(), Some(variables))
        .expect("configuration valide")
}

async fn start(config: &GroupwareConfig, client: &Surreal<Any>) -> Started {
    runtime::start(
        config,
        client,
        bind_listeners(config).expect("liaison"),
        None,
    )
    .await
    .expect("démarrage")
}

async fn mail_health(started: &Started) -> (HealthStatus, Option<String>) {
    let probe = started
        .runtime
        .health_registry()
        .get_check(&ModuleId::new(lyxal_mail::MODULE_ID))
        .expect("sonde de lyxal_mail");
    let result = probe
        .check(&ModuleContext::new(lyxal_mail::MODULE_ID))
        .await
        .expect("sonde");
    (result.status, result.message)
}

async fn run(client: &Surreal<Any>, query: &str) {
    client
        .query(query)
        .await
        .expect("requête")
        .check()
        .unwrap_or_else(|error| panic!("{query} : {error}"));
}

/// Organisation, domaine vérifié, compte de courrier de jean ; rend son compte et sa boîte de
/// réception.
async fn account(client: &Surreal<Any>, started: &Started) -> (String, String) {
    run(
        client,
        "CREATE auth_organization:alpha CONTENT { slug: 'alpha', name: 'Alpha BTP' };
         CREATE auth_organization_domain:alpha CONTENT { organization: auth_organization:alpha, domain: 'alpha.test', state: 'verified', challenge_hash: 'af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262' };
         CREATE auth_identity:jean CONTENT { schema: auth_identity_schema:default_v1, traits: { email: 'jean@lyxal.test' } };
         RELATE auth_identity:jean->auth_member_of->auth_organization:alpha;",
    )
    .await;
    let system = &started.services.system;
    let domain = system
        .domain_create(DomainCreateParams {
            auth_domain: "auth_organization_domain:alpha".to_string(),
            subaddress_separator: None,
        })
        .await
        .expect("domaine")
        .id
        .to_sql();
    let account = system
        .account_create(AccountCreateParams {
            identity: "auth_identity:jean".to_string(),
            domain,
            local_part: "jean".to_string(),
            quota_bytes: None,
        })
        .await
        .expect("compte")
        .account
        .id
        .to_sql();
    let inbox = system
        .mailbox_list(MailboxListParams {
            account: Some(account.clone()),
        })
        .await
        .expect("dossiers")
        .into_iter()
        .find(|mailbox| mailbox.role.as_deref() == Some("inbox"))
        .expect("boîte de réception")
        .id
        .to_sql();
    (account, inbox)
}

/// Déclenche la planification de la maintenance du courrier et attend la fin de l'exécution par
/// le planificateur de l'hôte ; rend son résultat court.
async fn trigger_maintenance(store: &SchedulerStore) -> Value {
    let page = store
        .schedule_list(ScheduleListParams {
            task: Some(MAIL_MAINTENANCE_TASK.to_string()),
            ..ScheduleListParams::default()
        })
        .await
        .expect("planifications");
    assert_eq!(page.total, 1, "{:?}", page.items);
    assert_eq!(page.items[0].name, MAIL_MAINTENANCE_SCHEDULE);
    let run: Run = store
        .schedule_trigger(ScheduleTriggerParams {
            schedule: page.items[0].id.clone(),
            overlap: Some(Overlap::AllowAll),
            language: None,
        })
        .await
        .expect("déclenchement");
    for _ in 0..300 {
        let current = store
            .run_get(RunRefParams {
                run: run.id.clone(),
                language: None,
            })
            .await
            .expect("exécution");
        match current.state {
            RunState::Completed => {
                return current
                    .result
                    .map(|value| value.into_json_value())
                    .unwrap_or(Value::Null)
            }
            RunState::Dead | RunState::Cancelled | RunState::Skipped => {
                panic!("maintenance : {:?} ({:?})", current.state, current.error)
            }
            _ => tokio::time::sleep(Duration::from_millis(100)).await,
        }
    }
    panic!("l'exécution de la maintenance n'a pas abouti");
}

#[tokio::test]
async fn the_host_delivers_reads_and_maintains_encrypted_mail() {
    let root = tempfile::tempdir().expect("support");
    let config = config("mail_service", root.path(), true);
    let client = crate::support::database("mail_service").await;
    let started = start(&config, &client).await;

    let (status, message) = mail_health(&started).await;
    assert_eq!(status, HealthStatus::Healthy, "{message:?}");

    let (account, inbox) = account(&client, &started).await;
    let system = started.services.system.clone();
    let message = started
        .services
        .ingest
        .deliver(
            &system,
            Delivery {
                account: account.clone(),
                mailbox: inbox.clone(),
                raw: Bytes::from_static(MESSAGE.as_bytes()),
                received_at: None,
                flags: DeliveryFlags::default(),
            },
        )
        .await
        .expect("dépôt");
    let read = started
        .services
        .content
        .read(&system, &message.id.to_sql(), None)
        .await
        .expect("lecture");
    assert_eq!(read, MESSAGE.as_bytes());
    // Octets rangés sur le disque : chiffrés
    let mut stored = Vec::new();
    for entry in walk(root.path()) {
        stored.push(fs::read(entry).expect("fichier"));
    }
    assert_eq!(stored.len(), 1);
    assert!(stored[0].starts_with(b"LXS1"));
    assert!(!stored[0].windows(8).any(|w| w == b"Bonjour."));

    // Effacement, puis maintenance par le planificateur : contenu libéré retiré avec son fichier
    system
        .message_expunge(ExpungeParams {
            mailbox: inbox,
            messages: Some(vec![message.id.to_sql()]),
        })
        .await
        .expect("effacement");
    let store = SchedulerStore::new(client.clone());
    let result = trigger_maintenance(&store).await;
    assert_eq!(result["released"], 1, "{result}");
    let mut response = client
        .query("RETURN count(SELECT * FROM mail_content);")
        .await
        .expect("requête");
    let contents: Option<i64> = response.take(0).expect("total");
    assert_eq!(contents, Some(0));
    started.runtime.stop_all().await.expect("arrêt");
    drop(started);

    // Redémarrage : la tâche et sa planification ne sont pas recréées
    let restarted = start(&config, &client).await;
    let page = store
        .schedule_list(ScheduleListParams {
            task: Some(MAIL_MAINTENANCE_TASK.to_string()),
            ..ScheduleListParams::default()
        })
        .await
        .expect("planifications");
    assert_eq!(page.total, 1);
    restarted.runtime.stop_all().await.expect("arrêt");
}

#[tokio::test]
async fn without_master_key_the_probe_is_degraded_and_deliveries_are_retryable() {
    let root = tempfile::tempdir().expect("support");
    let config = config("mail_service_keyless", root.path(), false);
    let client = crate::support::database("mail_service_keyless").await;
    let started = start(&config, &client).await;

    let (status, message) = mail_health(&started).await;
    assert_eq!(status, HealthStatus::Degraded);
    assert!(
        message
            .as_deref()
            .is_some_and(|m| m.contains("MAIL_CONTENT_UNAVAILABLE")),
        "{message:?}"
    );
    assert!(!started.services.ingest.is_available());

    let (account, inbox) = account(&client, &started).await;
    let refused = started
        .services
        .ingest
        .deliver(
            &started.services.system,
            Delivery {
                account,
                mailbox: inbox,
                raw: Bytes::from_static(MESSAGE.as_bytes()),
                received_at: None,
                flags: DeliveryFlags::default(),
            },
        )
        .await
        .expect_err("dépôt refusé");
    assert_eq!(refused.code(), "MAIL_CONTENT_UNAVAILABLE");
    assert!(refused.is_retryable());
    assert!(walk(root.path()).is_empty());
    started.runtime.stop_all().await.expect("arrêt");
}

/// Fichiers sous un dossier (fichiers témoins de la sonde du stockage exclus).
fn walk(directory: &std::path::Path) -> Vec<std::path::PathBuf> {
    let mut files = Vec::new();
    let Ok(entries) = fs::read_dir(directory) else {
        return files;
    };
    for entry in entries.flatten() {
        let path = entry.path();
        if path.file_name().is_some_and(|name| name == "_lyxal_probe") {
            continue;
        }
        if path.is_dir() {
            files.extend(walk(&path));
        } else {
            files.push(path);
        }
    }
    files
}
