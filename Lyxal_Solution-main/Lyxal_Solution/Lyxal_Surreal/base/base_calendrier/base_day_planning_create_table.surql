DEFINE FUNCTION IF NOT EXISTS fn::base_day_planning_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_day_planning', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS base_day_planning TYPE NORMAL SCHEMAFULL
COMMENT 'Planification quotidienne (DayPlanning)'
PERMISSIONS FULL;

DEFINE FIELD weeklyPlanning ON base_day_planning TYPE option<record<base_weekly_planning>>;
DEFINE FIELD nameSelect ON base_day_planning TYPE string;
DEFINE FIELD morningFrom ON base_day_planning TYPE option<time>;
DEFINE FIELD morningTo ON base_day_planning TYPE option<time>;
DEFINE FIELD afternoonFrom ON base_day_planning TYPE option<time>;
DEFINE FIELD afternoonTo ON base_day_planning TYPE option<time>;
DEFINE FIELD sequence ON base_day_planning TYPE option<int>;

DEFINE FIELD created_at ON base_day_planning TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON base_day_planning TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_base_day_planning_weekly ON base_day_planning FIELDS weeklyPlanning;
DEFINE INDEX idx_base_day_planning_sequence ON base_day_planning FIELDS sequence;

LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_calendrier' LIMIT 1)[0];
IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_calendrier introuvable' }; };
LET $t_rec = fn::builder_table_create_record('base_day_planning', $sm.id, 'Planification quotidienne', true, true, true, $phase, ['module_base'], $run_id);
IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };

LET $f_rec = fn::builder_function_create_record('base_day_planning_create_table_initialise', $sm.id, 'Crée la table base_day_planning', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_day_planning', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_day_planning'
PERMISSIONS FULL;

