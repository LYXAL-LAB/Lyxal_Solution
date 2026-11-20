// SPDX-License-Identifier: AGPL-3.0-only

//! Contrat des sessions : ce que l'hôte remet à un protocole pour chaque connexion acceptée.
//!
//! Écrit pour Lyxal OS sur le modèle de Stalwart (`common/src/network/mod.rs` : `SessionData`,
//! `SessionStream`, `SessionResult::UpgradeTls`), sans code repris.

use crate::net::memory::MemoryReservation;
use async_trait::async_trait;
use std::fmt;
use std::io;
use std::net::SocketAddr;
use std::pin::Pin;
use std::sync::Arc;
use std::task::{Context, Poll};
use std::time::Duration;
use thiserror::Error;
use tokio::io::{AsyncRead, AsyncWrite, ReadBuf};
use tokio_util::sync::CancellationToken;

/// Protocole servi par une écoute.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum MailProtocol {
    /// Réception SMTP des autres serveurs (port 25).
    Smtp,
    /// Dépôt SMTP authentifié des logiciels de courrier (ports 587 et 465).
    Submission,
    /// IMAP (ports 143 et 993).
    Imap,
    /// POP3 (ports 110 et 995).
    Pop3,
    /// ManageSieve (port 4190).
    ManageSieve,
}

impl MailProtocol {
    /// Nom du protocole dans la configuration et le journal (`smtp`, `submission`, `imap`,
    /// `pop3`, `managesieve`).
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Smtp => "smtp",
            Self::Submission => "submission",
            Self::Imap => "imap",
            Self::Pop3 => "pop3",
            Self::ManageSieve => "managesieve",
        }
    }
}

impl fmt::Display for MailProtocol {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(self.as_str())
    }
}

/// TLS d'une écoute : aucun, demandé en session (STARTTLS, RFC 3207 et équivalents), ou dès la
/// connexion (TLS implicite, RFC 8314).
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum TlsMode {
    /// Connexion en clair, sans mise à niveau.
    None,
    /// Connexion en clair, mise à niveau TLS offerte à la session.
    StartTls,
    /// Poignée de main TLS dès l'acceptation.
    Implicit,
}

impl TlsMode {
    /// Nom du mode dans la configuration et le journal (`none`, `starttls`, `implicit`).
    pub fn as_str(self) -> &'static str {
        match self {
            Self::None => "none",
            Self::StartTls => "starttls",
            Self::Implicit => "implicit",
        }
    }
}

/// Paramètres TLS négociés d'une connexion.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct TlsInfo {
    /// Version négociée (ex. `TLSv1_3`).
    pub version: &'static str,
    /// Suite de chiffrement négociée.
    pub cipher: &'static str,
    /// Nom demandé par le client (SNI), s'il en a donné un.
    pub server_name: Option<String>,
    /// Protocole d'application négocié (ALPN).
    pub alpn: Option<Vec<u8>>,
}

/// État TLS d'une connexion, lu par les sessions (ex. refuser un mot de passe en clair).
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum TlsState {
    /// Connexion en clair.
    Plain,
    /// TLS dès la connexion.
    Implicit(TlsInfo),
    /// TLS obtenu par mise à niveau (STARTTLS).
    Upgraded(TlsInfo),
}

impl TlsState {
    /// Vrai si la connexion est chiffrée.
    pub fn is_tls(&self) -> bool {
        !matches!(self, Self::Plain)
    }
}

/// Ce que la session sait de sa connexion.
#[derive(Clone, Debug)]
pub struct ConnectionInfo {
    /// Identifiant de l'écoute (réglage `listeners[].id`).
    pub listener_id: String,
    /// Protocole de l'écoute.
    pub protocol: MailProtocol,
    /// Numéro de la connexion, unique dans le processus.
    pub session_id: u64,
    /// Adresse locale (après PROXY : adresse de destination annoncée par le répartiteur).
    pub local: SocketAddr,
    /// Adresse du client (après PROXY : adresse source annoncée par le répartiteur).
    pub remote: SocketAddr,
    /// Vrai si l'adresse du client vient d'un en-tête PROXY.
    pub via_proxy: bool,
    /// État TLS de la connexion.
    pub tls: TlsState,
}

/// Flux d'octets d'une connexion (TCP, ou TLS par-dessus).
pub trait MailStream: AsyncRead + AsyncWrite + Send + Unpin + 'static {}

impl<T: AsyncRead + AsyncWrite + Send + Unpin + 'static> MailStream for T {}

/// Flux d'une session, de type effacé.
pub type BoxedStream = Box<dyn MailStream>;

