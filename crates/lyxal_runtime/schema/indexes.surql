-- ==============================================================================
-- Index des tables du runtime de Lyxal OS
-- ==============================================================================

DEFINE INDEX OVERWRITE idx_runtime_module_id ON TABLE runtime_module COLUMNS module_id UNIQUE;

DEFINE INDEX OVERWRITE idx_runtime_module_version ON TABLE runtime_release COLUMNS module_id, version UNIQUE;

DEFINE INDEX OVERWRITE idx_runtime_migration_module_id ON TABLE runtime_migration COLUMNS module_id, migration_id UNIQUE;

DEFINE INDEX OVERWRITE idx_runtime_migration_status ON TABLE runtime_migration COLUMNS status;

DEFINE INDEX OVERWRITE idx_runtime_lease_key ON TABLE runtime_lease COLUMNS kind, key UNIQUE;

DEFINE INDEX OVERWRITE idx_runtime_health_unique ON TABLE runtime_health COLUMNS node_id, module_id UNIQUE;

DEFINE INDEX OVERWRITE idx_runtime_worker_unique ON TABLE runtime_worker COLUMNS node_id, worker_id UNIQUE;

DEFINE INDEX OVERWRITE idx_runtime_runtime_event_id ON TABLE runtime_event_journal COLUMNS event_id UNIQUE;
DEFINE INDEX OVERWRITE idx_runtime_runtime_event_node_seq ON TABLE runtime_event_journal COLUMNS node_id, sequence UNIQUE;
DEFINE INDEX OVERWRITE idx_runtime_runtime_event_module ON TABLE runtime_event_journal COLUMNS module_id;
DEFINE INDEX OVERWRITE idx_runtime_runtime_event_kind ON TABLE runtime_event_journal COLUMNS kind;
DEFINE INDEX OVERWRITE idx_runtime_runtime_event_timestamp ON TABLE runtime_event_journal COLUMNS timestamp;

