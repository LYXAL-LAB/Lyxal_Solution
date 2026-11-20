//! STARTTLS par un protocole d'essai (salut `220`, `EHLO`, `STARTTLS` → `220` → mise à niveau →
//! `TlsState::Upgraded`), avec le client `openssl s_client -starttls smtp` ; données envoyées à
//! la suite de `STARTTLS` dans le même paquet refusées (injection de commandes en clair) ;
//! `start_tls` refusé sur une écoute sans STARTTLS ; poignée de main en échec comptée.

use crate::support::{
    first_line, listener, run_workers, s_client, smtp_listener, tls_net, TestCertificates,
};
use async_trait::async_trait;
use lyxal_mail::net::{MailProtocol, Session, SessionEnd, SessionHandler, TlsState};
use std::sync::{Arc, Mutex};
use std::time::Duration;
use tokio::io::{AsyncReadExt, AsyncWriteExt};
use tokio::net::TcpStream;

/// Issue d'une demande STARTTLS vue par le protocole d'essai.
#[derive(Debug)]
enum Outcome {
    Upgraded(TlsState),
    Refused(String),
}

/// Protocole d'essai, façon SMTP : `220`, `EHLO` → `250 STARTTLS`, `STARTTLS` → `220` puis mise
/// à niveau avec les octets déjà lus après la commande ; après la mise à niveau, `250 secured`
/// et fermeture.
#[derive(Clone, Default)]
struct StartTlsHandler {
    outcomes: Arc<Mutex<Vec<Outcome>>>,
}

impl StartTlsHandler {
    fn last(&self) -> Outcome {
        self.outcomes.lock().unwrap().pop().expect("aucune issue")
    }
}

#[async_trait]
impl SessionHandler for StartTlsHandler {
    fn protocol(&self) -> MailProtocol {
        MailProtocol::Smtp
    }

    async fn handle(&self, mut session: Session) -> SessionEnd {
        if session
            .stream()
            .write_all(b"220 starttls-test\r\n")
            .await
            .is_err()
        {
            return SessionEnd::Closed;
        }
        // Tampon de lecture du protocole : ce qui suit la ligne en cours y reste
        let mut buffer = Vec::new();
        loop {
            let line = loop {
                if let Some(end) = buffer.windows(2).position(|w| w == b"\r\n") {
                    let line = String::from_utf8_lossy(&buffer[..end]).to_string();
                    buffer.drain(..end + 2);
                    break line;
                }
                let mut chunk = [0u8; 512];
                match session.stream().read(&mut chunk).await {
                    Ok(0) | Err(_) => return SessionEnd::Closed,
                    Ok(n) => buffer.extend_from_slice(&chunk[..n]),
                }
            };
            let command = line.to_ascii_uppercase();
            if command.starts_with("EHLO") {
                let reply: &[u8] = if session.can_start_tls() {
                    b"250-starttls-test\r\n250 STARTTLS\r\n"
                } else {
                    b"250 starttls-test\r\n"
                };
                let _ = session.stream().write_all(reply).await;
            } else if command == "STARTTLS" {
                if session.can_start_tls() {
                    let _ = session.stream().write_all(b"220 go ahead\r\n").await;
                }
                return match session.start_tls(&buffer).await {
                    Ok(()) => {
                        self.outcomes
                            .lock()
                            .unwrap()
                            .push(Outcome::Upgraded(session.info.tls.clone()));
                        let _ = session.stream().write_all(b"250 secured\r\n").await;
                        let _ = session.stream().shutdown().await;
                        SessionEnd::Closed
                    }
                    Err(error) => {
                        self.outcomes
                            .lock()
                            .unwrap()
                            .push(Outcome::Refused(format!("{error:?}")));
                        SessionEnd::Failed(error)
                    }
                };
            } else {
                let _ = session.stream().write_all(b"500 unknown\r\n").await;
            }
        }
    }
}

fn starttls_config(certificates: &TestCertificates) -> lyxal_groupware::config::GroupwareConfig {
    crate::support::config(
        "starttls",
        &format!(
            "[limits]\ndrain_seconds = 2\n{}{}{}",
            certificates.tls_section(),
            listener("submission", "submission", "starttls", ""),
            smtp_listener("plain", ""),
        ),
    )
}

