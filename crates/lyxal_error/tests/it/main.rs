//! Point d'entrée unique des tests d'intégration du crate.
//!
//! Chaque fichier de ce dossier est un module : Cargo produit un seul exécutable de tests
//! au lieu d'un par fichier (chaque exécutable embarque le moteur SurrealDB complet).

// `LyxalCallError` est l'erreur du contrat `{ ok, data, error }` (admise dans le crate, voir
// `src/lib.rs`) ; Clippy de Rust 1.98 signale les fonctions d'essai qui la rendent
// (`result_large_err`), 1.97 ne le faisait pas.
#![allow(clippy::result_large_err)]

mod contracts_tests;
mod manifest_tests;
mod surreal_integration_tests;
