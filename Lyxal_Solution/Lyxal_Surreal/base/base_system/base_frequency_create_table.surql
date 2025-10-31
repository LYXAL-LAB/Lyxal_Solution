DEFINE FUNCTION IF NOT EXISTS fn::base_frequency_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
  LET $run_id = rand::uuid();
  LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_frequency', { run_id: $run_id, parent_run_id: $parent_run_id });

  DEFINE TABLE IF NOT EXISTS base_frequency TYPE NORMAL SCHEMAFULL
  COMMENT 'Fréquences'
  PERMISSIONS FULL;
  DEFINE FIELD name ON base_frequency TYPE string;
  DEFINE FIELD code ON base_frequency TYPE string;
  DEFINE FIELD period_type_select ON base_frequency TYPE string;
  DEFINE FIELD period_value ON base_frequency TYPE int;
  DEFINE FIELD created_at ON base_frequency TYPE datetime DEFAULT time::now();
  DEFINE FIELD updated_at ON base_frequency TYPE datetime DEFAULT time::now();
  DEFINE FIELD version ON base_frequency TYPE int DEFAULT 0;

  LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_system' LIMIT 1)[0];
  IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_system introuvable' }; };
  LET $t1 = fn::builder_table_create_record('base_frequency', $sm.id, 'Fréquences', true, true, true, $phase, ['module_base'], $run_id);

  LET $f_rec = fn::builder_function_create_record('base_frequency_create_table_initialise', $sm.id, 'Crée la table base_frequency', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
  IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

  LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création de la table base_frequency', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_frequency'
PERMISSIONS FULL;


