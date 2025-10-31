DEFINE FUNCTION IF NOT EXISTS fn::crm_event_reminder_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table crm_event_reminder', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS crm_event_reminder TYPE NORMAL SCHEMAFULL
COMMENT 'CRM EventReminder'
PERMISSIONS FULL;

DEFINE FIELD event ON crm_event_reminder TYPE record<crm_event>;
DEFINE FIELD typeSelect ON crm_event_reminder TYPE int DEFAULT 1;
DEFINE FIELD modeSelect ON crm_event_reminder TYPE int DEFAULT 1;
DEFINE FIELD user ON crm_event_reminder TYPE record<base_user>;
DEFINE FIELD duration ON crm_event_reminder TYPE option<int>;
DEFINE FIELD durationTypeSelect ON crm_event_reminder TYPE option<int>;
DEFINE FIELD assignToSelect ON crm_event_reminder TYPE int DEFAULT 1;
DEFINE FIELD isReminded ON crm_event_reminder TYPE bool DEFAULT false;
DEFINE FIELD sendingDateT ON crm_event_reminder TYPE option<datetime>;
DEFINE FIELD batchSet ON crm_event_reminder TYPE array<record<base_batch>>;

LET $sm_id = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_crm' LIMIT 1)[0].id;
LET $t_rec = fn::builder_table_create_record('crm_event_reminder', $sm_id, 'CRM EventReminder', true, true, true, $phase, ['module_crm'], $run_id);
LET $f_rec = fn::builder_function_create_record('crm_event_reminder_create_table_initialise', $sm_id, 'Crée la table crm_event_reminder', true, true, true, 'deploy', NONE, $phase, ['module_crm'], $run_id);

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création crm_event_reminder', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table crm_event_reminder'
PERMISSIONS FULL;


