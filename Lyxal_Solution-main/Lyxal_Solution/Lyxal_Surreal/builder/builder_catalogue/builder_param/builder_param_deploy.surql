DEFINE FUNCTION IF NOT EXISTS fn::builder_param_deploy(
  $parent_run_id: option<string>,
  $phase: string
) {
  LET $run_id = rand::uuid();
  LET $start = fn::system_log_create_record([$phase, 'log_sub_module', 'log_deploy', 'log_start', 'log_initialise'], 'Start: déploiement du sous-module builder_param', { run_id: $run_id, parent_run_id: $parent_run_id });
  LET $total_steps = 4;

  -- Étape 1: créer le sous-module builder_param
  LET $p1 = fn::system_log_create_record([$phase, 'log_sub_module', 'log_deploy', 'log_inprogress', 'log_advanced'], 'Progress: étape 1/4 - sub_module builder_param', { run_id: $run_id, parent_run_id: $parent_run_id, step: 1, total_steps: $total_steps, sub: 'builder_param' });
  LET $mod_builder = (SELECT id FROM builder_module WHERE module_code = 'module_builder' LIMIT 1)[0];
  IF $mod_builder == NONE { LET $done_err = fn::system_log_create_record([$phase, 'log_sub_module', 'log_deploy', 'log_done', 'log_failure'], 'Erreur: module parent builder introuvable', { run_id: $run_id, parent_run_id: $parent_run_id }); LET $done = fn::system_log_create_record([$phase, 'log_sub_module', 'log_deploy', 'log_done', 'log_failure'], 'Done: déploiement du sous-module builder_param (arrêt sur erreur)', { run_id: $run_id, parent_run_id: $parent_run_id }); RETURN { success: false, run_id: $run_id }; };
  LET $r_sm = fn::builder_sub_module_create_record('builder_param', $mod_builder.id, 'Sous-module des paramètres', true, true, true, $phase, ['module_builder']);
  IF $r_sm.success != true { LET $done_err = fn::system_log_create_record([$phase, 'log_sub_module', 'log_deploy', 'log_done', 'log_failure'], 'Erreur: création du sous-module builder_param', { run_id: $run_id, parent_run_id: $parent_run_id, result: $r_sm }); LET $done = fn::system_log_create_record([$phase, 'log_sub_module', 'log_deploy', 'log_done', 'log_failure'], 'Done: déploiement du sous-module builder_param (arrêt sur erreur)', { run_id: $run_id, parent_run_id: $parent_run_id }); RETURN { success: false, run_id: $run_id }; };

  -- Étape 2: initialiser la création de la table builder_param
  LET $p2 = fn::system_log_create_record([$phase, 'log_sub_module', 'log_deploy', 'log_inprogress', 'log_advanced'], 'Progress: étape 2/4 - builder_param (create_table)', { run_id: $run_id, parent_run_id: $parent_run_id, step: 2, total_steps: $total_steps, sub: 'builder_param_create_table' });
  LET $t = fn::builder_param_create_table_initialise($run_id, $phase);
  IF $t.success != true { LET $done_err = fn::system_log_create_record([$phase, 'log_sub_module', 'log_deploy', 'log_done', 'log_failure'], 'Erreur: initialisation de la fonction builder_param_create_table', { run_id: $run_id, parent_run_id: $parent_run_id, result: $t }); LET $done = fn::system_log_create_record([$phase, 'log_sub_module', 'log_deploy', 'log_done', 'log_failure'], 'Done: déploiement du sous-module builder_param (arrêt sur erreur)', { run_id: $run_id, parent_run_id: $parent_run_id }); RETURN { success: false, run_id: $run_id }; };

  -- Étape 3: initialiser la fonction de création de record builder_param
  LET $p3 = fn::system_log_create_record([$phase, 'log_sub_module', 'log_deploy', 'log_inprogress', 'log_advanced'], 'Progress: étape 3/4 - builder_param (create_record_fn)', { run_id: $run_id, parent_run_id: $parent_run_id, step: 3, total_steps: $total_steps, sub: 'builder_param_create_record' });
  LET $r = fn::builder_param_create_record_initialise($run_id, $phase);
  IF $r.success != true { LET $done_err = fn::system_log_create_record([$phase, 'log_sub_module', 'log_deploy', 'log_done', 'log_failure'], 'Erreur: initialisation de la fonction builder_param_create_record', { run_id: $run_id, parent_run_id: $parent_run_id, result: $r }); LET $done = fn::system_log_create_record([$phase, 'log_sub_module', 'log_deploy', 'log_done', 'log_failure'], 'Done: déploiement du sous-module builder_param (arrêt sur erreur)', { run_id: $run_id, parent_run_id: $parent_run_id }); RETURN { success: false, run_id: $run_id }; };

  -- Étape 4: référencer la fonction builder_param_deploy dans builder_function
  LET $p4 = fn::system_log_create_record([$phase, 'log_sub_module', 'log_deploy', 'log_inprogress', 'log_advanced'], 'Progress: étape 4/4 - builder_function record: builder_param_deploy', { run_id: $run_id, parent_run_id: $parent_run_id, step: 4, total_steps: $total_steps, function: 'builder_param_deploy' });
  LET $r_fn = fn::builder_function_create_record('builder_param_deploy', $r_sm.sub_module.id, 'Déploie le sous-module builder_param', true, true, true, 'deploy', NONE, $phase, ['module_builder'], $run_id);
  IF $r_fn.success != true { LET $done_err = fn::system_log_create_record([$phase, 'log_function', 'log_create', 'log_done', 'log_failure'], 'Erreur: création du record builder_param_deploy', { run_id: $run_id, parent_run_id: $parent_run_id, result: $r_fn }); LET $done = fn::system_log_create_record([$phase, 'log_sub_module', 'log_deploy', 'log_done', 'log_failure'], 'Done: déploiement du sous-module builder_param (arrêt sur erreur)', { run_id: $run_id, parent_run_id: $parent_run_id }); RETURN { success: false, run_id: $run_id }; };

  LET $done = fn::system_log_create_record([$phase, 'log_sub_module', 'log_deploy', 'log_done', 'log_success'], 'Done: déploiement du sous-module builder_param', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Déploie la section builder_param'
PERMISSIONS FULL;