/// Mise à niveau TLS offerte par l'hôte (seul détenteur de `tokio-rustls`).
#[async_trait]
pub trait TlsUpgrade: Send + Sync {
    /// Poignée de main TLS côté serveur sur `stream`, sous le délai de l'écoute. En cas
    /// d'échec, le flux est perdu : la connexion est fermée.
    async fn upgrade(&self, stream: BoxedStream) -> Result<(BoxedStream, TlsInfo), NetError>;
}

/// Délais d'une session, fixés par l'écoute.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct SessionLimits {
    /// Inactivité tolérée entre deux commandes du client (appliquée par le protocole).
    pub idle: Duration,
    /// Écriture bloquée tolérée (client qui ne lit plus), appliquée par l'hôte sur le flux.
    pub write_stall: Duration,
}

/// Erreurs du transport. Énumération interne : jamais renvoyée à un client ni écrite en base.
#[derive(Debug, Error)]
pub enum NetError {
    /// Erreur d'entrée-sortie de la connexion.
    #[error("erreur d'entrée-sortie : {0}")]
    Io(#[from] io::Error),
    /// Délai dépassé.
    #[error("délai dépassé")]
    Timeout,
    /// Poignée de main TLS en échec (catégorie de l'erreur, sans donnée du client).
    #[error("poignée de main TLS en échec : {0}")]
    TlsHandshake(String),
    /// Mise à niveau TLS impossible : écoute sans STARTTLS, ou connexion déjà chiffrée.
    #[error("mise à niveau TLS indisponible")]
    TlsUnavailable,
    /// Octets reçus après la commande STARTTLS, avant la mise à niveau : la connexion doit être
    /// fermée (injection de commandes en clair).
    #[error("données reçues avant la mise à niveau TLS")]
    PipelinedBeforeTls,
    /// Budget mémoire épuisé.
    #[error("budget mémoire épuisé")]
    MemoryBudget,
}

/// Une connexion acceptée, remise au protocole.
pub struct Session {
    /// Ce que la session sait de sa connexion.
    pub info: ConnectionInfo,
    /// Délais de la session.
    pub limits: SessionLimits,
    /// Annulé à l'arrêt du nœud : le protocole dit au revoir à la prochaine commande.
    pub shutdown: CancellationToken,
    /// Mémoire réservée pour cette connexion (base réservée à l'acceptation), à agrandir par le
    /// protocole.
    pub memory: MemoryReservation,
    stream: BoxedStream,
    upgrade: Option<Arc<dyn TlsUpgrade>>,
}

impl Session {
    /// Session sur `stream` ; `upgrade` : mise à niveau TLS offerte (écoute `starttls`).
    pub fn new(
        info: ConnectionInfo,
        limits: SessionLimits,
        shutdown: CancellationToken,
        memory: MemoryReservation,
        stream: BoxedStream,
        upgrade: Option<Arc<dyn TlsUpgrade>>,
    ) -> Self {
        Self {
            info,
            limits,
            shutdown,
            memory,
            stream,
            upgrade,
        }
    }

    /// Flux de la connexion.
    pub fn stream(&mut self) -> &mut BoxedStream {
        &mut self.stream
    }

    /// Mise à niveau STARTTLS. `pending_input` : octets déjà lus après la commande STARTTLS ;
    /// non vide → [`NetError::PipelinedBeforeTls`] et la connexion doit être fermée (injection
    /// de commandes en clair). Écoute sans STARTTLS ou connexion déjà chiffrée →
    /// [`NetError::TlsUnavailable`]. Après un échec de la poignée de main, le flux est fermé.
    pub async fn start_tls(&mut self, pending_input: &[u8]) -> Result<(), NetError> {
        if !pending_input.is_empty() {
            return Err(NetError::PipelinedBeforeTls);
        }
        if self.info.tls.is_tls() {
            return Err(NetError::TlsUnavailable);
        }
        let Some(upgrade) = self.upgrade.clone() else {
            return Err(NetError::TlsUnavailable);
        };
        let plain = std::mem::replace(&mut self.stream, Box::new(ClosedStream));
        let (stream, info) = upgrade.upgrade(plain).await?;
        self.stream = stream;
        self.info.tls = TlsState::Upgraded(info);
        // Une seule mise à niveau par connexion
        self.upgrade = None;
        Ok(())
    }

