// SPDX-License-Identifier: AGPL-3.0-only

//! Refus poli et standard, par protocole : la ligne écrite avant de fermer une connexion
//! refusée (limites, blocage, arrêt) ou servie par un protocole qui n'existe pas encore.
//!
//! Les lignes sont fixes : elles ne reprennent ni l'adresse du client ni le détail interne de la
//! raison. SMTP : code `421` (RFC 5321 §3.8 et §4.2.3) avec code étendu (RFC 3463) : `4.3.2`
//! (service indisponible), `4.7.0` (refus de politique : limites, blocage). IMAP : `* BYE` avec
//! le code `[UNAVAILABLE]` (RFC 9051, RFC 5530). POP3 : `-ERR` avec `[SYS/TEMP]` (RFC 2449,
//! RFC 3206). ManageSieve : `BYE` avec `(TRYLATER)` (RFC 5804).

use crate::net::session::{MailProtocol, Session, SessionEnd, SessionHandler};
use async_trait::async_trait;
use std::time::Duration;
use tokio::io::AsyncWriteExt;

/// Délai d'écriture d'une ligne de refus.
pub const REFUSAL_WRITE_TIMEOUT: Duration = Duration::from_secs(5);

/// Raison d'un refus.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum RefusalReason {
    /// Trop de connexions ouvertes depuis le réseau du client.
    TooManyConnections,
    /// Trop de connexions nouvelles depuis le réseau du client.
    RateLimited,
    /// Réseau refusé par la configuration.
    Blocked,
    /// Budget mémoire épuisé.
    MemoryBudget,
    /// Nœud en cours d'arrêt.
    ShuttingDown,
    /// Service pas encore disponible sur ce port.
    Unavailable,
}

impl RefusalReason {
    /// Nom de la raison pour le journal et les mesures.
    pub fn as_str(self) -> &'static str {
        match self {
            Self::TooManyConnections => "too_many_connections",
            Self::RateLimited => "rate_limited",
            Self::Blocked => "blocked",
            Self::MemoryBudget => "memory_budget",
            Self::ShuttingDown => "shutting_down",
            Self::Unavailable => "unavailable",
        }
    }
}

/// Ligne complète (CRLF compris) à écrire avant de fermer une connexion refusée.
pub fn refusal_line(protocol: MailProtocol, reason: RefusalReason) -> &'static [u8] {
    use RefusalReason as R;
    match protocol {
        MailProtocol::Smtp | MailProtocol::Submission => match reason {
            R::TooManyConnections => {
                b"421 4.7.0 Too many connections from your network, try again later\r\n"
            }
            R::RateLimited => {
                b"421 4.7.0 Connection rate from your network too high, slow down\r\n"
            }
            R::Blocked => b"421 4.7.0 Connection refused by policy\r\n",
            R::MemoryBudget => b"421 4.3.2 Server busy, try again later\r\n",
            R::ShuttingDown => b"421 4.3.2 Service shutting down, try again later\r\n",
            R::Unavailable => b"421 4.3.2 Service not available, try again later\r\n",
        },
        MailProtocol::Imap => match reason {
            R::TooManyConnections => {
                b"* BYE [UNAVAILABLE] Too many connections from your network, try again later\r\n"
            }
            R::RateLimited => {
                b"* BYE [UNAVAILABLE] Connection rate from your network too high, slow down\r\n"
            }
            R::Blocked => b"* BYE Connection refused by policy\r\n",
            R::MemoryBudget => b"* BYE [UNAVAILABLE] Server busy, try again later\r\n",
            R::ShuttingDown => b"* BYE [UNAVAILABLE] Service shutting down, try again later\r\n",
            R::Unavailable => b"* BYE [UNAVAILABLE] Service not available, try again later\r\n",
        },
        MailProtocol::Pop3 => match reason {
            R::TooManyConnections => {
                b"-ERR [SYS/TEMP] Too many connections from your network, try again later\r\n"
            }
            R::RateLimited => {
                b"-ERR [SYS/TEMP] Connection rate from your network too high, slow down\r\n"
            }
            R::Blocked => b"-ERR Connection refused by policy\r\n",
            R::MemoryBudget => b"-ERR [SYS/TEMP] Server busy, try again later\r\n",
            R::ShuttingDown => b"-ERR [SYS/TEMP] Service shutting down, try again later\r\n",
            R::Unavailable => b"-ERR [SYS/TEMP] Service not available, try again later\r\n",
        },
        MailProtocol::ManageSieve => match reason {
            R::TooManyConnections => {
                b"BYE (TRYLATER) \"Too many connections from your network, try again later\"\r\n"
            }
            R::RateLimited => {
                b"BYE (TRYLATER) \"Connection rate from your network too high, slow down\"\r\n"
            }
            R::Blocked => b"BYE \"Connection refused by policy\"\r\n",
            R::MemoryBudget => b"BYE (TRYLATER) \"Server busy, try again later\"\r\n",
            R::ShuttingDown => b"BYE (TRYLATER) \"Service shutting down, try again later\"\r\n",
            R::Unavailable => b"BYE (TRYLATER) \"Service not available, try again later\"\r\n",
        },
    }
}

