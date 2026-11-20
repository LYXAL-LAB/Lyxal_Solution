/*
 * SPDX-FileCopyrightText: 2020 Stalwart Labs LLC <hello@stalw.art>
 *
 * SPDX-License-Identifier: AGPL-3.0-only
 *
 * Porté de Stalwart, `crates/common/src/network/listen.rs` (boucle d'acceptation : erreurs
 * passagères ignorées, recul de 5 ms à 1 s sur les autres), commit 3adead9, licence
 * `AGPL-3.0-only OR LicenseRef-SEL`, option AGPL-3.0-only retenue. Modifié pour Lyxal OS :
 * boucle portée par un `LyxalWorker` supervisé par le runtime et arrêtée par son
 * `CancellationToken` (au lieu d'un canal `watch` et de `tokio::spawn`) ; plusieurs adresses
 * servies par une seule boucle ; sessions dans un `JoinSet` possédé par le worker, drainées à
 * l'arrêt dans un délai, puis abandonnées.
 */

//! Worker d'une écoute : accepte les connexions de ses sockets et sert chacune dans une tâche
//! de son `JoinSet`.

use super::accept;
use super::metrics::Refusal;
use super::Listener;
use async_trait::async_trait;
use lyxal_runtime::worker::{
    LyxalWorker, RestartPolicy, WorkerContext, WorkerCriticality, WorkerDescriptor, WorkerId,
    WorkerRestartBackoff,
};
use lyxal_runtime::{ModuleId, RuntimeError};
use std::future::poll_fn;
use std::io;
use std::net::SocketAddr;
use std::sync::Arc;
use std::task::Poll;
use std::time::Duration;
use tokio::net::{TcpListener, TcpStream};
use tokio::task::JoinSet;
use tokio_util::sync::CancellationToken;

const ACCEPT_BACKOFF: Duration = Duration::from_millis(5);
const MAX_ACCEPT_BACKOFF: Duration = Duration::from_secs(1);

/// Worker `lyxal_mail:mail.listener.<id>` d'une écoute.
pub struct ListenerWorker {
    descriptor: WorkerDescriptor,
    listener: Arc<Listener>,
}

impl ListenerWorker {
    pub(super) fn new(listener: Arc<Listener>) -> Result<Self, RuntimeError> {
        let module = ModuleId::new(lyxal_mail::MODULE_ID);
        let name = format!("mail.listener.{}", listener.id);
        let descriptor = WorkerDescriptor::new(WorkerId::new(&module, &name)?, module, name)
            .with_description(format!(
                "Écoute {} ({}) sur {}",
                listener.id,
                listener.protocol,
                addresses(&listener.local)
            ))
            // Une écoute arrêtée rend le module « malade »
            .with_criticality(WorkerCriticality::Required)
            .with_restart_policy(RestartPolicy::OnFailure {
                max_retries: 5,
                backoff: WorkerRestartBackoff::default(),
            })
            .with_shutdown_timeout(listener.acceptance.drain + Duration::from_secs(5));
        Ok(Self {
            descriptor,
            listener,
        })
    }
}

#[async_trait]
impl LyxalWorker for ListenerWorker {
    fn descriptor(&self) -> &WorkerDescriptor {
        &self.descriptor
    }

