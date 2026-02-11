DEFINE FUNCTION IF NOT EXISTS fn::base_calendar_management_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_calendar_management', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS base_calendar_management TYPE NORMAL SCHEMAFULL
COMMENT 'Gestion des calendriers'
PERMISSIONS FULL;

DEFINE FIELD parentUser ON base_calendar_management TYPE record<base_user>;
DEFINE FIELD calendar ON base_calendar_management TYPE record<base_icalendar>;
DEFINE FIELD canRead ON base_calendar_management TYPE bool DEFAULT false;
DEFINE FIELD canWrite ON base_calendar_management TYPE bool DEFAULT false;

DEFINE FIELD created_at ON base_calendar_management TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON base_calendar_management TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_base_calendar_management_user ON base_calendar_management FIELDS parentUser;
DEFINE INDEX idx_base_calendar_management_calendar ON base_calendar_management FIELDS calendar;

LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_calendrier' LIMIT 1)[0];
IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_calendrier introuvable' }; };
LET $t_rec = fn::builder_table_create_record('base_calendar_management', $sm.id, 'Gestion des calendriers', true, true, true, $phase, ['module_base'], $run_id);
IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };

LET $f_rec = fn::builder_function_create_record('base_calendar_management_create_table_initialise', $sm.id, 'Crée la table base_calendar_management', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_calendar_management', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_calendar_management'
PERMISSIONS FULL;