#[tokio::test]
async fn starttls_upgrades_the_session() {
    let certificates = TestCertificates::new();
    let config = starttls_config(&certificates);
    let handler = StartTlsHandler::default();
    let net = tls_net(&config, Arc::new(handler.clone()));
    let running = run_workers(&net);

    for (flag, version) in [("-tls1_3", "TLSv1_3"), ("-tls1_2", "TLSv1_2")] {
        let client = s_client(
            net.local_addrs("submission")[0],
            &certificates,
            &[
                "-starttls",
                "smtp",
                flag,
                "-servername",
                "mail.example.test",
            ],
            b"",
        )
        .await;
        assert!(client.success, "{client:?}");
        assert_eq!(client.field("Peer certificate"), Some("CN = p256"));
        assert!(client.stdout.contains("250 secured"), "{client:?}");
        match handler.last() {
            Outcome::Upgraded(TlsState::Upgraded(info)) => {
                assert_eq!(info.version, version);
                assert_eq!(info.server_name.as_deref(), Some("mail.example.test"));
            }
            other => panic!("mise à niveau attendue : {other:?}"),
        }
    }
    running.stop().await;
}

#[tokio::test]
async fn input_pipelined_after_starttls_is_refused() {
    let certificates = TestCertificates::new();
    let config = starttls_config(&certificates);
    let handler = StartTlsHandler::default();
    let net = tls_net(&config, Arc::new(handler.clone()));
    let running = run_workers(&net);

    let mut stream = TcpStream::connect(net.local_addrs("submission")[0])
        .await
        .unwrap();
    assert_eq!(first_line(&mut stream).await, "220 starttls-test");
    // Commande en clair glissée dans le même paquet que STARTTLS
    stream
        .write_all(b"STARTTLS\r\nMAIL FROM:<attacker@example.test>\r\n")
        .await
        .unwrap();
    assert_eq!(first_line(&mut stream).await, "220 go ahead");
    // Puis fermeture, sans mise à niveau
    assert_eq!(first_line(&mut stream).await, "");
    match handler.last() {
        Outcome::Refused(error) => assert!(error.contains("PipelinedBeforeTls"), "{error}"),
        other => panic!("refus attendu : {other:?}"),
    }
    assert_eq!(net.snapshot().listeners["submission"].failed_sessions, 1);
    running.stop().await;
}

#[tokio::test]
async fn starttls_is_unavailable_on_a_plain_listener_and_a_failed_handshake_is_counted() {
    let certificates = TestCertificates::new();
    let config = starttls_config(&certificates);
    let handler = StartTlsHandler::default();
    let net = tls_net(&config, Arc::new(handler.clone()));
    let running = run_workers(&net);

    // Écoute sans STARTTLS : pas d'annonce, mise à niveau refusée
    let mut plain = TcpStream::connect(net.local_addrs("plain")[0])
        .await
        .unwrap();
    assert_eq!(first_line(&mut plain).await, "220 starttls-test");
    plain.write_all(b"EHLO client.test\r\n").await.unwrap();
    assert_eq!(first_line(&mut plain).await, "250 starttls-test");
    plain.write_all(b"STARTTLS\r\n").await.unwrap();
    assert_eq!(first_line(&mut plain).await, "");
    match handler.last() {
        Outcome::Refused(error) => assert!(error.contains("TlsUnavailable"), "{error}"),
        other => panic!("refus attendu : {other:?}"),
    }

    // Poignée de main en échec après STARTTLS : comptée, connexion fermée
    let mut stream = TcpStream::connect(net.local_addrs("submission")[0])
        .await
        .unwrap();
    assert_eq!(first_line(&mut stream).await, "220 starttls-test");
    stream.write_all(b"STARTTLS\r\n").await.unwrap();
    assert_eq!(first_line(&mut stream).await, "220 go ahead");
    stream
        .write_all(b"this is not a TLS client hello\r\n")
        .await
        .unwrap();
    let mut rest = Vec::new();
    tokio::time::timeout(Duration::from_secs(5), stream.read_to_end(&mut rest))
        .await
        .expect("fermeture")
        .ok();
    match handler.last() {
        Outcome::Refused(error) => assert!(error.contains("TlsHandshake"), "{error}"),
        other => panic!("échec attendu : {other:?}"),
    }
    assert_eq!(
        net.snapshot().listeners["submission"].tls_handshake_failures,
        1
    );
    running.stop().await;
}
