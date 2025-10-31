DEFINE FUNCTION IF NOT EXISTS fn::crm_event_attendee_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table crm_event_attendee', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS crm_event_attendee TYPE NORMAL SCHEMAFULL
COMMENT 'CRM EventAttendee'
PERMISSIONS FULL;

DEFINE FIELD event ON crm_event_attendee TYPE record<crm_event>;
DEFINE FIELD statusSelect ON crm_event_attendee TYPE option<int>;
DEFINE FIELD contactPartner ON crm_event_attendee TYPE option<record<base_partner>>;
DEFINE FIELD eventAttendeeLead ON crm_event_attendee TYPE option<record<crm_lead>>;
DEFINE FIELD name ON crm_event_attendee TYPE option<string>;

DEFINE INDEX idx_crm_event_attendee_event ON crm_event_attendee FIELDS event;
DEFINE INDEX idx_crm_event_attendee_contact ON crm_event_attendee FIELDS contactPartner;

LET $sm_id = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_crm' LIMIT 1)[0].id;
LET $t_rec = fn::builder_table_create_record('crm_event_attendee', $sm_id, 'CRM EventAttendee', true, true, true, $phase, ['module_crm'], $run_id);
LET $f_rec = fn::builder_function_create_record('crm_event_attendee_create_table_initialise', $sm_id, 'Crée la table crm_event_attendee', true, true, true, 'deploy', NONE, $phase, ['module_crm'], $run_id);

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création crm_event_attendee', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table crm_event_attendee'
PERMISSIONS FULL;


