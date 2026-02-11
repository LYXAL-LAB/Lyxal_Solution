DEFINE FUNCTION IF NOT EXISTS fn::base_payment_mode_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
  LET $run_id = rand::uuid();
  LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_payment_mode', { run_id: $run_id, parent_run_id: $parent_run_id });

  DEFINE TABLE IF NOT EXISTS base_payment_mode TYPE NORMAL SCHEMAFULL
  COMMENT 'Modes de paiement'
  PERMISSIONS FULL;

  DEFINE FIELD name ON base_payment_mode TYPE string;
  DEFINE FIELD code ON base_payment_mode TYPE string;
  DEFINE FIELD type_select ON base_payment_mode TYPE int DEFAULT 1; -- 1=OTHER, 2=DD, 3=IPO, etc.
  DEFINE FIELD in_out_select ON base_payment_mode TYPE int DEFAULT 1; -- 1=IN, 2=OUT
  DEFINE FIELD tags ON base_payment_mode TYPE array<record<system_tag>> DEFAULT [];
  DEFINE FIELD is_active ON base_payment_mode TYPE bool DEFAULT true;
  DEFINE FIELD created_at ON base_payment_mode TYPE datetime DEFAULT time::now();
  DEFINE FIELD updated_at ON base_payment_mode TYPE datetime DEFAULT time::now();

  DEFINE INDEX idx_base_payment_mode_name ON base_payment_mode FIELDS name UNIQUE;
  DEFINE INDEX idx_base_payment_mode_code ON base_payment_mode FIELDS code UNIQUE;

  LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_system' LIMIT 1)[0];
  IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_system introuvable' }; };
  LET $t_rec = fn::builder_table_create_record('base_payment_mode', $sm.id, 'Modes de paiement', true, true, true, $phase, ['module_base'], $run_id);
  IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };
  LET $f_rec = fn::builder_function_create_record('base_payment_mode_create_table_initialise', $sm.id, 'Crée la table base_payment_mode', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
  IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

  LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_payment_mode', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_payment_mode'
PERMISSIONS FULL;

