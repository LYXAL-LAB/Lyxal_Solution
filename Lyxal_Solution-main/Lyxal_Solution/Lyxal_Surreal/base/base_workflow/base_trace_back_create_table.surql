DEFINE FUNCTION IF NOT EXISTS fn::base_trace_back_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_trace_back', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS base_trace_back TYPE NORMAL SCHEMAFULL
COMMENT 'Traçage des erreurs'
PERMISSIONS FULL;

DEFINE FIELD ref ON base_trace_back TYPE option<string>;
DEFINE FIELD exception ON base_trace_back TYPE option<string>;
DEFINE FIELD trace ON base_trace_back TYPE option<string>;
DEFINE FIELD dateT ON base_trace_back TYPE option<datetime>;

DEFINE FIELD created_at ON base_trace_back TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON base_trace_back TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_base_trace_back_ref ON base_trace_back FIELDS ref;
DEFINE INDEX idx_base_trace_back_date ON base_trace_back FIELDS dateT;

LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_workflow' LIMIT 1)[0];
IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_workflow introuvable' }; };
LET $t_rec = fn::builder_table_create_record('base_trace_back', $sm.id, 'Trace back', true, true, true, $phase, ['module_base'], $run_id);
IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };

LET $f_rec = fn::builder_function_create_record('base_trace_back_create_table_initialise', $sm.id, 'Crée la table base_trace_back', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_trace_back', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_trace_back'
PERMISSIONS FULL;

