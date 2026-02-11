DEFINE FUNCTION IF NOT EXISTS fn::base_currency_conversion_line_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
  LET $run_id = rand::uuid();
  LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_currency_conversion_line', { run_id: $run_id, parent_run_id: $parent_run_id });

  DEFINE TABLE IF NOT EXISTS base_currency_conversion_line TYPE NORMAL SCHEMAFULL
  COMMENT 'Lignes de conversion de devise'
  PERMISSIONS FULL;
  DEFINE FIELD app_base ON base_currency_conversion_line TYPE record<base_app_base>;
  DEFINE FIELD from_currency ON base_currency_conversion_line TYPE record<base_currency>;
  DEFINE FIELD to_currency ON base_currency_conversion_line TYPE record<base_currency>;
  DEFINE FIELD exchange_rate ON base_currency_conversion_line TYPE decimal;
  DEFINE FIELD conversion_date ON base_currency_conversion_line TYPE datetime;
  DEFINE FIELD created_at ON base_currency_conversion_line TYPE datetime DEFAULT time::now();
  DEFINE FIELD updated_at ON base_currency_conversion_line TYPE datetime DEFAULT time::now();
  DEFINE FIELD version ON base_currency_conversion_line TYPE int DEFAULT 0;
  DEFINE INDEX idx_base_currency_conversion_date ON base_currency_conversion_line FIELDS conversion_date;
  DEFINE INDEX idx_base_currency_conversion_currencies ON base_currency_conversion_line FIELDS from_currency, to_currency;

  LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_system' LIMIT 1)[0];
  IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_system introuvable' }; };
  LET $t_rec = fn::builder_table_create_record('base_currency_conversion_line', $sm.id, 'Ligne de conversion de devise', true, true, true, $phase, ['module_base'], $run_id);
  IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };

  LET $f_rec = fn::builder_function_create_record('base_currency_conversion_line_create_table_initialise', $sm.id, 'Crée la table base_currency_conversion_line', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
  IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

  LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_currency_conversion_line', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_currency_conversion_line'
PERMISSIONS FULL;

