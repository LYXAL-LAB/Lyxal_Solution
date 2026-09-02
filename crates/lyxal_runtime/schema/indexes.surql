-- ==============================================================================
-- Index des tables système de Lyxal OS (V1.4)
-- ==============================================================================

DEFINE INDEX OVERWRITE idx_system_module_id ON TABLE system_module COLUMNS module_id UNIQUE;

DEFINE INDEX OVERWRITE idx_system_module_version ON TABLE system_module_release COLUMNS module_id, version UNIQUE;

DEFINE INDEX OVERWRITE idx_system_migration_module_id ON TABLE system_migration COLUMNS module_id, migration_id UNIQUE;

DEFINE INDEX OVERWRITE idx_system_migration_status ON TABLE system_migration COLUMNS status;

DEFINE INDEX OVERWRITE idx_system_migration_lock_key ON TABLE system_migration_lock COLUMNS lock_key UNIQUE;

DEFINE INDEX OVERWRITE idx_system_installation_lock_key ON TABLE system_installation_lock COLUMNS lock_key UNIQUE;

DEFINE INDEX OVERWRITE idx_system_health_unique ON TABLE system_health COLUMNS node_id, module_id UNIQUE;

DEFINE INDEX OVERWRITE idx_system_worker_unique ON TABLE system_worker COLUMNS node_id, worker_id UNIQUE;

DEFINE INDEX OVERWRITE idx_system_runtime_event_id ON TABLE system_runtime_event COLUMNS event_id UNIQUE;
DEFINE INDEX OVERWRITE idx_system_runtime_event_node_seq ON TABLE system_runtime_event COLUMNS node_id, sequence UNIQUE;
DEFINE INDEX OVERWRITE idx_system_runtime_event_module ON TABLE system_runtime_event COLUMNS module_id;
DEFINE INDEX OVERWRITE idx_system_runtime_event_kind ON TABLE system_runtime_event COLUMNS kind;
DEFINE INDEX OVERWRITE idx_system_runtime_event_timestamp ON TABLE system_runtime_event COLUMNS timestamp;

