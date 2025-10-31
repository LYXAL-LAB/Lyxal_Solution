DEFINE FUNCTION IF NOT EXISTS fn::builder_event_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table builder_event', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS builder_event TYPE NORMAL SCHEMAFULL
COMMENT 'Catalogue : métadonnées des events (DEFINE EVENT) rattachés à une table'
PERMISSIONS
    FOR SELECT WHERE $auth.permissions CONTAINS 'system'
    FOR CREATE WHERE $auth.permissions CONTAINS 'system'
    FOR UPDATE WHERE $auth.permissions CONTAINS 'system'
    FOR DELETE WHERE $auth.permissions CONTAINS 'system';

-- ------------------------------
-- FIELDS
-- ------------------------------

DEFINE FIELD event_name ON builder_event TYPE string
COMMENT 'Nom de l\'event (minuscule, underscores conservés)';

DEFINE FIELD event_code ON builder_event TYPE string
COMMENT 'Code unique de l\'event (event_<event_name>)';

DEFINE FIELD description ON builder_event TYPE string
COMMENT 'Description de l\'event (brève)';

DEFINE FIELD table_id ON builder_event TYPE record<builder_table>
COMMENT 'Table parente';

DEFINE FIELD spec ON builder_event TYPE option<object>
COMMENT 'Spécification de l\'event (conditions, statements, etc.)';

DEFINE FIELD personnal_tag ON builder_event TYPE record<system_tag>
COMMENT 'Tag personnalisé pour l\'event';

DEFINE FIELD tags ON builder_event TYPE array<record<system_tag>> DEFAULT []
COMMENT 'Tags de classification de l\'event';

DEFINE FIELD version ON builder_event TYPE string DEFAULT '1.0.0'
COMMENT 'Version de l\'event.';

DEFINE FIELD metadata ON builder_event TYPE object DEFAULT {}
COMMENT 'Données libres pour extension future (utilisé par l\'IA, le builder, ou plugins).';

DEFINE FIELD created_at ON builder_event TYPE datetime DEFAULT time::now()
COMMENT 'Date de création de l\'event.';

DEFINE FIELD updated_at ON builder_event TYPE datetime DEFAULT time::now()
COMMENT 'Date de dernière modification de l\'event.';

-- ------------------------------
-- INDEXES
-- ------------------------------

DEFINE INDEX idx_builder_event_table_id     ON builder_event FIELDS table_id;
DEFINE INDEX idx_builder_event_code         ON builder_event FIELDS event_code UNIQUE;
DEFINE INDEX idx_builder_event_name         ON builder_event FIELDS event_name UNIQUE;
DEFINE INDEX idx_builder_event_tags         ON builder_event FIELDS tags;
DEFINE INDEX idx_builder_event_updated_at   ON builder_event FIELDS updated_at;

-- Enregistrer la table dans builder_table
LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_builder_event' LIMIT 1)[0];
IF $sm == NONE {
  LET $err = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_failure'], 'Erreur: sous-module builder_event introuvable pour builder_table', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: false, run_id: $run_id };
};
LET $t_rec = fn::builder_table_create_record('builder_event', $sm.id, 'Table des events (DEFINE EVENT) rattachés aux tables', true, true, true, $phase, ['module_builder'], $run_id);
IF $t_rec.success != true {
  LET $err2 = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_failure'], 'Erreur: enregistrement builder_table pour builder_event', { run_id: $run_id, parent_run_id: $parent_run_id, result: $t_rec });
  RETURN { success: false, run_id: $run_id };
};

-- Référencer la fonction dans builder_function
LET $f_rec = fn::builder_function_create_record('builder_event_create_table_initialise', $sm.id, 'Initialise la création de la table builder_event', true, true, true, 'deploy', NONE, $phase, ['module_builder'], $run_id);
IF $f_rec.success != true {
  LET $err3 = fn::system_log_create_record([$phase, 'log_function', 'log_create', 'log_done', 'log_failure'], 'Erreur: enregistrement builder_function pour builder_event_create_table_initialise', { run_id: $run_id, parent_run_id: $parent_run_id, result: $f_rec });
  RETURN { success: false, run_id: $run_id };
};

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création de la table builder_event', { run_id: $run_id, parent_run_id: $parent_run_id, table: 'builder_event' });
RETURN { success: true, run_id: $run_id };
}
COMMENT "Crée la table builder_event dans la base de données"
PERMISSIONS FULL;

