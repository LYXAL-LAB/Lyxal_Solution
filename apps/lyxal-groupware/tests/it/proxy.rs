//! PROXY protocol v1 et v2 sur de vraies sockets : accepté et exigé depuis un réseau de
//! répartiteur déclaré (adresse vue = adresse de l'en-tête, limites appliquées à elle), en-tête
//! absent ou hors délai → fermeture, en-tête envoyé depuis un réseau non déclaré → traité comme
//! des données.

use crate::support::{
    config, first_line, greeting, mail_net, run_workers, smtp_listener, HoldHandler,
    RecordingHandler,
};
use async_trait::async_trait;
use lyxal_mail::net::{
    refusal_line, MailProtocol, RefusalReason, Session, SessionEnd, SessionHandler,
};
use proxy_header::{ProxiedAddress, ProxyHeader};
use std::net::SocketAddr;
use std::sync::{Arc, Mutex};
use std::time::{Duration, Instant};
use tokio::io::{AsyncReadExt, AsyncWriteExt};
use tokio::net::TcpStream;

const TRUSTED: &str = "proxy_networks = [\"127.0.0.0/8\"]";

fn header_v2(source: &str, destination: &str) -> Vec<u8> {
    let header = ProxyHeader::with_address(ProxiedAddress::stream(
        source.parse().unwrap(),
        destination.parse().unwrap(),
    ));
    let mut bytes = Vec::new();
    header.encode_v2(&mut bytes).unwrap();
    bytes
}

/// Connexion qui commence par `header`, et la première ligne du serveur.
async fn proxied(address: SocketAddr, header: &[u8]) -> (TcpStream, String) {
    let mut stream = TcpStream::connect(address).await.unwrap();
    stream.write_all(header).await.unwrap();
    let line = first_line(&mut stream).await;
    (stream, line)
}

#[tokio::test]
async fn v1_and_v2_headers_from_a_trusted_network_give_the_client_address() {
    let config = config(
        "proxy",
        &format!(
            "[limits]\ndrain_seconds = 2\n{}",
            smtp_listener("smtp", TRUSTED)
        ),
    );
    let handler = RecordingHandler::default();
    let net = mail_net(&config, Arc::new(handler.clone()));
    let running = run_workers(&net);
    let address = net.local_addrs("smtp")[0];

    let (_stream, reply) =
        proxied(address, b"PROXY TCP4 203.0.113.9 192.0.2.25 40000 25\r\n").await;
    assert!(reply.starts_with("220 session"), "{reply}");
    let seen = handler.last();
    assert!(seen.via_proxy);
    assert_eq!(
        seen.remote,
        "203.0.113.9:40000".parse::<SocketAddr>().unwrap()
    );
    assert_eq!(seen.local, "192.0.2.25:25".parse::<SocketAddr>().unwrap());

    let (_stream, reply) = proxied(
        address,
        &header_v2("[2001:db8::7]:41000", "[2001:db8::25]:25"),
    )
    .await;
    assert!(reply.starts_with("220 session"), "{reply}");
    let seen = handler.last();
    assert!(seen.via_proxy);
    assert_eq!(
        seen.remote,
        "[2001:db8::7]:41000".parse::<SocketAddr>().unwrap()
    );

    // IPv4 transportée en IPv6, ramenée à l'IPv4
    let (_stream, _) = proxied(
        address,
        &header_v2("[::ffff:198.51.100.4]:42000", "[::ffff:192.0.2.25]:25"),
    )
    .await;
    assert_eq!(
        handler.last().remote,
        "198.51.100.4:42000".parse::<SocketAddr>().unwrap()
    );

    // Sonde du répartiteur (`LOCAL`) : adresse de la connexion gardée
    let mut local = Vec::new();
    ProxyHeader::with_local().encode_v2(&mut local).unwrap();
    let (_stream, reply) = proxied(address, &local).await;
    assert!(reply.starts_with("220 session"), "{reply}");
    let seen = handler.last();
    assert!(!seen.via_proxy);
    assert_eq!(seen.remote.ip().to_string(), "127.0.0.1");
    assert_eq!(net.snapshot().listeners["smtp"].via_proxy, 3);
    running.stop().await;
}

