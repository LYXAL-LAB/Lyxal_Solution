DEFINE FUNCTION IF NOT EXISTS fn::base_icalendar_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_icalendar', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS base_icalendar TYPE NORMAL SCHEMAFULL
COMMENT 'Calendriers iCal (ICalendar)'
PERMISSIONS FULL;

DEFINE FIELD name ON base_icalendar TYPE string;
DEFINE FIELD clientId ON base_icalendar TYPE option<string>;
DEFINE FIELD keepRemote ON base_icalendar TYPE bool DEFAULT false;
DEFINE FIELD user ON base_icalendar TYPE option<record<base_user>>;

DEFINE FIELD url ON base_icalendar TYPE option<string>;
DEFINE FIELD login ON base_icalendar TYPE option<string>;
DEFINE FIELD password ON base_icalendar TYPE option<string>;
DEFINE FIELD typeSelect ON base_icalendar TYPE option<int>;
DEFINE FIELD synchronizationSelect ON base_icalendar TYPE option<string>;
DEFINE FIELD isSslConnection ON base_icalendar TYPE option<bool>;
DEFINE FIELD port ON base_icalendar TYPE option<int> DEFAULT 80;
DEFINE FIELD isValid ON base_icalendar TYPE option<bool>;
DEFINE FIELD lastSynchronizationDateT ON base_icalendar TYPE option<datetime>;
DEFINE FIELD synchronizationDuration ON base_icalendar TYPE option<int> DEFAULT 1;
DEFINE FIELD sharingSettingList ON base_icalendar TYPE array<record<base_sharing_setting>> DEFAULT [];

DEFINE FIELD created_at ON base_icalendar TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON base_icalendar TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_base_icalendar_name ON base_icalendar FIELDS name;
DEFINE INDEX idx_base_icalendar_user ON base_icalendar FIELDS user;
DEFINE INDEX idx_base_icalendar_valid ON base_icalendar FIELDS isValid;

LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_calendrier' LIMIT 1)[0];
IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_calendrier introuvable' }; };
LET $t_rec = fn::builder_table_create_record('base_icalendar', $sm.id, 'Calendriers iCal', true, true, true, $phase, ['module_base'], $run_id);
IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };

LET $f_rec = fn::builder_function_create_record('base_icalendar_create_table_initialise', $sm.id, 'Crée la table base_icalendar', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_icalendar', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_icalendar'
PERMISSIONS FULL;

