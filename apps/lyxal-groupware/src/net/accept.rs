// SPDX-License-Identifier: AGPL-3.0-only

//! Pipeline d'acceptation d'une connexion (§6.3 du plan du lot 3), dans l'ordre : listes
//! statiques, limites par réseau (cadence puis connexions ouvertes), budget mémoire, remise au
//! handler du protocole. Le plafond de l'écoute est pris avant, dans la boucle d'acceptation.
//! Un refus écrit la ligne du protocole en clair, sous délai, puis ferme. Les places, compteurs
//! et réservations sont rendus à la fin de la tâche, quelle qu'en soit l'issue.
//!
//! Écrit pour Lyxal OS sur le modèle de Stalwart (`common/src/network/listen.rs`,
//! `build_session`) et de Mox (`smtpserver/server.go`, limites de connexion), sans code repris.

use super::metrics::Refusal;
use super::{bind, idle_timeout, Listener, WRITE_STALL};
use crate::config::LogClientIp;
use lyxal_host::net::{log_network, normalize_ip};
use lyxal_mail::net::{
    refusal_line, ConnectionInfo, InFlight, IpRateLimiter, MemoryClass, RefusalReason, Session,
    SessionEnd, SessionLimits, TlsState, REFUSAL_WRITE_TIMEOUT,
};
use std::net::{IpAddr, SocketAddr};
use std::sync::Arc;
use std::time::Instant;
use tokio::io::AsyncWriteExt;
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
    let remote = SocketAddr::new(normalize_ip(remote.ip()), remote.port());
    let ip = remote.ip();
    let acceptance = &listener.acceptance;

    // Listes statiques
    let denied = acceptance.deny.iter().any(|net| net.contains(ip))
        || (!acceptance.allow.is_empty() && !acceptance.allow.iter().any(|net| net.contains(ip)));
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

    listener.metrics.accepted();
    let session_id = acceptance.next_session_id();
    let mut timed = TimeoutStream::new(stream);
    timed.set_write_timeout(Some(WRITE_STALL));
    let session = Session::new(
        ConnectionInfo {
            listener_id: listener.id.clone(),
            protocol: listener.protocol,
            session_id,
            local,
            remote,
            via_proxy: false,
            tls: TlsState::Plain,
        },
        SessionLimits {
            idle: idle_timeout(listener.protocol),
            write_stall: WRITE_STALL,
        },
        shutdown,
        memory,
        Box::new(Box::pin(timed)),
        None,
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

/// Refus poli : ligne du protocole en clair, sous délai, puis fermeture.
async fn refuse(listener: &Listener, mut stream: TcpStream, ip: IpAddr, reason: RefusalReason) {
    listener.metrics.refused(Refusal::Polite(reason));
    log_refusal(listener, ip, Refusal::Polite(reason));
    let line = refusal_line(listener.protocol, reason);
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