#[tokio::test]
async fn a_missing_or_late_header_from_a_trusted_network_closes_the_connection() {
    let config = config(
        "proxy",
        &format!(
            "[limits]\ndrain_seconds = 2\nproxy_header_timeout_seconds = 1\n{}",
            smtp_listener("smtp", TRUSTED)
        ),
    );
    let handler = RecordingHandler::default();
    let net = mail_net(&config, Arc::new(handler.clone()));
    let running = run_workers(&net);
    let address = net.local_addrs("smtp")[0];

    // Pas d'en-tête : fermeture sans un mot
    let (_stream, reply) = proxied(address, b"EHLO client.example.test\r\n").await;
    assert_eq!(reply, "");
    // En-tête attendu en vain : fermeture au délai
    let started = Instant::now();
    let (_stream, reply) = greeting(address).await;
    assert_eq!(reply, "");
    assert!(started.elapsed() >= Duration::from_millis(800));

    assert!(handler.seen.lock().unwrap().is_empty());
    let snapshot = net.snapshot();
    assert_eq!(snapshot.listeners["smtp"].refused["proxy_header"], 2);
    assert_eq!(snapshot.listeners["smtp"].accepted, 0);
    running.stop().await;
}

/// Protocole d'essai : salue, puis renvoie la première ligne reçue.
#[derive(Clone, Default)]
struct FirstLine {
    remote: Arc<Mutex<Option<SocketAddr>>>,
}

#[async_trait]
impl SessionHandler for FirstLine {
    fn protocol(&self) -> MailProtocol {
        MailProtocol::Smtp
    }

    async fn handle(&self, mut session: Session) -> SessionEnd {
        *self.remote.lock().unwrap() = Some(session.info.remote);
        let stream = session.stream();
        let _ = stream.write_all(b"220 ready\r\n").await;
        let mut line = Vec::new();
        let mut byte = [0u8; 1];
        while !line.ends_with(b"\r\n") {
            match stream.read(&mut byte).await {
                Ok(0) | Err(_) => return SessionEnd::Closed,
                Ok(_) => line.push(byte[0]),
            }
        }
        let _ = stream.write_all(b"seen ").await;
        let _ = stream.write_all(&line).await;
        SessionEnd::Closed
    }
}

#[tokio::test]
async fn a_header_from_an_undeclared_network_is_plain_data() {
    let config = config(
        "proxy",
        &format!(
            "[limits]\ndrain_seconds = 2\n{}",
            smtp_listener("smtp", "proxy_networks = [\"10.0.0.0/8\"]")
        ),
    );
    let handler = FirstLine::default();
    let net = mail_net(&config, Arc::new(handler.clone()));
    let running = run_workers(&net);

    let (mut stream, reply) = proxied(
        net.local_addrs("smtp")[0],
        b"PROXY TCP4 203.0.113.9 192.0.2.25 40000 25\r\n",
    )
    .await;
    assert_eq!(reply, "220 ready");
    assert_eq!(
        first_line(&mut stream).await,
        "seen PROXY TCP4 203.0.113.9 192.0.2.25 40000 25"
    );
    let remote = handler.remote.lock().unwrap().expect("session");
    assert_eq!(remote.ip().to_string(), "127.0.0.1");
    assert_eq!(net.snapshot().listeners["smtp"].via_proxy, 0);
    running.stop().await;
}

#[tokio::test]
async fn limits_apply_to_the_client_address_of_the_header() {
    let config = config(
        "proxy",
        &format!(
            "[limits]\ndrain_seconds = 2\nconnections_per_network = [1, 10, 10]\n{}",
            smtp_listener("smtp", TRUSTED)
        ),
    );
    let net = mail_net(&config, Arc::new(HoldHandler(MailProtocol::Smtp)));
    let running = run_workers(&net);
    let address = net.local_addrs("smtp")[0];
    let refused = String::from_utf8(
        refusal_line(MailProtocol::Smtp, RefusalReason::TooManyConnections).to_vec(),
    )
    .unwrap();

    // Toutes les connexions viennent de 127.0.0.1 (le répartiteur) : seule l'adresse de
    // l'en-tête compte
    let (_first, reply) = proxied(address, b"PROXY TCP4 203.0.113.1 192.0.2.25 40000 25\r\n").await;
    assert_eq!(reply, "220 hold");
    let (_second, reply) =
        proxied(address, b"PROXY TCP4 203.0.113.1 192.0.2.25 40001 25\r\n").await;
    assert_eq!(reply, refused.trim_end());
    let (_third, reply) =
        proxied(address, b"PROXY TCP4 198.51.100.1 192.0.2.25 40002 25\r\n").await;
    assert_eq!(reply, "220 hold");
    assert_eq!(
        net.snapshot().listeners["smtp"].refused["too_many_connections"],
        1
    );
    running.stop().await;
}
