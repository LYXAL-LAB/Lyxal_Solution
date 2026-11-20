//! Certificats : rechargement à chaud (nouvelle poignée de main avec le nouveau certificat,
//! connexion ouverte inchangée), fichier invalide tenu à l'écart (ancien certificat gardé, sonde
//! « dégradé », `GROUPWARE_TLS_CERTIFICATE_INVALID` au journal, puis retour à « sain »), clé
//! lisible par d'autres comptes refusée, certificat ne couvrant pas son nom refusé, relecture
//! périodique par le worker `mail.tls_reload`.

use crate::support::{
    capture_logs, config, listener, run_workers, s_client, s_client_process, tls_net,
    TestCertificates,
};
use async_trait::async_trait;
use lyxal_groupware::config::GroupwareConfig;
use lyxal_groupware::net::certificates::Certificates;
use lyxal_mail::net::{MailProtocol, Session, SessionEnd, SessionHandler};
use lyxal_runtime::health::{HealthStatus, ModuleHealthCheck};
use lyxal_runtime::ModuleContext;
use std::fs;
use std::sync::Arc;
use std::time::Duration;
use tokio::io::{AsyncBufReadExt, AsyncReadExt, AsyncWriteExt, BufReader};

/// Protocole d'essai : `220 ready`, puis renvoie chaque ligne (`echo …`) jusqu'à `QUIT`.
struct EchoHandler;

#[async_trait]
impl SessionHandler for EchoHandler {
    fn protocol(&self) -> MailProtocol {
        MailProtocol::Imap
    }

    async fn handle(&self, mut session: Session) -> SessionEnd {
        let stream = session.stream();
        let _ = stream.write_all(b"220 ready\r\n").await;
        let mut line = Vec::new();
        let mut byte = [0u8; 1];
        loop {
            match stream.read(&mut byte).await {
                Ok(0) | Err(_) => return SessionEnd::Closed,
                Ok(_) if byte[0] == b'\n' => {
                    let text = String::from_utf8_lossy(&line).trim_end().to_string();
                    line.clear();
                    if text == "QUIT" {
                        let _ = stream.write_all(b"221 bye\r\n").await;
                        let _ = stream.shutdown().await;
                        return SessionEnd::Closed;
                    }
                    let _ = stream
                        .write_all(format!("echo {text}\r\n").as_bytes())
                        .await;
                }
                Ok(_) => line.push(byte[0]),
            }
        }
    }
}

fn reload_config(certificates: &TestCertificates, tls_extra: &str) -> GroupwareConfig {
    config(
        "reload",
        &format!(
            "[limits]\ndrain_seconds = 2\n{}\n{}",
            certificates
                .tls_section()
                .replace("[tls]\n", &format!("[tls]\n{tls_extra}")),
            listener("imaps", "imap", "implicit", "")
        ),
    )
}

/// Certificat présenté pour `mail.example.test`.
async fn served(address: std::net::SocketAddr, certificates: &TestCertificates) -> String {
    let client = s_client(
        address,
        certificates,
        &["-servername", "mail.example.test"],
        b"QUIT\n",
    )
    .await;
    assert!(client.success, "{client:?}");
    client.peer_certificate().expect("certificat")
}

