// SPDX-License-Identifier: AGPL-3.0-only

//! Serveur de courrier de Lyxal OS (module du Noyau Technique, licence `AGPL-3.0-only`).
//!
//! **État : squelette (lot 3 du programme courrier).** Le crate ne contient que le contrat
//! réseau des sessions ([`net`]) : ce que l'hôte `lyxal-groupware` remet à un protocole pour
//! chaque connexion acceptée, les limites appliquées à l'acceptation (plafond par écoute,
//! cadence et connexions ouvertes par réseau, budget mémoire) et les lignes de refus poli de
//! chaque protocole. Les protocoles (SMTP, IMAP, POP3, ManageSieve) arrivent aux lots 5 à 10 ;
//! les tables, fonctions SurrealQL et codes `MAIL_*` au lot 4.
//!
//! Provenance : voir `SOURCES.md` (code porté de Stalwart, transposé de Mox).

#![forbid(unsafe_code)]
#![deny(missing_docs)]
#![deny(clippy::unwrap_used, clippy::expect_used, clippy::panic)]

/// Identifiant du module (`id` de `manifest.toml`).
pub const MODULE_ID: &str = "lyxal_mail";

pub mod net;
