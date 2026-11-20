/*
 * SPDX-FileCopyrightText: 2020 Stalwart Labs LLC <hello@stalw.art>
 *
 * SPDX-License-Identifier: AGPL-3.0-only
 *
 * Porté de Stalwart, `crates/common/src/config/server/listener.rs` (création des sockets, repli
 * IPv4, options) et `crates/common/src/network/listen.rs` (`TcpListener::listen`,
 * `is_bound_to`, keepalive), commit 3adead9, licence `AGPL-3.0-only OR LicenseRef-SEL`, option
 * AGPL-3.0-only retenue. Modifié pour Lyxal OS : liaison faite une fois au démarrage, avant
 * l'installation des modules, et toute erreur arrête le démarrage (`GROUPWARE_BIND_FAILED`) ;
 * `SO_REUSEPORT` non posé (deux processus ne doivent jamais se partager un port de courrier
 * sans le savoir) ; `IPV6_V6ONLY` posé quand la même configuration lie aussi l'IPv4 sur le même
 * port ; réglages `TOS`, `TTL` et tampons non repris ; options de connexion par `socket2`.
 */

//! Liaison des ports des écoutes, au démarrage.

use crate::config::{GroupwareConfig, ListenerConfig};
use crate::error::GroupwareError;
use socket2::{Domain, Protocol, SockRef, Socket, TcpKeepalive, Type};
use std::io;
use std::net::{IpAddr, Ipv4Addr, SocketAddr};
use std::time::Duration;
use tokio::net::{TcpListener, TcpStream};

/// File d'attente des connexions non encore acceptées.
const BACKLOG: i32 = 1024;
const KEEPALIVE_IDLE: Duration = Duration::from_secs(300);

/// Écoute dont les adresses sont liées.
pub struct BoundListener {
    pub config: ListenerConfig,
    pub sockets: Vec<TcpListener>,
}

impl BoundListener {
    /// Adresses effectivement liées (port réel quand le port demandé est `0`).
    pub fn local_addrs(&self) -> Vec<SocketAddr> {
        self.sockets
            .iter()
            .filter_map(|socket| socket.local_addr().ok())
            .collect()
    }
}

/// Lie toutes les adresses de toutes les écoutes de `config`. Une adresse indisponible arrête
/// tout : les sockets déjà liées sont refermées.
pub fn bind_listeners(config: &GroupwareConfig) -> Result<Vec<BoundListener>, GroupwareError> {
    let all: Vec<SocketAddr> = config
        .listeners
        .iter()
        .flat_map(|listener| listener.bind.iter().copied())
        .collect();
    config
        .listeners
        .iter()
        .map(|listener| {
            let sockets = listener
                .bind
                .iter()
                .map(|address| {
                    // Un `[::]:port` et un `0.0.0.0:port` déclarés ensemble : IPv6 seule sur la
                    // socket IPv6, sinon les deux liaisons se gênent (pile double de Linux).
                    let v6_only = address.is_ipv6()
                        && all
                            .iter()
                            .any(|other| other.is_ipv4() && other.port() == address.port());
                    bind_address(*address, v6_only).map_err(|error| GroupwareError::Bind {
                        address: address.to_string(),
                        message: error.to_string(),
                    })
                })
                .collect::<Result<Vec<_>, _>>()?;
            Ok(BoundListener {
                config: listener.clone(),
                sockets,
            })
        })
        .collect()
}

