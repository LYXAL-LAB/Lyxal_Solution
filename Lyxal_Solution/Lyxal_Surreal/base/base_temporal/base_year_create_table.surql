DEFINE FUNCTION IF NOT EXISTS fn::base_year_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
  LET $run_id = rand::uuid();
  LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_year', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS base_year TYPE NORMAL SCHEMAFULL
COMMENT 'Années fiscales et civiles'
PERMISSIONS FULL;

-- Identification
DEFINE FIELD name ON base_year TYPE string
COMMENT 'Nom de l\'année';
DEFINE FIELD code ON base_year TYPE string
COMMENT 'Code de l\'année';

-- Dates
DEFINE FIELD fromDate ON base_year TYPE datetime;
DEFINE FIELD toDate ON base_year TYPE datetime;

-- Relations
DEFINE FIELD company ON base_year TYPE option<record<base_company>>;

-- Statut
DEFINE FIELD statusSelect ON base_year TYPE int DEFAULT 1; -- 1=OPENED, 2=CLOSED, 3=ADJUSTING

-- Configuration
DEFINE FIELD periodDurationSelect ON base_year TYPE option<string>; -- week, 2week, month, etc.
DEFINE FIELD typeSelect ON base_year TYPE int; -- 0=CIVIL, 1=FISCAL, 2=PAYROLL, etc.

-- Historique des ajustements
DEFINE FIELD adjustHistoryList ON base_year TYPE array<record<base_adjust_history>>;

-- Index et contraintes
DEFINE INDEX idx_year_code_company_type ON base_year FIELDS code, company, typeSelect UNIQUE;
DEFINE INDEX idx_year_company ON base_year FIELDS company;
DEFINE INDEX idx_year_dates ON base_year FIELDS fromDate, toDate;

  LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_temporal' LIMIT 1)[0];
  IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_temporal introuvable' }; };

  LET $t_rec = fn::builder_table_create_record('base_year', $sm.id, 'Années', true, true, true, $phase, ['module_base'], $run_id);
  IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };

  LET $f_rec = fn::builder_function_create_record('base_year_create_table_initialise', $sm.id, 'Crée la table base_year', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
  IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

  LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_year', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_year (temporal)'
PERMISSIONS FULL;