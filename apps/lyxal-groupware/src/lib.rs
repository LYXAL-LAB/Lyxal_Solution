// SPDX-License-Identifier: AGPL-3.0-only

//! Hôte `lyxal_groupware` de Lyxal OS : courrier, agendas et contacts (licence `AGPL-3.0-only`).
//!
//! Second programme de Lyxal OS, à côté de `lyxal-server` sur la même base : il installe ou
//! retrouve le socle, installe ses modules, se déclare dans `runtime_node`, élit son propre chef
//! des événements et ouvre les ports de courrier configurés, supervisés par le runtime. Le
//! démarrage commun aux hôtes vient de `lyxal_host` ; les limites et le contrat des sessions de
//! `lyxal_mail::net`.

#![forbid(unsafe_code)]
#![deny(clippy::unwrap_used, clippy::expect_used)]

pub mod bootstrap;
pub mod config;
pub mod error;
pub mod http;
pub mod modules;
pub mod net;
pub mod runtime;

pub use bootstrap::run;
