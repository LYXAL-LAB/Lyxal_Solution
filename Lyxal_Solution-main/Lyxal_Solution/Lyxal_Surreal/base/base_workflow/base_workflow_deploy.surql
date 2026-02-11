DEFINE FUNCTION IF NOT EXISTS fn::base_workflow_deploy(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $log_phase = IF $phase == NONE THEN 'log_deploy' ELSE (IF string::trim($phase) == '' THEN 'log_deploy' ELSE $phase END) END;
LET $total_steps = 15;

LET $start = fn::system_log_create_record([$log_phase, 'log_sub_module', 'log_deploy', 'log_start', 'log_initialise'], 'Start: déploiement du sous-module base_workflow', { run_id: $run_id, parent_run_id: $parent_run_id });

-- Étape 1: créer/valider sous-module
LET $p0s = fn::system_log_create_record([$log_phase, 'log_sub_module', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 1/10 - base_workflow (création/validation sous-module)', { run_id: $run_id, parent_run_id: $parent_run_id, step: 1, total_steps: $total_steps, sub: 'sub_module_base_workflow' });
LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_workflow' LIMIT 1)[0];
IF $sm == NONE {
  LET $mod_base = (SELECT id FROM builder_module WHERE module_code = 'module_base' LIMIT 1)[0];
  IF $mod_base == NONE { RETURN { success: false, run_id: $run_id, step: 1, message: 'module_base introuvable' }; };
  LET $create_sm = fn::builder_sub_module_create_record('base_workflow', $mod_base.id, 'Sous-module workflow & système', true, true, true, $log_phase, ['module_base'], $run_id);
  IF $create_sm.success != true { RETURN { success: false, run_id: $run_id, step: 1, result: $create_sm }; };
};

-- Étapes 2..10: tables
LET $p2 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 2/10 - base_mail_batch', { run_id: $run_id, parent_run_id: $parent_run_id, step: 2, total_steps: $total_steps, sub: 'base_mail_batch' });
LET $s2 = fn::base_mail_batch_create_table_initialise($run_id, $log_phase);
IF $s2.success != true { RETURN { success: false, run_id: $run_id, step: 2, result: $s2 }; };

LET $p3 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 3/11 - base_batch', { run_id: $run_id, parent_run_id: $parent_run_id, step: 3, total_steps: $total_steps, sub: 'base_batch' });
LET $s3 = fn::base_batch_create_table_initialise($run_id, $log_phase);
IF $s3.success != true { RETURN { success: false, run_id: $run_id, step: 3, result: $s3 }; };

LET $p4 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 4/10 - base_timer', { run_id: $run_id, parent_run_id: $parent_run_id, step: 4, total_steps: $total_steps, sub: 'base_timer' });
LET $s4 = fn::base_timer_create_table_initialise($run_id, $log_phase);
IF $s4.success != true { RETURN { success: false, run_id: $run_id, step: 4, result: $s4 }; };

LET $p5 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 5/10 - base_timer_history', { run_id: $run_id, parent_run_id: $parent_run_id, step: 5, total_steps: $total_steps, sub: 'base_timer_history' });
LET $s5 = fn::base_timer_history_create_table_initialise($run_id, $log_phase);
IF $s5.success != true { RETURN { success: false, run_id: $run_id, step: 5, result: $s5 }; };

LET $p6 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 6/10 - base_sequence_version', { run_id: $run_id, parent_run_id: $parent_run_id, step: 6, total_steps: $total_steps, sub: 'base_sequence_version' });
LET $s6 = fn::base_sequence_version_create_table_initialise($run_id, $log_phase);
IF $s6.success != true { RETURN { success: false, run_id: $run_id, step: 6, result: $s6 }; };

LET $p7 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 7/10 - base_trace_back', { run_id: $run_id, parent_run_id: $parent_run_id, step: 7, total_steps: $total_steps, sub: 'base_trace_back' });
LET $s7 = fn::base_trace_back_create_table_initialise($run_id, $log_phase);
IF $s7.success != true { RETURN { success: false, run_id: $run_id, step: 7, result: $s7 }; };

LET $p8 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 8/10 - base_stop_reason', { run_id: $run_id, parent_run_id: $parent_run_id, step: 8, total_steps: $total_steps, sub: 'base_stop_reason' });
LET $s8 = fn::base_stop_reason_create_table_initialise($run_id, $log_phase);
IF $s8.success != true { RETURN { success: false, run_id: $run_id, step: 8, result: $s8 }; };

LET $p8b = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 9/11 - base_blocking', { run_id: $run_id, parent_run_id: $parent_run_id, step: 9, total_steps: $total_steps, sub: 'base_blocking' });
LET $s8b = fn::base_blocking_create_table_initialise($run_id, $log_phase);
IF $s8b.success != true { RETURN { success: false, run_id: $run_id, step: 9, result: $s8b }; };

LET $p9 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 9/10 - base_sharing_setting', { run_id: $run_id, parent_run_id: $parent_run_id, step: 9, total_steps: $total_steps, sub: 'base_sharing_setting' });
LET $s9 = fn::base_sharing_setting_create_table_initialise($run_id, $log_phase);
IF $s9.success != true { RETURN { success: false, run_id: $run_id, step: 9, result: $s9 }; };

-- Sequence (nouvelle étape avant approval_level)
-- Nouvelle table BaseBatch
LET $p3b = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 4/13 - base_base_batch', { run_id: $run_id, parent_run_id: $parent_run_id, step: 4, total_steps: $total_steps, sub: 'base_base_batch' });
LET $s3b = fn::base_base_batch_create_table_initialise($run_id, $log_phase);
IF $s3b.success != true { RETURN { success: false, run_id: $run_id, step: 4, result: $s3b }; };

LET $p10 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 10/13 - base_sequence', { run_id: $run_id, parent_run_id: $parent_run_id, step: 10, total_steps: $total_steps, sub: 'base_sequence' });
LET $s10 = fn::base_sequence_create_table_initialise($run_id, $log_phase);
IF $s10.success != true { RETURN { success: false, run_id: $run_id, step: 10, result: $s10 }; };

LET $p11 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 11/12 - base_approval_level', { run_id: $run_id, parent_run_id: $parent_run_id, step: 11, total_steps: $total_steps, sub: 'base_approval_level' });
LET $s10 = fn::base_approval_level_create_table_initialise($run_id, $log_phase);
IF $s10.success != true { RETURN { success: false, run_id: $run_id, step: 11, result: $s10 }; };

-- CancelReason (nouvelle étape)
LET $p_cancel = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 12/14 - base_cancel_reason', { run_id: $run_id, parent_run_id: $parent_run_id, step: 12, total_steps: $total_steps, sub: 'base_cancel_reason' });
LET $s_cancel = fn::base_cancel_reason_create_table_initialise($run_id, $log_phase);
IF $s_cancel.success != true { RETURN { success: false, run_id: $run_id, step: 12, result: $s_cancel }; };

LET $p12 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 13/14 - base_routing*', { run_id: $run_id, parent_run_id: $parent_run_id, step: 13, total_steps: $total_steps, sub: 'base_routing*' });
LET $s12 = fn::base_routing_create_tables_initialise($run_id, $log_phase);
IF $s12.success != true { RETURN { success: false, run_id: $run_id, step: 12, result: $s12 }; };

LET $p_ref = fn::system_log_create_record([$log_phase, 'log_function', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: référence function base_workflow_deploy', { run_id: $run_id, parent_run_id: $parent_run_id, sub: 'builder_function_reference' });
LET $sm2 = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_workflow' LIMIT 1)[0];
IF $sm2 == NONE { RETURN { success: false, run_id: $run_id }; };
LET $ref_fn = fn::builder_function_create_record('base_workflow_deploy', $sm2.id, 'Déploie le sous-module workflow & système', true, true, true, 'deploy', NONE, $log_phase, ['module_base'], $run_id);
IF $ref_fn.success != true { RETURN { success: false, run_id: $run_id, result: $ref_fn }; };

LET $done = fn::system_log_create_record([$log_phase, 'log_sub_module', 'log_deploy', 'log_done', 'log_success'], 'Done: déploiement du sous-module base_workflow', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Déploie le sous-module workflow & système'
PERMISSIONS FULL;

