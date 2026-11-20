//! TLS implicite sur de vraies sockets (client d'essai `openssl s_client`, certificats d'essai
//! de `lyxal_crypto`) : TLS 1.2 et 1.3, certificat par nom (SNI) et par défaut, ALPN négocié et
//! ALPN étranger refusé, version minimale par écoute, poignée de main hors délai fermée, refus
//! sans poignée de main.

use crate::support::{
    listener, run_workers, s_client, tls_net, RecordingHandler, TestCertificates,
};
use lyxal_mail::net::{TlsInfo, TlsState};
use std::sync::Arc;
use std::time::{Duration, Instant};
use tokio::io::AsyncReadExt;
use tokio::net::TcpStream;

fn implicit_info(state: &TlsState) -> &TlsInfo {
    match state {
        TlsState::Implicit(info) => info,
        other => panic!("TLS implicite attendu : {other:?}"),
    }
}

#[tokio::test]
async fn implicit_tls_serves_named_and_default_certificates_over_tls12_and_tls13() {
    let certificates = TestCertificates::new();
    let config = crate::support::config(
        "tls",
        &format!(
            "[limits]\ndrain_seconds = 2\n{}{}",
            certificates.tls_section(),
            listener("imaps", "imap", "implicit", "")
        ),
    );
    let handler = RecordingHandler::default();
    let net = tls_net(&config, Arc::new(handler.clone()));
    let running = run_workers(&net);
    let address = net.local_addrs("imaps")[0];

    for (flag, openssl_name, rustls_name) in [
        ("-tls1_3", "TLSv1.3", "TLSv1_3"),
        ("-tls1_2", "TLSv1.2", "TLSv1_2"),
    ] {
        let client = s_client(
            address,
            &certificates,
            &[flag, "-servername", "mail.example.test", "-alpn", "imap"],
            b"",
        )
        .await;
        assert!(client.success, "{client:?}");
        assert_eq!(client.field("Protocol version"), Some(openssl_name));
        assert_eq!(client.field("Peer certificate"), Some("CN = p256"));
        assert_eq!(client.field("Verification"), Some("OK"));
        assert!(client.stdout.contains("220 session"), "{client:?}");

        let seen = handler.last();
        let info = implicit_info(&seen.tls);
        assert_eq!(info.version, rustls_name);
        assert_eq!(info.server_name.as_deref(), Some("mail.example.test"));
        assert_eq!(info.alpn.as_deref(), Some(&b"imap"[..]));
        assert!(!info.cipher.is_empty() && info.cipher != "unknown");
        assert!(!seen.via_proxy);
    }

    // Sans nom (SNI) : certificat par défaut ; sans ALPN : accepté, rien de négocié
    let client = s_client(address, &certificates, &["-noservername"], b"").await;
    assert!(client.success, "{client:?}");
    assert_eq!(client.field("Peer certificate"), Some("CN = default"));
    let seen = handler.last();
    let info = implicit_info(&seen.tls);
    assert_eq!(info.server_name, None);
    assert_eq!(info.alpn, None);
    assert_eq!(net.snapshot().listeners["imaps"].accepted, 3);
    assert_eq!(net.snapshot().listeners["imaps"].tls_handshake_failures, 0);
    running.stop().await;
}

#[tokio::test]
async fn foreign_alpn_old_versions_and_slow_handshakes_are_refused() {
    let certificates = TestCertificates::new();
    let config = crate::support::config(
        "tls",
        &format!(
            "[limits]\ndrain_seconds = 2\n{}{}{}",
            certificates.tls_section(),
            listener("imaps", "imap", "implicit", ""),
            listener("pop3s", "pop3", "implicit", "tls_min_version = \"1.3\""),
        ),
    );
    let handler = RecordingHandler::default();
    let net = tls_net(&config, Arc::new(handler.clone()));
    let running = run_workers(&net);
    let imaps = net.local_addrs("imaps")[0];
    let pop3s = net.local_addrs("pop3s")[0];

    // ALPN d'un autre protocole (h2) : alerte TLS, aucune session
    let client = s_client(
        imaps,
        &certificates,
        &["-servername", "mail.example.test", "-alpn", "h2"],
        b"",
    )
    .await;
    assert!(!client.success, "{client:?}");
    // TLS 1.2 sur une écoute en TLS 1.3 seulement
    let client = s_client(
        pop3s,
        &certificates,
        &["-tls1_2", "-servername", "mail.example.test"],
        b"",
    )
    .await;
    assert!(!client.success, "{client:?}");
    let client = s_client(
        pop3s,
        &certificates,
        &[
            "-tls1_3",
            "-servername",
            "mail.example.test",
            "-alpn",
            "pop3",
        ],
        b"",
    )
    .await;
    assert!(client.success, "{client:?}");

    // Client muet : fermé au délai de la poignée de main (2 s)
    let started = Instant::now();
    let mut silent = TcpStream::connect(imaps).await.unwrap();
    let mut buffer = [0u8; 16];
    let read = tokio::time::timeout(Duration::from_secs(10), silent.read(&mut buffer))
        .await
        .expect("connexion fermée par le serveur");
    assert!(matches!(read, Ok(0) | Err(_)), "{read:?}");
    assert!(started.elapsed() >= Duration::from_millis(1500));

    let snapshot = net.snapshot();
    assert_eq!(snapshot.listeners["imaps"].tls_handshake_failures, 2);
    assert_eq!(snapshot.listeners["imaps"].accepted, 0);
    assert_eq!(snapshot.listeners["pop3s"].tls_handshake_failures, 1);
    assert_eq!(snapshot.listeners["pop3s"].accepted, 1);
    assert_eq!(handler.seen.lock().unwrap().len(), 1);
    running.stop().await;
}

#[tokio::test]
async fn refusals_on_an_implicit_listener_close_without_a_handshake() {
    let certificates = TestCertificates::new();
    let config = crate::support::config(
        "tls",
        &format!(
            "[limits]\ndrain_seconds = 2\ndeny_networks = [\"127.0.0.0/8\"]\n{}{}",
            certificates.tls_section(),
            listener("imaps", "imap", "implicit", "")
        ),
    );
    let net = tls_net(&config, Arc::new(RecordingHandler::default()));
    let running = run_workers(&net);
    let mut stream = TcpStream::connect(net.local_addrs("imaps")[0])
        .await
        .unwrap();
    // Aucune ligne en clair sur une écoute chiffrée : fermeture seule
    let mut received = Vec::new();
    tokio::time::timeout(Duration::from_secs(5), stream.read_to_end(&mut received))
        .await
        .expect("fermeture")
        .ok();
    assert!(received.is_empty(), "{received:?}");
    let snapshot = net.snapshot();
    assert_eq!(snapshot.listeners["imaps"].refused["blocked"], 1);
    assert_eq!(snapshot.listeners["imaps"].tls_handshake_failures, 0);
    running.stop().await;
}
