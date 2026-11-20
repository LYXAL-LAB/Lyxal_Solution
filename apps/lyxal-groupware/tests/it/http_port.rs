//! Port HTTP derrière un répartiteur (en-tête PROXY depuis `http.proxy_networks`) et en TLS
//! (`http.tls`) : l'adresse transmise aux routes est celle de l'en-tête ; sans réglage, le port
//! est servi tel quel.

use crate::support::{config, s_client, TestCertificates};
use axum::extract::ConnectInfo;
use axum::routing::get;
use axum::Router;
use lyxal_groupware::http::prepare;
use lyxal_groupware::net::certificates::Certificates;
use std::net::SocketAddr;
use std::time::Duration;
use tokio::io::{AsyncReadExt, AsyncWriteExt};
use tokio::net::{TcpListener, TcpStream};
use tokio_util::sync::CancellationToken;

const REQUEST: &[u8] = b"GET /ip HTTP/1.1\r\nHost: test\r\nConnection: close\r\n\r\n";

/// Port HTTP d'essai (`/ip` : adresse du client vue par les routes), arrêté par `stop`.
async fn serve(
    config: &lyxal_groupware::config::GroupwareConfig,
) -> (SocketAddr, CancellationToken, tokio::task::JoinHandle<()>) {
    let certificates = Certificates::load(&config.tls).expect("certificats");
    let prepare = prepare(config, certificates.as_ref()).expect("préparation");
    let listener = TcpListener::bind("127.0.0.1:0").await.unwrap();
    let address = listener.local_addr().unwrap();
    let router = Router::new().route(
        "/ip",
        get(|ConnectInfo(remote): ConnectInfo<SocketAddr>| async move { remote.ip().to_string() }),
    );
    let stop = CancellationToken::new();
    let cancelled = stop.clone();
    let server = tokio::spawn(lyxal_host::http::serve_prepared(
        listener,
        router,
        Duration::from_secs(5),
        Duration::from_secs(1),
        async move { cancelled.cancelled().await },
        prepare,
    ));
    (address, stop, server)
}

async fn get_ip(address: SocketAddr, header: &[u8]) -> String {
    let mut stream = TcpStream::connect(address).await.unwrap();
    stream.write_all(header).await.unwrap();
    stream.write_all(REQUEST).await.unwrap();
    let mut response = String::new();
    tokio::time::timeout(Duration::from_secs(5), stream.read_to_string(&mut response))
        .await
        .expect("réponse")
        .ok();
    response
}

#[tokio::test]
async fn the_http_port_reads_the_proxy_header_from_declared_networks_only() {
    let mut config = config("http", "");
    assert!(prepare(&config, None).unwrap().is_none());
    // TLS sans certificat : refusé par la validation
    config.http.tls = true;
    let error = config.validate().expect_err("http.tls sans certificat");
    assert!(error.to_string().contains("http.tls"), "{error}");
    config.http.tls = false;

    config.http.proxy_networks = vec!["127.0.0.0/8".parse().unwrap()];
    let (address, stop, server) = serve(&config).await;
    let response = get_ip(address, b"PROXY TCP4 203.0.113.9 192.0.2.80 40000 8090\r\n").await;
    assert!(response.starts_with("HTTP/1.1 200"), "{response}");
    assert!(response.ends_with("203.0.113.9"), "{response}");
    // Sans en-tête depuis le répartiteur : fermeture sans réponse
    assert_eq!(get_ip(address, b"").await, "");
    stop.cancel();
    server.await.unwrap();

    // Réseau non déclaré : en-tête jamais lu (requête invalide pour HTTP)
    config.http.proxy_networks = vec!["10.0.0.0/8".parse().unwrap()];
    let (address, stop, server) = serve(&config).await;
    let response = get_ip(address, b"").await;
    assert!(response.ends_with("127.0.0.1"), "{response}");
    let response = get_ip(address, b"PROXY TCP4 203.0.113.9 192.0.2.80 40000 8090\r\n").await;
    assert!(!response.contains("203.0.113.9"), "{response}");
    stop.cancel();
    server.await.unwrap();
}

#[tokio::test]
async fn the_http_port_serves_tls_with_the_listener_certificates() {
    let certificates = TestCertificates::new();
    let mut config = config("http", &certificates.tls_section());
    config.http.tls = true;
    let (address, stop, server) = serve(&config).await;
    let client = s_client(
        address,
        &certificates,
        &["-servername", "mail.example.test", "-alpn", "http/1.1"],
        REQUEST,
    )
    .await;
    assert!(client.success, "{client:?}");
    assert_eq!(client.field("Peer certificate"), Some("CN = p256"));
    assert!(client.stdout.contains("HTTP/1.1 200"), "{client:?}");
    assert!(client.stdout.contains("127.0.0.1"), "{client:?}");
    stop.cancel();
    server.await.unwrap();
}