/// Lie `address` (repli sur `0.0.0.0` si l'IPv6 manque à l'hôte pour `[::]`), puis écoute.
fn bind_address(address: SocketAddr, v6_only: bool) -> io::Result<TcpListener> {
    let mut address = address;
    let socket = match Socket::new(
        Domain::for_address(address),
        Type::STREAM,
        Some(Protocol::TCP),
    ) {
        Ok(socket) => socket,
        Err(error)
            if is_ipv6_unsupported(&error)
                && address.is_ipv6()
                && address.ip().is_unspecified() =>
        {
            tracing::warn!(
                %address,
                %error,
                "IPv6 indisponible sur cet hôte : écoute repliée sur 0.0.0.0"
            );
            address = SocketAddr::new(IpAddr::V4(Ipv4Addr::UNSPECIFIED), address.port());
            Socket::new(Domain::IPV4, Type::STREAM, Some(Protocol::TCP))?
        }
        Err(error) => return Err(error),
    };
    if address.is_ipv6() && v6_only {
        socket.set_only_v6(true)?;
    }
    #[cfg(windows)]
    if address.is_ipv6() && !v6_only && address.ip().is_unspecified() {
        socket.set_only_v6(false)?;
    }
    socket.set_reuse_address(true)?;
    socket.set_nonblocking(true)?;
    socket.bind(&address.into())?;
    socket.listen(BACKLOG)?;
    let local = socket
        .local_addr()?
        .as_socket()
        .ok_or_else(|| io::Error::other("adresse liée illisible"))?;
    if !is_bound_to(address, local) {
        return Err(io::Error::other(format!(
            "socket liée à {local} au lieu de {address}"
        )));
    }
    TcpListener::from_std(socket.into())
}

/// Vrai si la socket est bien liée à l'adresse demandée.
fn is_bound_to(requested: SocketAddr, local: SocketAddr) -> bool {
    (requested.ip().is_unspecified() || local.ip() == requested.ip())
        && local.port() != 0
        && (requested.port() == 0 || local.port() == requested.port())
}

/// Options d'une connexion acceptée : `TCP_NODELAY`, keepalive 300 s / 30 s / 4 essais. Un
/// échec est journalisé : la connexion reste servie.
pub fn apply_connection_options(stream: &TcpStream) {
    if let Err(error) = stream.set_nodelay(true) {
        tracing::debug!(%error, "TCP_NODELAY impossible");
    }
    if let Err(error) = SockRef::from(stream).set_tcp_keepalive(&keepalive()) {
        tracing::debug!(%error, "keepalive TCP impossible");
    }
}

fn keepalive() -> TcpKeepalive {
    let keepalive = TcpKeepalive::new().with_time(KEEPALIVE_IDLE);
    #[cfg(any(
        target_os = "linux",
        target_os = "macos",
        target_os = "freebsd",
        windows
    ))]
    let keepalive = keepalive.with_interval(Duration::from_secs(30));
    #[cfg(any(target_os = "linux", target_os = "macos", target_os = "freebsd"))]
    let keepalive = keepalive.with_retries(4);
    keepalive
}

/// Famille d'adresses ou protocole non pris en charge (IPv6 absente de l'hôte).
fn is_ipv6_unsupported(error: &io::Error) -> bool {
    let code = error.raw_os_error();
    #[cfg(target_os = "linux")]
    let codes = [97, 93]; // EAFNOSUPPORT, EPROTONOSUPPORT
    #[cfg(all(unix, not(target_os = "linux")))]
    let codes = [47, 43];
    #[cfg(windows)]
    let codes = [10047, 10043];
    #[cfg(not(any(unix, windows)))]
    let codes: [i32; 0] = [];
    code.is_some_and(|code| codes.contains(&code))
}

#[cfg(test)]
#[allow(clippy::unwrap_used, clippy::expect_used, clippy::panic)]
mod tests {
    use super::*;

    #[test]
    fn bound_address_is_checked() {
        let any: SocketAddr = "0.0.0.0:25".parse().unwrap();
        assert!(is_bound_to(any, "10.0.0.1:25".parse().unwrap()));
        assert!(!is_bound_to(any, "10.0.0.1:26".parse().unwrap()));
        let loopback: SocketAddr = "127.0.0.1:0".parse().unwrap();
        assert!(is_bound_to(loopback, "127.0.0.1:4000".parse().unwrap()));
        assert!(!is_bound_to(loopback, "127.0.0.2:4000".parse().unwrap()));
        assert!(!is_bound_to(loopback, "127.0.0.1:0".parse().unwrap()));
    }

    #[tokio::test]
    async fn an_address_taken_by_another_socket_is_refused() {
        let taken = bind_address("127.0.0.1:0".parse().unwrap(), false).expect("liaison");
        let address = taken.local_addr().unwrap();
        assert!(bind_address(address, false).is_err());
    }
}
