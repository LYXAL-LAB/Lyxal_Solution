DEFINE FUNCTION IF NOT EXISTS fn::base_tax_number_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_tax_number', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS base_tax_number TYPE NORMAL SCHEMAFULL
COMMENT 'Numéros de taxe par partenaire et pays'
PERMISSIONS FULL;

DEFINE FIELD partner ON base_tax_number TYPE record<base_partner>;
DEFINE FIELD taxNbr ON base_tax_number TYPE string;
DEFINE FIELD country ON base_tax_number TYPE record<base_country>;

DEFINE FIELD created_at ON base_tax_number TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON base_tax_number TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_base_tax_number_partner ON base_tax_number FIELDS partner;
DEFINE INDEX idx_base_tax_number_country ON base_tax_number FIELDS country;

LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_taxation_pricing' LIMIT 1)[0];
IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_taxation_pricing introuvable' }; };
LET $t_rec = fn::builder_table_create_record('base_tax_number', $sm.id, 'Numéros de taxe', true, true, true, $phase, ['module_base'], $run_id);
IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };

LET $f_rec = fn::builder_function_create_record('base_tax_number_create_table_initialise', $sm.id, 'Crée la table base_tax_number', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_tax_number', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_tax_number'
PERMISSIONS FULL;