#[tokio::test]
async fn hot_reload_replaces_the_certificate_and_keeps_an_invalid_file_out() {
    let (captured, _logs) = capture_logs();

    let certificates = TestCertificates::new();
    let config = reload_config(&certificates, "");
    let net = tls_net(&config, Arc::new(EchoHandler));
    let running = run_workers(&net);
    let address = net.local_addrs("imaps")[0];
    let loaded = net.certificates().expect("certificats").clone();
    let probe = net.health_check();
    let ctx = ModuleContext::new(lyxal_mail::MODULE_ID);
    assert_eq!(served(address, &certificates).await, "CN=p256");

    // Connexion ouverte avant le rechargement
    let mut open = s_client_process(
        address,
        &certificates,
        &["-servername", "mail.example.test"],
    );
    let mut open_out = BufReader::new(open.stdout.take().unwrap()).lines();
    let mut open_in = open.stdin.take().unwrap();
    let line = tokio::time::timeout(Duration::from_secs(10), open_out.next_line())
        .await
        .expect("salut")
        .unwrap();
    assert_eq!(line.as_deref().map(str::trim_end), Some("220 ready"));

    // Fichiers remplacés : nouvelles poignées de main avec le nouveau certificat
    certificates.serve("p256_next");
    assert_eq!(loaded.reload(), 1);
    assert_eq!(served(address, &certificates).await, "CN=p256_next");
    assert_eq!(loaded.snapshot().reloaded, 1);
    // Contenu inchangé : rien n'est rechargé
    assert_eq!(loaded.reload(), 0);
    // La connexion ouverte reste servie
    open_in.write_all(b"ping\n").await.unwrap();
    let line = tokio::time::timeout(Duration::from_secs(10), open_out.next_line())
        .await
        .expect("écho")
        .unwrap();
    assert_eq!(line.as_deref().map(str::trim_end), Some("echo ping"));
    open_in.write_all(b"QUIT\n").await.unwrap();
    drop(open_in);
    let status = tokio::time::timeout(Duration::from_secs(10), open.wait())
        .await
        .expect("fin")
        .unwrap();
    assert!(status.success());

    // Fichier invalide : ignoré, l'ancien certificat reste, la sonde passe à « dégradé »
    fs::write(certificates.path("served.chain.pem"), b"pas un certificat").unwrap();
    assert_eq!(loaded.reload(), 0);
    assert!(loaded.degraded());
    assert_eq!(loaded.snapshot().failed, 1);
    assert_eq!(served(address, &certificates).await, "CN=p256_next");
    let health = probe.check(&ctx).await.unwrap();
    assert_eq!(health.status, HealthStatus::Degraded);
    assert!(net.snapshot().certificates.expect("mesures").degraded);

    // Fichier corrigé : rechargé, sonde « saine »
    certificates.serve("p256");
    assert_eq!(loaded.reload(), 1);
    assert!(!loaded.degraded());
    assert_eq!(
        probe.check(&ctx).await.unwrap().status,
        HealthStatus::Healthy
    );
    assert_eq!(served(address, &certificates).await, "CN=p256");
    running.stop().await;

    let log = captured.text();
    let refused: Vec<&str> = log
        .lines()
        .filter(|line| line.contains("GROUPWARE_TLS_CERTIFICATE_INVALID"))
        .collect();
    assert_eq!(refused.len(), 1, "{log}");
    assert!(refused[0].contains("mail.example.test"), "{log}");
    assert!(!log.contains("PRIVATE KEY"), "clé au journal : {log}");
}

#[cfg(unix)]
#[tokio::test]
async fn a_key_readable_by_other_accounts_is_refused() {
    let certificates = TestCertificates::new();
    let config = reload_config(&certificates, "");

    // Au démarrage : refus, code GROUPWARE_TLS_CERTIFICATE_INVALID
    certificates.set_mode("served.key.pem", 0o640);
    let error = match Certificates::load(&config.tls) {
        Ok(_) => panic!("clé lisible par le groupe acceptée"),
        Err(error) => error,
    };
    assert_eq!(error.code(), "GROUPWARE_TLS_CERTIFICATE_INVALID");
    assert!(error.to_string().contains("groupe"), "{error}");
    assert!(error.to_string().contains("640"), "{error}");

    // Au rechargement : nouveau couple refusé, l'ancien reste
    certificates.set_mode("served.key.pem", 0o600);
    let loaded = Certificates::load(&config.tls)
        .expect("certificats")
        .expect("déclarés");
    certificates.serve("p256_next");
    certificates.set_mode("served.key.pem", 0o644);
    assert_eq!(loaded.reload(), 0);
    assert!(loaded.degraded());
}

#[tokio::test]
async fn a_certificate_that_does_not_cover_its_name_is_refused_at_startup() {
    let certificates = TestCertificates::new();
    let mut config = reload_config(&certificates, "").tls;
    config.certificates[0].names = vec!["other.example.test".into()];
    let error = match Certificates::load(&config) {
        Ok(_) => panic!("certificat accepté pour un nom qu'il ne couvre pas"),
        Err(error) => error,
    };
    assert_eq!(error.code(), "GROUPWARE_TLS_CERTIFICATE_INVALID");
    assert!(error.to_string().contains("other.example.test"), "{error}");
}

#[tokio::test]
async fn the_reload_worker_picks_up_new_files() {
    let certificates = TestCertificates::new();
    let config = reload_config(&certificates, "reload_interval_seconds = 5\n");
    let net = tls_net(&config, Arc::new(EchoHandler));
    let running = run_workers(&net);
    let address = net.local_addrs("imaps")[0];
    let loaded = net.certificates().expect("certificats").clone();

    certificates.serve("p256_next");
    let deadline = tokio::time::Instant::now() + Duration::from_secs(15);
    while loaded.snapshot().reloaded == 0 {
        assert!(
            tokio::time::Instant::now() < deadline,
            "certificat non relu par le worker"
        );
        tokio::time::sleep(Duration::from_millis(100)).await;
    }
    assert_eq!(served(address, &certificates).await, "CN=p256_next");
    running.stop().await;
}
