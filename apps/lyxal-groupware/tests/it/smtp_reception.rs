// SPDX-License-Identifier: AGPL-3.0-only

//! Réception SMTP dans l'hôte (lot 5d) : écoute `smtp` servie par `SmtpInboundHandler`,
//! résolveur du nœud (serveur DNS d'essai qui ne connaît aucun nom), message envoyé par le
//! client `lettre` puis lu par le service du courrier, événement publié, mesures ; STARTTLS réel
//! par `openssl s_client -starttls smtp` ; liste de blocage de l'installation appliquée à
//! l'acceptation ; configuration `[smtp]` et `[dns]`.

use crate::mail_service::{account, start, test_master_key, MASTER_KEY_VAR};
use crate::support::{fake_dns, first_line, s_client, toml, try_config, TestCertificates};
use lettre::message::Mailbox;
use lettre::transport::smtp::extension::ClientId;
use lettre::{AsyncSmtpTransport, AsyncTransport, Message, Tokio1Executor};
use lyxal_groupware::config::GroupwareConfig;
use lyxal_mail::models::{BlockCreateParams, MessageListParams};
use lyxal_surreal::ToSql;
use std::fs;
use tokio::io::{AsyncReadExt, AsyncWriteExt};
use tokio::net::TcpStream;

/// Configuration : support disque, clé maîtresse, DNS d'essai, écoute `smtp` (`tls`).
async fn config(
    database: &str,
    root: &std::path::Path,
    tls: &str,
    certificates: Option<&TestCertificates>,
) -> GroupwareConfig {
    let directory = tempfile::tempdir().expect("tempdir");
    let key = test_master_key();
    std::env::set_var(MASTER_KEY_VAR, &key);
    let mut variables = config::Map::new();
    variables.insert(MASTER_KEY_VAR.to_string(), key);
    let mut extra = format!(
        "[storage.disk]\nroot = \"{}\"\n[secrets]\nmaster_key_id = \"vault-1\"\n{}",
        root.display().to_string().replace('\\', "/"),
        fake_dns().await
    );
    if let Some(certificates) = certificates {
        extra.push_str(&certificates.tls_section());
    }
    extra.push_str(&format!(
        "\n[[listeners]]\nid = \"smtp\"\nprotocol = \"smtp\"\nbind = [\"127.0.0.1:0\"]\ntls = \"{tls}\"\n"
    ));
    fs::write(
        directory.path().join("default.toml"),
        toml(database, &extra),
    )
    .expect("default.toml");
    GroupwareConfig::load_with_environment(directory.path(), Some(variables))
        .expect("configuration valide")
}

const MESSAGE_ID: &str = "lettre-1@ailleurs.test";