/// Handler d'un protocole qui n'a pas encore de session : refus `Unavailable` puis fermeture.
/// Retiré quand le dernier protocole aura sa session (lot 10).
#[derive(Clone, Copy, Debug)]
pub struct UnavailableHandler {
    protocol: MailProtocol,
}

impl UnavailableHandler {
    /// Handler du protocole `protocol`.
    pub fn new(protocol: MailProtocol) -> Self {
        Self { protocol }
    }
}

#[async_trait]
impl SessionHandler for UnavailableHandler {
    fn protocol(&self) -> MailProtocol {
        self.protocol
    }

    async fn handle(&self, mut session: Session) -> SessionEnd {
        let line = refusal_line(self.protocol, RefusalReason::Unavailable);
        let write = async {
            let stream = session.stream();
            stream.write_all(line).await?;
            stream.flush().await?;
            stream.shutdown().await
        };
        match tokio::time::timeout(REFUSAL_WRITE_TIMEOUT, write).await {
            Ok(Ok(())) => SessionEnd::Closed,
            Ok(Err(error)) => SessionEnd::Failed(error.into()),
            Err(_) => SessionEnd::Failed(crate::net::session::NetError::Timeout),
        }
    }
}

#[cfg(test)]
#[allow(clippy::unwrap_used, clippy::expect_used, clippy::panic)]
mod tests {
    use super::*;

    const PROTOCOLS: [MailProtocol; 5] = [
        MailProtocol::Smtp,
        MailProtocol::Submission,
        MailProtocol::Imap,
        MailProtocol::Pop3,
        MailProtocol::ManageSieve,
    ];
    const REASONS: [RefusalReason; 6] = [
        RefusalReason::TooManyConnections,
        RefusalReason::RateLimited,
        RefusalReason::Blocked,
        RefusalReason::MemoryBudget,
        RefusalReason::ShuttingDown,
        RefusalReason::Unavailable,
    ];

    #[test]
    fn every_line_is_one_crlf_terminated_ascii_line() {
        for protocol in PROTOCOLS {
            for reason in REASONS {
                let line = refusal_line(protocol, reason);
                assert!(line.ends_with(b"\r\n"), "{protocol} {reason:?}");
                let body = &line[..line.len() - 2];
                assert!(
                    body.iter().all(|b| (0x20..0x7f).contains(b)),
                    "{protocol} {reason:?}"
                );
                assert!(line.len() <= 512, "{protocol} {reason:?}");
            }
        }
    }

    #[test]
    fn lines_follow_each_protocol() {
        for reason in REASONS {
            let smtp = refusal_line(MailProtocol::Smtp, reason);
            let code: &[u8] = match reason {
                RefusalReason::TooManyConnections
                | RefusalReason::RateLimited
                | RefusalReason::Blocked => b"421 4.7.0 ",
                _ => b"421 4.3.2 ",
            };
            assert!(smtp.starts_with(code), "{reason:?}");
            assert_eq!(smtp, refusal_line(MailProtocol::Submission, reason));
            assert!(refusal_line(MailProtocol::Imap, reason).starts_with(b"* BYE "));
            assert!(refusal_line(MailProtocol::Pop3, reason).starts_with(b"-ERR "));
            let sieve = refusal_line(MailProtocol::ManageSieve, reason);
            assert!(sieve.starts_with(b"BYE "));
            // Chaîne entre guillemets, sans guillemet interne
            let quoted = &sieve[sieve.iter().position(|b| *b == b'"').unwrap()..sieve.len() - 2];
            assert!(quoted.ends_with(b"\"") && quoted.iter().filter(|b| **b == b'"').count() == 2);
        }
        assert_eq!(
            refusal_line(MailProtocol::Smtp, RefusalReason::Unavailable),
            b"421 4.3.2 Service not available, try again later\r\n"
        );
    }

    #[tokio::test]
    async fn unavailable_handler_writes_its_line_and_closes() {
        use crate::net::memory::{MemoryBudget, MemoryClass};
        use crate::net::session::{ConnectionInfo, SessionLimits, TlsState};
        use tokio::io::AsyncReadExt;

        for protocol in PROTOCOLS {
            let (server, mut client) = tokio::io::duplex(1024);
            let session = Session::new(
                ConnectionInfo {
                    listener_id: "essai".into(),
                    protocol,
                    session_id: 1,
                    local: "127.0.0.1:1".parse().unwrap(),
                    remote: "127.0.0.1:2".parse().unwrap(),
                    via_proxy: false,
                    tls: TlsState::Plain,
                },
                SessionLimits {
                    idle: Duration::from_secs(1),
                    write_stall: Duration::from_secs(1),
                },
                tokio_util::sync::CancellationToken::new(),
                MemoryBudget::new(1 << 20).reservation(MemoryClass::Read, 1 << 20),
                Box::new(server),
                None,
            );
            let handler = UnavailableHandler::new(protocol);
            assert_eq!(handler.protocol(), protocol);
            assert!(matches!(handler.handle(session).await, SessionEnd::Closed));
            let mut received = Vec::new();
            client.read_to_end(&mut received).await.unwrap();
            assert_eq!(received, refusal_line(protocol, RefusalReason::Unavailable));
        }
    }
}