    /// Vrai si la session peut demander une mise à niveau TLS.
    pub fn can_start_tls(&self) -> bool {
        self.upgrade.is_some() && !self.info.tls.is_tls()
    }
}

/// Flux fermé : remplace le flux d'une session pendant et après une mise à niveau en échec.
struct ClosedStream;

impl AsyncRead for ClosedStream {
    fn poll_read(
        self: Pin<&mut Self>,
        _cx: &mut Context<'_>,
        _buf: &mut ReadBuf<'_>,
    ) -> Poll<io::Result<()>> {
        Poll::Ready(Ok(()))
    }
}

impl AsyncWrite for ClosedStream {
    fn poll_write(
        self: Pin<&mut Self>,
        _cx: &mut Context<'_>,
        _buf: &[u8],
    ) -> Poll<io::Result<usize>> {
        Poll::Ready(Err(io::ErrorKind::NotConnected.into()))
    }

    fn poll_flush(self: Pin<&mut Self>, _cx: &mut Context<'_>) -> Poll<io::Result<()>> {
        Poll::Ready(Ok(()))
    }

    fn poll_shutdown(self: Pin<&mut Self>, _cx: &mut Context<'_>) -> Poll<io::Result<()>> {
        Poll::Ready(Ok(()))
    }
}

/// Issue d'une session.
#[derive(Debug)]
pub enum SessionEnd {
    /// Connexion fermée normalement (par le client ou le protocole).
    Closed,
    /// Connexion fermée à l'arrêt du nœud.
    ClosedOnShutdown,
    /// Connexion fermée sur erreur du transport.
    Failed(NetError),
}

/// Ce qu'un protocole implémente (lots 5, 6, 8, 9, 10).
#[async_trait]
pub trait SessionHandler: Send + Sync + 'static {
    /// Protocole servi.
    fn protocol(&self) -> MailProtocol;

    /// Sert la connexion jusqu'à sa fin.
    async fn handle(&self, session: Session) -> SessionEnd;
}

#[cfg(test)]
#[allow(clippy::unwrap_used, clippy::expect_used, clippy::panic)]
mod tests {
    use super::*;
    use crate::net::memory::{MemoryBudget, MemoryClass};
    use tokio::io::{AsyncReadExt, AsyncWriteExt};

    struct EchoUpgrade;

    #[async_trait]
    impl TlsUpgrade for EchoUpgrade {
        async fn upgrade(&self, stream: BoxedStream) -> Result<(BoxedStream, TlsInfo), NetError> {
            Ok((
                stream,
                TlsInfo {
                    version: "TLSv1_3",
                    cipher: "TLS13_AES_128_GCM_SHA256",
                    server_name: None,
                    alpn: None,
                },
            ))
        }
    }

    fn session(upgrade: Option<Arc<dyn TlsUpgrade>>) -> (Session, tokio::io::DuplexStream) {
        let (server, client) = tokio::io::duplex(1024);
        let info = ConnectionInfo {
            listener_id: "essai".into(),
            protocol: MailProtocol::Smtp,
            session_id: 1,
            local: "127.0.0.1:25".parse().unwrap(),
            remote: "192.0.2.1:4000".parse().unwrap(),
            via_proxy: false,
            tls: TlsState::Plain,
        };
        let budget = MemoryBudget::new(1024 * 1024);
        let session = Session::new(
            info,
            SessionLimits {
                idle: Duration::from_secs(1),
                write_stall: Duration::from_secs(1),
            },
            CancellationToken::new(),
            budget.reservation(MemoryClass::Read, 1024 * 1024),
            Box::new(server),
            upgrade,
        );
        (session, client)
    }

    #[tokio::test]
    async fn start_tls_refuses_pipelined_input_and_missing_upgrade() {
        let (mut plain, _client) = session(None);
        assert!(!plain.can_start_tls());
        assert!(matches!(
            plain.start_tls(b"").await,
            Err(NetError::TlsUnavailable)
        ));

        let (mut offered, _client) = session(Some(Arc::new(EchoUpgrade)));
        assert!(offered.can_start_tls());
        assert!(matches!(
            offered.start_tls(b"MAIL FROM:<x@y>\r\n").await,
            Err(NetError::PipelinedBeforeTls)
        ));
        // Le refus n'a rien consommé : la mise à niveau reste possible
        offered.start_tls(b"").await.expect("mise à niveau");
        assert!(matches!(offered.info.tls, TlsState::Upgraded(_)));
        assert!(!offered.can_start_tls());
        assert!(matches!(
            offered.start_tls(b"").await,
            Err(NetError::TlsUnavailable)
        ));
    }

    #[tokio::test]
    async fn upgraded_stream_keeps_the_connection() {
        let (mut session, mut client) = session(Some(Arc::new(EchoUpgrade)));
        session.start_tls(b"").await.expect("mise à niveau");
        session.stream().write_all(b"220 ok\r\n").await.unwrap();
        let mut line = [0u8; 8];
        client.read_exact(&mut line).await.unwrap();
        assert_eq!(&line, b"220 ok\r\n");
    }
}