    async fn run(&self, ctx: WorkerContext) -> Result<(), RuntimeError> {
        let listener = &self.listener;
        let sockets = listener
            .sockets
            .lock()
            .unwrap_or_else(|poisoned| poisoned.into_inner())
            .clone()
            .ok_or_else(|| RuntimeError::WorkerFailed {
                worker: self.descriptor.id.to_string(),
                message: "sockets de l'écoute refermées : relancer l'hôte".into(),
            })?;
        tracing::info!(
            listener = %listener.id,
            protocol = %listener.protocol,
            tls = listener.tls.mode().as_str(),
            addresses = %addresses(&listener.local),
            "écoute démarrée"
        );

        let sessions_shutdown = CancellationToken::new();
        let mut sessions = JoinSet::new();
        let mut backoff = ACCEPT_BACKOFF;
        // Socket interrogée en premier, avancée après chaque acceptation : aucune adresse de
        // l'écoute ne peut affamer les autres
        let mut next = 0;
        loop {
            tokio::select! {
                biased;
                () = ctx.cancellation.cancelled() => break,
                Some(joined) = sessions.join_next(), if !sessions.is_empty() => {
                    if let Err(error) = joined {
                        if error.is_panic() {
                            listener.metrics.session_failed();
                            tracing::error!(listener = %listener.id, "session interrompue par une panique");
                        }
                    }
                }
                (index, accepted) = accept_any(&sockets, next) => match accepted {
                    Ok((stream, remote)) => {
                        next = (index + 1) % sockets.len().max(1);
                        backoff = ACCEPT_BACKOFF;
                        let Some(place) = listener.limiter.try_acquire() else {
                            // Plafond de l'écoute : fermeture immédiate, sans écriture
                            listener.metrics.refused(Refusal::ListenerFull);
                            accept::log_refusal(listener, remote.ip(), Refusal::ListenerFull);
                            drop(stream);
                            continue;
                        };
                        let local = stream
                            .local_addr()
                            .unwrap_or_else(|_| listener.local.get(index).copied().unwrap_or(remote));
                        sessions.spawn(accept::serve(
                            listener.clone(),
                            stream,
                            local,
                            remote,
                            place,
                            sessions_shutdown.clone(),
                        ));
                    }
                    Err(error) if is_transient(&error) => {}
                    Err(error) => {
                        listener.metrics.accept_error();
                        tracing::warn!(listener = %listener.id, %error, "erreur d'acceptation");
                        tokio::select! {
                            () = tokio::time::sleep(backoff) => {}
                            () = ctx.cancellation.cancelled() => break,
                        }
                        backoff = (backoff * 2).min(MAX_ACCEPT_BACKOFF);
                    }
                }
            }
        }

        // Arrêt : plus aucune acceptation, sessions prévenues puis drainées. Les sockets restent
        // liées (un redémarrage du worker reprend le même port) ; l'hôte les referme à son arrêt
        // définitif (`MailNet::close`).
        drop(sockets);
        sessions_shutdown.cancel();
        let open = sessions.len();
        let drain = listener.acceptance.drain;
        let drained = tokio::time::timeout(drain, async {
            while sessions.join_next().await.is_some() {}
        })
        .await;
        if drained.is_err() {
            tracing::warn!(
                listener = %listener.id,
                abandoned = sessions.len(),
                drain_seconds = drain.as_secs(),
                "arrêt : sessions abandonnées au délai de drainage"
            );
            sessions.shutdown().await;
        }
        tracing::info!(listener = %listener.id, drained = open, "écoute arrêtée");
        Ok(())
    }
}

/// Première connexion acceptée sur l'une des sockets, en commençant par la socket `start` puis
/// dans l'ordre circulaire, avec l'indice de la socket.
async fn accept_any(
    sockets: &[TcpListener],
    start: usize,
) -> (usize, io::Result<(TcpStream, SocketAddr)>) {
    poll_fn(|cx| {
        let count = sockets.len();
        for offset in 0..count {
            let index = (start + offset) % count;
            if let Poll::Ready(accepted) = sockets[index].poll_accept(cx) {
                return Poll::Ready((index, accepted));
            }
        }
        Poll::Pending
    })
    .await
}

/// Erreurs d'acceptation sans conséquence pour l'écoute (connexion abandonnée par le client).
fn is_transient(error: &io::Error) -> bool {
    matches!(
        error.kind(),
        io::ErrorKind::ConnectionAborted
            | io::ErrorKind::ConnectionReset
            | io::ErrorKind::Interrupted
    )
}

fn addresses(local: &[SocketAddr]) -> String {
    local
        .iter()
        .map(SocketAddr::to_string)
        .collect::<Vec<_>>()
        .join(", ")
}

#[cfg(test)]
#[allow(clippy::expect_used)]
mod tests {
    use super::accept_any;
    use tokio::net::{TcpListener, TcpStream};

    #[tokio::test]
    async fn sockets_are_served_in_turn() {
        // Deux sockets avec chacune deux connexions en attente : les acceptations alternent au
        // lieu de vider la première
        let sockets = [
            TcpListener::bind("127.0.0.1:0").await.expect("liaison"),
            TcpListener::bind("127.0.0.1:0").await.expect("liaison"),
        ];
        let mut clients = Vec::new();
        for socket in &sockets {
            let address = socket.local_addr().expect("adresse");
            for _ in 0..2 {
                clients.push(TcpStream::connect(address).await.expect("connexion"));
            }
        }
        let mut next = 0;
        let mut order = Vec::new();
        for _ in 0..4 {
            let (index, accepted) = accept_any(&sockets, next).await;
            accepted.expect("acceptation");
            order.push(index);
            next = (index + 1) % sockets.len();
        }
        assert_eq!(order, [0, 1, 0, 1]);
    }
}
