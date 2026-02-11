DEFINE FUNCTION IF NOT EXISTS fn::base_pricing_line_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_pricing_line', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS base_pricing_line TYPE NORMAL SCHEMAFULL
COMMENT 'Lignes de règles de tarification'
PERMISSIONS FULL;

DEFINE FIELD pricing ON base_pricing_line TYPE record<base_pricing>;
DEFINE FIELD product ON base_pricing_line TYPE option<record<base_product>>;
DEFINE FIELD productCategory ON base_pricing_line TYPE option<record<base_product_category>>;
DEFINE FIELD formula ON base_pricing_line TYPE option<string>;
DEFINE FIELD result ON base_pricing_line TYPE option<decimal>;

DEFINE FIELD created_at ON base_pricing_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON base_pricing_line TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_base_pricing_line_pricing ON base_pricing_line FIELDS pricing;
DEFINE INDEX idx_base_pricing_line_product ON base_pricing_line FIELDS product;

LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_taxation_pricing' LIMIT 1)[0];
IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_taxation_pricing introuvable' }; };
LET $t_rec = fn::builder_table_create_record('base_pricing_line', $sm.id, 'Lignes de tarification', true, true, true, $phase, ['module_base'], $run_id);
IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };

LET $f_rec = fn::builder_function_create_record('base_pricing_line_create_table_initialise', $sm.id, 'Crée la table base_pricing_line', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_pricing_line', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_pricing_line'
PERMISSIONS FULL;

