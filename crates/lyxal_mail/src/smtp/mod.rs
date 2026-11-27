// SPDX-License-Identifier: AGPL-3.0-only

//! Réception SMTP (plan du lot 5, §7 et §11) : session du port 25, refus dès `RCPT TO`,
//! contrôles d'authenticité, remise par la chaîne de remise, limites, liste de blocage et
//! bannissement. L'hôte `lyxal-groupware` lie le port, accepte les connexions et remet chacune à
//! [`SmtpInboundHandler`] ; la syntaxe vient de `lyxal_mail_proto::smtp`.
//!
//! Aucun envoi vers l'extérieur (lot 6) : rien n'est jamais relayé, aucun avis de non-remise
//! n'est produit, tout refus se fait pendant la session.

mod block;
mod checks;
mod config;
pub(crate) mod handler;
mod metrics;
mod resolver;
pub(crate) mod session;

pub use block::{
    BlockList, BlockRefreshWorker, Network, NetworkParseError, Offence, BAN_OFFENCES, BAN_WINDOW,
    BLOCK_REFRESH_INTERVAL,
};
pub use config::{
    SmtpConfig, SmtpConfigError, DEFAULT_COMMAND_TIMEOUT, DEFAULT_DATA_MIN_BYTES_PER_SECOND,
    DEFAULT_DATA_TIMEOUT, DEFAULT_MAX_ERRORS, DEFAULT_MAX_LINE_BYTES,
    DEFAULT_MAX_MESSAGES_PER_SESSION, DEFAULT_MAX_MESSAGE_BYTES, DEFAULT_MAX_RECIPIENTS,
    DEFAULT_MESSAGES_PER_NETWORK_PER_MINUTE, DEFAULT_SESSION_MAX,
};
pub use handler::{SmtpInboundHandler, SmtpServices};
pub use metrics::{RefusedReason, SmtpMetrics};
