DEFINE FUNCTION IF NOT EXISTS fn::base_timer_history_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_timer_history', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS base_timer_history TYPE NORMAL SCHEMAFULL
COMMENT 'Historique des minuteurs'
PERMISSIONS FULL;

DEFINE FIELD timer ON base_timer_history TYPE record<base_timer>;
DEFINE FIELD startDateT ON base_timer_history TYPE option<datetime>;
DEFINE FIELD endDateT ON base_timer_history TYPE option<datetime>;

DEFINE FIELD created_at ON base_timer_history TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON base_timer_history TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_base_timer_history_timer ON base_timer_history FIELDS timer;
DEFINE INDEX idx_base_timer_history_dates ON base_timer_history FIELDS startDateT, endDateT;

LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_workflow' LIMIT 1)[0];
IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_workflow introuvable' }; };
LET $t_rec = fn::builder_table_create_record('base_timer_history', $sm.id, 'Historique des minuteurs', true, true, true, $phase, ['module_base'], $run_id);
IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };

LET $f_rec = fn::builder_function_create_record('base_timer_history_create_table_initialise', $sm.id, 'Crée la table base_timer_history', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_timer_history', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_timer_history'
PERMISSIONS FULL;

