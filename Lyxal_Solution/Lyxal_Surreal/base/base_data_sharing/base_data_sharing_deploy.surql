DEFINE FUNCTION IF NOT EXISTS fn::base_data_sharing_deploy(
  $parent_run_id: option<string>,
  $phase: string
) {
  LET $run_id = rand::uuid();
  LET $log_phase = IF $phase == NONE THEN 'log_deploy' ELSE (IF string::trim($phase) == '' THEN 'log_deploy' ELSE $phase END) END;
  LET $total_steps = 11;

  LET $start = fn::system_log_create_record([$log_phase, 'log_sub_module', 'log_deploy', 'log_start', 'log_initialise'], 'Start: déploiement du sous-module base_data_sharing', { run_id: $run_id, parent_run_id: $parent_run_id });

  -- Étape 1: créer/valider sous-module
  LET $p0s = fn::system_log_create_record([$log_phase, 'log_sub_module', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 1/3 - base_data_sharing (création/validation sous-module)', { run_id: $run_id, parent_run_id: $parent_run_id, step: 1, total_steps: $total_steps, sub: 'sub_module_base_data_sharing' });
  LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_data_sharing' LIMIT 1)[0];
  IF $sm == NONE {
    LET $mod_base = (SELECT id FROM builder_module WHERE module_code = 'module_base' LIMIT 1)[0];
    IF $mod_base == NONE { RETURN { success: false, run_id: $run_id, step: 1, message: 'module_base introuvable' }; };
    LET $create_sm = fn::builder_sub_module_create_record('base_data_sharing', $mod_base.id, 'Sous-module data sharing (Axelor)', true, true, true, $log_phase, ['module_base'], $run_id);
    IF $create_sm.success != true { RETURN { success: false, run_id: $run_id, step: 1, result: $create_sm }; };
  };

  -- Étape 2: tables (DataSharingReferential/Line)
  LET $p2 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 2/3 - base_data_sharing_referential', { run_id: $run_id, parent_run_id: $parent_run_id, step: 2, total_steps: $total_steps, sub: 'base_data_sharing_referential' });
  LET $s2 = fn::base_data_sharing_referential_create_table_initialise($run_id, $log_phase);
  IF $s2.success != true { RETURN { success: false, run_id: $run_id, step: 2, result: $s2 }; };

  LET $p2b = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 2/3 - base_data_sharing_referential_line', { run_id: $run_id, parent_run_id: $parent_run_id, step: 2, total_steps: $total_steps, sub: 'base_data_sharing_referential_line' });
  LET $s2b = fn::base_data_sharing_referential_line_create_table_initialise($run_id, $log_phase);
  IF $s2b.success != true { RETURN { success: false, run_id: $run_id, step: 2, result: $s2b }; };

  -- Étape 3: AdvancedExport(+Line)
  LET $p3 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 3/5 - base_advanced_export', { run_id: $run_id, parent_run_id: $parent_run_id, step: 3, total_steps: $total_steps, sub: 'base_advanced_export' });
  LET $s3 = fn::base_advanced_export_create_table_initialise($run_id, $log_phase);
  IF $s3.success != true { RETURN { success: false, run_id: $run_id, step: 3, result: $s3 }; };

  LET $p4 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 4/5 - base_advanced_export_line', { run_id: $run_id, parent_run_id: $parent_run_id, step: 4, total_steps: $total_steps, sub: 'base_advanced_export_line' });
  LET $s4 = fn::base_advanced_export_line_create_table_initialise($run_id, $log_phase);
  IF $s4.success != true { RETURN { success: false, run_id: $run_id, step: 4, result: $s4 }; };

  -- Étape 5: AdvancedImport + référencer la fonction
  LET $p5 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 5/5 - base_advanced_import', { run_id: $run_id, parent_run_id: $parent_run_id, step: 5, total_steps: $total_steps, sub: 'base_advanced_import' });
  LET $s5 = fn::base_advanced_import_create_table_initialise($run_id, $log_phase);
  IF $s5.success != true { RETURN { success: false, run_id: $run_id, step: 5, result: $s5 }; };

  -- Étape 6: DataSharingProductWizard
  LET $p6b = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 6/11 - base_data_sharing_product_wizard', { run_id: $run_id, parent_run_id: $parent_run_id, step: 6, total_steps: $total_steps, sub: 'base_data_sharing_product_wizard' });
  LET $s6b = fn::base_data_sharing_product_wizard_create_table_initialise($run_id, $log_phase);
  IF $s6b.success != true { RETURN { success: false, run_id: $run_id, step: 6, result: $s6b }; };

  -- Étape 6: ImportConfiguration
  LET $p6 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 6/10 - base_import_configuration', { run_id: $run_id, parent_run_id: $parent_run_id, step: 6, total_steps: $total_steps, sub: 'base_import_configuration' });
  LET $s6 = fn::base_import_configuration_create_table_initialise($run_id, $log_phase);
  IF $s6.success != true { RETURN { success: false, run_id: $run_id, step: 6, result: $s6 }; };

  -- Étape 7: ImportBatch
  LET $p7 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 7/10 - base_import_batch', { run_id: $run_id, parent_run_id: $parent_run_id, step: 7, total_steps: $total_steps, sub: 'base_import_batch' });
  LET $s7 = fn::base_import_batch_create_table_initialise($run_id, $log_phase);
  IF $s7.success != true { RETURN { success: false, run_id: $run_id, step: 7, result: $s7 }; };

  -- Étape 8: ImportExportTranslation
  LET $p8 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 8/10 - base_import_export_translation', { run_id: $run_id, parent_run_id: $parent_run_id, step: 8, total_steps: $total_steps, sub: 'base_import_export_translation' });
  LET $s8 = fn::base_import_export_translation_create_table_initialise($run_id, $log_phase);
  IF $s8.success != true { RETURN { success: false, run_id: $run_id, step: 8, result: $s8 }; };

  -- Étape 9: ImportExportTranslationHistory
  LET $p9 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 9/10 - base_import_export_translation_history', { run_id: $run_id, parent_run_id: $parent_run_id, step: 9, total_steps: $total_steps, sub: 'base_import_export_translation_history' });
  LET $s9 = fn::base_import_export_translation_history_create_table_initialise($run_id, $log_phase);
  IF $s9.success != true { RETURN { success: false, run_id: $run_id, step: 9, result: $s9 }; };

  -- Étape 10: ImportHistory
  LET $p10 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 10/10 - base_import_history', { run_id: $run_id, parent_run_id: $parent_run_id, step: 10, total_steps: $total_steps, sub: 'base_import_history' });
  LET $s10 = fn::base_import_history_create_table_initialise($run_id, $log_phase);
  IF $s10.success != true { RETURN { success: false, run_id: $run_id, step: 10, result: $s10 }; };

  LET $p_ref = fn::system_log_create_record([$log_phase, 'log_function', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: référence function base_data_sharing_deploy', { run_id: $run_id, parent_run_id: $parent_run_id, sub: 'builder_function_reference' });
  LET $sm2 = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_data_sharing' LIMIT 1)[0];
  IF $sm2 == NONE { RETURN { success: false, run_id: $run_id }; };
  LET $ref_fn = fn::builder_function_create_record('base_data_sharing_deploy', $sm2.id, 'Déploie le sous-module data sharing (Axelor)', true, true, true, 'deploy', NONE, $log_phase, ['module_base'], $run_id);
  IF $ref_fn.success != true { RETURN { success: false, run_id: $run_id, result: $ref_fn }; };

  LET $done = fn::system_log_create_record([$log_phase, 'log_sub_module', 'log_deploy', 'log_done', 'log_success'], 'Done: déploiement du sous-module base_data_sharing', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Déploie le sous-module data sharing (Axelor)'
PERMISSIONS FULL;

