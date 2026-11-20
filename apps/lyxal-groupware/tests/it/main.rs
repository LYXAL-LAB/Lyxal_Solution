//! Point d'entrée unique des tests d'intégration du crate.
//!
//! Chaque fichier de ce dossier est un module : Cargo produit un seul exécutable de tests
//! au lieu d'un par fichier (chaque exécutable embarque le moteur SurrealDB complet, et ici
//! aussi `lyxal-server`).

#![allow(clippy::unwrap_used, clippy::expect_used, clippy::panic)]

mod binary;
mod config;
mod limits;
mod listeners;
mod shutdown;
mod support;
mod two_hosts;
