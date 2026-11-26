// SPDX-License-Identifier: AGPL-3.0-only

//! Pipeline d'acceptation d'une connexion (`README.md` de l'hôte, §4), dans l'ordre : en-tête PROXY
//! (depuis un réseau de répartiteur seulement), listes statiques, limites par réseau (cadence
//! puis connexions ouvertes), budget mémoire, poignée de main TLS implicite, remise au handler
//! du protocole. Le plafond de l'écoute est pris avant, dans la boucle d'acceptation. Les
//! limites s'appliquent à l'adresse du client, celle de l'en-tête PROXY s'il y en a un.
//!
//! Un refus écrit la ligne du protocole en clair, sous délai, puis ferme ; sur une écoute à TLS
//! implicite, il ferme sans poignée de main (elle coûterait du calcul pour un client refusé).
//! Les places, compteurs et réservations sont rendus à la fin de la tâche, quelle qu'en soit
//! l'issue.
//!
//! Écrit pour Lyxal OS sur le modèle de Stalwart (`common/src/network/listen.rs`,
//! `build_session`) et de Mox (`smtpserver/server.go`, limites de connexion), sans code repris.

use super::metrics::Refusal;
use super::proxy::{self, PlainStream};
use super::tls::HostTlsUpgrade;
use super::{bind, idle_timeout, Listener, ListenerTlsMode, WRITE_STALL};
use crate::config::LogClientIp;
use lyxal_host::net::{log_network, normalize_ip};
use lyxal_mail::net::{
    refusal_line, BoxedStream, ConnectionInfo, InFlight, IpRateLimiter, MemoryClass, NetError,
    RefusalReason, Session, SessionEnd, SessionLimits, TlsState, TlsUpgrade, REFUSAL_WRITE_TIMEOUT,
};
use proxy_header::io::ProxiedStream;
use std::net::{IpAddr, SocketAddr};
use std::sync::Arc;
use std::time::Instant;
use tokio::io::{AsyncWrite, AsyncWriteExt};
use tokio::net::TcpStream;
use tokio_io_timeout::TimeoutStream;
use tokio_util::sync::CancellationToken;

/// Connexion ouverte comptée par réseau, rendue à la libération.
struct OpenConnection {
    limiter: Arc<IpRateLimiter>,
    ip: IpAddr,
}

impl Drop for OpenConnection {
    fn drop(&mut self) {
        self.limiter.release(self.ip, Instant::now(), 1);
    }
}

