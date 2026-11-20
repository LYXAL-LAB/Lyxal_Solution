// SPDX-License-Identifier: AGPL-3.0-only

//! Contrat réseau des sessions de courrier, limites et budget mémoire.
//!
//! Partage des rôles (décision G2 du lot 3) : l'hôte `lyxal-groupware` lie les ports, accepte
//! les connexions, applique les limites de ce module puis remet chaque connexion à un
//! [`SessionHandler`] sous forme de [`Session`]. Seul l'hôte détient `tokio-rustls` : la mise à
//! niveau TLS est offerte aux sessions par le trait [`TlsUpgrade`].

mod limit;
mod memory;
mod ratelimit;
mod refusal;
mod session;

pub use limit::{ConnectionLimiter, InFlight};
pub use memory::{MemoryBudget, MemoryClass, MemoryReservation, ReservationScope, MEMORY_GRANULE};
pub use ratelimit::{IpRateLimiter, WindowLimit, DEFAULT_MAX_TRACKED_NETWORKS};
pub use refusal::{refusal_line, RefusalReason, UnavailableHandler, REFUSAL_WRITE_TIMEOUT};
pub use session::{
    BoxedStream, ConnectionInfo, MailProtocol, MailStream, NetError, Session, SessionEnd,
    SessionHandler, SessionLimits, TlsInfo, TlsMode, TlsState, TlsUpgrade,
};
