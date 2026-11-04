//! Point d'entrée unique des tests d'intégration du crate.
//!
//! Chaque fichier de ce dossier est un module : Cargo produit un seul exécutable de tests
//! au lieu d'un par fichier (chaque exécutable embarque le moteur SurrealDB complet).

mod common;

mod catalogue_runtime_integration_tests;
mod controller_loop_tests;
mod health_status_tests;
mod health_store_tests;
mod lease_fencing_tests;
mod lifecycle_tests;
mod lyxal_event_runtime_integration_tests;
mod manifest_tests;
mod migration_lease_tests;
mod migration_plan_tests;
mod migration_runner_tests;
mod migration_tests;
mod module_batch_dag_tests;
mod module_installation_tests;
mod multi_node_installation_tests;
mod multi_node_locking_tests;
mod reconciler_apply_tests;
mod reconciler_plan_tests;
mod registry_and_resolver_tests;
mod resource_provider_tests;
mod runtime_event_bus_tests;
mod runtime_event_integration_tests;
mod runtime_event_journal_tests;
mod runtime_event_model_tests;
mod scenario_tests;
mod schema_importer_tests;
mod store_memory_tests;
mod store_surreal_tests;
mod worker_concurrency_tests;
mod worker_lifecycle_integration_tests;
mod worker_registry_tests;
mod worker_restart_tests;
mod worker_store_tests;
mod worker_supervisor_tests;
