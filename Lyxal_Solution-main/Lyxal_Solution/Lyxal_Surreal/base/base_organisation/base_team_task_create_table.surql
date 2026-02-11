DEFINE FUNCTION IF NOT EXISTS fn::base_team_task_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_team_task', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS base_team_task TYPE NORMAL SCHEMAFULL
COMMENT 'Tâches d\'équipe'
PERMISSIONS FULL;

DEFINE FIELD name ON base_team_task TYPE string;
DEFINE FIELD team ON base_team_task TYPE option<record<base_team>>;
DEFINE FIELD assignedTo ON base_team_task TYPE option<record<base_user>>;
DEFINE FIELD taskDate ON base_team_task TYPE option<datetime>;
DEFINE FIELD taskDeadline ON base_team_task TYPE option<datetime>;
DEFINE FIELD status ON base_team_task TYPE option<string>;
DEFINE FIELD priority ON base_team_task TYPE option<string>;

DEFINE FIELD created_at ON base_team_task TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON base_team_task TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_base_team_task_team ON base_team_task FIELDS team;
DEFINE INDEX idx_base_team_task_assigned ON base_team_task FIELDS assignedTo;
DEFINE INDEX idx_base_team_task_deadline ON base_team_task FIELDS taskDeadline;

LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_organisation' LIMIT 1)[0];
IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_organisation introuvable' }; };
LET $t_rec = fn::builder_table_create_record('base_team_task', $sm.id, 'Tâches d\'équipe', true, true, true, $phase, ['module_base'], $run_id);
IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };

LET $f_rec = fn::builder_function_create_record('base_team_task_create_table_initialise', $sm.id, 'Crée la table base_team_task', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_team_task', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_team_task'
PERMISSIONS FULL;

