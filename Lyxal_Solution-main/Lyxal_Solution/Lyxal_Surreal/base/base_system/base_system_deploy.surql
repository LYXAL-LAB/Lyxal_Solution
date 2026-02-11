DEFINE FUNCTION IF NOT EXISTS fn::base_system_deploy(
  $parent_run_id: option<string>,
  $phase: string
) {
  LET $run_id = rand::uuid();
  LET $log_phase = IF $phase == NONE THEN 'log_deploy' ELSE (IF string::trim($phase) == '' THEN 'log_deploy' ELSE $phase END) END;
  LET $total_steps = 21;

  LET $start = fn::system_log_create_record([$log_phase, 'log_sub_module', 'log_deploy', 'log_start', 'log_initialise'], 'Start: déploiement du sous-module base_system', { run_id: $run_id, parent_run_id: $parent_run_id });

  -- Étape 1: créer/valider module_base
  LET $p0m = fn::system_log_create_record([$log_phase, 'log_module', 'log_deploy', 'log_inprogress', 'log_advanced'], 'Progress: étape 1/4 - base (création/validation du module)', { run_id: $run_id, parent_run_id: $parent_run_id, step: 1, total_steps: $total_steps, sub: 'module_base' });
  LET $mod_base = (SELECT id FROM builder_module WHERE module_code = 'module_base' LIMIT 1)[0];
  IF $mod_base == NONE {
    LET $create_mod = fn::builder_module_create_record('base', 'Module base des entités fondamentales', true, true, true, $log_phase, ['module_base'], $run_id);
    IF $create_mod.success != true { RETURN { success: false, run_id: $run_id, step: 1, result: $create_mod }; };
  };

  -- Étape 2: créer/valider sous-module base_system
  LET $p0s = fn::system_log_create_record([$log_phase, 'log_sub_module', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 2/4 - base_system (création/validation sous-module)', { run_id: $run_id, parent_run_id: $parent_run_id, step: 2, total_steps: $total_steps, sub: 'sub_module_base_system' });
  LET $sm_base_system = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_system' LIMIT 1)[0];
  IF $sm_base_system == NONE {
    LET $mod_base2 = (SELECT id FROM builder_module WHERE module_code = 'module_base' LIMIT 1)[0];
    IF $mod_base2 == NONE { RETURN { success: false, run_id: $run_id, step: 2, message: 'module_base introuvable' }; };
    LET $create_sm = fn::builder_sub_module_create_record('base_system', $mod_base2.id, 'Sous-module système (référentiels techniques)', true, true, true, $log_phase, ['module_base'], $run_id);
    IF $create_sm.success != true { RETURN { success: false, run_id: $run_id, step: 2, result: $create_sm }; };
  };

  -- Étape 3: base_currency
  LET $p1 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 3/12 - base_currency (create table)', { run_id: $run_id, parent_run_id: $parent_run_id, step: 3, total_steps: $total_steps, sub: 'base_currency' });
  LET $s1 = fn::base_currency_create_table_initialise($run_id, $log_phase);
  IF $s1.success != true { RETURN { success: false, run_id: $run_id, step: 3, result: $s1 }; };

  -- Étape 4: seeds currencies (ISO 4217)
  LET $p_seed_cur = fn::system_log_create_record([$log_phase, 'log_table', 'log_reference', 'log_inprogress', 'log_advanced'], 'Progress: étape 4/12 - base_system (seed currencies)', { run_id: $run_id, parent_run_id: $parent_run_id, step: 4, total_steps: $total_steps, sub: 'seed_currencies' });
  LET $s_seed_cur = fn::base_currency_seed_initialise($run_id, $log_phase);
  IF $s_seed_cur.success != true { RETURN { success: false, run_id: $run_id, step: 4, result: $s_seed_cur }; };

  -- Étape 5: fichiers (base_file*)
  LET $p5 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 5/12 - base_file* (create tables)', { run_id: $run_id, parent_run_id: $parent_run_id, step: 5, total_steps: $total_steps, sub: 'base_file*' });
  LET $s5 = fn::base_file_create_tables_initialise($run_id, $log_phase);
  IF $s5.success != true { RETURN { success: false, run_id: $run_id, step: 5, result: $s5 }; };

  -- Étape 6: file_source_connector*
  LET $p6 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 6/12 - base_file_source_connector* (create tables)', { run_id: $run_id, parent_run_id: $parent_run_id, step: 6, total_steps: $total_steps, sub: 'base_file_source_connector*' });
  LET $s6 = fn::base_file_source_connector_create_tables_initialise($run_id, $log_phase);
  IF $s6.success != true { RETURN { success: false, run_id: $run_id, step: 6, result: $s6 }; };

  -- Étape 7: base_frequency
  LET $p7 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 7/12 - base_frequency (create table)', { run_id: $run_id, parent_run_id: $parent_run_id, step: 7, total_steps: $total_steps, sub: 'base_frequency' });
  LET $s7 = fn::base_frequency_create_table_initialise($run_id, $log_phase);
  IF $s7.success != true { RETURN { success: false, run_id: $run_id, step: 7, result: $s7 }; };

  -- Étape 8: base_duration
  LET $p7b = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 8/12 - base_duration (create table)', { run_id: $run_id, parent_run_id: $parent_run_id, step: 8, total_steps: $total_steps, sub: 'base_duration' });
  LET $s7b = fn::base_duration_create_table_initialise($run_id, $log_phase);
  IF $s7b.success != true { RETURN { success: false, run_id: $run_id, step: 8, result: $s7b }; };

  -- Étape 9: exception_origin
  LET $p8 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 9/12 - base_exception_origin (create table)', { run_id: $run_id, parent_run_id: $parent_run_id, step: 9, total_steps: $total_steps, sub: 'base_exception_origin' });
  LET $s8 = fn::base_exception_origin_create_table_initialise($run_id, $log_phase);
  IF $s8.success != true { RETURN { success: false, run_id: $run_id, step: 9, result: $s8 }; };

  -- Étape 10: faker_api*
  LET $p9 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 9/12 - base_faker_api* (create tables)', { run_id: $run_id, parent_run_id: $parent_run_id, step: 9, total_steps: $total_steps, sub: 'base_faker_api*' });
  LET $s9 = fn::base_faker_api_create_tables_initialise($run_id, $log_phase);
  IF $s9.success != true { RETURN { success: false, run_id: $run_id, step: 9, result: $s9 }; };

  -- Étape 11: import_export_interface
  LET $p10 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 10/12 - base_import_export_interface (create table)', { run_id: $run_id, parent_run_id: $parent_run_id, step: 10, total_steps: $total_steps, sub: 'base_import_export_interface' });
  LET $s10 = fn::base_import_export_interface_create_table_initialise($run_id, $log_phase);
  IF $s10.success != true { RETURN { success: false, run_id: $run_id, step: 10, result: $s10 }; };

  -- Étape 12: currency_conversion_line
  LET $p11 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 11/12 - base_currency_conversion_line (create table)', { run_id: $run_id, parent_run_id: $parent_run_id, step: 11, total_steps: $total_steps, sub: 'base_currency_conversion_line' });
  LET $s11 = fn::base_currency_conversion_line_create_table_initialise($run_id, $log_phase);
  IF $s11.success != true { RETURN { success: false, run_id: $run_id, step: 11, result: $s11 }; };

  -- Étape 12: base_priority (create)
  LET $p12 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 12/14 - base_priority (create table)', { run_id: $run_id, parent_run_id: $parent_run_id, step: 12, total_steps: $total_steps, sub: 'base_priority' });
  LET $s12 = fn::base_priority_create_table_initialise($run_id, $log_phase);
  IF $s12.success != true { RETURN { success: false, run_id: $run_id, step: 12, result: $s12 }; };

  -- Étape 13: seeds priority
  LET $p13 = fn::system_log_create_record([$log_phase, 'log_table', 'log_reference', 'log_inprogress', 'log_advanced'], 'Progress: étape 13/14 - base_priority (seeds)', { run_id: $run_id, parent_run_id: $parent_run_id, step: 13, total_steps: $total_steps, sub: 'seed_priority' });
  LET $s13 = fn::base_priority_seed_initialise($run_id, $log_phase);
  IF $s13.success != true { RETURN { success: false, run_id: $run_id, step: 13, result: $s13 }; };

  -- Étape 14: base_anonymizer (create)
  LET $p14 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 14/18 - base_anonymizer (create table)', { run_id: $run_id, parent_run_id: $parent_run_id, step: 14, total_steps: $total_steps, sub: 'base_anonymizer' });
  LET $s14 = fn::base_anonymizer_create_table_initialise($run_id, $log_phase);
  IF $s14.success != true { RETURN { success: false, run_id: $run_id, step: 14, result: $s14 }; };

  -- Étape 15: base_anonymizer_line (create)
  LET $p15 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 15/18 - base_anonymizer_line (create table)', { run_id: $run_id, parent_run_id: $parent_run_id, step: 15, total_steps: $total_steps, sub: 'base_anonymizer_line' });
  LET $s15 = fn::base_anonymizer_line_create_table_initialise($run_id, $log_phase);
  IF $s15.success != true { RETURN { success: false, run_id: $run_id, step: 15, result: $s15 }; };

  -- Étape 16: base_email_account (create)
  LET $p16 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 16/18 - base_email_account (create table)', { run_id: $run_id, parent_run_id: $parent_run_id, step: 16, total_steps: $total_steps, sub: 'base_email_account' });
  LET $s14 = fn::base_email_account_create_table_initialise($run_id, $log_phase);
  IF $s14.success != true { RETURN { success: false, run_id: $run_id, step: 16, result: $s14 }; };

  -- Étape 17: base_unit (create)
  LET $p17 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 17/20 - base_unit (create table)', { run_id: $run_id, parent_run_id: $parent_run_id, step: 17, total_steps: $total_steps, sub: 'base_unit' });
  LET $s17 = fn::base_unit_create_table_initialise($run_id, $log_phase);
  IF $s17.success != true { RETURN { success: false, run_id: $run_id, step: 17, result: $s17 }; };

  -- Étape 18: base_unit_conversion (create)
  LET $p18 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 18/20 - base_unit_conversion (create table)', { run_id: $run_id, parent_run_id: $parent_run_id, step: 18, total_steps: $total_steps, sub: 'base_unit_conversion' });
  LET $s18 = fn::base_unit_conversion_create_table_initialise($run_id, $log_phase);
  IF $s18.success != true { RETURN { success: false, run_id: $run_id, step: 18, result: $s18 }; };

  -- Étape 19: base_sync_contact (create)
  LET $p19 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 19/22 - base_sync_contact (create table)', { run_id: $run_id, parent_run_id: $parent_run_id, step: 19, total_steps: $total_steps, sub: 'base_sync_contact' });
  LET $s19 = fn::base_sync_contact_create_table_initialise($run_id, $log_phase);
  IF $s19.success != true { RETURN { success: false, run_id: $run_id, step: 19, result: $s19 }; };

  -- Étape 20: base_data_backup (create)
  LET $p20 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 20/22 - base_data_backup (create table)', { run_id: $run_id, parent_run_id: $parent_run_id, step: 20, total_steps: $total_steps, sub: 'base_data_backup' });
  LET $s20 = fn::base_data_backup_create_table_initialise($run_id, $log_phase);
  IF $s20.success != true { RETURN { success: false, run_id: $run_id, step: 20, result: $s20 }; };

  -- Étape 16: référencer la fonction de déploiement
  -- Étape 21: base_meta_group_menu_assistant (create)
  LET $p21 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 21/23 - base_meta_group_menu_assistant (create table)', { run_id: $run_id, parent_run_id: $parent_run_id, step: 21, total_steps: $total_steps, sub: 'base_meta_group_menu_assistant' });
  LET $s21 = fn::base_meta_group_menu_assistant_create_table_initialise($run_id, $log_phase);
  IF $s21.success != true { RETURN { success: false, run_id: $run_id, step: 21, result: $s21 }; };

  LET $p_ref = fn::system_log_create_record([$log_phase, 'log_function', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 23/23 - référence function base_system_deploy', { run_id: $run_id, parent_run_id: $parent_run_id, step: 23, total_steps: $total_steps, sub: 'builder_function_reference' });
  LET $sm_sys2 = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_system' LIMIT 1)[0];
  IF $sm_sys2 == NONE {
    LET $err_ref1 = fn::system_log_create_record([$log_phase, 'log_sub_module', 'log_deploy', 'log_done', 'log_failure'], 'Erreur: sous-module base_system introuvable pour rattacher la fonction', { run_id: $run_id, parent_run_id: $parent_run_id });
    RETURN { success: false, run_id: $run_id };
  };
  LET $ref_fn = fn::builder_function_create_record('base_system_deploy', $sm_sys2.id, 'Déploie le sous-module base_system', true, true, true, 'deploy', NONE, $log_phase, ['module_base'], $run_id);
  IF $ref_fn.success != true {
    LET $err_ref2 = fn::system_log_create_record([$log_phase, 'log_function', 'log_create', 'log_done', 'log_failure'], 'Erreur: création du record builder_function pour base_system_deploy', { run_id: $run_id, parent_run_id: $parent_run_id, result: $ref_fn });
    RETURN { success: false, run_id: $run_id };
  };

  LET $done = fn::system_log_create_record([$log_phase, 'log_sub_module', 'log_deploy', 'log_done', 'log_success'], 'Done: déploiement du sous-module base_system', { run_id: $run_id, parent_run_id: $parent_run_id });

  RETURN {
    success: true,
    run_id: $run_id
  };
}
COMMENT 'Déploie le sous-module base_system (tables)'
PERMISSIONS FULL;

