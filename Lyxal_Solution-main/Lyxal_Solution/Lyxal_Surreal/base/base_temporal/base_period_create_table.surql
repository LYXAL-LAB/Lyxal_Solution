DEFINE FUNCTION IF NOT EXISTS fn::base_period_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
  LET $run_id = rand::uuid();
  LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_period', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS base_period TYPE NORMAL SCHEMAFULL
COMMENT 'Périodes fiscales et comptables'
PERMISSIONS FULL;

-- Identification
DEFINE FIELD name ON base_period TYPE string
COMMENT 'Nom de la période';
DEFINE FIELD code ON base_period TYPE option<string>
COMMENT 'Code de la période';

-- Relation avec l'année
DEFINE FIELD year ON base_period TYPE record<base_year>
COMMENT 'Année de la période';

-- Dates
DEFINE FIELD fromDate ON base_period TYPE option<date>
COMMENT 'Date de début de la période';
DEFINE FIELD toDate ON base_period TYPE option<date>
COMMENT 'Date de fin de la période';

-- Statut
DEFINE FIELD statusSelect ON base_period TYPE int DEFAULT 1
COMMENT 'Statut de la période'; -- 1=OPENED, 2=CLOSED, 3=ADJUSTING, 4=TEMPORARILY_CLOSED, 5=CLOSURE_IN_PROGRESS

-- Dates de fermeture
DEFINE FIELD closureDateTime ON base_period TYPE option<datetime>
COMMENT 'Date de fermeture de la période';
DEFINE FIELD temporarilyCloseDateTime ON base_period TYPE option<datetime>
COMMENT 'Date de fermeture temporaire de la période';

-- Historique des ajustements
DEFINE FIELD adjustHistoryList ON base_period TYPE array<record<base_adjust_history>>
COMMENT 'Historique des ajustements sur la période';

-- Index
DEFINE INDEX idx_period_year ON base_period FIELDS year;
DEFINE INDEX idx_period_dates ON base_period FIELDS fromDate, toDate;
DEFINE INDEX idx_period_status ON base_period FIELDS statusSelect;

  LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_temporal' LIMIT 1)[0];
  IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_temporal introuvable' }; };

  LET $t_rec = fn::builder_table_create_record('base_period', $sm.id, 'Périodes', true, true, true, $phase, ['module_base'], $run_id);
  IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };

  LET $f_rec = fn::builder_function_create_record('base_period_create_table_initialise', $sm.id, 'Crée la table base_period', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
  IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

  LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_period', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_period (temporal)'
PERMISSIONS FULL;