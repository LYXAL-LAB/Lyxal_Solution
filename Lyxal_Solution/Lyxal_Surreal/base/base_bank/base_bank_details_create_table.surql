DEFINE FUNCTION IF NOT EXISTS fn::base_bank_details_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
  LET $run_id = rand::uuid();
  LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_bank_details', { run_id: $run_id, parent_run_id: $parent_run_id });

  DEFINE TABLE IF NOT EXISTS base_bank_details TYPE NORMAL SCHEMAFULL
  COMMENT 'Coordonnées bancaires (Axelor BankDetails)'
  PERMISSIONS FULL;

  -- Propriétaire
  DEFINE FIELD partner ON base_bank_details TYPE option<record<base_partner>>;
  DEFINE FIELD company ON base_bank_details TYPE option<record<base_company>>;
  DEFINE FIELD ownerName ON base_bank_details TYPE option<string>;

  -- Banque
  DEFINE FIELD bank ON base_bank_details TYPE record<base_bank>;
  DEFINE FIELD bankAddress ON base_bank_details TYPE option<record<base_bank_address>>;

  -- Comptes
  DEFINE FIELD iban ON base_bank_details TYPE string;
  DEFINE FIELD bankCode ON base_bank_details TYPE option<string>;
  DEFINE FIELD sortCode ON base_bank_details TYPE option<string>;
  DEFINE FIELD accountNbr ON base_bank_details TYPE option<string>;
  DEFINE FIELD bbanKey ON base_bank_details TYPE option<string>;
  DEFINE FIELD ibanBic ON base_bank_details TYPE option<string>;

  -- Configuration
  DEFINE FIELD currency ON base_bank_details TYPE option<record<base_currency>>;
  DEFINE FIELD label ON base_bank_details TYPE option<string>;
  DEFINE FIELD code ON base_bank_details TYPE option<string>;
  DEFINE FIELD isDefault ON base_bank_details TYPE bool DEFAULT false;
  DEFINE FIELD active ON base_bank_details TYPE bool DEFAULT true;

  -- Nom complet (pré-calculable côté service si besoin)
  DEFINE FIELD fullName ON base_bank_details TYPE option<string>;

  -- Indexes
  DEFINE INDEX idx_base_bank_details_partner ON base_bank_details FIELDS partner;
  DEFINE INDEX idx_base_bank_details_company ON base_bank_details FIELDS company;
  DEFINE INDEX idx_base_bank_details_iban ON base_bank_details FIELDS iban;
  DEFINE INDEX idx_base_bank_details_default_partner ON base_bank_details FIELDS partner, isDefault;

  LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_bank' LIMIT 1)[0];
  IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_bank introuvable' }; };
  LET $t_rec = fn::builder_table_create_record('base_bank_details', $sm.id, 'Détails bancaires (Axelor BankDetails)', true, true, true, $phase, ['module_base'], $run_id);
  IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };
  LET $f_rec = fn::builder_function_create_record('base_bank_details_create_table_initialise', $sm.id, 'Crée la table base_bank_details', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
  IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

  LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_bank_details', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_bank_details'
PERMISSIONS FULL;

