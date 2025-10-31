DEFINE FUNCTION IF NOT EXISTS fn::crm_event_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table crm_event', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS crm_event TYPE NORMAL SCHEMAFULL
COMMENT 'CRM Event (extends ICalendarEvent)'
PERMISSIONS FULL;

DEFINE FIELD limitDateT ON crm_event TYPE option<datetime>;
DEFINE FIELD duration ON crm_event TYPE option<int>;
DEFINE FIELD eventCategory ON crm_event TYPE option<record<crm_event_category>>;
DEFINE FIELD relatedToSelect ON crm_event TYPE option<string>;
DEFINE FIELD relatedToSelectId ON crm_event TYPE option<int>;
DEFINE FIELD statusSelect ON crm_event TYPE option<int>;
DEFINE FIELD team ON crm_event TYPE option<record<base_team>>;
DEFINE FIELD calendarEventUid ON crm_event TYPE option<string>;
DEFINE FIELD eventReminderList ON crm_event TYPE array<record<crm_event_reminder>>;
DEFINE FIELD partner ON crm_event TYPE option<record<base_partner>>;
DEFINE FIELD contactPartner ON crm_event TYPE option<record<base_partner>>;
DEFINE FIELD eventLead ON crm_event TYPE option<record<crm_lead>>;
DEFINE FIELD opportunity ON crm_event TYPE option<record<crm_opportunity>>;
DEFINE FIELD callTypeSelect ON crm_event TYPE option<int>;
DEFINE FIELD isRecurrent ON crm_event TYPE bool DEFAULT false;
DEFINE FIELD parentEvent ON crm_event TYPE option<record<crm_event>>;
DEFINE FIELD prioritySelect ON crm_event TYPE option<int>;
DEFINE FIELD recurrenceConfiguration ON crm_event TYPE option<record<crm_recurrence_configuration>>;

DEFINE INDEX idx_crm_event_partner ON crm_event FIELDS partner;
DEFINE INDEX idx_crm_event_status ON crm_event FIELDS statusSelect;

LET $sm_id = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_crm' LIMIT 1)[0].id;
LET $t_rec = fn::builder_table_create_record('crm_event', $sm_id, 'CRM Event', true, true, true, $phase, ['module_crm'], $run_id);
LET $f_rec = fn::builder_function_create_record('crm_event_create_table_initialise', $sm_id, 'Crée la table crm_event', true, true, true, 'deploy', NONE, $phase, ['module_crm'], $run_id);

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création crm_event', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table crm_event'
PERMISSIONS FULL;


