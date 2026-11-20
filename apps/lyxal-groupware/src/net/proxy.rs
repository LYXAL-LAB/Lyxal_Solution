// SPDX-License-Identifier: AGPL-3.0-only

//! PROXY protocol v1 (texte) et v2 (binaire) (décision G9), lu par `proxy-header` comme chez
//! Stalwart (`ProxiedStream::create_from_tokio`), sans code repris.
//!
//! L'en-tête n'est lu que sur une connexion venue d'un réseau déclaré (`proxy_networks` de
//! l'écoute), où il est alors exigé ; ailleurs il n'est jamais lu (un client ne peut pas choisir
//! son adresse). Les octets reçus après l'en-tête restent dans le flux.

use lyxal_host::net::normalize_ip;
use proxy_header::io::ProxiedStream;
use proxy_header::{ParseConfig, Protocol};
use std::io;
use std::net::SocketAddr;
use std::time::Duration;
use tokio::net::TcpStream;

/// Flux d'une connexion acceptée : TCP, précédé ou non d'un en-tête PROXY déjà lu.
pub type PlainStream = ProxiedStream<TcpStream>;

/// Adresses d'une connexion après lecture de l'en-tête.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct ProxiedAddresses {
    /// Adresse du client (source de l'en-tête).
    pub remote: SocketAddr,
    /// Adresse visée par le client (destination de l'en-tête).
    pub local: SocketAddr,
}

/// Lit l'en-tête PROXY de `stream`, sous `timeout`. `Ok((flux, None))` : en-tête `LOCAL` ou
/// `UNKNOWN` (sonde du répartiteur), l'adresse de la connexion est gardée. En-tête absent,
/// illisible, hors délai, ou d'un transport autre que TCP : erreur, la connexion est fermée.
pub async fn read_header(
    stream: TcpStream,
    timeout: Duration,
) -> io::Result<(PlainStream, Option<ProxiedAddresses>)> {
    let config = ParseConfig {
        include_tlvs: false,
        allow_v1: true,
        allow_v2: true,
    };
    let stream = tokio::time::timeout(timeout, ProxiedStream::create_from_tokio(stream, config))
        .await
        .map_err(|_| io::Error::new(io::ErrorKind::TimedOut, "en-tête PROXY hors délai"))??;
    let addresses = match stream.proxy_header().proxied_address() {
        None => None,
        Some(address) if address.protocol == Protocol::Stream => Some(ProxiedAddresses {
            remote: normalize(address.source),
            local: normalize(address.destination),
        }),
        Some(_) => {
            return Err(io::Error::new(
                io::ErrorKind::InvalidData,
                "en-tête PROXY d'un transport autre que TCP",
            ))
        }
    };
    Ok((stream, addresses))
}

/// Adresse IPv4 transportée en IPv6 ramenée à l'IPv4.
fn normalize(address: SocketAddr) -> SocketAddr {
    SocketAddr::new(normalize_ip(address.ip()), address.port())
}

#[cfg(test)]
#[allow(clippy::unwrap_used, clippy::expect_used)]
mod tests {
    use super::*;
    use tokio::io::{AsyncReadExt, AsyncWriteExt};
    use tokio::net::TcpListener;

    async fn pair() -> (TcpStream, TcpStream) {
        let listener = TcpListener::bind("127.0.0.1:0").await.unwrap();
        let client = TcpStream::connect(listener.local_addr().unwrap())
            .await
            .unwrap();
        let (server, _) = listener.accept().await.unwrap();
        (client, server)
    }

    #[tokio::test]
    async fn v1_header_gives_the_client_address_and_keeps_following_bytes() {
        let (mut client, server) = pair().await;
        client
            .write_all(b"PROXY TCP6 ::ffff:192.0.2.7 2001:db8::1 40000 993\r\nHELLO")
            .await
            .unwrap();
        let (mut stream, addresses) = read_header(server, Duration::from_secs(1)).await.unwrap();
        let addresses = addresses.expect("adresses");
        assert_eq!(
            addresses.remote,
            "192.0.2.7:40000".parse::<SocketAddr>().unwrap()
        );
        assert_eq!(
            addresses.local,
            "[2001:db8::1]:993".parse::<SocketAddr>().unwrap()
        );
        let mut rest = [0u8; 5];
        stream.read_exact(&mut rest).await.unwrap();
        assert_eq!(&rest, b"HELLO");
    }

    #[tokio::test]
    async fn unknown_header_keeps_the_connection_address() {
        let (mut client, server) = pair().await;
        client.write_all(b"PROXY UNKNOWN\r\n").await.unwrap();
        let (_, addresses) = read_header(server, Duration::from_secs(1)).await.unwrap();
        assert_eq!(addresses, None);
    }

    #[tokio::test]
    async fn missing_or_late_header_is_refused() {
        let (mut client, server) = pair().await;
        client.write_all(b"EHLO client.example\r\n").await.unwrap();
        assert!(read_header(server, Duration::from_secs(1)).await.is_err());

        let (_client, server) = pair().await;
        let error = read_header(server, Duration::from_millis(50))
            .await
            .unwrap_err();
        assert_eq!(error.kind(), io::ErrorKind::TimedOut);
    }
}
