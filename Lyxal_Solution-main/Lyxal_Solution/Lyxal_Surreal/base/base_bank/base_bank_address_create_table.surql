DEFINE FUNCTION IF NOT EXISTS fn::base_bank_address_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
  LET $run_id = rand::uuid();
  LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_bank_address', { run_id: $run_id, parent_run_id: $parent_run_id });

  DEFINE TABLE IF NOT EXISTS base_bank_address TYPE NORMAL SCHEMAFULL
  COMMENT 'SWIFT addresses des banques'
  PERMISSIONS FULL;

  DEFINE FIELD bank ON base_bank_address TYPE record<base_bank>;
  DEFINE FIELD address ON base_bank_address TYPE option<string>;
  DEFINE FIELD label ON base_bank_address TYPE option<string>;
  DEFINE FIELD fullAddress ON base_bank_address TYPE option<string>;

  DEFINE INDEX idx_base_bank_address_bank ON base_bank_address FIELDS bank;

  LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_bank' LIMIT 1)[0];
  IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_bank introuvable' }; };
  LET $t_rec = fn::builder_table_create_record('base_bank_address', $sm.id, 'Adresses SWIFT des banques', true, true, true, $phase, ['module_base'], $run_id);
  IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };
  LET $f_rec = fn::builder_function_create_record('base_bank_address_create_table_initialise', $sm.id, 'Crée la table base_bank_address', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
  IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

  LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_bank_address', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_bank_address'
PERMISSIONS FULL;

