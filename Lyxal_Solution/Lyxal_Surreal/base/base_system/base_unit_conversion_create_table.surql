DEFINE FUNCTION IF NOT EXISTS fn::base_unit_conversion_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
  LET $run_id = rand::uuid();
  LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_unit_conversion', { run_id: $run_id, parent_run_id: $parent_run_id });

  DEFINE TABLE IF NOT EXISTS base_unit_conversion TYPE NORMAL SCHEMAFULL
  COMMENT 'UnitConversion (Axelor)'
  PERMISSIONS FULL;

  DEFINE FIELD startUnit ON base_unit_conversion TYPE record<base_unit>;
  DEFINE FIELD endUnit ON base_unit_conversion TYPE record<base_unit>;
  DEFINE FIELD coef ON base_unit_conversion TYPE number;
  DEFINE FIELD typeSelect ON base_unit_conversion TYPE option<int> DEFAULT 1;
  DEFINE FIELD formula ON base_unit_conversion TYPE option<string>;
  DEFINE FIELD entitySelect ON base_unit_conversion TYPE option<int>;
  DEFINE FIELD name ON base_unit_conversion TYPE option<string>;

  DEFINE FIELD created_at ON base_unit_conversion TYPE datetime DEFAULT time::now();
  DEFINE FIELD updated_at ON base_unit_conversion TYPE datetime DEFAULT time::now();

  DEFINE INDEX idx_base_unit_conversion_units ON base_unit_conversion FIELDS startUnit, endUnit;

  LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_system' LIMIT 1)[0];
  IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_system introuvable' }; };
  LET $t_rec = fn::builder_table_create_record('base_unit_conversion', $sm.id, 'Conversions d\'unités (Axelor)', true, true, true, $phase, ['module_base'], $run_id);
  IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };

  LET $f_rec = fn::builder_function_create_record('base_unit_conversion_create_table_initialise', $sm.id, 'Crée la table base_unit_conversion', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
  IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

  LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_unit_conversion', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_unit_conversion'
PERMISSIONS FULL;

