DEFINE FUNCTION IF NOT EXISTS fn::base_calendar_configuration_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_calendar_configuration', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS base_calendar_configuration TYPE NORMAL SCHEMAFULL
COMMENT 'Configuration des calendriers (CalendarConfiguration)'
PERMISSIONS FULL;

DEFINE FIELD calendar ON base_calendar_configuration TYPE option<record<base_icalendar>>;
DEFINE FIELD synchronizationDuration ON base_calendar_configuration TYPE option<int>;
DEFINE FIELD isSslConnection ON base_calendar_configuration TYPE option<bool>;
DEFINE FIELD port ON base_calendar_configuration TYPE option<int>;
DEFINE FIELD keepRemote ON base_calendar_configuration TYPE option<bool>;

DEFINE FIELD created_at ON base_calendar_configuration TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON base_calendar_configuration TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_base_calendar_configuration_calendar ON base_calendar_configuration FIELDS calendar;

LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_calendrier' LIMIT 1)[0];
IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_calendrier introuvable' }; };
LET $t_rec = fn::builder_table_create_record('base_calendar_configuration', $sm.id, 'Configuration de calendrier', true, true, true, $phase, ['module_base'], $run_id);
IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };

LET $f_rec = fn::builder_function_create_record('base_calendar_configuration_create_table_initialise', $sm.id, 'Crée la table base_calendar_configuration', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_calendar_configuration', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_calendar_configuration'
PERMISSIONS FULL;

