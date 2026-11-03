-- ==============================================================================
-- Champs des tables du runtime de Lyxal OS
-- ==============================================================================

-- Champs pour runtime_module
DEFINE FIELD OVERWRITE module_id ON TABLE runtime_module TYPE string;
DEFINE FIELD OVERWRITE name ON TABLE runtime_module TYPE string;
DEFINE FIELD OVERWRITE description ON TABLE runtime_module TYPE option<string>;
DEFINE FIELD OVERWRITE created_at ON TABLE runtime_module TYPE datetime DEFAULT time::now() READONLY;
DEFINE FIELD OVERWRITE updated_at ON TABLE runtime_module TYPE datetime DEFAULT time::now();

-- Champs pour runtime_release
DEFINE FIELD OVERWRITE module_id ON TABLE runtime_release TYPE string;
DEFINE FIELD OVERWRITE version ON TABLE runtime_release TYPE string;
DEFINE FIELD OVERWRITE manifest_version ON TABLE runtime_release TYPE int;
DEFINE FIELD OVERWRITE description ON TABLE runtime_release TYPE option<string>;
DEFINE FIELD OVERWRITE status ON TABLE runtime_release TYPE string;
DEFINE FIELD OVERWRITE checksum ON TABLE runtime_release TYPE option<string>;
DEFINE FIELD OVERWRITE created_at ON TABLE runtime_release TYPE datetime DEFAULT time::now() READONLY;
DEFINE FIELD OVERWRITE installation_phase ON TABLE runtime_release TYPE option<string>;
DEFINE FIELD OVERWRITE installed_at ON TABLE runtime_release TYPE option<datetime>;
DEFINE FIELD OVERWRITE updated_at ON TABLE runtime_release TYPE option<datetime>;

-- Champs pour runtime_migration
DEFINE FIELD OVERWRITE migration_id ON TABLE runtime_migration TYPE string;
DEFINE FIELD OVERWRITE module_id ON TABLE runtime_migration TYPE string;
DEFINE FIELD OVERWRITE module_version ON TABLE runtime_migration TYPE string;
DEFINE FIELD OVERWRITE order ON TABLE runtime_migration TYPE option<int>;
DEFINE FIELD OVERWRITE checksum ON TABLE runtime_migration TYPE string;
DEFINE FIELD OVERWRITE status ON TABLE runtime_migration TYPE string;
DEFINE FIELD OVERWRITE reversible ON TABLE runtime_migration TYPE option<bool>;
DEFINE FIELD OVERWRITE resource_path ON TABLE runtime_migration TYPE option<string>;
DEFINE FIELD OVERWRITE applied_at ON TABLE runtime_migration TYPE option<int>;
DEFINE FIELD OVERWRITE duration_ms ON TABLE runtime_migration TYPE option<int>;
DEFINE FIELD OVERWRITE error ON TABLE runtime_migration TYPE option<string>;
DEFINE FIELD OVERWRITE created_at ON TABLE runtime_migration TYPE datetime DEFAULT time::now() READONLY;
DEFINE FIELD OVERWRITE updated_at ON TABLE runtime_migration TYPE datetime DEFAULT time::now();

-- Champs pour runtime_migration_lock
DEFINE FIELD OVERWRITE lock_key ON TABLE runtime_migration_lock TYPE string;
DEFINE FIELD OVERWRITE module_id ON TABLE runtime_migration_lock TYPE string;
DEFINE FIELD OVERWRITE migration_id ON TABLE runtime_migration_lock TYPE string;
DEFINE FIELD OVERWRITE owner_node_id ON TABLE runtime_migration_lock TYPE string;
DEFINE FIELD OVERWRITE generation ON TABLE runtime_migration_lock TYPE int;
DEFINE FIELD OVERWRITE is_released ON TABLE runtime_migration_lock TYPE option<bool>;
DEFINE FIELD OVERWRITE acquired_at ON TABLE runtime_migration_lock TYPE option<int>;
DEFINE FIELD OVERWRITE renewed_at ON TABLE runtime_migration_lock TYPE option<int>;
DEFINE FIELD OVERWRITE expires_at ON TABLE runtime_migration_lock TYPE option<int>;
DEFINE FIELD OVERWRITE released_at ON TABLE runtime_migration_lock TYPE option<int>;
DEFINE FIELD OVERWRITE created_at ON TABLE runtime_migration_lock TYPE datetime DEFAULT time::now() READONLY;
DEFINE FIELD OVERWRITE updated_at ON TABLE runtime_migration_lock TYPE datetime DEFAULT time::now();

