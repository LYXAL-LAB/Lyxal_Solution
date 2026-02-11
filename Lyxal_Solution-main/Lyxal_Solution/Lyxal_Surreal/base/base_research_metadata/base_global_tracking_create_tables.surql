DEFINE FUNCTION IF NOT EXISTS fn::base_global_tracking_create_tables_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création des tables de tracking global', { run_id: $run_id, parent_run_id: $parent_run_id });

-- global_tracking_configuration_line
DEFINE TABLE IF NOT EXISTS base_global_tracking_configuration_line TYPE NORMAL SCHEMAFULL
COMMENT 'Ligne configuration tracking global'
PERMISSIONS FULL;
DEFINE FIELD app_base ON base_global_tracking_configuration_line TYPE record<base_app_base>;
DEFINE FIELD meta_field ON base_global_tracking_configuration_line TYPE record<base_meta_field>;
DEFINE FIELD track_type_select ON base_global_tracking_configuration_line TYPE string;
DEFINE FIELD is_enabled ON base_global_tracking_configuration_line TYPE bool DEFAULT true;
DEFINE FIELD created_at ON base_global_tracking_configuration_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON base_global_tracking_configuration_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON base_global_tracking_configuration_line TYPE int DEFAULT 0;

-- global_tracking_log
DEFINE TABLE IF NOT EXISTS base_global_tracking_log TYPE NORMAL SCHEMAFULL
COMMENT 'Log de tracking global'
PERMISSIONS FULL;
DEFINE FIELD meta_model ON base_global_tracking_log TYPE string;
DEFINE FIELD object_id ON base_global_tracking_log TYPE string;
DEFINE FIELD tracking_date ON base_global_tracking_log TYPE datetime;
DEFINE FIELD user ON base_global_tracking_log TYPE record<base_user>;
DEFINE FIELD tracking_log_lines ON base_global_tracking_log TYPE array<record<base_global_tracking_log_line>>;
DEFINE FIELD created_at ON base_global_tracking_log TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON base_global_tracking_log TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON base_global_tracking_log TYPE int DEFAULT 0;

-- global_tracking_log_line
DEFINE TABLE IF NOT EXISTS base_global_tracking_log_line TYPE NORMAL SCHEMAFULL
COMMENT 'Ligne de log de tracking global'
PERMISSIONS FULL;
DEFINE FIELD global_tracking_log ON base_global_tracking_log_line TYPE record<base_global_tracking_log>;
DEFINE FIELD meta_field ON base_global_tracking_log_line TYPE record<base_meta_field>;
DEFINE FIELD previous_value ON base_global_tracking_log_line TYPE string;
DEFINE FIELD new_value ON base_global_tracking_log_line TYPE string;
DEFINE FIELD created_at ON base_global_tracking_log_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON base_global_tracking_log_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON base_global_tracking_log_line TYPE int DEFAULT 0;

LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_research_metadata' LIMIT 1)[0];
IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_research_metadata introuvable' }; };
LET $t1 = fn::builder_table_create_record('base_global_tracking_configuration_line', $sm.id, 'Config tracking global', true, true, true, $phase, ['module_base'], $run_id);
LET $t2 = fn::builder_table_create_record('base_global_tracking_log', $sm.id, 'Log tracking global', true, true, true, $phase, ['module_base'], $run_id);
LET $t3 = fn::builder_table_create_record('base_global_tracking_log_line', $sm.id, 'Ligne log tracking global', true, true, true, $phase, ['module_base'], $run_id);

LET $f_rec = fn::builder_function_create_record('base_global_tracking_create_tables_initialise', $sm.id, 'Crée les tables de tracking global', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création des tables de tracking global', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée les tables de tracking global'
PERMISSIONS FULL;

