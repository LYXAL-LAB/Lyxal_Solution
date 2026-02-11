DEFINE FUNCTION IF NOT EXISTS fn::base_country_language_relation_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table relation base_country_language', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS base_country_language TYPE RELATION 
FROM base_country TO base_language 
COMMENT 'Relation pays ↔ langue(s) officielle(s)/utilisées)'
PERMISSIONS FULL;

-- INDEX (unicité d'un couple pays-langue)
DEFINE INDEX idx_base_country_language_unique ON base_country_language FIELDS out, in UNIQUE;

-- Register builder_table
LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_geographic' LIMIT 1)[0];
IF $sm == NONE {
  LET $err = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_failure'], 'Erreur: sous-module base_geographic introuvable pour builder_table (relation country-language)', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: false, run_id: $run_id };
};
LET $t_rec = fn::builder_table_create_record('base_country_language', $sm.id, 'Relation pays-langue', true, true, true, $phase, ['module_base'], $run_id);
IF $t_rec.success != true {
  LET $err2 = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_failure'], 'Erreur: enregistrement builder_table pour base_country_language', { run_id: $run_id, parent_run_id: $parent_run_id, result: $t_rec });
  RETURN { success: false, run_id: $run_id };
};

-- Register builder_function
LET $f_rec = fn::builder_function_create_record('base_country_language_relation_create_table_initialise', $sm.id, 'Initialise la création de la table relation base_country_language', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
IF $f_rec.success != true {
  LET $err3 = fn::system_log_create_record([$phase, 'log_function', 'log_create', 'log_done', 'log_failure'], 'Erreur: enregistrement builder_function pour base_country_language_relation_create_table_initialise', { run_id: $run_id, parent_run_id: $parent_run_id, result: $f_rec });
  RETURN { success: false, run_id: $run_id };
};

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création de la table relation base_country_language', { run_id: $run_id, parent_run_id: $parent_run_id, table: 'base_country_language' });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table relation base_country_language (geographic)'
PERMISSIONS FULL;

