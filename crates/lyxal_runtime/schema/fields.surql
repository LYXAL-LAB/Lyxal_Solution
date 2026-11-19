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
DEFINE FIELD OVERWRITE checksum ON TABLE runtime_migration TYPE string;
DEFINE FIELD OVERWRITE status ON TABLE runtime_migration TYPE string ASSERT $value IN ["Pending", "Applying", "Applied", "Failed", "RolledBack", "Skipped", "RetryRequested", "Abandoned"];
DEFINE FIELD OVERWRITE applied_at ON TABLE runtime_migration TYPE option<int>;
DEFINE FIELD OVERWRITE duration_ms ON TABLE runtime_migration TYPE option<int>;
DEFINE FIELD OVERWRITE error ON TABLE runtime_migration TYPE option<string>;
-- Script de la migration (chemin déclaré au manifeste), nœud qui a écrit le dernier état et
-- début de la dernière exécution : ce qu'il faut pour reprendre une migration interrompue
DEFINE FIELD OVERWRITE script ON TABLE runtime_migration TYPE option<string>;
DEFINE FIELD OVERWRITE node_id ON TABLE runtime_migration TYPE option<string>;
DEFINE FIELD OVERWRITE started_at ON TABLE runtime_migration TYPE option<datetime>;
-- Dernière décision d'exploitation sur une migration interrompue (fn::runtime_migration_resolve)
DEFINE FIELD OVERWRITE resolution ON TABLE runtime_migration TYPE option<object>;
DEFINE FIELD OVERWRITE resolution.action ON TABLE runtime_migration TYPE string ASSERT $value IN ["retry", "abandon"];
DEFINE FIELD OVERWRITE resolution.actor ON TABLE runtime_migration TYPE string;
DEFINE FIELD OVERWRITE resolution.reason ON TABLE runtime_migration TYPE string;
DEFINE FIELD OVERWRITE resolution.node_id ON TABLE runtime_migration TYPE string;
DEFINE FIELD OVERWRITE resolution.at ON TABLE runtime_migration TYPE datetime;
DEFINE FIELD OVERWRITE created_at ON TABLE runtime_migration TYPE datetime DEFAULT time::now() READONLY;
DEFINE FIELD OVERWRITE updated_at ON TABLE runtime_migration TYPE datetime DEFAULT time::now();

-- Champs pour runtime_lease (instants en secondes Unix, heure de la base)
DEFINE FIELD OVERWRITE kind ON TABLE runtime_lease TYPE string ASSERT $value IN ["migration", "installation", "leader"];
DEFINE FIELD OVERWRITE key ON TABLE runtime_lease TYPE string;
DEFINE FIELD OVERWRITE owner_node_id ON TABLE runtime_lease TYPE string;
DEFINE FIELD OVERWRITE generation ON TABLE runtime_lease TYPE int;
DEFINE FIELD OVERWRITE is_released ON TABLE runtime_lease TYPE bool;
DEFINE FIELD OVERWRITE acquired_at ON TABLE runtime_lease TYPE int;
DEFINE FIELD OVERWRITE renewed_at ON TABLE runtime_lease TYPE int;
DEFINE FIELD OVERWRITE expires_at ON TABLE runtime_lease TYPE int;
DEFINE FIELD OVERWRITE released_at ON TABLE runtime_lease TYPE option<int>;
DEFINE FIELD OVERWRITE updated_at ON TABLE runtime_lease TYPE datetime DEFAULT time::now();

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

-- Champs pour runtime_node (identifiant runtime_node:<node_id>)
DEFINE FIELD OVERWRITE node_id ON TABLE runtime_node TYPE string;
-- Hôte : rôle du binaire, le même pour toutes ses copies (format d'un identifiant de module)
DEFINE FIELD OVERWRITE host ON TABLE runtime_node TYPE string ASSERT string::matches($value, "^[a-z][a-z0-9_]{0,63}$");
-- Modules enregistrés dans le runtime de ce nœud
DEFINE FIELD OVERWRITE modules ON TABLE runtime_node TYPE array<string>;
-- Empreinte du socle embarqué par le binaire de ce nœud (NONE : nœud démarré sans socle déclaré)
DEFINE FIELD OVERWRITE foundation_checksum ON TABLE runtime_node TYPE option<string>;
-- Dates écrites par fn::runtime_node_upsert, à l'heure de la base : premier et dernier battement
DEFINE FIELD OVERWRITE started_at ON TABLE runtime_node TYPE datetime;
DEFINE FIELD OVERWRITE seen_at ON TABLE runtime_node TYPE datetime;

-- Champs pour runtime_foundation (enregistrement unique runtime_foundation:current)
DEFINE FIELD OVERWRITE checksum ON TABLE runtime_foundation TYPE string;
DEFINE FIELD OVERWRITE host ON TABLE runtime_foundation TYPE string;
DEFINE FIELD OVERWRITE node_id ON TABLE runtime_foundation TYPE string;
DEFINE FIELD OVERWRITE installed_at ON TABLE runtime_foundation TYPE datetime;

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

