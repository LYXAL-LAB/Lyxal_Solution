DEFINE FUNCTION IF NOT EXISTS fn::base_icalendar_event_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_icalendar_event', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS base_icalendar_event TYPE NORMAL SCHEMAFULL
COMMENT 'Événement iCal (ICalendarEvent)'
PERMISSIONS FULL;

DEFINE FIELD uid ON base_icalendar_event TYPE option<string>;
DEFINE FIELD url ON base_icalendar_event TYPE option<string>;
DEFINE FIELD subject ON base_icalendar_event TYPE string;
DEFINE FIELD description ON base_icalendar_event TYPE option<string>;
DEFINE FIELD status ON base_icalendar_event TYPE option<string>;
DEFINE FIELD startDateTime ON base_icalendar_event TYPE datetime;
DEFINE FIELD endDateTime ON base_icalendar_event TYPE datetime;
DEFINE FIELD allDay ON base_icalendar_event TYPE option<bool>;
DEFINE FIELD location ON base_icalendar_event TYPE option<string>;
DEFINE FIELD geo ON base_icalendar_event TYPE option<string>;
DEFINE FIELD calendar ON base_icalendar_event TYPE option<record<base_icalendar>>;
DEFINE FIELD organizer ON base_icalendar_event TYPE option<record<base_icalendar_user>>;
DEFINE FIELD attendees ON base_icalendar_event TYPE array<record<base_icalendar_user>> DEFAULT [];
DEFINE FIELD computedAttendeeList ON base_icalendar_event TYPE option<string>;
DEFINE FIELD visibilitySelect ON base_icalendar_event TYPE option<int> DEFAULT 1;
DEFINE FIELD disponibilitySelect ON base_icalendar_event TYPE option<int> DEFAULT 1;
DEFINE FIELD subjectTeam ON base_icalendar_event TYPE option<string>;
DEFINE FIELD typeSelect ON base_icalendar_event TYPE int;
DEFINE FIELD user ON base_icalendar_event TYPE option<record<base_user>>;

DEFINE FIELD created_at ON base_icalendar_event TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON base_icalendar_event TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_base_icalendar_event_uid ON base_icalendar_event FIELDS uid UNIQUE;
DEFINE INDEX idx_base_icalendar_event_start ON base_icalendar_event FIELDS startDateTime;
DEFINE INDEX idx_base_icalendar_event_calendar ON base_icalendar_event FIELDS calendar;

LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_calendrier' LIMIT 1)[0];
IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_calendrier introuvable' }; };
LET $t_rec = fn::builder_table_create_record('base_icalendar_event', $sm.id, 'Événement iCal', true, true, true, $phase, ['module_base'], $run_id);
IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };

LET $f_rec = fn::builder_function_create_record('base_icalendar_event_create_table_initialise', $sm.id, 'Crée la table base_icalendar_event', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_icalendar_event', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_icalendar_event'
PERMISSIONS FULL;

