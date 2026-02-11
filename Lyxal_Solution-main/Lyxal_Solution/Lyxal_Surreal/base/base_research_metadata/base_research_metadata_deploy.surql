DEFINE FUNCTION IF NOT EXISTS fn::base_research_metadata_deploy(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $log_phase = IF $phase == NONE THEN 'log_deploy' ELSE (IF string::trim($phase) == '' THEN 'log_deploy' ELSE $phase END) END;
LET $total_steps = 19;

LET $start = fn::system_log_create_record([$log_phase, 'log_sub_module', 'log_deploy', 'log_start', 'log_initialise'], 'Start: déploiement du sous-module base_research_metadata', { run_id: $run_id, parent_run_id: $parent_run_id });

-- Étape 1: créer/valider sous-module
LET $p0s = fn::system_log_create_record([$log_phase, 'log_sub_module', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 1/10 - base_research_metadata (création/validation sous-module)', { run_id: $run_id, parent_run_id: $parent_run_id, step: 1, total_steps: $total_steps, sub: 'sub_module_base_research_metadata' });
LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_research_metadata' LIMIT 1)[0];
IF $sm == NONE {
  LET $mod_base = (SELECT id FROM builder_module WHERE module_code = 'module_base' LIMIT 1)[0];
  IF $mod_base == NONE { RETURN { success: false, run_id: $run_id, step: 1, message: 'module_base introuvable' }; };
  LET $create_sm = fn::builder_sub_module_create_record('base_research_metadata', $mod_base.id, 'Sous-module recherche & métadonnées', true, true, true, $log_phase, ['module_base'], $run_id);
  IF $create_sm.success != true { RETURN { success: false, run_id: $run_id, step: 1, result: $create_sm }; };
};

-- Étapes 2..10: créer les tables
LET $p2 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 2/10 - base_meta_model', { run_id: $run_id, parent_run_id: $parent_run_id, step: 2, total_steps: $total_steps, sub: 'base_meta_model' });
LET $s2 = fn::base_meta_model_create_table_initialise($run_id, $log_phase);
IF $s2.success != true { RETURN { success: false, run_id: $run_id, step: 2, result: $s2 }; };

LET $p3 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 3/10 - base_meta_field', { run_id: $run_id, parent_run_id: $parent_run_id, step: 3, total_steps: $total_steps, sub: 'base_meta_field' });
LET $s3 = fn::base_meta_field_create_table_initialise($run_id, $log_phase);
IF $s3.success != true { RETURN { success: false, run_id: $run_id, step: 3, result: $s3 }; };

LET $p4 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 4/10 - base_meta_file', { run_id: $run_id, parent_run_id: $parent_run_id, step: 4, total_steps: $total_steps, sub: 'base_meta_file' });
LET $s4 = fn::base_meta_file_create_table_initialise($run_id, $log_phase);
IF $s4.success != true { RETURN { success: false, run_id: $run_id, step: 4, result: $s4 }; };

LET $p5 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 5/10 - base_research_request', { run_id: $run_id, parent_run_id: $parent_run_id, step: 5, total_steps: $total_steps, sub: 'base_research_request' });
LET $s5 = fn::base_research_request_create_table_initialise($run_id, $log_phase);
IF $s5.success != true { RETURN { success: false, run_id: $run_id, step: 5, result: $s5 }; };

LET $p6 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 6/10 - base_research_parameter', { run_id: $run_id, parent_run_id: $parent_run_id, step: 6, total_steps: $total_steps, sub: 'base_research_parameter' });
LET $s6 = fn::base_research_parameter_create_table_initialise($run_id, $log_phase);
IF $s6.success != true { RETURN { success: false, run_id: $run_id, step: 6, result: $s6 }; };

LET $p7 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 7/10 - base_research_parameter_config', { run_id: $run_id, parent_run_id: $parent_run_id, step: 7, total_steps: $total_steps, sub: 'base_research_parameter_config' });
LET $s7 = fn::base_research_parameter_config_create_table_initialise($run_id, $log_phase);
IF $s7.success != true { RETURN { success: false, run_id: $run_id, step: 7, result: $s7 }; };

LET $p8 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 8/10 - base_research_result_line', { run_id: $run_id, parent_run_id: $parent_run_id, step: 8, total_steps: $total_steps, sub: 'base_research_result_line' });
LET $s8 = fn::base_research_result_line_create_table_initialise($run_id, $log_phase);
IF $s8.success != true { RETURN { success: false, run_id: $run_id, step: 8, result: $s8 }; };

LET $p9 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 9/10 - base_research_primary_key', { run_id: $run_id, parent_run_id: $parent_run_id, step: 9, total_steps: $total_steps, sub: 'base_research_primary_key' });
LET $s9 = fn::base_research_primary_key_create_table_initialise($run_id, $log_phase);
IF $s9.success != true { RETURN { success: false, run_id: $run_id, step: 9, result: $s9 }; };

LET $p10 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 10/12 - base_indicator_generator', { run_id: $run_id, parent_run_id: $parent_run_id, step: 10, total_steps: $total_steps, sub: 'base_indicator_generator' });
LET $s10 = fn::base_indicator_generator_create_table_initialise($run_id, $log_phase);
IF $s10.success != true { RETURN { success: false, run_id: $run_id, step: 10, result: $s10 }; };

LET $p11 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 11/12 - base_indicator_generator_grouping', { run_id: $run_id, parent_run_id: $parent_run_id, step: 11, total_steps: $total_steps, sub: 'base_indicator_generator_grouping' });
LET $s11 = fn::base_indicator_generator_grouping_create_table_initialise($run_id, $log_phase);
IF $s11.success != true { RETURN { success: false, run_id: $run_id, step: 11, result: $s11 }; };

LET $p12 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 12/16 - base_abc_analysis', { run_id: $run_id, parent_run_id: $parent_run_id, step: 12, total_steps: $total_steps, sub: 'base_abc_analysis' });
LET $s12a = fn::base_meta_schedule_create_table_initialise($run_id, $log_phase);
IF $s12a.success != true { RETURN { success: false, run_id: $run_id, step: 12, result: $s12a }; };
LET $s12b = fn::base_abc_analysis_create_table_initialise($run_id, $log_phase);
IF $s12b.success != true { RETURN { success: false, run_id: $run_id, step: 12, result: $s12b }; };

LET $p13 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 13/16 - base_abc_analysis_class', { run_id: $run_id, parent_run_id: $parent_run_id, step: 13, total_steps: $total_steps, sub: 'base_abc_analysis_class' });
LET $s13 = fn::base_abc_analysis_class_create_table_initialise($run_id, $log_phase);
IF $s13.success != true { RETURN { success: false, run_id: $run_id, step: 13, result: $s13 }; };

LET $p14 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 14/16 - base_abc_analysis_line', { run_id: $run_id, parent_run_id: $parent_run_id, step: 14, total_steps: $total_steps, sub: 'base_abc_analysis_line' });
LET $s14 = fn::base_abc_analysis_line_create_table_initialise($run_id, $log_phase);
IF $s14.success != true { RETURN { success: false, run_id: $run_id, step: 14, result: $s14 }; };

LET $p15 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 15/16 - base_global_tracking*', { run_id: $run_id, parent_run_id: $parent_run_id, step: 15, total_steps: $total_steps, sub: 'base_global_tracking*' });
LET $s15 = fn::base_global_tracking_create_tables_initialise($run_id, $log_phase);
IF $s15.success != true { RETURN { success: false, run_id: $run_id, step: 15, result: $s15 }; };

LET $p16 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 16/16 - base_meta_schedule + base_meta_group_menu_assistant + base_pick_list_entry + base_pfx_certificate', { run_id: $run_id, parent_run_id: $parent_run_id, step: 16, total_steps: $total_steps, sub: 'remaining_tables' });
LET $s16a = fn::base_meta_group_menu_assistant_create_table_initialise($run_id, $log_phase);
IF $s16a.success != true { RETURN { success: false, run_id: $run_id, step: 16, result: $s16a }; };
LET $s16b = fn::base_pick_list_entry_create_table_initialise($run_id, $log_phase);
IF $s16b.success != true { RETURN { success: false, run_id: $run_id, step: 16, result: $s16b }; };
LET $s16c = fn::base_pfx_certificate_create_table_initialise($run_id, $log_phase);
IF $s16c.success != true { RETURN { success: false, run_id: $run_id, step: 16, result: $s16c }; };

LET $p17 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 17/19 - base_attribution_model', { run_id: $run_id, parent_run_id: $parent_run_id, step: 17, total_steps: $total_steps, sub: 'base_attribution_model' });
LET $s17 = fn::base_attribution_model_create_table_initialise($run_id, $log_phase);
IF $s17.success != true { RETURN { success: false, run_id: $run_id, step: 17, result: $s17 }; };

LET $p18 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 18/19 - base_period_type', { run_id: $run_id, parent_run_id: $parent_run_id, step: 18, total_steps: $total_steps, sub: 'base_period_type' });
LET $s18 = fn::base_period_type_create_table_initialise($run_id, $log_phase);
IF $s18.success != true { RETURN { success: false, run_id: $run_id, step: 18, result: $s18 }; };

LET $p19 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 19/19 - base_report_type', { run_id: $run_id, parent_run_id: $parent_run_id, step: 19, total_steps: $total_steps, sub: 'base_report_type' });
LET $s19 = fn::base_report_type_create_table_initialise($run_id, $log_phase);
IF $s19.success != true { RETURN { success: false, run_id: $run_id, step: 19, result: $s19 }; };

-- Référencer la fonction
LET $p_ref = fn::system_log_create_record([$log_phase, 'log_function', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: référence function base_research_metadata_deploy', { run_id: $run_id, parent_run_id: $parent_run_id, sub: 'builder_function_reference' });
LET $sm2 = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_research_metadata' LIMIT 1)[0];
IF $sm2 == NONE { RETURN { success: false, run_id: $run_id }; };
LET $ref_fn = fn::builder_function_create_record('base_research_metadata_deploy', $sm2.id, 'Déploie le sous-module recherche & métadonnées', true, true, true, 'deploy', NONE, $log_phase, ['module_base'], $run_id);
IF $ref_fn.success != true { RETURN { success: false, run_id: $run_id, result: $ref_fn }; };

LET $done = fn::system_log_create_record([$log_phase, 'log_sub_module', 'log_deploy', 'log_done', 'log_success'], 'Done: déploiement du sous-module base_research_metadata', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Déploie le sous-module recherche & métadonnées'
PERMISSIONS FULL;

