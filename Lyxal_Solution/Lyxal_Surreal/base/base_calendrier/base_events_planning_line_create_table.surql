DEFINE FUNCTION IF NOT EXISTS fn::base_events_planning_line_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_events_planning_line', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS base_events_planning_line TYPE NORMAL SCHEMAFULL
COMMENT 'Ligne de planification des jours fériés (EventsPlanningLine)'
PERMISSIONS FULL;

DEFINE FIELD eventsPlanning ON base_events_planning_line TYPE option<record<base_events_planning>>;
DEFINE FIELD year ON base_events_planning_line TYPE int;
DEFINE FIELD date ON base_events_planning_line TYPE date;
DEFINE FIELD description ON base_events_planning_line TYPE option<string>;

DEFINE FIELD created_at ON base_events_planning_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON base_events_planning_line TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_base_events_planning_line_planning ON base_events_planning_line FIELDS eventsPlanning;
DEFINE INDEX idx_base_events_planning_line_year ON base_events_planning_line FIELDS year;
DEFINE INDEX idx_base_events_planning_line_date ON base_events_planning_line FIELDS date;

LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_calendrier' LIMIT 1)[0];
IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_calendrier introuvable' }; };
LET $t_rec = fn::builder_table_create_record('base_events_planning_line', $sm.id, 'Ligne de jours fériés', true, true, true, $phase, ['module_base'], $run_id);
IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };

LET $f_rec = fn::builder_function_create_record('base_events_planning_line_create_table_initialise', $sm.id, 'Crée la table base_events_planning_line', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_events_planning_line', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_events_planning_line'
PERMISSIONS FULL;