#[tokio::test]
async fn the_host_receives_smtp_mail_from_a_real_client() {
    let root = tempfile::tempdir().expect("support");
    let config = config("smtp_reception", root.path(), "none", None).await;
    let client = crate::support::database("smtp_reception").await;
    let started = start(&config, &client).await;
    let (_, inbox) = account(&client, &started).await;
    let address = started.mail.local_addrs("smtp")[0];

    let email = Message::builder()
        .from("Paul <paul@ailleurs.test>".parse::<Mailbox>().unwrap())
        .to("Jean <jean@alpha.test>".parse::<Mailbox>().unwrap())
        .subject("Devis du chantier")
        .message_id(Some(format!("<{MESSAGE_ID}>")))
        .body("Bonjour, voici le devis.".to_string())
        .unwrap();
    let transport = AsyncSmtpTransport::<Tokio1Executor>::builder_dangerous("127.0.0.1")
        .port(address.port())
        .hello_name(ClientId::Domain("client.ailleurs.test".to_string()))
        .build();
    let response = transport.send(email).await.expect("envoi accepté");
    assert_eq!(response.code().to_string(), "250");

    // Message rangé dans la boîte de réception, lu par le service du courrier
    let system = started.services.system.clone();
    let page = system
        .message_list(MessageListParams {
            mailbox: inbox.clone(),
            before: None,
            uid_min: None,
            uid_max: None,
            limit: None,
            fields: None,
        })
        .await
        .expect("liste");
    assert_eq!(page.items.len(), 1);
    let message = &page.items[0];
    assert_eq!(message.origin, "delivery");
    let bytes = started
        .services
        .content
        .read(&system, &message.id.to_sql(), None)
        .await
        .expect("lecture");
    let text = String::from_utf8(bytes.to_vec()).expect("texte");
    // Le nom inverse de 127.0.0.1 (`localhost`) est rendu par le résolveur lui-même
    assert!(
        text.starts_with(
            "Return-Path: <paul@ailleurs.test>\r\nReceived: from client.ailleurs.test ("
        ),
        "{text}"
    );
    assert!(
        text.contains("[127.0.0.1])\r\n\tby mx.lyxal.test with ESMTP id "),
        "{text}"
    );
    // DNS d'essai : aucun nom n'existe (SPF none, DMARC none, nom inverse permerror)
    assert!(
        text.contains(
            "Authentication-Results: mx.lyxal.test;\r\n\tspf=none smtp.mailfrom=ailleurs.test"
        ),
        "{text}"
    );
    assert!(
        text.contains("dmarc=none header.from=ailleurs.test"),
        "{text}"
    );
    assert!(text.contains(MESSAGE_ID));

    // Événement publié, sans adresse ni sujet
    let mut response = client
        .query("RETURN <string> (SELECT VALUE payload FROM ONLY event_outbox WHERE event_type = 'mail.message.received' LIMIT 1);")
        .await
        .expect("requête");
    let payload: Option<String> = response.take(0).expect("charge utile");
    let payload = payload.expect("événement publié");
    for word in ["@", "Devis", "ailleurs", "alpha.test"] {
        assert!(!payload.contains(word), "{word} : {payload}");
    }

    // Mesures de l'écoute et de la réception
    let snapshot = started.mail.snapshot();
    let smtp = snapshot.smtp.expect("mesures de la réception");
    assert_eq!(smtp["messages_accepted"], 1);
    assert!(smtp["dns_queries"] > 0);
    assert_eq!(smtp["dns_failures"], 0);
    assert_eq!(snapshot.listeners["smtp"].accepted, 1);

    // Destinataire d'un domaine extérieur : aucun relais
    let mut stream = TcpStream::connect(address).await.expect("connexion");
    assert_eq!(first_line(&mut stream).await, "220 mx.lyxal.test ESMTP");
    stream
        .write_all(b"HELO client.ailleurs.test\r\nMAIL FROM:<paul@ailleurs.test>\r\nRCPT TO:<qui@ailleurs.test>\r\nQUIT\r\n")
        .await
        .unwrap();
    for expected in ["250 mx.lyxal.test", "250 2.1.0", "550 5.7.1", "221 2.0.0"] {
        let line = first_line(&mut stream).await;
        assert!(line.starts_with(expected), "{expected} : {line}");
    }

    // Réseau bloqué pour l'installation : refusé à l'acceptation, sans dialogue
    system
        .block_create(BlockCreateParams {
            network: "127.0.0.1/32".to_string(),
            reason: None,
            expires_at: None,
        })
        .await
        .expect("blocage manuel");
    started
        .services
        .blocks
        .refresh(&system)
        .await
        .expect("liste relue");
    let mut stream = TcpStream::connect(address).await.expect("connexion");
    assert_eq!(
        first_line(&mut stream).await,
        "421 4.7.0 Connection refused by policy"
    );
    let mut rest = Vec::new();
    let _ = stream.read_to_end(&mut rest).await;
    started.runtime.stop_all().await.expect("arrêt");
}

