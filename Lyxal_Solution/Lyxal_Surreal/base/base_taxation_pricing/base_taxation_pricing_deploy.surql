DEFINE FUNCTION IF NOT EXISTS fn::base_taxation_pricing_deploy(
  $parent_run_id: option<string>,
  $phase: string
) {
LET $run_id = rand::uuid();
LET $log_phase = IF $phase == NONE THEN 'log_deploy' ELSE (IF string::trim($phase) == '' THEN 'log_deploy' ELSE $phase END) END;
LET $total_steps = 11;

LET $start = fn::system_log_create_record([$log_phase, 'log_sub_module', 'log_deploy', 'log_start', 'log_initialise'], 'Start: déploiement du sous-module base_taxation_pricing', { run_id: $run_id, parent_run_id: $parent_run_id });

-- Étape 1: créer/valider sous-module
LET $p0s = fn::system_log_create_record([$log_phase, 'log_sub_module', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 1/4 - base_taxation_pricing (création/validation sous-module)', { run_id: $run_id, parent_run_id: $parent_run_id, step: 1, total_steps: $total_steps, sub: 'sub_module_base_taxation_pricing' });
LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_taxation_pricing' LIMIT 1)[0];
IF $sm == NONE {
  LET $mod_base = (SELECT id FROM builder_module WHERE module_code = 'module_base' LIMIT 1)[0];
  IF $mod_base == NONE { RETURN { success: false, run_id: $run_id, step: 1, message: 'module_base introuvable' }; };
  LET $create_sm = fn::builder_sub_module_create_record('base_taxation_pricing', $mod_base.id, 'Sous-module taxation & pricing', true, true, true, $log_phase, ['module_base'], $run_id);
  IF $create_sm.success != true { RETURN { success: false, run_id: $run_id, step: 1, result: $create_sm }; };
};

-- Étape 2: base_tax_type
LET $p1 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 2/8 - base_tax_type', { run_id: $run_id, parent_run_id: $parent_run_id, step: 2, total_steps: $total_steps, sub: 'base_tax_type' });
LET $s1 = fn::base_tax_type_create_table_initialise($run_id, $log_phase);
IF $s1.success != true { RETURN { success: false, run_id: $run_id, step: 2, result: $s1 }; };

-- Étape 3: base_tax
LET $p2a = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 3/8 - base_tax', { run_id: $run_id, parent_run_id: $parent_run_id, step: 3, total_steps: $total_steps, sub: 'base_tax' });
LET $s2a = fn::base_tax_create_table_initialise($run_id, $log_phase);
IF $s2a.success != true { RETURN { success: false, run_id: $run_id, step: 3, result: $s2a }; };

-- Étape 4: base_tax_line
LET $p2b = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 4/8 - base_tax_line', { run_id: $run_id, parent_run_id: $parent_run_id, step: 4, total_steps: $total_steps, sub: 'base_tax_line' });
LET $s2b = fn::base_tax_line_create_table_initialise($run_id, $log_phase);
IF $s2b.success != true { RETURN { success: false, run_id: $run_id, step: 4, result: $s2b }; };

-- Étape 5: base_tax_equiv
LET $p2c = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 5/8 - base_tax_equiv', { run_id: $run_id, parent_run_id: $parent_run_id, step: 5, total_steps: $total_steps, sub: 'base_tax_equiv' });
LET $s2c = fn::base_tax_equiv_create_table_initialise($run_id, $log_phase);
IF $s2c.success != true { RETURN { success: false, run_id: $run_id, step: 5, result: $s2c }; };

-- Étape 6: base_pricing_rule
LET $p3a = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 6/8 - base_pricing_rule', { run_id: $run_id, parent_run_id: $parent_run_id, step: 6, total_steps: $total_steps, sub: 'base_pricing_rule' });
LET $s3a = fn::base_pricing_rule_create_table_initialise($run_id, $log_phase);
IF $s3a.success != true { RETURN { success: false, run_id: $run_id, step: 6, result: $s3a }; };

-- Étape 7: base_pricing
LET $p3b = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 7/8 - base_pricing', { run_id: $run_id, parent_run_id: $parent_run_id, step: 7, total_steps: $total_steps, sub: 'base_pricing' });
LET $s3b = fn::base_pricing_create_table_initialise($run_id, $log_phase);
IF $s3b.success != true { RETURN { success: false, run_id: $run_id, step: 7, result: $s3b }; };

-- Étape 8: base_pricing_line
LET $p3c = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 8/10 - base_pricing_line', { run_id: $run_id, parent_run_id: $parent_run_id, step: 8, total_steps: $total_steps, sub: 'base_pricing_line' });
LET $s3c = fn::base_pricing_line_create_table_initialise($run_id, $log_phase);
IF $s3c.success != true { RETURN { success: false, run_id: $run_id, step: 8, result: $s3c }; };

-- Étape 9: base_shipping_coef
LET $p3d = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 9/10 - base_shipping_coef', { run_id: $run_id, parent_run_id: $parent_run_id, step: 9, total_steps: $total_steps, sub: 'base_shipping_coef' });
LET $s3d = fn::base_shipping_coef_create_table_initialise($run_id, $log_phase);
IF $s3d.success != true { RETURN { success: false, run_id: $run_id, step: 9, result: $s3d }; };

-- Étape 9: base_account_management
LET $p9 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 10/11 - base_account_management', { run_id: $run_id, parent_run_id: $parent_run_id, step: 10, total_steps: $total_steps, sub: 'base_account_management' });
LET $s9 = fn::base_account_management_create_table_initialise($run_id, $log_phase);
IF $s9.success != true { RETURN { success: false, run_id: $run_id, step: 9, result: $s9 }; };

-- Étape 11: base_fiscal_position
LET $p10 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 11/11 - base_fiscal_position', { run_id: $run_id, parent_run_id: $parent_run_id, step: 11, total_steps: $total_steps, sub: 'base_fiscal_position' });
LET $s10 = fn::base_fiscal_position_create_table_initialise($run_id, $log_phase);
IF $s10.success != true { RETURN { success: false, run_id: $run_id, step: 11, result: $s10 }; };

-- Étape 4: référencer la fonction
LET $p_ref = fn::system_log_create_record([$log_phase, 'log_function', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: référence function base_taxation_pricing_deploy', { run_id: $run_id, parent_run_id: $parent_run_id, sub: 'builder_function_reference' });
LET $sm2 = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_taxation_pricing' LIMIT 1)[0];
IF $sm2 == NONE { RETURN { success: false, run_id: $run_id }; };
LET $ref_fn = fn::builder_function_create_record('base_taxation_pricing_deploy', $sm2.id, 'Déploie le sous-module taxation & pricing', true, true, true, 'deploy', NONE, $log_phase, ['module_base'], $run_id);
IF $ref_fn.success != true { RETURN { success: false, run_id: $run_id, result: $ref_fn }; };

LET $done = fn::system_log_create_record([$log_phase, 'log_sub_module', 'log_deploy', 'log_done', 'log_success'], 'Done: déploiement du sous-module base_taxation_pricing', { run_id: $run_id, parent_run_id: $parent_run_id });
RETURN { success: true, run_id: $run_id };
}
COMMENT 'Déploie le sous-module taxation & pricing'
PERMISSIONS FULL;