/// Sert une connexion acceptée par `listener` (`place` : place prise dans son plafond).
pub(super) async fn serve(
    listener: Arc<Listener>,
    stream: TcpStream,
    local: SocketAddr,
    remote: SocketAddr,
    place: InFlight,
    shutdown: CancellationToken,
) {
    let _place = place;
    bind::apply_connection_options(&stream);
    let peer = SocketAddr::new(normalize_ip(remote.ip()), remote.port());
    let acceptance = &listener.acceptance;

    // En-tête PROXY : exigé depuis un réseau de répartiteur, jamais lu ailleurs
    let (stream, local, remote, via_proxy) = if listener
        .proxy_networks
        .iter()
        .any(|net| net.contains(peer.ip()))
    {
        match proxy::read_header(stream, acceptance.proxy_header_timeout).await {
            Ok((stream, Some(addresses))) => {
                listener.metrics.proxied();
                (stream, addresses.local, addresses.remote, true)
            }
            // `LOCAL` / `UNKNOWN` : sonde du répartiteur, adresse de la connexion gardée
            Ok((stream, None)) => (stream, local, peer, false),
            Err(error) => {
                listener.metrics.refused(Refusal::ProxyHeader);
                log_refusal(&listener, peer.ip(), Refusal::ProxyHeader);
                tracing::debug!(listener = %listener.id, %error, "en-tête PROXY refusé");
                return;
            }
        }
    } else {
        (ProxiedStream::unproxied(stream), local, peer, false)
    };
    let ip = remote.ip();

    // Listes statiques
    let denied = acceptance.deny.iter().any(|net| net.contains(ip))
        || (!acceptance.allow.is_empty() && !acceptance.allow.iter().any(|net| net.contains(ip)))
        || acceptance.blocks.contains(ip);
    if denied {
        return refuse(&listener, stream, ip, RefusalReason::Blocked).await;
    }

    // Limites par réseau
    let mut _open = None;
    if !acceptance.exempt.iter().any(|net| net.contains(ip)) {
        let now = Instant::now();
        if !acceptance.rate.try_add(ip, now, 1) {
            return refuse(&listener, stream, ip, RefusalReason::RateLimited).await;
        }
        if !acceptance.open.try_add(ip, now, 1) {
            return refuse(&listener, stream, ip, RefusalReason::TooManyConnections).await;
        }
        _open = Some(OpenConnection {
            limiter: acceptance.open.clone(),
            ip,
        });
    }

    // Budget mémoire : base de la connexion
    let mut memory = acceptance
        .budget
        .reservation(MemoryClass::Read, acceptance.budget.limit());
    if !memory.reserve_to(acceptance.connection_base) {
        return refuse(&listener, stream, ip, RefusalReason::MemoryBudget).await;
    }

    let mut timed = TimeoutStream::new(stream);
    timed.set_write_timeout(Some(WRITE_STALL));
    let timed = Box::pin(timed);

    // TLS : poignée de main implicite, ou mise à niveau offerte à la session
    let (stream, tls, upgrade): (BoxedStream, TlsState, Option<Arc<dyn TlsUpgrade>>) =
        match &listener.tls {
            ListenerTlsMode::None => (Box::new(timed), TlsState::Plain, None),
            ListenerTlsMode::StartTls(acceptor) => {
                let failed = listener.clone();
                let upgrade = HostTlsUpgrade::new(
                    acceptor.clone(),
                    Box::new(move |error| handshake_failed(&failed, ip, error)),
                );
                (Box::new(timed), TlsState::Plain, Some(Arc::new(upgrade)))
            }
            ListenerTlsMode::Implicit(acceptor) => {
                let handshake = tokio::select! {
                    handshake = acceptor.accept(timed) => handshake,
                    () = shutdown.cancelled() => return,
                };
                match handshake {
                    Ok((stream, info)) => (Box::new(stream), TlsState::Implicit(info), None),
                    Err(error) => return handshake_failed(&listener, ip, &error),
                }
            }
        };

    listener.metrics.accepted();
    let session_id = acceptance.next_session_id();
    let session = Session::new(
        ConnectionInfo {
            listener_id: listener.id.clone(),
            protocol: listener.protocol,
            session_id,
            local,
            remote,
            via_proxy,
            tls,
        },
        SessionLimits {
            idle: idle_timeout(listener.protocol),
            write_stall: WRITE_STALL,
        },
        shutdown,
        memory,
        stream,
        upgrade,
    );
    match listener.handler.handle(session).await {
        SessionEnd::Closed | SessionEnd::ClosedOnShutdown => {}
        SessionEnd::Failed(error) => {
            listener.metrics.session_failed();
            tracing::debug!(
                listener = %listener.id,
                session_id,
                network = %log_network(ip),
                %error,
                "session terminée sur erreur"
            );
        }
    }
}

/// Poignée de main TLS en échec ou hors délai : comptée et journalisée (catégorie de l'erreur,
/// réseau masqué), la connexion est fermée.
fn handshake_failed(listener: &Listener, ip: IpAddr, error: &NetError) {
    listener.metrics.tls_handshake_failed();
    tracing::info!(
        listener = %listener.id,
        protocol = %listener.protocol,
        network = %log_network(ip),
        %error,
        "poignée de main TLS en échec"
    );
}

/// Refus : ligne du protocole en clair sous délai puis fermeture ; fermeture seule sur une
/// écoute à TLS implicite.
async fn refuse(listener: &Listener, mut stream: PlainStream, ip: IpAddr, reason: RefusalReason) {
    listener.metrics.refused(Refusal::Polite(reason));
    log_refusal(listener, ip, Refusal::Polite(reason));
    if matches!(listener.tls, ListenerTlsMode::Implicit(_)) {
        return;
    }
    write_refusal(
        listener,
        &mut stream,
        refusal_line(listener.protocol, reason),
    )
    .await;
}

async fn write_refusal<S: AsyncWrite + Unpin>(listener: &Listener, stream: &mut S, line: &[u8]) {
    let write = async {
        stream.write_all(line).await?;
        stream.shutdown().await
    };
    if let Err(error) = tokio::time::timeout(REFUSAL_WRITE_TIMEOUT, write)
        .await
        .unwrap_or_else(|_| Err(std::io::ErrorKind::TimedOut.into()))
    {
        tracing::debug!(listener = %listener.id, %error, "ligne de refus non écrite");
    }
}

/// Refus au journal : raison et réseau masqué (G13) ; adresse complète au niveau `debug`
/// seulement, et seulement si `observability.log_client_ip = "full"`.
pub(super) fn log_refusal(listener: &Listener, ip: IpAddr, refusal: Refusal) {
    tracing::info!(
        listener = %listener.id,
        protocol = %listener.protocol,
        reason = refusal.as_str(),
        network = %log_network(ip),
        "connexion refusée"
    );
    if listener.acceptance.log_client_ip == LogClientIp::Full {
        tracing::debug!(
            listener = %listener.id,
            reason = refusal.as_str(),
            client = %ip,
            "connexion refusée (adresse complète)"
        );
    }
}
