//! Bout en bout du binaire `lyxal-groupware` : démarrage sur une configuration d'essai (base
//! embarquée, support disque et clé maîtresse du coffre-fort passés par l'environnement),
//! `/live`, `/ready`, `/health`, `/metrics`, réception SMTP (accueil, relais refusé), puis arrêt par SIGTERM.

use crate::support::{first_line, toml};
use std::fs;
use std::net::{SocketAddr, TcpListener};
use std::process::{Child, Command, Stdio};
use std::time::Duration;
use tokio::io::{AsyncReadExt, AsyncWriteExt};
use tokio::net::TcpStream;

/// Port libre de `127.0.0.1` (lié puis relâché).
fn free_port() -> u16 {
    TcpListener::bind("127.0.0.1:0")
        .unwrap()
        .local_addr()
        .unwrap()
        .port()
}

/// Requête HTTP/1.1 minimale : statut et corps.
async fn http_get(address: SocketAddr, path: &str) -> Option<(u16, String)> {
    let mut stream = TcpStream::connect(address).await.ok()?;
    stream
        .write_all(
            format!("GET {path} HTTP/1.1\r\nHost: test\r\nConnection: close\r\n\r\n").as_bytes(),
        )
        .await
        .ok()?;
    let mut response = String::new();
    stream.read_to_string(&mut response).await.ok()?;
    let status = response.split(' ').nth(1)?.parse().ok()?;
    let body = response.split_once("\r\n\r\n")?.1.to_string();
    Some((status, body))
}

struct Process(Child);

impl Drop for Process {
    fn drop(&mut self) {
        let _ = self.0.kill();
        let _ = self.0.wait();
    }
}

#[cfg(unix)]
#[tokio::test]
async fn binary_serves_health_and_mail_ports_then_stops_on_sigterm() {
    let http_port = free_port();
    let smtp_port = free_port();
    let directory = tempfile::tempdir().unwrap();
    let config = directory.path().join("config");
    fs::create_dir(&config).unwrap();
    // Serveur DNS d'essai : le binaire n'interroge jamais le vrai DNS
    let dns = crate::support::fake_dns().await;
    let text = toml("binary", &format!("[limits]\ndrain_seconds = 2\n{dns}"))
        .replace("127.0.0.1:0\"\ngraceful", &format!("127.0.0.1:{http_port}\"\ngraceful"))
        + &format!(
            "\n[[listeners]]\nid = \"smtp\"\nprotocol = \"smtp\"\nbind = [\"127.0.0.1:{smtp_port}\"]\ntls = \"none\"\n"
        );
    fs::write(config.join("default.toml"), text).unwrap();

    let mut process = Process(
        Command::new(env!("CARGO_BIN_EXE_lyxal-groupware"))
            .current_dir(directory.path())
            .env("LYXAL_ENV", "test")
            .env(
                "LYXAL_GROUPWARE__STORAGE__DISK__ROOT",
                directory.path().join("fichiers"),
            )
            // Clé d'essai (32 octets en Base64 canonique), jamais une vraie clé
            .env(
                "LYXAL_GROUPWARE__SECRETS__MASTER_KEY",
                "AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8=",
            )
            .env("LYXAL_GROUPWARE__SECRETS__MASTER_KEY_ID", "vault-1")
            .stdout(Stdio::null())
            .stderr(Stdio::null())
            .spawn()
            .expect("lancement du binaire"),
    );
    let http: SocketAddr = format!("127.0.0.1:{http_port}").parse().unwrap();

    // Démarrage : le port HTTP répond quand tout est installé et démarré
    let deadline = std::time::Instant::now() + Duration::from_secs(120);
    loop {
        if let Some((204, _)) = http_get(http, "/ready").await {
            break;
        }
        assert!(
            process.0.try_wait().unwrap().is_none(),
            "le binaire s'est arrêté au démarrage"
        );
        assert!(std::time::Instant::now() < deadline, "démarrage trop long");
        tokio::time::sleep(Duration::from_millis(100)).await;
    }
    assert_eq!(http_get(http, "/live").await.map(|r| r.0), Some(204));
    let (status, body) = http_get(http, "/health").await.expect("/health");
    assert_eq!(status, 200, "{body}");
    let health: serde_json::Value = serde_json::from_str(&body).expect("JSON");
    for component in ["groupware", "database", "http"] {
        assert_eq!(
            health["host"]["components"][component]["state"], "healthy",
            "{body}"
        );
    }
    assert_eq!(
        health["modules"]["modules"]["lyxal_mail"], "healthy",
        "{body}"
    );

    let mut smtp = TcpStream::connect(format!("127.0.0.1:{smtp_port}"))
        .await
        .expect("port SMTP");
    assert_eq!(first_line(&mut smtp).await, "220 mx.lyxal.test ESMTP");
    // Aucun relais : un domaine qui n'est pas à l'installation est refusé dès `RCPT TO`
    smtp.write_all(b"HELO client.ailleurs.test\r\nMAIL FROM:<paul@ailleurs.test>\r\nRCPT TO:<qui@ailleurs.test>\r\nQUIT\r\n")
        .await
        .unwrap();
    for expected in ["250 mx.lyxal.test", "250 2.1.0", "550 5.7.1", "221 2.0.0"] {
        let line = first_line(&mut smtp).await;
        assert!(line.starts_with(expected), "{expected} : {line}");
    }
    let (status, body) = http_get(http, "/metrics").await.expect("/metrics");
    assert_eq!(status, 200);
    let metrics: serde_json::Value = serde_json::from_str(&body).expect("JSON");
    assert_eq!(
        metrics["mail"]["listeners"]["smtp"]["accepted"], 1,
        "{body}"
    );

    // SIGTERM : arrêt propre
    let killed = Command::new("kill")
        .args(["-TERM", &process.0.id().to_string()])
        .status()
        .expect("kill");
    assert!(killed.success());
    let deadline = std::time::Instant::now() + Duration::from_secs(30);
    let status = loop {
        if let Some(status) = process.0.try_wait().unwrap() {
            break status;
        }
        assert!(std::time::Instant::now() < deadline, "arrêt trop long");
        tokio::time::sleep(Duration::from_millis(100)).await;
    };
    assert!(status.success(), "{status:?}");
    assert!(TcpStream::connect(format!("127.0.0.1:{smtp_port}"))
        .await
        .is_err());
}
