DEFINE FUNCTION IF NOT EXISTS fn::base_shipping_coef_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_shipping_coef', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS base_shipping_coef TYPE NORMAL SCHEMAFULL
COMMENT 'Coefficients de livraison'
PERMISSIONS FULL;

DEFINE FIELD shippingCoef ON base_shipping_coef TYPE decimal;
DEFINE FIELD partner ON base_shipping_coef TYPE record<base_partner>;
DEFINE FIELD product ON base_shipping_coef TYPE record<base_product>;

DEFINE FIELD created_at ON base_shipping_coef TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON base_shipping_coef TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_base_shipping_coef_partner ON base_shipping_coef FIELDS partner;
DEFINE INDEX idx_base_shipping_coef_product ON base_shipping_coef FIELDS product;

LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_taxation_pricing' LIMIT 1)[0];
IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_taxation_pricing introuvable' }; };
LET $t_rec = fn::builder_table_create_record('base_shipping_coef', $sm.id, 'Coefficients de livraison', true, true, true, $phase, ['module_base'], $run_id);
IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };

LET $f_rec = fn::builder_function_create_record('base_shipping_coef_create_table_initialise', $sm.id, 'Crée la table base_shipping_coef', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_shipping_coef', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_shipping_coef'
PERMISSIONS FULL;

