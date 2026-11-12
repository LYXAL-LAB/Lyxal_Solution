//! Point d'entrée unique des tests d'intégration du crate.
//!
//! Chaque fichier de ce dossier est un module : Cargo produit un seul exécutable de tests
//! au lieu d'un par fichier (chaque exécutable embarque le moteur SurrealDB complet).

mod auth_routes;
mod configuration;
mod serve;
mod startup;
mod storage_routes;
mod upload_routes;
