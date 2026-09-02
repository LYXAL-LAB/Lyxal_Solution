-- ==============================================================================
-- Champs des tables système de Lyxal OS (V1.4)
-- ==============================================================================

-- Champs pour system_module
DEFINE FIELD OVERWRITE module_id ON TABLE system_module TYPE string;
DEFINE FIELD OVERWRITE name ON TABLE system_module TYPE string;
DEFINE FIELD OVERWRITE description ON TABLE system_module TYPE option<string>;
DEFINE FIELD OVERWRITE created_at ON TABLE system_module TYPE datetime DEFAULT time::now() READONLY;
DEFINE FIELD OVERWRITE updated_at ON TABLE system_module TYPE datetime DEFAULT time::now();

-- Champs pour system_module_release
DEFINE FIELD OVERWRITE module_id ON TABLE system_module_release TYPE string;
DEFINE FIELD OVERWRITE version ON TABLE system_module_release TYPE string;
DEFINE FIELD OVERWRITE manifest_version ON TABLE system_module_release TYPE int;
DEFINE FIELD OVERWRITE description ON TABLE system_module_release TYPE option<string>;
DEFINE FIELD OVERWRITE status ON TABLE system_module_release TYPE string;
DEFINE FIELD OVERWRITE checksum ON TABLE system_module_release TYPE option<string>;
DEFINE FIELD OVERWRITE created_at ON TABLE system_module_release TYPE datetime DEFAULT time::now() READONLY;
DEFINE FIELD OVERWRITE installed_at ON TABLE system_module_release TYPE option<datetime>;

-- Champs pour system_migration
DEFINE FIELD OVERWRITE migration_id ON TABLE system_migration TYPE string;
DEFINE FIELD OVERWRITE module_id ON TABLE system_migration TYPE string;
DEFINE FIELD OVERWRITE module_version ON TABLE system_migration TYPE string;
DEFINE FIELD OVERWRITE order ON TABLE system_migration TYPE option<int>;
DEFINE FIELD OVERWRITE checksum ON TABLE system_migration TYPE string;
DEFINE FIELD OVERWRITE status ON TABLE system_migration TYPE string;
DEFINE FIELD OVERWRITE reversible ON TABLE system_migration TYPE option<bool>;
DEFINE FIELD OVERWRITE resource_path ON TABLE system_migration TYPE option<string>;
DEFINE FIELD OVERWRITE applied_at ON TABLE system_migration TYPE option<int>;
DEFINE FIELD OVERWRITE duration_ms ON TABLE system_migration TYPE option<int>;
DEFINE FIELD OVERWRITE error ON TABLE system_migration TYPE option<string>;
DEFINE FIELD OVERWRITE created_at ON TABLE system_migration TYPE datetime DEFAULT time::now() READONLY;
DEFINE FIELD OVERWRITE updated_at ON TABLE system_migration TYPE datetime DEFAULT time::now();

-- Champs pour system_migration_lock
DEFINE FIELD OVERWRITE lock_key ON TABLE system_migration_lock TYPE string;
DEFINE FIELD OVERWRITE module_id ON TABLE system_migration_lock TYPE string;
DEFINE FIELD OVERWRITE migration_id ON TABLE system_migration_lock TYPE string;
DEFINE FIELD OVERWRITE owner_node_id ON TABLE system_migration_lock TYPE string;
DEFINE FIELD OVERWRITE generation ON TABLE system_migration_lock TYPE int;
DEFINE FIELD OVERWRITE is_released ON TABLE system_migration_lock TYPE option<bool>;
DEFINE FIELD OVERWRITE acquired_at ON TABLE system_migration_lock TYPE option<int>;
DEFINE FIELD OVERWRITE renewed_at ON TABLE system_migration_lock TYPE option<int>;
DEFINE FIELD OVERWRITE expires_at ON TABLE system_migration_lock TYPE option<int>;
DEFINE FIELD OVERWRITE released_at ON TABLE system_migration_lock TYPE option<int>;
DEFINE FIELD OVERWRITE created_at ON TABLE system_migration_lock TYPE datetime DEFAULT time::now() READONLY;
DEFINE FIELD OVERWRITE updated_at ON TABLE system_migration_lock TYPE datetime DEFAULT time::now();

