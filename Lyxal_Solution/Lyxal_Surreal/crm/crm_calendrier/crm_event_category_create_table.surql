DEFINE FUNCTION IF NOT EXISTS fn::crm_event_category_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table crm_event_category', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS crm_event_category TYPE NORMAL SCHEMAFULL
COMMENT 'CRM EventCategory'
PERMISSIONS FULL;

DEFINE FIELD name ON crm_event_category TYPE string;
DEFINE FIELD code ON crm_event_category TYPE string;
DEFINE FIELD typeSelect ON crm_event_category TYPE int;

DEFINE INDEX idx_crm_event_category_name ON crm_event_category FIELDS name;
DEFINE INDEX idx_crm_event_category_code ON crm_event_category FIELDS code UNIQUE;

LET $mod = (SELECT id FROM builder_module WHERE module_code = 'module_crm' LIMIT 1)[0];
IF $mod == NONE { LET $modc = fn::builder_module_create_record('crm', 'Module CRM', true, true, true, $phase, ['module_crm'], $run_id); };
LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_crm' LIMIT 1)[0];
IF $sm == NONE {
  LET $mod2 = (SELECT id FROM builder_module WHERE module_code = 'module_crm' LIMIT 1)[0];
  LET $smc = fn::builder_sub_module_create_record('crm', $mod2.id, 'Sous-module CRM', true, true, true, $phase, ['module_crm'], $run_id);
};
LET $sm_id = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_crm' LIMIT 1)[0].id;
LET $t_rec = fn::builder_table_create_record('crm_event_category', $sm_id, 'CRM EventCategory', true, true, true, $phase, ['module_crm'], $run_id);
LET $f_rec = fn::builder_function_create_record('crm_event_category_create_table_initialise', $sm_id, 'Crée la table crm_event_category', true, true, true, 'deploy', NONE, $phase, ['module_crm'], $run_id);

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création crm_event_category', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table crm_event_category'
PERMISSIONS FULL;


