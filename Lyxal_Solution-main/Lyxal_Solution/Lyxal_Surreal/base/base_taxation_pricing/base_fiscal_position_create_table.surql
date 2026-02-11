DEFINE FUNCTION IF NOT EXISTS fn::base_fiscal_position_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_fiscal_position', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS base_fiscal_position TYPE NORMAL SCHEMAFULL
COMMENT 'Positions fiscales'
PERMISSIONS FULL;

DEFINE FIELD name ON base_fiscal_position TYPE string;
DEFINE FIELD code ON base_fiscal_position TYPE string;
DEFINE FIELD customerSpecificNote ON base_fiscal_position TYPE bool DEFAULT false;
DEFINE FIELD customerSpecificNoteText ON base_fiscal_position TYPE option<string>;
DEFINE FIELD taxEquivList ON base_fiscal_position TYPE array<record<base_tax_equiv>>;

DEFINE INDEX idx_base_fiscal_position_name ON base_fiscal_position FIELDS name;
DEFINE INDEX idx_base_fiscal_position_code ON base_fiscal_position FIELDS code UNIQUE;

LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_taxation_pricing' LIMIT 1)[0];
IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_taxation_pricing introuvable' }; };
LET $t_rec = fn::builder_table_create_record('base_fiscal_position', $sm.id, 'Positions fiscales', true, true, true, $phase, ['module_base'], $run_id);
IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };

LET $f_rec = fn::builder_function_create_record('base_fiscal_position_create_table_initialise', $sm.id, 'Crée la table base_fiscal_position', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_fiscal_position', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_fiscal_position'
PERMISSIONS FULL;