-- Champs pour system_installation_lock
DEFINE FIELD OVERWRITE lock_key ON TABLE system_installation_lock TYPE string;
DEFINE FIELD OVERWRITE module_id ON TABLE system_installation_lock TYPE string;
DEFINE FIELD OVERWRITE version ON TABLE system_installation_lock TYPE string;
DEFINE FIELD OVERWRITE owner_node_id ON TABLE system_installation_lock TYPE string;
DEFINE FIELD OVERWRITE generation ON TABLE system_installation_lock TYPE int;
DEFINE FIELD OVERWRITE is_released ON TABLE system_installation_lock TYPE option<bool>;
DEFINE FIELD OVERWRITE acquired_at ON TABLE system_installation_lock TYPE option<int>;
DEFINE FIELD OVERWRITE renewed_at ON TABLE system_installation_lock TYPE option<int>;
DEFINE FIELD OVERWRITE expires_at ON TABLE system_installation_lock TYPE option<int>;
DEFINE FIELD OVERWRITE released_at ON TABLE system_installation_lock TYPE option<int>;
DEFINE FIELD OVERWRITE created_at ON TABLE system_installation_lock TYPE datetime DEFAULT time::now() READONLY;
DEFINE FIELD OVERWRITE updated_at ON TABLE system_installation_lock TYPE datetime DEFAULT time::now();

-- Champs pour system_health
DEFINE FIELD OVERWRITE node_id ON TABLE system_health TYPE string;
DEFINE FIELD OVERWRITE module_id ON TABLE system_health TYPE string;
DEFINE FIELD OVERWRITE status ON TABLE system_health TYPE string;
DEFINE FIELD OVERWRITE latency_ms ON TABLE system_health TYPE option<int>;
DEFINE FIELD OVERWRITE message ON TABLE system_health TYPE option<string>;
DEFINE FIELD OVERWRITE checked_at ON TABLE system_health TYPE option<datetime>;
DEFINE FIELD OVERWRITE updated_at ON TABLE system_health TYPE option<datetime>;

-- Champs pour system_worker
DEFINE FIELD OVERWRITE node_id ON TABLE system_worker TYPE string;
DEFINE FIELD OVERWRITE worker_id ON TABLE system_worker TYPE string;
DEFINE FIELD OVERWRITE module_id ON TABLE system_worker TYPE string;
DEFINE FIELD OVERWRITE state ON TABLE system_worker TYPE string;
DEFINE FIELD OVERWRITE criticality ON TABLE system_worker TYPE string;
DEFINE FIELD OVERWRITE restart_count ON TABLE system_worker TYPE int;
DEFINE FIELD OVERWRITE failure_count ON TABLE system_worker TYPE int;
DEFINE FIELD OVERWRITE last_error ON TABLE system_worker TYPE option<string>;
DEFINE FIELD OVERWRITE started_at ON TABLE system_worker TYPE option<int>;
DEFINE FIELD OVERWRITE stopped_at ON TABLE system_worker TYPE option<int>;
DEFINE FIELD OVERWRITE updated_at ON TABLE system_worker TYPE option<datetime>;

-- Champs pour system_runtime_event
DEFINE FIELD OVERWRITE event_id ON TABLE system_runtime_event TYPE string;
DEFINE FIELD OVERWRITE sequence ON TABLE system_runtime_event TYPE int;
DEFINE FIELD OVERWRITE node_id ON TABLE system_runtime_event TYPE string;
DEFINE FIELD OVERWRITE timestamp ON TABLE system_runtime_event TYPE int;
DEFINE FIELD OVERWRITE kind ON TABLE system_runtime_event TYPE string;
DEFINE FIELD OVERWRITE module_id ON TABLE system_runtime_event TYPE option<string>;
DEFINE FIELD OVERWRITE correlation_id ON TABLE system_runtime_event TYPE option<string>;
DEFINE FIELD OVERWRITE causation_id ON TABLE system_runtime_event TYPE option<string>;
DEFINE FIELD OVERWRITE payload ON TABLE system_runtime_event FLEXIBLE TYPE object;
DEFINE FIELD OVERWRITE created_at ON TABLE system_runtime_event TYPE datetime DEFAULT time::now();