#[tokio::test]
async fn smtp_starttls_is_negotiated_and_the_message_is_marked_tls() {
    let certificates = TestCertificates::new();
    let root = tempfile::tempdir().expect("support");
    let config = config(
        "smtp_starttls",
        root.path(),
        "starttls",
        Some(&certificates),
    )
    .await;
    let client = crate::support::database("smtp_starttls").await;
    let certificates_loaded =
        lyxal_groupware::net::certificates::Certificates::load(&config.tls).expect("certificats");
    let started = lyxal_groupware::runtime::start(
        &config,
        &client.clone().into(),
        lyxal_groupware::net::bind::bind_listeners(&config).expect("liaison"),
        certificates_loaded,
    )
    .await
    .expect("démarrage");
    let (_, inbox) = account(&client, &started).await;
    let address = started.mail.local_addrs("smtp")[0];
    let body = "From: <paul@ailleurs.test>\r\nSubject: chiffre\r\n\r\nCorps.\r\n";
    let input = format!(
        "EHLO client.ailleurs.test\r\nMAIL FROM:<paul@ailleurs.test>\r\nRCPT TO:<jean@alpha.test>\r\nBDAT {} LAST\r\n{body}QUIT\r\n",
        body.len()
    );
    let result = s_client(
        address,
        &certificates,
        &["-starttls", "smtp", "-servername", "mail.example.test"],
        input.as_bytes(),
    )
    .await;
    assert!(result.stdout.contains("250 2.0.0 Ok"), "{result:?}");
    assert!(result.stdout.contains("221 2.0.0 Bye"), "{result:?}");
    let system = started.services.system.clone();
    let page = system
        .message_list(MessageListParams {
            mailbox: inbox,
            before: None,
            uid_min: None,
            uid_max: None,
            limit: None,
            fields: None,
        })
        .await
        .expect("liste");
    assert_eq!(page.items.len(), 1);
    let text = String::from_utf8(
        started
            .services
            .content
            .read(&system, &page.items[0].id.to_sql(), None)
            .await
            .expect("lecture")
            .to_vec(),
    )
    .expect("texte");
    assert!(text.contains("with ESMTPS id "), "{text}");
    assert!(text.contains("(version=TLSv1_"), "{text}");
    started.runtime.stop_all().await.expect("arrêt");
}

#[test]
fn smtp_and_dns_settings_are_checked() {
    let listener = "\n[[listeners]]\nid = \"smtp\"\nprotocol = \"smtp\"\nbind = [\"127.0.0.1:0\"]\ntls = \"none\"\n";
    let without_hostname =
        toml("smtp_config", listener).replace("[smtp]\nhostname = \"mx.lyxal.test\"\n", "");
    let error = try_config(&without_hostname).expect_err("hostname obligatoire");
    assert!(error.to_string().contains("smtp.hostname"), "{error}");
    // Sans écoute smtp, le nom n'est pas exigé
    assert!(try_config(
        &toml("smtp_config", "").replace("[smtp]\nhostname = \"mx.lyxal.test\"\n", "")
    )
    .is_ok());
    for (extra, expected) in [
        ("max_recipients = 0", "smtp.max_recipients"),
        ("max_message_bytes = 10", "smtp.max_message_bytes"),
        (
            "command_timeout_seconds = 5",
            "smtp.command_timeout_seconds",
        ),
        ("max_errors = 1000", "smtp.max_errors"),
        (
            "messages_per_network_per_minute = [0, 1, 1]",
            "messages_per_network_per_minute",
        ),
    ] {
        let text = toml("smtp_config", listener).replace(
            "hostname = \"mx.lyxal.test\"\n",
            &format!("hostname = \"mx.lyxal.test\"\n{extra}\n"),
        );
        let error = try_config(&text).expect_err(extra);
        assert!(error.to_string().contains(expected), "{extra} : {error}");
    }
    let text = toml("smtp_config", listener).replace("mx.lyxal.test", "pas un nom");
    assert!(try_config(&text).is_err());
    for (dns, expected) in [
        ("servers = [\"pas-une-adresse\"]", "dns.servers"),
        ("timeout_seconds = 0", "timeout_seconds"),
        ("attempts = 9", "attempts"),
    ] {
        let error = try_config(&toml("smtp_config", &format!("[dns]\n{dns}\n"))).expect_err(dns);
        assert!(error.to_string().contains(expected), "{dns} : {error}");
    }
    let config = try_config(&toml(
        "smtp_config",
        &format!("[dns]\nservers = [\"192.0.2.53\", \"[2001:db8::53]:5353\"]\n{listener}"),
    ))
    .expect("configuration");
    let dns = config.dns.dns_config().expect("dns");
    assert_eq!(dns.servers[0].to_string(), "192.0.2.53:53");
    assert_eq!(dns.servers[1].to_string(), "[2001:db8::53]:5353");
    let smtp = config.smtp.smtp_config().expect("smtp");
    assert_eq!(smtp.hostname, "mx.lyxal.test");
    assert_eq!(smtp.max_recipients, 100);
    assert!(smtp.dmarc_enforce);
}
