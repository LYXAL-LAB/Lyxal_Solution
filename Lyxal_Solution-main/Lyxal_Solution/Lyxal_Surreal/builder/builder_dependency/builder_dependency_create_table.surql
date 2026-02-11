DEFINE FUNCTION IF NOT EXISTS fn::builder_dependency_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table builder_dependency', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS builder_dependency TYPE NORMAL SCHEMAFULL
COMMENT 'Catalogue : dépendances entre entités builder via arêtes et références'
PERMISSIONS FULL;

-- ------------------------------
-- FIELDS
-- ------------------------------

DEFINE FIELD dependency_name ON builder_dependency TYPE string
COMMENT 'Nom de la dépendance (minuscule, underscores conservés)';

DEFINE FIELD dependency_code ON builder_dependency TYPE string
COMMENT 'Code unique de la dépendance (dependency_<name>)';

DEFINE FIELD description ON builder_dependency TYPE string
COMMENT 'Description de la dépendance';

DEFINE FIELD sub_module_id ON builder_dependency TYPE record<builder_sub_module>
COMMENT 'Sous-module parent';

DEFINE FIELD owner_id ON builder_dependency TYPE option<record<any>>
COMMENT 'Propriétaire de l\'entrée (ex: sous-module ou autre ressource)';

DEFINE FIELD spec ON builder_dependency TYPE option<object>
COMMENT 'Spécification/contrat de dépendance (types, contraintes, etc.)';

DEFINE FIELD personnal_tag ON builder_dependency TYPE record<system_tag>
COMMENT 'Tag personnalisé pour la dépendance';

DEFINE FIELD tags ON builder_dependency TYPE array<record<system_tag>> DEFAULT []
COMMENT 'Tags de classification de la dépendance';

DEFINE FIELD version ON builder_dependency TYPE string DEFAULT '1.0.0'
COMMENT 'Version';

DEFINE FIELD metadata ON builder_dependency TYPE object DEFAULT {}
COMMENT 'Données libres';

DEFINE FIELD created_at ON builder_dependency TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON builder_dependency TYPE datetime DEFAULT time::now();

-- ------------------------------
-- INDEXES
-- ------------------------------

DEFINE INDEX idx_builder_dependency_sub_module_id ON builder_dependency FIELDS sub_module_id;
DEFINE INDEX idx_builder_dependency_owner_id      ON builder_dependency FIELDS owner_id;
DEFINE INDEX idx_builder_dependency_code          ON builder_dependency FIELDS dependency_code UNIQUE;
DEFINE INDEX idx_builder_dependency_name          ON builder_dependency FIELDS dependency_name UNIQUE;
DEFINE INDEX idx_builder_dependency_tags          ON builder_dependency FIELDS tags;
DEFINE INDEX idx_builder_dependency_updated_at    ON builder_dependency FIELDS updated_at;

-- Enregistrer la table dans builder_table
LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_builder_dependency' LIMIT 1)[0];
IF $sm == NONE {
  LET $err = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_failure'], 'Erreur: sous-module builder_dependency introuvable pour builder_table', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: false, run_id: $run_id };
};
LET $t_rec = fn::builder_table_create_record('builder_dependency', $sm.id, 'Table des dépendances entre entités builder', true, true, true, $phase, ['module_builder'], $run_id);
IF $t_rec.success != true {
  LET $err2 = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_failure'], 'Erreur: enregistrement builder_table pour builder_dependency', { run_id: $run_id, parent_run_id: $parent_run_id, result: $t_rec });
  RETURN { success: false, run_id: $run_id };
};

-- Référencer la fonction dans builder_function
LET $f_rec = fn::builder_function_create_record('builder_dependency_create_table_initialise', $sm.id, 'Initialise la création de la table builder_dependency', true, true, true, 'deploy', NONE, $phase, ['module_builder'], $run_id);
IF $f_rec.success != true {
  LET $err3 = fn::system_log_create_record([$phase, 'log_function', 'log_create', 'log_done', 'log_failure'], 'Erreur: enregistrement builder_function pour builder_dependency_create_table_initialise', { run_id: $run_id, parent_run_id: $parent_run_id, result: $f_rec });
  RETURN { success: false, run_id: $run_id };
};

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création de la table builder_dependency', { run_id: $run_id, parent_run_id: $parent_run_id, table: 'builder_dependency' });
RETURN { success: true, run_id: $run_id };
}
COMMENT "Crée la table builder_dependency dans la base de données"
PERMISSIONS FULL;


