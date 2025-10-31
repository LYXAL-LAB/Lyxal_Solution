DEFINE FUNCTION IF NOT EXISTS fn::base_data_sharing_product_wizard_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_data_sharing_product_wizard', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS base_data_sharing_product_wizard TYPE NORMAL SCHEMAFULL
COMMENT 'Assistant de partage de produits'
PERMISSIONS FULL;

DEFINE FIELD dataSharingReferential ON base_data_sharing_product_wizard TYPE record<base_data_sharing_referential>;
DEFINE FIELD productSet ON base_data_sharing_product_wizard TYPE array<record<base_product>>;
DEFINE FIELD productCategorySet ON base_data_sharing_product_wizard TYPE array<record<base_product_category>>;

DEFINE INDEX idx_base_data_sharing_product_wizard_ref ON base_data_sharing_product_wizard FIELDS dataSharingReferential UNIQUE;

LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_data_sharing' LIMIT 1)[0];
IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_data_sharing introuvable' }; };
LET $t_rec = fn::builder_table_create_record('base_data_sharing_product_wizard', $sm.id, 'Assistant de partage de produits', true, true, true, $phase, ['module_base'], $run_id);
IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };

LET $f_rec = fn::builder_function_create_record('base_data_sharing_product_wizard_create_table_initialise', $sm.id, 'Crée la table base_data_sharing_product_wizard', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_data_sharing_product_wizard', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_data_sharing_product_wizard'
PERMISSIONS FULL;


