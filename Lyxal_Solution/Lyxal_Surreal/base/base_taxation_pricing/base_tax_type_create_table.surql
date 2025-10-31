DEFINE FUNCTION IF NOT EXISTS fn::base_tax_type_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_tax_type', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS base_tax_type TYPE NORMAL SCHEMAFULL
COMMENT 'Types de taxes'
PERMISSIONS FULL;

DEFINE FIELD name ON base_tax_type TYPE string;
DEFINE FIELD code ON base_tax_type TYPE string;
DEFINE FIELD typeSelect ON base_tax_type TYPE int; -- 1=VAT, 2=OTHER

DEFINE FIELD created_at ON base_tax_type TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON base_tax_type TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_base_tax_type_code ON base_tax_type FIELDS code UNIQUE;
DEFINE INDEX idx_base_tax_type_name ON base_tax_type FIELDS name;

LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_taxation_pricing' LIMIT 1)[0];
IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_taxation_pricing introuvable' }; };
LET $t_rec = fn::builder_table_create_record('base_tax_type', $sm.id, 'Types de taxes', true, true, true, $phase, ['module_base'], $run_id);
IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };

LET $f_rec = fn::builder_function_create_record('base_tax_type_create_table_initialise', $sm.id, 'Crée la table base_tax_type', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_tax_type', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_tax_type'
PERMISSIONS FULL;

