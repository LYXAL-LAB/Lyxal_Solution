//! Service des connexions : adresse du client transmise aux routes, client qui cesse de lire
//! déconnecté après le délai d'écriture, arrêt qui laisse finir les requêtes en cours.

use axum::body::Body;
use axum::extract::ConnectInfo;
use axum::routing::get;
use axum::Router;
use futures::StreamExt;
use std::net::SocketAddr;
use std::time::Duration;
use tokio::io::{AsyncReadExt, AsyncWriteExt};
use tokio::net::{TcpListener, TcpStream};

/// Taille de la réponse volumineuse : bien plus que les tampons d'une connexion locale.
const BIG: usize = 256 * 1024 * 1024;

fn router() -> Router {
    Router::new()
        .route(
            "/ip",
            get(|ConnectInfo(remote): ConnectInfo<SocketAddr>| async move {
                remote.ip().to_string()
            }),
        )
        .route(
            "/big",
            get(|| async {
                let chunk = bytes::Bytes::from(vec![0u8; 64 * 1024]);
                let chunks = futures::stream::repeat(chunk)
                    .take(BIG / (64 * 1024))
                    .map(Ok::<_, std::io::Error>);
                Body::from_stream(chunks)
            }),
        )
}

async fn request(address: SocketAddr, path: &str) -> TcpStream {
    let mut client = TcpStream::connect(address).await.expect("connexion");
    client
        .write_all(
            format!("GET {path} HTTP/1.1\r\nHost: lyxal.test\r\nConnection: close\r\n\r\n")
                .as_bytes(),
        )
        .await
        .expect("requête");
    client
}

/// Octets reçus jusqu'à la fermeture de la connexion (fin normale ou coupure par le serveur).
async fn drain(client: &mut TcpStream) -> usize {
    let mut total = 0;
    let mut buffer = vec![0u8; 256 * 1024];
    loop {
        match client.read(&mut buffer).await {
            Ok(0) | Err(_) => return total,
            Ok(read) => total += read,
        }
    }
}

#[tokio::test]
async fn a_client_that_stops_reading_is_disconnected() {
    let listener = TcpListener::bind("127.0.0.1:0").await.expect("écoute");
    let address = listener.local_addr().expect("adresse");
    let (stop, stopped) = tokio::sync::oneshot::channel::<()>();
    let server = tokio::spawn(lyxal_server::serve::serve(
        listener,
        router(),
        Duration::from_secs(1),
        Duration::from_secs(5),
        async {
            let _ = stopped.await;
        },
    ));

    // Requête ordinaire : la route reçoit l'adresse du client
    let mut client = request(address, "/ip").await;
    let mut response = String::new();
    client.read_to_string(&mut response).await.expect("réponse");
    assert!(response.starts_with("HTTP/1.1 200"), "{response}");
    assert!(response.ends_with("127.0.0.1"), "{response}");

    // Client qui lit normalement : la réponse volumineuse arrive en entier
    let mut reader = request(address, "/big").await;
    let received = tokio::time::timeout(Duration::from_secs(60), drain(&mut reader))
        .await
        .expect("téléchargement");
    assert!(received >= BIG, "{received} octets reçus");

    // Client qui ne lit plus : le serveur ferme la connexion après le délai d'écriture
    let mut stalled = request(address, "/big").await;
    tokio::time::sleep(Duration::from_secs(4)).await;
    let received = tokio::time::timeout(Duration::from_secs(30), drain(&mut stalled))
        .await
        .expect("connexion fermée par le serveur");
    assert!(
        received < BIG,
        "{received} octets reçus : la connexion n'a pas été coupée"
    );

    // Arrêt : le serveur rend la main
    stop.send(()).expect("arrêt");
    tokio::time::timeout(Duration::from_secs(10), server)
        .await
        .expect("arrêt du serveur")
        .expect("serveur");
}
