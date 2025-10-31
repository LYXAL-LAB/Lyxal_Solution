DEFINE FUNCTION IF NOT EXISTS fn::builder_analyzer_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table builder_analyzer', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS builder_analyzer TYPE NORMAL SCHEMAFULL
COMMENT 'Catalogue : métadonnées des analyzers (DEFINE ANALYZER) rattachés à un sous-module'
PERMISSIONS
    FOR SELECT WHERE $auth.permissions CONTAINS 'system'
    FOR CREATE WHERE $auth.permissions CONTAINS 'system'
    FOR UPDATE WHERE $auth.permissions CONTAINS 'system'
    FOR DELETE WHERE $auth.permissions CONTAINS 'system';

-- ------------------------------
-- FIELDS
-- ------------------------------

DEFINE FIELD analyzer_name ON builder_analyzer TYPE string
COMMENT 'Nom de l\'analyzer (minuscule, underscores conservés)';

DEFINE FIELD analyzer_code ON builder_analyzer TYPE string
COMMENT 'Code unique de l\'analyzer (analyzer_<analyzer_name>)';

DEFINE FIELD description ON builder_analyzer TYPE string
COMMENT 'Description de l\'analyzer (brève)';

DEFINE FIELD sub_module_id ON builder_analyzer TYPE record<builder_sub_module>
COMMENT 'Sous-module parent';

-- Spécification technique optionnelle (configuration du DEFINE ANALYZER)
DEFINE FIELD spec ON builder_analyzer TYPE option<object>
COMMENT 'Spécification de configuration (tokenizers, filters, locale, etc.)';

DEFINE FIELD personnal_tag ON builder_analyzer TYPE record<system_tag>
COMMENT 'Tag personnalisé pour l\'analyzer';

DEFINE FIELD tags ON builder_analyzer TYPE array<record<system_tag>> DEFAULT []
COMMENT 'Tags de classification de l\'analyzer';

DEFINE FIELD version ON builder_analyzer TYPE string DEFAULT '1.0.0'
COMMENT 'Version de l\'analyzer.';

DEFINE FIELD metadata ON builder_analyzer TYPE object DEFAULT {}
COMMENT 'Données libres pour extension future (utilisé par l\'IA, le builder, ou plugins).';

DEFINE FIELD created_at ON builder_analyzer TYPE datetime DEFAULT time::now()
COMMENT 'Date de création de l\'analyzer.';

DEFINE FIELD updated_at ON builder_analyzer TYPE datetime DEFAULT time::now()
COMMENT 'Date de dernière modification de l\'analyzer.';

-- ------------------------------
-- INDEXES
-- ------------------------------

DEFINE INDEX idx_builder_analyzer_sub_module_id   ON builder_analyzer FIELDS sub_module_id;
DEFINE INDEX idx_builder_analyzer_code            ON builder_analyzer FIELDS analyzer_code UNIQUE;
DEFINE INDEX idx_builder_analyzer_name            ON builder_analyzer FIELDS analyzer_name UNIQUE;
DEFINE INDEX idx_builder_analyzer_tags            ON builder_analyzer FIELDS tags;
DEFINE INDEX idx_builder_analyzer_updated_at      ON builder_analyzer FIELDS updated_at;

-- Enregistrer la table dans builder_table
LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_builder_analyzer' LIMIT 1)[0];
IF $sm == NONE {
  LET $err = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_failure'], 'Erreur: sous-module builder_analyzer introuvable pour builder_table', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: false, run_id: $run_id };
};
LET $t_rec = fn::builder_table_create_record('builder_analyzer', $sm.id, 'Table des analyzers (DEFINE ANALYZER) rattachés aux sous-modules', true, true, true, $phase, ['module_builder'], $run_id);
IF $t_rec.success != true {
  LET $err2 = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_failure'], 'Erreur: enregistrement builder_table pour builder_analyzer', { run_id: $run_id, parent_run_id: $parent_run_id, result: $t_rec });
  RETURN { success: false, run_id: $run_id };
};

-- Référencer la fonction dans builder_function
LET $f_rec = fn::builder_function_create_record('builder_analyzer_create_table_initialise', $sm.id, 'Initialise la création de la table builder_analyzer', true, true, true, 'deploy', NONE, $phase, ['module_builder'], $run_id);
IF $f_rec.success != true {
  LET $err3 = fn::system_log_create_record([$phase, 'log_function', 'log_create', 'log_done', 'log_failure'], 'Erreur: enregistrement builder_function pour builder_analyzer_create_table_initialise', { run_id: $run_id, parent_run_id: $parent_run_id, result: $f_rec });
  RETURN { success: false, run_id: $run_id };
};

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création de la table builder_analyzer', { run_id: $run_id, parent_run_id: $parent_run_id, table: 'builder_analyzer' });
RETURN { success: true, run_id: $run_id };
}
COMMENT "Crée la table builder_analyzer dans la base de données"
PERMISSIONS FULL;





