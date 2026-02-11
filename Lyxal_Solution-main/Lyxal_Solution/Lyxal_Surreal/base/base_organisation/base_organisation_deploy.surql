DEFINE FUNCTION IF NOT EXISTS fn::base_organisation_deploy(
  $parent_run_id: option<string>,
  $phase: string
) {
  LET $run_id = rand::uuid();
  LET $log_phase = IF $phase == NONE THEN 'log_deploy' ELSE (IF string::trim($phase) == '' THEN 'log_deploy' ELSE $phase END) END;
  LET $total_steps = 9;

  LET $start = fn::system_log_create_record([$log_phase, 'log_sub_module', 'log_deploy', 'log_start', 'log_initialise'], 'Start: déploiement du sous-module base_organisation', { run_id: $run_id, parent_run_id: $parent_run_id });

  -- Étape 1: créer/valider module_base
  LET $p0m = fn::system_log_create_record([$log_phase, 'log_module', 'log_deploy', 'log_inprogress', 'log_advanced'], 'Progress: étape 1/5 - base (création/validation du module)', { run_id: $run_id, parent_run_id: $parent_run_id, step: 1, total_steps: $total_steps, sub: 'module_base' });
  LET $mod_base = (SELECT id FROM builder_module WHERE module_code = 'module_base' LIMIT 1)[0];
  IF $mod_base == NONE {
    LET $create_mod = fn::builder_module_create_record('base', 'Module base des entités fondamentales', true, true, true, $log_phase, ['module_base'], $run_id);
    IF $create_mod.success != true { RETURN { success: false, run_id: $run_id, step: 1, result: $create_mod }; };
  };

  -- Étape 2: créer/valider sous-module base_organisation
  LET $p0s = fn::system_log_create_record([$log_phase, 'log_sub_module', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 2/5 - base_organisation (création/validation sous-module)', { run_id: $run_id, parent_run_id: $parent_run_id, step: 2, total_steps: $total_steps, sub: 'sub_module_base_organisation' });
  LET $sm_base_org = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_organisation' LIMIT 1)[0];
  IF $sm_base_org == NONE {
    LET $mod_base2 = (SELECT id FROM builder_module WHERE module_code = 'module_base' LIMIT 1)[0];
    IF $mod_base2 == NONE { RETURN { success: false, run_id: $run_id, step: 2, message: 'module_base introuvable' }; };
    LET $create_sm = fn::builder_sub_module_create_record('base_organisation', $mod_base2.id, 'Sous-module organisation (équipes)', true, true, true, $log_phase, ['module_base'], $run_id);
    IF $create_sm.success != true { RETURN { success: false, run_id: $run_id, step: 2, result: $create_sm }; };
  };

  -- Étape 3: base_team
  LET $p1 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 3/9 - base_team (create table)', { run_id: $run_id, parent_run_id: $parent_run_id, step: 3, total_steps: $total_steps, sub: 'base_team' });
  LET $s1 = fn::base_team_create_table_initialise($run_id, $log_phase);
  IF $s1.success != true { RETURN { success: false, run_id: $run_id, step: 3, result: $s1 }; };

  -- Étape 4: seeds (tags team)
  LET $p2 = fn::system_log_create_record([$log_phase, 'log_table', 'log_reference', 'log_inprogress', 'log_advanced'], 'Progress: étape 4/9 - base_team_tag_reference_initialise', { run_id: $run_id, parent_run_id: $parent_run_id, step: 4, total_steps: $total_steps, sub: 'seed_team_tags' });
  LET $s2 = fn::base_team_tag_reference_initialise($run_id, $log_phase);
  IF $s2.success != true { RETURN { success: false, run_id: $run_id, step: 4, result: $s2 }; };

  -- Étape 5: base_activity_category (create)
  LET $p3 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 5/9 - base_activity_category (create table)', { run_id: $run_id, parent_run_id: $parent_run_id, step: 5, total_steps: $total_steps, sub: 'base_activity_category' });
  LET $s3 = fn::base_activity_category_create_table_initialise($run_id, $log_phase);
  IF $s3.success != true { RETURN { success: false, run_id: $run_id, step: 5, result: $s3 }; };

  -- Étape 6: base_activity_category (seed)
  LET $p4 = fn::system_log_create_record([$log_phase, 'log_table', 'log_reference', 'log_inprogress', 'log_advanced'], 'Progress: étape 6/9 - base_activity_category (seed)', { run_id: $run_id, parent_run_id: $parent_run_id, step: 6, total_steps: $total_steps, sub: 'seed_activity_category' });
  LET $s4 = fn::base_activity_category_seed_initialise($run_id, $log_phase);
  IF $s4.success != true { RETURN { success: false, run_id: $run_id, step: 6, result: $s4 }; };

  -- Étape 7: base_activity_type (create)
  LET $p5 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 7/9 - base_activity_type (create table)', { run_id: $run_id, parent_run_id: $parent_run_id, step: 7, total_steps: $total_steps, sub: 'base_activity_type' });
  LET $s5 = fn::base_activity_type_create_table_initialise($run_id, $log_phase);
  IF $s5.success != true { RETURN { success: false, run_id: $run_id, step: 7, result: $s5 }; };

  -- Étape 8: base_activity_type (seed)
  LET $p6 = fn::system_log_create_record([$log_phase, 'log_table', 'log_reference', 'log_inprogress', 'log_advanced'], 'Progress: étape 8/9 - base_activity_type (seed)', { run_id: $run_id, parent_run_id: $parent_run_id, step: 8, total_steps: $total_steps, sub: 'seed_activity_type' });
  LET $s6 = fn::base_activity_type_seed_initialise($run_id, $log_phase);
  IF $s6.success != true { RETURN { success: false, run_id: $run_id, step: 8, result: $s6 }; };

  -- Étape 9: base_tour/base_tour_line (create)
  LET $p7 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 9/9 - base_tour & base_tour_line (create tables)', { run_id: $run_id, parent_run_id: $parent_run_id, step: 9, total_steps: $total_steps, sub: 'base_tour*' });
  LET $s7a = fn::base_tour_create_table_initialise($run_id, $log_phase);
  IF $s7a.success != true { RETURN { success: false, run_id: $run_id, step: 9, result: $s7a }; };
  LET $s7b = fn::base_tour_line_create_table_initialise($run_id, $log_phase);
  IF $s7b.success != true { RETURN { success: false, run_id: $run_id, step: 9, result: $s7b }; };

  -- Étape 5: référencer la fonction de déploiement
  LET $p_ref = fn::system_log_create_record([$log_phase, 'log_function', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: référence function base_organisation_deploy', { run_id: $run_id, parent_run_id: $parent_run_id, step: 9, total_steps: $total_steps, sub: 'builder_function_reference' });
  LET $sm_org2 = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_organisation' LIMIT 1)[0];
  IF $sm_org2 == NONE {
    LET $err_ref1 = fn::system_log_create_record([$log_phase, 'log_sub_module', 'log_deploy', 'log_done', 'log_failure'], 'Erreur: sous-module base_organisation introuvable pour rattacher la fonction', { run_id: $run_id, parent_run_id: $parent_run_id });
    RETURN { success: false, run_id: $run_id };
  };
  LET $ref_fn = fn::builder_function_create_record('base_organisation_deploy', $sm_org2.id, 'Déploie le sous-module base_organisation', true, true, true, 'deploy', NONE, $log_phase, ['module_base'], $run_id);
  IF $ref_fn.success != true {
    LET $err_ref2 = fn::system_log_create_record([$log_phase, 'log_function', 'log_create', 'log_done', 'log_failure'], 'Erreur: création du record builder_function pour base_organisation_deploy', { run_id: $run_id, parent_run_id: $parent_run_id, result: $ref_fn });
    RETURN { success: false, run_id: $run_id };
  };

  LET $done = fn::system_log_create_record([$log_phase, 'log_sub_module', 'log_deploy', 'log_done', 'log_success'], 'Done: déploiement du sous-module base_organisation', { run_id: $run_id, parent_run_id: $parent_run_id });

  RETURN {
    success: true,
    run_id: $run_id
  };
}
COMMENT 'Déploie le sous-module base_organisation (tables + seeds)'
PERMISSIONS FULL;

