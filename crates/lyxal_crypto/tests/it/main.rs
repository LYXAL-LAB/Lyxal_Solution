//! Point d'entrée unique des tests d'intégration du crate.
//!
//! Chaque fichier de ce dossier est un module : Cargo produit un seul exécutable de tests
//! au lieu d'un par fichier (chaque exécutable embarque le moteur SurrealDB complet).

mod encryption;
mod envelope_v2_fixtures;
mod file_v2;
mod fuzz_robustness;
mod hash_vectors;
mod key_generation;
mod key_resolver;
mod mac_kdf_v2;
mod negative_tests;
mod password_tests;
mod password_v2;
mod proptests;
mod protocol_v2;
mod resource_boundaries;
mod rotation_v2;
mod secrets_v2;