-- Champs pour runtime_installation_lock
DEFINE FIELD OVERWRITE lock_key ON TABLE runtime_installation_lock TYPE string;
DEFINE FIELD OVERWRITE module_id ON TABLE runtime_installation_lock TYPE string;
DEFINE FIELD OVERWRITE version ON TABLE runtime_installation_lock TYPE string;
DEFINE FIELD OVERWRITE owner_node_id ON TABLE runtime_installation_lock TYPE string;
DEFINE FIELD OVERWRITE generation ON TABLE runtime_installation_lock TYPE int;
DEFINE FIELD OVERWRITE is_released ON TABLE runtime_installation_lock TYPE option<bool>;
DEFINE FIELD OVERWRITE acquired_at ON TABLE runtime_installation_lock TYPE option<int>;
DEFINE FIELD OVERWRITE renewed_at ON TABLE runtime_installation_lock TYPE option<int>;
DEFINE FIELD OVERWRITE expires_at ON TABLE runtime_installation_lock TYPE option<int>;
DEFINE FIELD OVERWRITE released_at ON TABLE runtime_installation_lock TYPE option<int>;
DEFINE FIELD OVERWRITE created_at ON TABLE runtime_installation_lock TYPE datetime DEFAULT time::now() READONLY;
DEFINE FIELD OVERWRITE updated_at ON TABLE runtime_installation_lock TYPE datetime DEFAULT time::now();

-- Champs pour runtime_health
DEFINE FIELD OVERWRITE node_id ON TABLE runtime_health TYPE string;
DEFINE FIELD OVERWRITE module_id ON TABLE runtime_health TYPE string;
DEFINE FIELD OVERWRITE status ON TABLE runtime_health TYPE string;
DEFINE FIELD OVERWRITE latency_ms ON TABLE runtime_health TYPE option<int>;
DEFINE FIELD OVERWRITE message ON TABLE runtime_health TYPE option<string>;
DEFINE FIELD OVERWRITE checked_at ON TABLE runtime_health TYPE option<datetime>;
DEFINE FIELD OVERWRITE updated_at ON TABLE runtime_health TYPE option<datetime>;

-- Champs pour runtime_worker
DEFINE FIELD OVERWRITE node_id ON TABLE runtime_worker TYPE string;
DEFINE FIELD OVERWRITE worker_id ON TABLE runtime_worker TYPE string;
DEFINE FIELD OVERWRITE module_id ON TABLE runtime_worker TYPE string;
DEFINE FIELD OVERWRITE state ON TABLE runtime_worker TYPE string;
DEFINE FIELD OVERWRITE criticality ON TABLE runtime_worker TYPE string;
DEFINE FIELD OVERWRITE restart_count ON TABLE runtime_worker TYPE int;
DEFINE FIELD OVERWRITE failure_count ON TABLE runtime_worker TYPE int;
DEFINE FIELD OVERWRITE last_error ON TABLE runtime_worker TYPE option<string>;
DEFINE FIELD OVERWRITE started_at ON TABLE runtime_worker TYPE option<int>;
DEFINE FIELD OVERWRITE stopped_at ON TABLE runtime_worker TYPE option<int>;
DEFINE FIELD OVERWRITE updated_at ON TABLE runtime_worker TYPE option<datetime>;

-- Champs pour runtime_event_journal
DEFINE FIELD OVERWRITE event_id ON TABLE runtime_event_journal TYPE string;
DEFINE FIELD OVERWRITE sequence ON TABLE runtime_event_journal TYPE int;
DEFINE FIELD OVERWRITE node_id ON TABLE runtime_event_journal TYPE string;
DEFINE FIELD OVERWRITE timestamp ON TABLE runtime_event_journal TYPE int;
DEFINE FIELD OVERWRITE kind ON TABLE runtime_event_journal TYPE string;
DEFINE FIELD OVERWRITE module_id ON TABLE runtime_event_journal TYPE option<string>;
DEFINE FIELD OVERWRITE correlation_id ON TABLE runtime_event_journal TYPE option<string>;
DEFINE FIELD OVERWRITE causation_id ON TABLE runtime_event_journal TYPE option<string>;
DEFINE FIELD OVERWRITE payload ON TABLE runtime_event_journal TYPE object FLEXIBLE;
DEFINE FIELD OVERWRITE created_at ON TABLE runtime_event_journal TYPE datetime DEFAULT time::now();

