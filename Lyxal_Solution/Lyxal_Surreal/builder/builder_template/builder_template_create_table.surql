DEFINE FUNCTION IF NOT EXISTS fn::builder_template_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table builder_template', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS builder_template TYPE NORMAL SCHEMAFULL
COMMENT 'Catalogue : modèles/templates rattachés à un module (agrégations pour déploiements SaaS)'
PERMISSIONS
    FOR SELECT WHERE $auth.permissions CONTAINS 'system'
    FOR CREATE WHERE $auth.permissions CONTAINS 'system'
    FOR UPDATE WHERE $auth.permissions CONTAINS 'system'
    FOR DELETE WHERE $auth.permissions CONTAINS 'system';

-- ------------------------------
-- FIELDS
-- ------------------------------

DEFINE FIELD template_name ON builder_template TYPE string
COMMENT 'Nom du template (minuscule, underscores conservés)';

DEFINE FIELD template_code ON builder_template TYPE string
COMMENT 'Code unique du template (template_<template_name>)';

DEFINE FIELD description ON builder_template TYPE string
COMMENT 'Description du template (brève)';

DEFINE FIELD module_id ON builder_template TYPE record<builder_module>
COMMENT 'Module parent du template';

DEFINE FIELD spec ON builder_template TYPE option<object>
COMMENT 'Spécification/composition du template (liste d\'éléments, options)';

DEFINE FIELD personnal_tag ON builder_template TYPE record<system_tag>
COMMENT 'Tag personnalisé pour le template';

DEFINE FIELD tags ON builder_template TYPE array<record<system_tag>> DEFAULT []
COMMENT 'Tags de classification du template';

DEFINE FIELD version ON builder_template TYPE string DEFAULT '1.0.0'
COMMENT 'Version du template.';

DEFINE FIELD metadata ON builder_template TYPE object DEFAULT {}
COMMENT 'Données libres (IA, builder, plugins).';

DEFINE FIELD created_at ON builder_template TYPE datetime DEFAULT time::now()
COMMENT 'Date de création du template.';

DEFINE FIELD updated_at ON builder_template TYPE datetime DEFAULT time::now()
COMMENT 'Date de dernière modification du template.';

-- ------------------------------
-- INDEXES
-- ------------------------------

DEFINE INDEX idx_builder_template_module_id     ON builder_template FIELDS module_id;
DEFINE INDEX idx_builder_template_code          ON builder_template FIELDS template_code UNIQUE;
DEFINE INDEX idx_builder_template_name          ON builder_template FIELDS template_name UNIQUE;
DEFINE INDEX idx_builder_template_tags          ON builder_template FIELDS tags;
DEFINE INDEX idx_builder_template_updated_at    ON builder_template FIELDS updated_at;

-- Enregistrer la table dans builder_table
LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_builder_template' LIMIT 1)[0];
IF $sm == NONE {
  LET $err = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_failure'], 'Erreur: sous-module builder_template introuvable pour builder_table', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: false, run_id: $run_id };
};
LET $t_rec = fn::builder_table_create_record('builder_template', $sm.id, 'Table des templates rattachés aux modules', true, true, true, $phase, ['module_builder'], $run_id);
IF $t_rec.success != true {
  LET $err2 = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_failure'], 'Erreur: enregistrement builder_table pour builder_template', { run_id: $run_id, parent_run_id: $parent_run_id, result: $t_rec });
  RETURN { success: false, run_id: $run_id };
};

-- Référencer la fonction dans builder_function
LET $f_rec = fn::builder_function_create_record('builder_template_create_table_initialise', $sm.id, 'Initialise la création de la table builder_template', true, true, true, 'deploy', NONE, $phase, ['module_builder'], $run_id);
IF $f_rec.success != true {
  LET $err3 = fn::system_log_create_record([$phase, 'log_function', 'log_create', 'log_done', 'log_failure'], 'Erreur: enregistrement builder_function pour builder_template_create_table_initialise', { run_id: $run_id, parent_run_id: $parent_run_id, result: $f_rec });
  RETURN { success: false, run_id: $run_id };
};

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création de la table builder_template', { run_id: $run_id, parent_run_id: $parent_run_id, table: 'builder_template' });
RETURN { success: true, run_id: $run_id };
}
COMMENT "Crée la table builder_template dans la base de données"
PERMISSIONS FULL;


