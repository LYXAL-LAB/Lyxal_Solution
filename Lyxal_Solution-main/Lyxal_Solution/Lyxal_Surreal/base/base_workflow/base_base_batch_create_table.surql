DEFINE FUNCTION IF NOT EXISTS fn::base_base_batch_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_base_batch', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS base_base_batch TYPE NORMAL SCHEMAFULL
COMMENT 'BaseBatch (configuration des batchs)'
PERMISSIONS FULL;

-- Header
DEFINE FIELD code ON base_base_batch TYPE string;
DEFINE FIELD actionSelect ON base_base_batch TYPE int;
DEFINE FIELD company ON base_base_batch TYPE option<record<base_company>>;

-- Infos
DEFINE FIELD fetchLimit ON base_base_batch TYPE option<int>;
DEFINE FIELD description ON base_base_batch TYPE option<string>;
DEFINE FIELD batchList ON base_base_batch TYPE array<record<base_batch>> DEFAULT [];

-- Countries
DEFINE FIELD countrySet ON base_base_batch TYPE array<record<base_country>> DEFAULT [];
DEFINE FIELD allCountries ON base_base_batch TYPE option<bool>;

-- Calendar
DEFINE FIELD synchronizationDuration ON base_base_batch TYPE option<int>;
DEFINE FIELD allEvents ON base_base_batch TYPE option<bool>;

-- Password change
DEFINE FIELD passwordChangeActionSelect ON base_base_batch TYPE option<int>;
DEFINE FIELD allUsers ON base_base_batch TYPE option<bool>;
DEFINE FIELD userSet ON base_base_batch TYPE array<record<base_user>> DEFAULT [];
DEFINE FIELD groupSet ON base_base_batch TYPE array<record<base_group>> DEFAULT [];

-- Audit
DEFINE FIELD created_at ON base_base_batch TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON base_base_batch TYPE datetime DEFAULT time::now();

-- Indexes
DEFINE INDEX idx_base_base_batch_code ON base_base_batch FIELDS code UNIQUE;
DEFINE INDEX idx_base_base_batch_company ON base_base_batch FIELDS company;

LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_workflow' LIMIT 1)[0];
IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_workflow introuvable' }; };
LET $t_rec = fn::builder_table_create_record('base_base_batch', $sm.id, 'Configuration des batchs (BaseBatch)', true, true, true, $phase, ['module_base'], $run_id);
IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };

LET $f_rec = fn::builder_function_create_record('base_base_batch_create_table_initialise', $sm.id, 'Crée la table base_base_batch', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_base_batch', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_base_batch (Axelor BaseBatch)'
PERMISSIONS FULL;

