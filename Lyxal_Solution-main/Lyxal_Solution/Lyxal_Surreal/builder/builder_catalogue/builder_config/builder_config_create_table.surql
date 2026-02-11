DEFINE FUNCTION IF NOT EXISTS fn::builder_config_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table builder_config', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS builder_config TYPE NORMAL SCHEMAFULL
COMMENT 'Catalogue : métadonnées des configurations (config) rattachées à un module'
PERMISSIONS
    FOR SELECT WHERE $auth.permissions CONTAINS 'system'
    FOR CREATE WHERE $auth.permissions CONTAINS 'system'
    FOR UPDATE WHERE $auth.permissions CONTAINS 'system'
    FOR DELETE WHERE $auth.permissions CONTAINS 'system';

-- ------------------------------
-- FIELDS
-- ------------------------------

DEFINE FIELD config_name ON builder_config TYPE string
COMMENT 'Nom de la config (minuscule, underscores conservés)';

DEFINE FIELD config_code ON builder_config TYPE string
COMMENT 'Code unique de la config (config_<config_name>)';

DEFINE FIELD description ON builder_config TYPE string
COMMENT 'Description de la config (brève)';

DEFINE FIELD module_id ON builder_config TYPE record<builder_module>
COMMENT 'Module parent';

DEFINE FIELD spec ON builder_config TYPE option<object>
COMMENT 'Spécification de la config';

DEFINE FIELD personnal_tag ON builder_config TYPE record<system_tag>
COMMENT 'Tag personnalisé pour la config';

DEFINE FIELD tags ON builder_config TYPE array<record<system_tag>> DEFAULT []
COMMENT 'Tags de classification de la config';

DEFINE FIELD version ON builder_config TYPE string DEFAULT '1.0.0'
COMMENT 'Version de la config.';

DEFINE FIELD metadata ON builder_config TYPE object DEFAULT {}
COMMENT 'Données libres pour extension future (utilisé par l\'IA, le builder, ou plugins).';

DEFINE FIELD created_at ON builder_config TYPE datetime DEFAULT time::now()
COMMENT 'Date de création de la config.';

DEFINE FIELD updated_at ON builder_config TYPE datetime DEFAULT time::now()
COMMENT 'Date de dernière modification de la config.';

-- ------------------------------
-- INDEXES
-- ------------------------------

DEFINE INDEX idx_builder_config_module_id  ON builder_config FIELDS module_id;
DEFINE INDEX idx_builder_config_code       ON builder_config FIELDS config_code UNIQUE;
DEFINE INDEX idx_builder_config_name       ON builder_config FIELDS config_name UNIQUE;
DEFINE INDEX idx_builder_config_tags       ON builder_config FIELDS tags;
DEFINE INDEX idx_builder_config_updated_at ON builder_config FIELDS updated_at;

-- Enregistrer la table dans builder_table
LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_builder_config' LIMIT 1)[0];
IF $sm == NONE {
  LET $err = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_failure'], 'Erreur: sous-module builder_config introuvable pour builder_table', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: false, run_id: $run_id };
};
LET $t_rec = fn::builder_table_create_record('builder_config', $sm.id, 'Table des configurations rattachées aux modules', true, true, true, $phase, ['module_builder'], $run_id);
IF $t_rec.success != true {
  LET $err2 = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_failure'], 'Erreur: enregistrement builder_table pour builder_config', { run_id: $run_id, parent_run_id: $parent_run_id, result: $t_rec });
  RETURN { success: false, run_id: $run_id };
};

-- Référencer la fonction dans builder_function
LET $f_rec = fn::builder_function_create_record('builder_config_create_table_initialise', $sm.id, 'Initialise la création de la table builder_config', true, true, true, 'deploy', NONE, $phase, ['module_builder'], $run_id);
IF $f_rec.success != true {
  LET $err3 = fn::system_log_create_record([$phase, 'log_function', 'log_create', 'log_done', 'log_failure'], 'Erreur: enregistrement builder_function pour builder_config_create_table_initialise', { run_id: $run_id, parent_run_id: $parent_run_id, result: $f_rec });
  RETURN { success: false, run_id: $run_id };
};

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création de la table builder_config', { run_id: $run_id, parent_run_id: $parent_run_id, table: 'builder_config' });
RETURN { success: true, run_id: $run_id };
}
COMMENT "Crée la table builder_config dans la base de données"
PERMISSIONS FULL;
