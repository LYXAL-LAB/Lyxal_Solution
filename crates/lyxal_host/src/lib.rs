//! Code commun des hôtes de Lyxal OS (`lyxal-server`, `lyxal-groupware`) : chargement de la
//! configuration en couches, sections `[secrets]` et `[storage]` et construction du trousseau
//! maître, des supports et de l'antivirus, connexion à la base et refus de l'accès anonyme,
//! santé, journal, signal d'arrêt, adresse réelle du client, service HTTP, modules embarqués et
//! installation du socle, aide de `build.rs`.
//!
//! Ce crate ne contient que du code écrit pour Lyxal (licence `MIT OR Apache-2.0`) : aucun code
//! porté d'un projet sous AGPL ou GPL n'y entre. Ses erreurs (`HostError`) n'ont pas de code :
//! chaque hôte les traduit dans ses propres codes (`SERVER_*`…).
//!
//! Fonctionnalités : `host` (par défaut) pour la bibliothèque des hôtes, `build` pour l'aide de
//! `build.rs` seule (dépendance de compilation, n'amène que `toml`).

#![forbid(unsafe_code)]
#![deny(clippy::unwrap_used, clippy::expect_used)]

#[cfg(feature = "build")]
pub mod build;
#[cfg(feature = "host")]
pub mod config;
#[cfg(feature = "host")]
pub mod database;
#[cfg(feature = "host")]
mod error;
#[cfg(feature = "host")]
pub mod health;
#[cfg(feature = "host")]
pub mod http;
#[cfg(feature = "host")]
pub mod metrics;
#[cfg(feature = "host")]
pub mod modules;
#[cfg(feature = "host")]
pub mod net;
#[cfg(feature = "host")]
pub mod services;
#[cfg(feature = "host")]
pub mod shutdown;
#[cfg(feature = "host")]
pub mod telemetry;

#[cfg(feature = "host")]
pub use error::HostError;
