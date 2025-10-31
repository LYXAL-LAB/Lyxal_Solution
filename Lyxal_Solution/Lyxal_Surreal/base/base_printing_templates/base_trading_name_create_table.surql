DEFINE FUNCTION IF NOT EXISTS fn::base_trading_name_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
  LET $run_id = rand::uuid();
  LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_trading_name', { run_id: $run_id, parent_run_id: $parent_run_id });

  DEFINE TABLE IF NOT EXISTS base_trading_name TYPE NORMAL SCHEMAFULL
  COMMENT 'TradingName (Axelor)'
  PERMISSIONS FULL;

  DEFINE FIELD name ON base_trading_name TYPE option<string>;
  DEFINE FIELD logo ON base_trading_name TYPE option<record<base_meta_file>>;
  DEFINE FIELD company ON base_trading_name TYPE option<record<base_company>>;
  DEFINE FIELD partner ON base_trading_name TYPE option<record<base_partner>>;

  DEFINE FIELD created_at ON base_trading_name TYPE datetime DEFAULT time::now();
  DEFINE FIELD updated_at ON base_trading_name TYPE datetime DEFAULT time::now();

  DEFINE INDEX idx_base_trading_name_company ON base_trading_name FIELDS company;
  DEFINE INDEX idx_base_trading_name_partner ON base_trading_name FIELDS partner;

  LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_printing_templates' LIMIT 1)[0];
  IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_printing_templates introuvable' }; };
  LET $t_rec = fn::builder_table_create_record('base_trading_name', $sm.id, 'Trading Name (Axelor)', true, true, true, $phase, ['module_base'], $run_id);
  IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };

  LET $f_rec = fn::builder_function_create_record('base_trading_name_create_table_initialise', $sm.id, 'Crée la table base_trading_name', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
  IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

  LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_trading_name', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_trading_name'
PERMISSIONS FULL;

