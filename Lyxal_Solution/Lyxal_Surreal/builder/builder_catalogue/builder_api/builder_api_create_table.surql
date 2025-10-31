DEFINE FUNCTION IF NOT EXISTS fn::builder_api_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table builder_api', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS builder_api TYPE NORMAL SCHEMAFULL
COMMENT 'Catalogue : métadonnées des APIs (DEFINE API) rattachées à un module'
PERMISSIONS
    FOR SELECT WHERE $auth.permissions CONTAINS 'system'
    FOR CREATE WHERE $auth.permissions CONTAINS 'system'
    FOR UPDATE WHERE $auth.permissions CONTAINS 'system'
    FOR DELETE WHERE $auth.permissions CONTAINS 'system';

-- ------------------------------
-- FIELDS
-- ------------------------------

DEFINE FIELD api_name ON builder_api TYPE string
COMMENT 'Nom de l\'API (minuscule, underscores conservés)';

DEFINE FIELD api_code ON builder_api TYPE string
COMMENT 'Code unique de l\'API (api_<api_name>)';

DEFINE FIELD description ON builder_api TYPE string
COMMENT 'Description de l\'API (brève)';

DEFINE FIELD module_id ON builder_api TYPE record<builder_module>
COMMENT 'Module parent';

DEFINE FIELD spec ON builder_api TYPE option<object>
COMMENT 'Spécification de l\'API';

DEFINE FIELD personnal_tag ON builder_api TYPE record<system_tag>
COMMENT 'Tag personnalisé pour l\'API';

DEFINE FIELD tags ON builder_api TYPE array<record<system_tag>> DEFAULT []
COMMENT 'Tags de classification de l\'API';

DEFINE FIELD version ON builder_api TYPE string DEFAULT '1.0.0'
COMMENT 'Version de l\'API.';

DEFINE FIELD metadata ON builder_api TYPE object DEFAULT {}
COMMENT 'Données libres pour extension future (utilisé par l\'IA, le builder, ou plugins).';

DEFINE FIELD created_at ON builder_api TYPE datetime DEFAULT time::now()
COMMENT 'Date de création de l\'API.';

DEFINE FIELD updated_at ON builder_api TYPE datetime DEFAULT time::now()
COMMENT 'Date de dernière modification de l\'API.';

-- ------------------------------
-- INDEXES
-- ------------------------------

DEFINE INDEX idx_builder_api_module_id     ON builder_api FIELDS module_id;
DEFINE INDEX idx_builder_api_code          ON builder_api FIELDS api_code UNIQUE;
DEFINE INDEX idx_builder_api_name          ON builder_api FIELDS api_name UNIQUE;
DEFINE INDEX idx_builder_api_tags          ON builder_api FIELDS tags;
DEFINE INDEX idx_builder_api_updated_at    ON builder_api FIELDS updated_at;

-- Enregistrer la table dans builder_table
LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_builder_api' LIMIT 1)[0];
IF $sm == NONE {
  LET $err = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_failure'], 'Erreur: sous-module builder_api introuvable pour builder_table', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: false, run_id: $run_id };
};
LET $t_rec = fn::builder_table_create_record('builder_api', $sm.id, "Table des APIs (DEFINE API) rattachées aux modules", true, true, true, $phase, ['module_builder'], $run_id);
IF $t_rec.success != true {
  LET $err2 = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_failure'], 'Erreur: enregistrement builder_table pour builder_api', { run_id: $run_id, parent_run_id: $parent_run_id, result: $t_rec });
  RETURN { success: false, run_id: $run_id };
};

-- Référencer la fonction dans builder_function
LET $f_rec = fn::builder_function_create_record('builder_api_create_table_initialise', $sm.id, 'Initialise la création de la table builder_api', true, true, true, 'deploy', NONE, $phase, ['module_builder'], $run_id);
IF $f_rec.success != true {
  LET $err3 = fn::system_log_create_record([$phase, 'log_function', 'log_create', 'log_done', 'log_failure'], 'Erreur: enregistrement builder_function pour builder_api_create_table_initialise', { run_id: $run_id, parent_run_id: $parent_run_id, result: $f_rec });
  RETURN { success: false, run_id: $run_id };
};

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création de la table builder_api', { run_id: $run_id, parent_run_id: $parent_run_id, table: 'builder_api' });
RETURN { success: true, run_id: $run_id };
}
COMMENT "Crée la table builder_api dans la base de données"
PERMISSIONS FULL;





