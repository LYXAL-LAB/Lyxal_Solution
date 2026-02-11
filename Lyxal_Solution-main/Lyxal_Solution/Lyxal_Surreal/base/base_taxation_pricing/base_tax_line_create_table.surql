DEFINE FUNCTION IF NOT EXISTS fn::base_tax_line_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_tax_line', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS base_tax_line TYPE NORMAL SCHEMAFULL
COMMENT 'Lignes de taxes avec taux et dates'
PERMISSIONS FULL;

DEFINE FIELD name ON base_tax_line TYPE string;
DEFINE FIELD tax ON base_tax_line TYPE record<base_tax>;
DEFINE FIELD value ON base_tax_line TYPE decimal;
DEFINE FIELD startDate ON base_tax_line TYPE datetime;
DEFINE FIELD endDate ON base_tax_line TYPE option<datetime>;

DEFINE FIELD created_at ON base_tax_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON base_tax_line TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_base_tax_line_tax ON base_tax_line FIELDS tax;
DEFINE INDEX idx_base_tax_line_dates ON base_tax_line FIELDS startDate, endDate;

LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_taxation_pricing' LIMIT 1)[0];
IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_taxation_pricing introuvable' }; };
LET $t_rec = fn::builder_table_create_record('base_tax_line', $sm.id, 'Lignes de taxes', true, true, true, $phase, ['module_base'], $run_id);
IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };

LET $f_rec = fn::builder_function_create_record('base_tax_line_create_table_initialise', $sm.id, 'Crée la table base_tax_line', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_tax_line', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_tax_line'
PERMISSIONS FULL;

