// SPDX-License-Identifier: AGPL-3.0-only

//! Envoi du courrier (lot 6, sous-lot 6d ; plan §5 à §7, §10, §16) : worker d'envoi supervisé
//! ([`OutboundDispatcher`]), résolution des MX ([`MxPlan`]), client SMTP ([`SmtpConnection`] :
//! STARTTLS opportuniste, `PIPELINING`, délais), connexions gardées et limites
//! ([`ConnectionPool`], [`DestinationLimiter`]), relais sortant facultatif, route locale
//! ([`LocalRoute`]), préparation des envois ([`Preparer`] : DKIM, jeton de retour, préfixe),
//! mesures ([`OutboundMetrics`]).
//!
//! Écrit pour Lyxal OS sur le modèle de Stalwart (`smtp/queue`, `smtp/outbound`), Mox (`queue`,
//! `smtpclient`) et KumoMTA (limites par destination) : voir `SOURCES.md`. Le TLS est négocié
//! par l'hôte ([`TlsConnectorProvider`]) : `lyxal_mail` ne dépend jamais de `rustls` ni de
//! `tokio-rustls`.

mod client;
mod config;
pub(crate) mod content;
mod dispatcher;
mod local;
mod metrics;
mod mx;
mod pool;
mod prepare;

pub use client::{
    ConnectTarget, Envelope, OpenFailure, RcptPlan, RecipientOutcome, RelayCredentials,
    SmtpConnection, TargetTls, TlsConnectorProvider, TransactionResult,
};
pub use config::{
    DestinationOverride, IpFamily, OutboundConfig, OutboundConfigError, OutboundTls, RelayConfig,
    RelayTls, Timeouts,
};
pub use dispatcher::{OutboundDispatcher, OutboundServices};
pub use local::{LocalMessage, LocalOutcome, LocalRoute};
pub use metrics::{stage_name, OutboundMetrics};
pub use mx::{is_public, MxHost, MxPlan, ResolveFailure, ResolveReason};
pub use pool::{ConnectionPool, DestinationLimiter, PoolKey, Slot};
pub use prepare::{Preparation, Preparer, MAX_HEADER_BYTES};
