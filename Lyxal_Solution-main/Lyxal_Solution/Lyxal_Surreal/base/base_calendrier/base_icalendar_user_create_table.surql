DEFINE FUNCTION IF NOT EXISTS fn::base_icalendar_user_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_icalendar_user', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS base_icalendar_user TYPE NORMAL SCHEMAFULL
COMMENT 'Participant iCal (ICalendarUser)'
PERMISSIONS FULL;

DEFINE FIELD name ON base_icalendar_user TYPE option<string>;
DEFINE FIELD email ON base_icalendar_user TYPE string;
DEFINE FIELD statusSelect ON base_icalendar_user TYPE option<int>;
DEFINE FIELD event ON base_icalendar_user TYPE option<record<base_icalendar_event>>;
DEFINE FIELD user ON base_icalendar_user TYPE option<record<base_user>>;

DEFINE FIELD created_at ON base_icalendar_user TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON base_icalendar_user TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_base_icalendar_user_email ON base_icalendar_user FIELDS email;
DEFINE INDEX idx_base_icalendar_user_event ON base_icalendar_user FIELDS event;

LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_calendrier' LIMIT 1)[0];
IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_calendrier introuvable' }; };
LET $t_rec = fn::builder_table_create_record('base_icalendar_user', $sm.id, 'Participant iCal', true, true, true, $phase, ['module_base'], $run_id);
IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };

LET $f_rec = fn::builder_function_create_record('base_icalendar_user_create_table_initialise', $sm.id, 'Crée la table base_icalendar_user', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_icalendar_user', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_icalendar_user'
PERMISSIONS FULL;

