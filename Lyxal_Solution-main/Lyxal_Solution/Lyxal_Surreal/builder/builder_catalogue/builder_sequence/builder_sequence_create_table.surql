DEFINE FUNCTION IF NOT EXISTS fn::builder_sequence_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table builder_sequence', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS builder_sequence TYPE NORMAL SCHEMAFULL
COMMENT 'Catalogue : métadonnées des sequences (DEFINE SEQUENCE) rattachées à une table'
PERMISSIONS
    FOR SELECT WHERE $auth.permissions CONTAINS 'system'
    FOR CREATE WHERE $auth.permissions CONTAINS 'system'
    FOR UPDATE WHERE $auth.permissions CONTAINS 'system'
    FOR DELETE WHERE $auth.permissions CONTAINS 'system';

-- ------------------------------
-- FIELDS
-- ------------------------------

DEFINE FIELD sequence_name ON builder_sequence TYPE string
COMMENT 'Nom de la sequence (minuscule, underscores conservés)';

DEFINE FIELD sequence_code ON builder_sequence TYPE string
COMMENT 'Code unique de la sequence (sequence_<sequence_name>)';

DEFINE FIELD description ON builder_sequence TYPE string
COMMENT 'Description de la sequence (brève)';

DEFINE FIELD table_id ON builder_sequence TYPE record<builder_table>
COMMENT 'Table parente';

DEFINE FIELD spec ON builder_sequence TYPE option<object>
COMMENT 'Spécification de la sequence (start, step, cache, etc.)';

DEFINE FIELD personnal_tag ON builder_sequence TYPE record<system_tag>
COMMENT 'Tag personnalisé pour la sequence';

DEFINE FIELD tags ON builder_sequence TYPE array<record<system_tag>> DEFAULT []
COMMENT 'Tags de classification de la sequence';

DEFINE FIELD version ON builder_sequence TYPE string DEFAULT '1.0.0'
COMMENT 'Version de la sequence.';

DEFINE FIELD metadata ON builder_sequence TYPE object DEFAULT {}
COMMENT 'Données libres pour extension future (utilisé par l\'IA, le builder, ou plugins).';

DEFINE FIELD created_at ON builder_sequence TYPE datetime DEFAULT time::now()
COMMENT 'Date de création de la sequence.';

DEFINE FIELD updated_at ON builder_sequence TYPE datetime DEFAULT time::now()
COMMENT 'Date de dernière modification de la sequence.';

-- ------------------------------
-- INDEXES
-- ------------------------------

DEFINE INDEX idx_builder_sequence_table_id     ON builder_sequence FIELDS table_id;
DEFINE INDEX idx_builder_sequence_code         ON builder_sequence FIELDS sequence_code UNIQUE;
DEFINE INDEX idx_builder_sequence_name         ON builder_sequence FIELDS sequence_name UNIQUE;
DEFINE INDEX idx_builder_sequence_tags         ON builder_sequence FIELDS tags;
DEFINE INDEX idx_builder_sequence_updated_at   ON builder_sequence FIELDS updated_at;

-- Enregistrer la table dans builder_table
LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_builder_sequence' LIMIT 1)[0];
IF $sm == NONE {
  LET $err = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_failure'], 'Erreur: sous-module builder_sequence introuvable pour builder_table', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: false, run_id: $run_id };
};
LET $t_rec = fn::builder_table_create_record('builder_sequence', $sm.id, 'Table des sequences (DEFINE SEQUENCE) rattachées aux tables', true, true, true, $phase, ['module_builder'], $run_id);
IF $t_rec.success != true {
  LET $err2 = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_failure'], 'Erreur: enregistrement builder_table pour builder_sequence', { run_id: $run_id, parent_run_id: $parent_run_id, result: $t_rec });
  RETURN { success: false, run_id: $run_id };
};

-- Référencer la fonction dans builder_function
LET $f_rec = fn::builder_function_create_record('builder_sequence_create_table_initialise', $sm.id, 'Initialise la création de la table builder_sequence', true, true, true, 'deploy', NONE, $phase, ['module_builder'], $run_id);
IF $f_rec.success != true {
  LET $err3 = fn::system_log_create_record([$phase, 'log_function', 'log_create', 'log_done', 'log_failure'], 'Erreur: enregistrement builder_function pour builder_sequence_create_table_initialise', { run_id: $run_id, parent_run_id: $parent_run_id, result: $f_rec });
  RETURN { success: false, run_id: $run_id };
};

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création de la table builder_sequence', { run_id: $run_id, parent_run_id: $parent_run_id, table: 'builder_sequence' });
RETURN { success: true, run_id: $run_id };
}
COMMENT "Crée la table builder_sequence dans la base de données"
PERMISSIONS FULL;

