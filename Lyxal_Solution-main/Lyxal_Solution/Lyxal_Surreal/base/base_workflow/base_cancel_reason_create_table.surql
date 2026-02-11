DEFINE FUNCTION IF NOT EXISTS fn::base_cancel_reason_create_table_initialise(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $start = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_start', 'log_initialise'], 'Start: création de la table base_cancel_reason', { run_id: $run_id, parent_run_id: $parent_run_id });

DEFINE TABLE IF NOT EXISTS base_cancel_reason TYPE NORMAL SCHEMAFULL
COMMENT 'CancelReason (Axelor)'
PERMISSIONS FULL;

DEFINE FIELD name ON base_cancel_reason TYPE string;
DEFINE FIELD freeText ON base_cancel_reason TYPE option<bool>;
DEFINE FIELD applicationType ON base_cancel_reason TYPE option<string>;

DEFINE FIELD created_at ON base_cancel_reason TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON base_cancel_reason TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_base_cancel_reason_name ON base_cancel_reason FIELDS name;

LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_workflow' LIMIT 1)[0];
IF $sm == NONE { RETURN { success: false, run_id: $run_id, message: 'sub_module_base_workflow introuvable' }; };
LET $t_rec = fn::builder_table_create_record('base_cancel_reason', $sm.id, 'Motifs d\'annulation (Axelor)', true, true, true, $phase, ['module_base'], $run_id);
IF $t_rec.success != true { RETURN { success: false, run_id: $run_id, result: $t_rec }; };

LET $f_rec = fn::builder_function_create_record('base_cancel_reason_create_table_initialise', $sm.id, 'Crée la table base_cancel_reason', true, true, true, 'deploy', NONE, $phase, ['module_base'], $run_id);
IF $f_rec.success != true { RETURN { success: false, run_id: $run_id, result: $f_rec }; };

LET $done = fn::system_log_create_record([$phase, 'log_table', 'log_create', 'log_done', 'log_success'], 'Done: création base_cancel_reason', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Crée la table base_cancel_reason'
PERMISSIONS FULL;

