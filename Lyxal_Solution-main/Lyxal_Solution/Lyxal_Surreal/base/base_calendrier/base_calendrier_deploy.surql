DEFINE FUNCTION IF NOT EXISTS fn::base_calendrier_deploy(
  $parent_run_id: option<string>,
  $phase: string
) {
  LET $run_id = rand::uuid();
  LET $log_phase = IF $phase == NONE THEN 'log_deploy' ELSE (IF string::trim($phase) == '' THEN 'log_deploy' ELSE $phase END) END;
  LET $total_steps = 9;

  LET $start = fn::system_log_create_record([$log_phase, 'log_sub_module', 'log_deploy', 'log_start', 'log_initialise'], 'Start: déploiement du sous-module base_calendrier', { run_id: $run_id, parent_run_id: $parent_run_id });

  -- Étape 1: créer/valider sous-module base_calendrier
  LET $p1 = fn::system_log_create_record([$log_phase, 'log_sub_module', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 1/6 - base_calendrier (création/validation sous-module)', { run_id: $run_id, parent_run_id: $parent_run_id, step: 1, total_steps: $total_steps, sub: 'sub_module_base_calendrier' });
  LET $sm = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_calendrier' LIMIT 1)[0];
  IF $sm == NONE {
    LET $mod_base = (SELECT id FROM builder_module WHERE module_code = 'module_base' LIMIT 1)[0];
    IF $mod_base == NONE { RETURN { success: false, run_id: $run_id, message: 'module_base introuvable' }; };
    LET $create_sm = fn::builder_sub_module_create_record('base_calendrier', $mod_base.id, 'Sous-module calendrier', true, true, true, $log_phase, ['module_base'], $run_id);
    IF $create_sm.success != true { RETURN { success: false, run_id: $run_id, result: $create_sm }; };
  };

  -- Étape 2: base_icalendar
  LET $p2a = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 2/7 - base_icalendar', { run_id: $run_id, parent_run_id: $parent_run_id, step: 2, total_steps: $total_steps, sub: 'base_icalendar' });
  LET $s2a = fn::base_icalendar_create_table_initialise($run_id, $log_phase);
  IF $s2a.success != true { RETURN { success: false, run_id: $run_id, step: 2, result: $s2a }; };

  -- Étape 3: base_calendar_management
  LET $p2b = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 3/9 - base_calendar_management', { run_id: $run_id, parent_run_id: $parent_run_id, step: 3, total_steps: $total_steps, sub: 'base_calendar_management' });
  LET $s2b = fn::base_calendar_management_create_table_initialise($run_id, $log_phase);
  IF $s2b.success != true { RETURN { success: false, run_id: $run_id, step: 3, result: $s2b }; };

  -- Étape 4: base_calendar_configuration
  LET $p2c = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 4/9 - base_calendar_configuration', { run_id: $run_id, parent_run_id: $parent_run_id, step: 4, total_steps: $total_steps, sub: 'base_calendar_configuration' });
  LET $s2c = fn::base_calendar_configuration_create_table_initialise($run_id, $log_phase);
  IF $s2c.success != true { RETURN { success: false, run_id: $run_id, step: 4, result: $s2c }; };

  -- Étape 5: base_weekly_planning
  LET $p2 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 5/9 - base_weekly_planning', { run_id: $run_id, parent_run_id: $parent_run_id, step: 5, total_steps: $total_steps, sub: 'base_weekly_planning' });
  LET $s2 = fn::base_weekly_planning_create_table_initialise($run_id, $log_phase);
  IF $s2.success != true { RETURN { success: false, run_id: $run_id, step: 2, result: $s2 }; };

  -- Étape 6: base_day_planning
  LET $p3 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 6/9 - base_day_planning', { run_id: $run_id, parent_run_id: $parent_run_id, step: 6, total_steps: $total_steps, sub: 'base_day_planning' });
  LET $s3 = fn::base_day_planning_create_table_initialise($run_id, $log_phase);
  IF $s3.success != true { RETURN { success: false, run_id: $run_id, step: 3, result: $s3 }; };

  -- Étape 7: base_events_planning
  LET $p4 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 7/9 - base_events_planning', { run_id: $run_id, parent_run_id: $parent_run_id, step: 7, total_steps: $total_steps, sub: 'base_events_planning' });
  LET $s4 = fn::base_events_planning_create_table_initialise($run_id, $log_phase);
  IF $s4.success != true { RETURN { success: false, run_id: $run_id, step: 4, result: $s4 }; };

  -- Étape 8: base_events_planning_line
  LET $p5 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 8/9 - base_events_planning_line', { run_id: $run_id, parent_run_id: $parent_run_id, step: 8, total_steps: $total_steps, sub: 'base_events_planning_line' });
  LET $s5 = fn::base_events_planning_line_create_table_initialise($run_id, $log_phase);
  IF $s5.success != true { RETURN { success: false, run_id: $run_id, step: 5, result: $s5 }; };

  -- Étape 9: base_icalendar_event/base_icalendar_user
  LET $p6 = fn::system_log_create_record([$log_phase, 'log_table', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: étape 9/9 - base_icalendar_event & base_icalendar_user', { run_id: $run_id, parent_run_id: $parent_run_id, step: 9, total_steps: $total_steps, sub: 'base_icalendar*' });
  LET $s6a = fn::base_icalendar_event_create_table_initialise($run_id, $log_phase);
  IF $s6a.success != true { RETURN { success: false, run_id: $run_id, step: 6, result: $s6a }; };
  LET $s6b = fn::base_icalendar_user_create_table_initialise($run_id, $log_phase);
  IF $s6b.success != true { RETURN { success: false, run_id: $run_id, step: 6, result: $s6b }; };

  -- Référencer la fonction
  LET $p_ref = fn::system_log_create_record([$log_phase, 'log_function', 'log_create', 'log_inprogress', 'log_advanced'], 'Progress: référence function base_calendrier_deploy', { run_id: $run_id, parent_run_id: $parent_run_id, sub: 'builder_function_reference' });
  LET $sm2 = (SELECT id FROM builder_sub_module WHERE sub_module_code = 'sub_module_base_calendrier' LIMIT 1)[0];
  IF $sm2 == NONE { RETURN { success: false, run_id: $run_id }; };
  LET $ref_fn = fn::builder_function_create_record('base_calendrier_deploy', $sm2.id, 'Déploie le sous-module calendrier', true, true, true, 'deploy', NONE, $log_phase, ['module_base'], $run_id);
  IF $ref_fn.success != true { RETURN { success: false, run_id: $run_id, result: $ref_fn }; };

  LET $done = fn::system_log_create_record([$log_phase, 'log_sub_module', 'log_deploy', 'log_done', 'log_success'], 'Done: déploiement du sous-module base_calendrier', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Déploie le sous-module calendrier (base_calendrier)'
PERMISSIONS FULL;

