DEFINE FUNCTION IF NOT EXISTS fn::builder_param_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table builder_param', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS builder_param TYPE NORMAL SCHEMAFULL
COMMENT 'Catalogue : métadonnées des paramètres (paramètres de sous-modules)'
PERMISSIONS
    FOR SELECT WHERE $auth.permissions CONTAINS 'system'
    FOR CREATE WHERE $auth.permissions CONTAINS 'system'
    FOR UPDATE WHERE $auth.permissions CONTAINS 'system'
    FOR DELETE WHERE $auth.permissions CONTAINS 'system';

-- ------------------------------
-- FIELDS
-- ------------------------------

DEFINE FIELD param_name ON builder_param TYPE string
COMMENT 'Nom du param (minuscule, underscores conservés)';

DEFINE FIELD param_code ON builder_param TYPE string
COMMENT 'Code unique du param (param_<param_name>)';

DEFINE FIELD description ON builder_param TYPE string
COMMENT 'Description du param (brève)';

DEFINE FIELD sub_module_id ON builder_param TYPE record<builder_sub_module>
COMMENT 'Sous-module parent';

DEFINE FIELD spec ON builder_param TYPE option<object>
COMMENT 'Spécification du paramètre (clé/valeur, types, etc.)';

DEFINE FIELD personnal_tag ON builder_param TYPE record<system_tag>
COMMENT 'Tag personnalisé pour le param';

DEFINE FIELD tags ON builder_param TYPE array<record<system_tag>> DEFAULT []
COMMENT 'Tags de classification du param';

DEFINE FIELD version ON builder_param TYPE string DEFAULT '1.0.0'
COMMENT 'Version du param.';

DEFINE FIELD metadata ON builder_param TYPE object DEFAULT {}
COMMENT 'Données libres pour extension future (utilisé par l\'IA, le builder, ou plugins).';

DEFINE FIELD created_at ON builder_param TYPE datetime DEFAULT time::now()
COMMENT 'Date de création du param.';

DEFINE FIELD updated_at ON builder_param TYPE datetime DEFAULT time::now()
COMMENT 'Date de dernière modification du param.';

-- ------------------------------
-- INDEXES
-- ------------------------------

DEFINE INDEX idx_builder_param_sub_module_id ON builder_param FIELDS sub_module_id;
DEFINE INDEX idx_builder_param_code          ON builder_param FIELDS param_code UNIQUE;
DEFINE INDEX idx_builder_param_name          ON builder_param FIELDS param_name UNIQUE;
DEFINE INDEX idx_builder_param_tags          ON builder_param FIELDS tags;
DEFINE INDEX idx_builder_param_updated_at    ON builder_param FIELDS updated_at;

-- Enregistrer la table dans builder_table
LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_builder_param' LIMIT 1)[0];
IF $sm == NONE {
  LET $err = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_failure'], 'Erreur: sous-module builder_param introuvable pour builder_table', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: false, run_id: $run_id };
};
LET $t_rec = fn::builder_table_create_record('builder_param', $sm.id, 'Table des paramètres rattachés aux sous-modules', true, true, true, $phase, ['module_builder'], $run_id);
IF $t_rec.success != true {
  LET $err2 = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_failure'], 'Erreur: enregistrement builder_table pour builder_param', { run_id: $run_id, parent_run_id: $parent_run_id, result: $t_rec });
  RETURN { success: false, run_id: $run_id };
};

-- Référencer la fonction dans builder_function
LET $f_rec = fn::builder_function_create_record('builder_param_create_table_initialise', $sm.id, 'Initialise la création de la table builder_param', true, true, true, 'deploy', NONE, $phase, ['module_builder'], $run_id);
IF $f_rec.success != true {
  LET $err3 = fn::system_log_create_record([$phase, 'log_function', 'log_create', 'log_done', 'log_failure'], 'Erreur: enregistrement builder_function pour builder_param_create_table_initialise', { run_id: $run_id, parent_run_id: $parent_run_id, result: $f_rec });
  RETURN { success: false, run_id: $run_id };
};

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création de la table builder_param', { run_id: $run_id, parent_run_id: $parent_run_id, table: 'builder_param' });
RETURN { success: true, run_id: $run_id };
}
COMMENT "Crée la table builder_param dans la base de données"
PERMISSIONS FULL;
