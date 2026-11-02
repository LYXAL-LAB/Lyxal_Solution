//! Point d'entrée unique des tests d'intégration du crate.
//!
//! Chaque fichier de ce dossier est un module : Cargo produit un seul exécutable de tests
//! au lieu d'un par fichier (chaque exécutable embarque le moteur SurrealDB complet).

mod common;

mod integration_concurrency;
mod integration_consumer_bridge;
mod integration_crash_recovery;
mod integration_define_event;
mod integration_dto_contracts;
mod integration_fanout_recovery;
mod integration_instance_isolation;
mod integration_publish_fanout;
mod integration_retry_dlq_replay;
mod unit_tests;
