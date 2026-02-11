DEFINE FUNCTION IF NOT EXISTS fn::base_faker_api_create_tables_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
  LET $run_id = rand::uuid();
  LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création des tables faker_api*', { run_id: $run_id, parent_run_id: $parent_run_id });

  -- faker_api_field
  DEFINE TABLE IF NOT EXISTS base_faker_api_field TYPE NORMAL SCHEMAFULL
  COMMENT 'Champs API Faker'
  PERMISSIONS FULL;
  DEFINE FIELD name ON base_faker_api_field TYPE string;
  DEFINE FIELD type_select ON base_faker_api_field TYPE string;
  DEFINE FIELD parameters ON base_faker_api_field TYPE array<record<base_faker_api_field_parameters>>;
  DEFINE FIELD created_at ON base_faker_api_field TYPE datetime DEFAULT time::now();
  DEFINE FIELD updated_at ON base_faker_api_field TYPE datetime DEFAULT time::now();
  DEFINE FIELD version ON base_faker_api_field TYPE int DEFAULT 0;

  -- faker_api_field_parameters
  DEFINE TABLE IF NOT EXISTS base_faker_api_field_parameters TYPE NORMAL SCHEMAFULL
  COMMENT 'Paramètres des champs API Faker'
  PERMISSIONS FULL;
  DEFINE FIELD faker_api_field ON base_faker_api_field_parameters TYPE record<base_faker_api_field>;
  DEFINE FIELD parameter_name ON base_faker_api_field_parameters TYPE string;
  DEFINE FIELD parameter_value ON base_faker_api_field_parameters TYPE string;
  DEFINE FIELD created_at ON base_faker_api_field_parameters TYPE datetime DEFAULT time::now();
  DEFINE FIELD updated_at ON base_faker_api_field_parameters TYPE datetime DEFAULT time::now();
  DEFINE FIELD version ON base_faker_api_field_parameters TYPE int DEFAULT 0;

  LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_system' LIMIT 1)[0];
  IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_system introuvable' }; };
  LET $t1 = fn::builder_table_create_record('base_faker_api_field', $sm.id, 'Champs API Faker', true, true, true, $phase, ['module_base'], $run_id);
  LET $t2 = fn::builder_table_create_record('base_faker_api_field_parameters', $sm.id, 'Paramètres champs API Faker', true, true, true, $phase, ['module_base'], $run_id);

  LET $f_rec = fn::builder_function_create_record('base_faker_api_create_tables_initialise', $sm.id, 'Crée les tables faker_api*', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
  IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

  LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création des tables faker_api*', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée les tables faker_api*'
PERMISSIONS FULL;

