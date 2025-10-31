DEFINE FUNCTION IF NOT EXISTS fn::base_file_create_tables_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
  LET $run_id = rand::uuid();
  LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création des tables de gestion de fichiers', { run_id: $run_id, parent_run_id: $parent_run_id });

  -- file
  DEFINE TABLE IF NOT EXISTS base_file TYPE NORMAL SCHEMAFULL
  COMMENT 'Fichiers génériques'
  PERMISSIONS FULL;
  DEFINE FIELD file_name ON base_file TYPE string;
  DEFINE FIELD file_type ON base_file TYPE record<base_file_type>;
  DEFINE FIELD file_path ON base_file TYPE string;
  DEFINE FIELD file_size ON base_file TYPE int;
  DEFINE FIELD content_type ON base_file TYPE string;
  DEFINE FIELD created_at ON base_file TYPE datetime DEFAULT time::now();
  DEFINE FIELD updated_at ON base_file TYPE datetime DEFAULT time::now();
  DEFINE FIELD version ON base_file TYPE int DEFAULT 0;
  DEFINE INDEX idx_base_file_file_type ON base_file FIELDS file_type;
  DEFINE INDEX idx_base_file_file_name ON base_file FIELDS file_name;

  -- file_type
  DEFINE TABLE IF NOT EXISTS base_file_type TYPE NORMAL SCHEMAFULL
  COMMENT 'Types de fichier'
  PERMISSIONS FULL;
  DEFINE FIELD name ON base_file_type TYPE string;
  DEFINE FIELD extension ON base_file_type TYPE string;
  DEFINE FIELD content_type ON base_file_type TYPE string;
  DEFINE FIELD max_size ON base_file_type TYPE int;
  DEFINE FIELD created_at ON base_file_type TYPE datetime DEFAULT time::now();
  DEFINE FIELD updated_at ON base_file_type TYPE datetime DEFAULT time::now();
  DEFINE FIELD version ON base_file_type TYPE int DEFAULT 0;

  -- file_field
  DEFINE TABLE IF NOT EXISTS base_file_field TYPE NORMAL SCHEMAFULL
  COMMENT 'Champs de fichier'
  PERMISSIONS FULL;
  DEFINE FIELD name ON base_file_field TYPE string;
  DEFINE FIELD type_select ON base_file_field TYPE string;
  DEFINE FIELD model_name ON base_file_field TYPE string;
  DEFINE FIELD field_name ON base_file_field TYPE string;
  DEFINE FIELD created_at ON base_file_field TYPE datetime DEFAULT time::now();
  DEFINE FIELD updated_at ON base_file_field TYPE datetime DEFAULT time::now();
  DEFINE FIELD version ON base_file_field TYPE int DEFAULT 0;

  -- file_tab
  DEFINE TABLE IF NOT EXISTS base_file_tab TYPE NORMAL SCHEMAFULL
  COMMENT 'Onglets de fichier'
  PERMISSIONS FULL;
  DEFINE FIELD name ON base_file_tab TYPE string;
  DEFINE FIELD model_name ON base_file_tab TYPE string;
  DEFINE FIELD file_field_list ON base_file_tab TYPE array<record<base_file_field>>;
  DEFINE FIELD created_at ON base_file_tab TYPE datetime DEFAULT time::now();
  DEFINE FIELD updated_at ON base_file_tab TYPE datetime DEFAULT time::now();
  DEFINE FIELD version ON base_file_tab TYPE int DEFAULT 0;

  LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_system' LIMIT 1)[0];
  IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_system introuvable' }; };
  LET $t1 = fn::builder_table_create_record('base_file', $sm.id, 'Fichiers génériques', true, true, true, $phase, ['module_base'], $run_id);
  LET $t2 = fn::builder_table_create_record('base_file_type', $sm.id, 'Types de fichier', true, true, true, $phase, ['module_base'], $run_id);
  LET $t3 = fn::builder_table_create_record('base_file_field', $sm.id, 'Champs de fichier', true, true, true, $phase, ['module_base'], $run_id);
  LET $t4 = fn::builder_table_create_record('base_file_tab', $sm.id, 'Onglets de fichier', true, true, true, $phase, ['module_base'], $run_id);

  LET $f_rec = fn::builder_function_create_record('base_file_create_tables_initialise', $sm.id, 'Crée les tables de gestion de fichiers', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
  IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

  LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création des tables de gestion de fichiers', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée les tables de gestion de fichiers (base_file*)'
PERMISSIONS FULL;

