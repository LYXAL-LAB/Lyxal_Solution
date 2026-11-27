//! Point d'entrée unique des tests d'intégration du crate.
//!
//! Chaque fichier de ce dossier est un module : Cargo produit un seul exécutable de tests
//! au lieu d'un par fichier (chaque exécutable embarque le moteur SurrealDB complet, et ici
//! aussi `lyxal-server`).

#![allow(clippy::unwrap_used, clippy::expect_used, clippy::panic)]

mod binary;
mod config;
mod http_port;
mod limits;
mod listeners;
mod mail_service;
mod proxy;
mod reload;
mod shutdown;
mod smtp_reception;
mod starttls;
mod submission;
mod support;
mod tls;
mod two_hosts;
