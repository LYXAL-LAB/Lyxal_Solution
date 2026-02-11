DEFINE FUNCTION IF NOT EXISTS fn::base_file_source_connector_create_tables_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
  LET $run_id = rand::uuid();
  LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création des tables file_source_connector*', { run_id: $run_id, parent_run_id: $parent_run_id });

  -- file_source_connector
  DEFINE TABLE IF NOT EXISTS base_file_source_connector TYPE NORMAL SCHEMAFULL
  COMMENT 'Connecteur de source de fichier'
  PERMISSIONS FULL;
  DEFINE FIELD name ON base_file_source_connector TYPE string;
  DEFINE FIELD file_path ON base_file_source_connector TYPE string;
  DEFINE FIELD file_type ON base_file_source_connector TYPE string;
  DEFINE FIELD delimiter ON base_file_source_connector TYPE string;
  DEFINE FIELD encoding ON base_file_source_connector TYPE string;
  DEFINE FIELD parameters ON base_file_source_connector TYPE array<record<base_file_source_connector_parameters>>;
  DEFINE FIELD created_at ON base_file_source_connector TYPE datetime DEFAULT time::now();
  DEFINE FIELD updated_at ON base_file_source_connector TYPE datetime DEFAULT time::now();
  DEFINE FIELD version ON base_file_source_connector TYPE int DEFAULT 0;

  -- file_source_connector_parameters
  DEFINE TABLE IF NOT EXISTS base_file_source_connector_parameters TYPE NORMAL SCHEMAFULL
  COMMENT 'Paramètres du connecteur de source de fichier'
  PERMISSIONS FULL;
  DEFINE FIELD file_source_connector ON base_file_source_connector_parameters TYPE record<base_file_source_connector>;
  DEFINE FIELD parameter_name ON base_file_source_connector_parameters TYPE string;
  DEFINE FIELD parameter_value ON base_file_source_connector_parameters TYPE string;
  DEFINE FIELD created_at ON base_file_source_connector_parameters TYPE datetime DEFAULT time::now();
  DEFINE FIELD updated_at ON base_file_source_connector_parameters TYPE datetime DEFAULT time::now();
  DEFINE FIELD version ON base_file_source_connector_parameters TYPE int DEFAULT 0;

  LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_system' LIMIT 1)[0];
  IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_system introuvable' }; };
  LET $t1 = fn::builder_table_create_record('base_file_source_connector', $sm.id, 'Connecteur de source de fichier', true, true, true, $phase, ['module_base'], $run_id);
  LET $t2 = fn::builder_table_create_record('base_file_source_connector_parameters', $sm.id, 'Paramètres connecteur de source de fichier', true, true, true, $phase, ['module_base'], $run_id);

  LET $f_rec = fn::builder_function_create_record('base_file_source_connector_create_tables_initialise', $sm.id, 'Crée les tables file_source_connector*', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
  IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

  LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création des tables file_source_connector*', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée les tables file_source_connector*'
PERMISSIONS FULL;

