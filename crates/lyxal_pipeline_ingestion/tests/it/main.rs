//! Point d'entrée unique des tests d'intégration du crate.
//!
//! Chaque fichier de ce dossier est un module : Cargo produit un seul exécutable de tests
//! au lieu d'un par fichier (chaque exécutable embarque le moteur SurrealDB complet).

mod integration_batch_claim;
mod integration_btp_41_qualification;
mod integration_manifest_install;
mod integration_phase2_flow;
mod integration_phase3_qualification;
mod integration_phase4_alignment;
mod integration_phase4_industrial;
mod integration_phase5_steward;
mod integration_publication;
mod integration_staging_live_server;
mod support;
