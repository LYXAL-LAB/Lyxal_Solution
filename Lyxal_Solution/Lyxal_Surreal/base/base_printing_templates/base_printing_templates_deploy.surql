DEFINE FUNCTION IF NOT EXISTS fn::base_printing_templates_deploy(
  $parent_run_id: option<string>,
  $phase: string
) {
  LET $run_id = rand::uuid();
  LET $log_phase = IF $phase == NONE THEN 'log_deploy' ELSE (IF string::trim($phase) == '' THEN 'log_deploy' ELSE $phase END) END;
  LET $total_steps = 6;

  LET $start = fn::system_log_create_record([$log_phase, 'log_sub_module', 'log_deploy', 'log_start', 'log_initialise'], 'Start: déploiement du sous-module base_printing_templates', { run_id: $run_id, parent_run_id: $parent_run_id });

  -- Étape 1: créer/valider sous-module
  LET $p0s = fn::system_log_create_record([$log_phase, 'log_sub_module', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 1/4 - base_printing_templates (création/validation sous-module)', { run_id: $run_id, parent_run_id: $parent_run_id, step: 1, total_steps: $total_steps, sub: 'sub_module_base_printing_templates' });
  LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_printing_templates' LIMIT 1)[0];
  IF $sm == NONE {
    LET $mod_base = (SELECT id FROM builder_module WHERE module_code = 'module_base' LIMIT 1)[0];
    IF $mod_base == NONE { RETURN { success: false, run_id: $run_id, step: 1, message: 'module_base introuvable' }; };
    LET $create_sm = fn::builder_sub_module_create_record('base_printing_templates', $mod_base.id, 'Sous-module impression (Print, Templates, BIRT)', true, true, true, $log_phase, ['module_base'], $run_id);
    IF $create_sm.success != true { RETURN { success: false, run_id: $run_id, step: 1, result: $create_sm }; };
  };

  -- Étape 2..4: tables BIRT
  LET $p2 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 2/4 - base_birt_template', { run_id: $run_id, parent_run_id: $parent_run_id, step: 2, total_steps: $total_steps, sub: 'base_birt_template' });
  LET $s2 = fn::base_birt_template_create_table_initialise($run_id, $log_phase);
  IF $s2.success != true { RETURN { success: false, run_id: $run_id, step: 2, result: $s2 }; };

  LET $p3 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 3/4 - base_birt_template_parameter', { run_id: $run_id, parent_run_id: $parent_run_id, step: 3, total_steps: $total_steps, sub: 'base_birt_template_parameter' });
  LET $s3 = fn::base_birt_template_parameter_create_table_initialise($run_id, $log_phase);
  IF $s3.success != true { RETURN { success: false, run_id: $run_id, step: 3, result: $s3 }; };

  LET $p4 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 4/4 - base_birt_printing_wizard', { run_id: $run_id, parent_run_id: $parent_run_id, step: 4, total_steps: $total_steps, sub: 'base_birt_printing_wizard' });
  LET $s4 = fn::base_birt_printing_wizard_create_table_initialise($run_id, $log_phase);
  IF $s4.success != true { RETURN { success: false, run_id: $run_id, step: 4, result: $s4 }; };

  -- Étape 5: TradingName
  LET $p5 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 5/6 - base_trading_name', { run_id: $run_id, parent_run_id: $parent_run_id, step: 5, total_steps: $total_steps, sub: 'base_trading_name' });
  LET $s5 = fn::base_trading_name_create_table_initialise($run_id, $log_phase);
  IF $s5.success != true { RETURN { success: false, run_id: $run_id, step: 5, result: $s5 }; };

  -- Étape 6: TradingNamePrintingSettings
  LET $p6 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 6/6 - base_trading_name_printing_settings', { run_id: $run_id, parent_run_id: $parent_run_id, step: 6, total_steps: $total_steps, sub: 'base_trading_name_printing_settings' });
  LET $s6 = fn::base_trading_name_printing_settings_create_table_initialise($run_id, $log_phase);
  IF $s6.success != true { RETURN { success: false, run_id: $run_id, step: 6, result: $s6 }; };

  -- Référence deploy
  LET $p_ref = fn::system_log_create_record([$log_phase, 'log_function', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: référence function base_printing_templates_deploy', { run_id: $run_id, parent_run_id: $parent_run_id, sub: 'builder_function_reference' });
  LET $sm2 = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_printing_templates' LIMIT 1)[0];
  IF $sm2 == NONE { RETURN { success: false, run_id: $run_id }; };
  LET $ref_fn = fn::builder_function_create_record('base_printing_templates_deploy', $sm2.id, 'Déploie le sous-module impression (Print, Templates, BIRT)', true, true, true, 'deploy', NONE, $log_phase, ['module_base'], $run_id);
  IF $ref_fn.success != true { RETURN { success: false, run_id: $run_id, result: $ref_fn }; };

  LET $done = fn::system_log_create_record([$log_phase, 'log_sub_module', 'log_deploy', 'log_done', 'log_success'], 'Done: déploiement du sous-module base_printing_templates', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Déploie le sous-module impression (Print, Templates, BIRT)'
PERMISSIONS FULL;

