DEFINE FUNCTION IF NOT EXISTS fn::base_account_management_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
  LET $run_id = rand::uuid();
  LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_account_management', { run_id: $run_id, parent_run_id: $parent_run_id });

  DEFINE TABLE IF NOT EXISTS base_account_management TYPE NORMAL SCHEMAFULL
  COMMENT 'AccountManagement (Axelor)' 
  PERMISSIONS FULL;

  DEFINE FIELD typeSelect ON base_account_management TYPE int;
  DEFINE FIELD company ON base_account_management TYPE record<base_company>;

  DEFINE FIELD purchaseTaxSet ON base_account_management TYPE array<record<base_tax>> DEFAULT [];
  DEFINE FIELD saleTaxSet ON base_account_management TYPE array<record<base_tax>> DEFAULT [];
  DEFINE FIELD tax ON base_account_management TYPE option<record<base_tax>>;

  DEFINE FIELD product ON base_account_management TYPE option<record<base_product>>;
  DEFINE FIELD productFamily ON base_account_management TYPE option<record<base_product_family>>;

  DEFINE FIELD created_at ON base_account_management TYPE datetime DEFAULT time::now();
  DEFINE FIELD updated_at ON base_account_management TYPE datetime DEFAULT time::now();

  DEFINE INDEX idx_base_account_mgmt_company ON base_account_management FIELDS company;
  DEFINE INDEX idx_base_account_mgmt_type ON base_account_management FIELDS typeSelect;

  LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_taxation_pricing' LIMIT 1)[0];
  IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_taxation_pricing introuvable' }; };
  LET $t_rec = fn::builder_table_create_record('base_account_management', $sm.id, 'Paramétrage comptable (Axelor)', true, true, true, $phase, ['module_base'], $run_id);
  IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };

  LET $f_rec = fn::builder_function_create_record('base_account_management_create_table_initialise', $sm.id, 'Crée la table base_account_management', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
  IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

  LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_account_management', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_account_management'
PERMISSIONS FULL;

