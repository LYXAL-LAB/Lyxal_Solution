DEFINE FUNCTION IF NOT EXISTS fn::base_bank_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
  LET $run_id = rand::uuid();
  LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_bank', { run_id: $run_id, parent_run_id: $parent_run_id });

  DEFINE TABLE IF NOT EXISTS base_bank TYPE NORMAL SCHEMAFULL
  COMMENT 'Bank (Axelor) — BIC, nom, pays et identifiants branche'
  PERMISSIONS FULL;

  DEFINE FIELD fullName ON base_bank TYPE option<string>;
  DEFINE FIELD bankDetailsTypeSelect ON base_bank TYPE int DEFAULT 1;
  DEFINE FIELD code ON base_bank TYPE string; -- BIC (Bank Identifier)
  DEFINE FIELD bankName ON base_bank TYPE option<string>;
  DEFINE FIELD businessPartyPrefix ON base_bank TYPE option<string>;
  DEFINE FIELD country ON base_bank TYPE option<record<base_country>>;
  DEFINE FIELD businessPartySuffix ON base_bank TYPE option<string>;
  DEFINE FIELD branchIdentifier ON base_bank TYPE option<string>;
  DEFINE FIELD bankAddressList ON base_bank TYPE array<record<base_bank_address>>;
  DEFINE FIELD bankDetailsList ON base_bank TYPE array<record<base_bank_details>>;

  -- Indexes
  DEFINE INDEX idx_base_bank_code_unique ON base_bank FIELDS code UNIQUE;
  DEFINE INDEX idx_base_bank_name ON base_bank FIELDS bankName;
  DEFINE INDEX idx_base_bank_country ON base_bank FIELDS country;

  LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_bank' LIMIT 1)[0];
  IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_bank introuvable' }; };
  LET $t_rec = fn::builder_table_create_record('base_bank', $sm.id, 'Table des banques (Axelor Bank)', true, true, true, $phase, ['module_base'], $run_id);
  IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };
  LET $f_rec = fn::builder_function_create_record('base_bank_create_table_initialise', $sm.id, 'Crée la table base_bank (Axelor)', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
  IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

  LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_bank', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_bank'
PERMISSIONS FULL;


