DEFINE FUNCTION IF NOT EXISTS fn::builder_bucket_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table builder_bucket', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS builder_bucket TYPE NORMAL SCHEMAFULL
COMMENT 'Catalogue : métadonnées des buckets (DEFINE BUCKET) rattachés à un module'
PERMISSIONS
    FOR SELECT WHERE $auth.permissions CONTAINS 'system'
    FOR CREATE WHERE $auth.permissions CONTAINS 'system'
    FOR UPDATE WHERE $auth.permissions CONTAINS 'system'
    FOR DELETE WHERE $auth.permissions CONTAINS 'system';

-- ------------------------------
-- FIELDS
-- ------------------------------

DEFINE FIELD bucket_name ON builder_bucket TYPE string
COMMENT 'Nom du bucket (minuscule, underscores conservés)';

DEFINE FIELD bucket_code ON builder_bucket TYPE string
COMMENT 'Code unique du bucket (bucket_<bucket_name>)';

DEFINE FIELD description ON builder_bucket TYPE string
COMMENT 'Description du bucket (brève)';

DEFINE FIELD module_id ON builder_bucket TYPE record<builder_module>
COMMENT 'Module parent (les buckets sont globaux par module)';

DEFINE FIELD spec ON builder_bucket TYPE option<object>
COMMENT 'Spécification du bucket (driver, ttl, size, etc.)';

DEFINE FIELD personnal_tag ON builder_bucket TYPE record<system_tag>
COMMENT 'Tag personnalisé pour le bucket';

DEFINE FIELD tags ON builder_bucket TYPE array<record<system_tag>> DEFAULT []
COMMENT 'Tags de classification du bucket';

DEFINE FIELD version ON builder_bucket TYPE string DEFAULT '1.0.0'
COMMENT 'Version du bucket.';

DEFINE FIELD metadata ON builder_bucket TYPE object DEFAULT {}
COMMENT 'Données libres pour extension future (utilisé par l\'IA, le builder, ou plugins).';

DEFINE FIELD created_at ON builder_bucket TYPE datetime DEFAULT time::now()
COMMENT 'Date de création du bucket.';

DEFINE FIELD updated_at ON builder_bucket TYPE datetime DEFAULT time::now()
COMMENT 'Date de dernière modification du bucket.';

-- ------------------------------
-- INDEXES
-- ------------------------------

DEFINE INDEX idx_builder_bucket_module_id     ON builder_bucket FIELDS module_id;
DEFINE INDEX idx_builder_bucket_code          ON builder_bucket FIELDS bucket_code UNIQUE;
DEFINE INDEX idx_builder_bucket_name          ON builder_bucket FIELDS bucket_name UNIQUE;
DEFINE INDEX idx_builder_bucket_tags          ON builder_bucket FIELDS tags;
DEFINE INDEX idx_builder_bucket_updated_at    ON builder_bucket FIELDS updated_at;

-- Enregistrer la table dans builder_table
LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_builder_bucket' LIMIT 1)[0];
IF $sm == NONE {
  LET $err = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_failure'], 'Erreur: sous-module builder_bucket introuvable pour builder_table', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: false, run_id: $run_id };
};
LET $t_rec = fn::builder_table_create_record('builder_bucket', $sm.id, 'Table des buckets (DEFINE BUCKET) rattachés aux modules', true, true, true, $phase, ['module_builder'], $run_id);
IF $t_rec.success != true {
  LET $err2 = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_failure'], 'Erreur: enregistrement builder_table pour builder_bucket', { run_id: $run_id, parent_run_id: $parent_run_id, result: $t_rec });
  RETURN { success: false, run_id: $run_id };
};

-- Référencer la fonction dans builder_function
LET $f_rec = fn::builder_function_create_record('builder_bucket_create_table_initialise', $sm.id, 'Initialise la création de la table builder_bucket', true, true, true, 'deploy', NONE, $phase, ['module_builder'], $run_id);
IF $f_rec.success != true {
  LET $err3 = fn::system_log_create_record([$phase, 'log_function', 'log_create', 'log_done', 'log_failure'], 'Erreur: enregistrement builder_function pour builder_bucket_create_table_initialise', { run_id: $run_id, parent_run_id: $parent_run_id, result: $f_rec });
  RETURN { success: false, run_id: $run_id };
};

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création de la table builder_bucket', { run_id: $run_id, parent_run_id: $parent_run_id, table: 'builder_bucket' });
RETURN { success: true, run_id: $run_id };
}
COMMENT "Crée la table builder_bucket dans la base de données"
PERMISSIONS FULL;

