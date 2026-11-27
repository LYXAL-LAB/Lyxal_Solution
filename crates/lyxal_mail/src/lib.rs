// SPDX-License-Identifier: AGPL-3.0-only

//! Serveur de courrier de Lyxal OS (module du Noyau Technique, licence `AGPL-3.0-only`).
//!
//! Les règles (domaines, comptes, adresses, dossiers, messages, quotas, droits) vivent dans les
//! fonctions SurrealQL `fn::mail_*`, installées par `lyxal_runtime` depuis `manifest.toml`. Ce
//! crate fournit :
//!
//! * les appels typés de ces fonctions ([`MailStore`], contrats dans [`models`]) ;
//! * le dépôt d'un message brut ([`MailIngest`] : lecture MIME par `lyxal_mail_proto`,
//!   écriture chiffrée par `lyxal_storage`, inscription) et sa lecture, entière ou par plage
//!   ([`MailContent`]) ;
//! * la remise d'un message reçu par SMTP ([`MailIngest::receive`], lot 5) : empreinte
//!   d'idempotence ([`delivery_key`]), ordre des inscriptions par compte dans le nœud et
//!   écriture groupée ([`AccountQueue`]) ;
//! * la maintenance ([`MailMaintenance`], exécutée par `lyxal_scheduler` sur l'hôte) ;
//! * le module [`MailModule`] et sa sonde [`MailHealthCheck`] ;
//! * le contrat réseau des sessions ([`net`], lot 3) : ce que l'hôte `lyxal-groupware` remet à
//!   un protocole pour chaque connexion acceptée. Les protocoles arrivent aux lots 5 à 12 ;
//! * le résolveur DNS du courrier ([`dns`], lot 5) et les contrôles d'authenticité ([`auth`],
//!   lot 5 : SPF, DKIM, DMARC, nom inverse, en-tête `Authentication-Results`) ;
//! * la réception SMTP ([`smtp`], lot 5 : session du port 25, liste de blocage, bannissement)
//!   et la chaîne de remise ([`DeliveryPipeline`] : antivirus → anti-spam → filtres → index →
//!   chiffrement).
//!
//! Provenance : voir `SOURCES.md` (code porté de Stalwart, transposé de Mox, écrit depuis les
//! RFC).

#![forbid(unsafe_code)]
#![deny(missing_docs)]
#![deny(clippy::unwrap_used, clippy::expect_used, clippy::panic)]
// `LyxalSurrealError` (erreur commune de `lyxal_surreal`) est rendue par les appels typés ;
// même règle que `lyxal_storage` : réduire cette erreur serait un changement de contrat.
#![allow(clippy::result_large_err)]

/// Identifiant du module (`id` de `manifest.toml`).
pub const MODULE_ID: &str = "lyxal_mail";

pub mod auth;
pub mod content;
pub mod delivery;
pub mod dns;
pub mod error;
pub mod ingest;
pub mod maintenance;
pub mod mime;
pub mod models;
pub mod module;
pub mod net;
pub mod smtp;
pub mod store;
pub mod submission;

pub use content::{MailContent, OpenedContent};
pub use delivery::{
    delivery_key, AccountQueue, DeliveryOutcome, DeliveryPipeline, QueueStats, MAX_BATCH,
};
pub use error::{MailError, MailResult};
pub use ingest::{Delivery, MailIngest, ReceivedDelivery, MAIL_BUCKET};
pub use maintenance::{MailMaintenance, MaintenanceReport};
pub use mime::DeliveryFlags;
pub use module::{MailHealthCheck, MailModule, RequiredHost, REQUIRED_HOST_ABSENCE_LIMIT};
pub use store::MailStore;
