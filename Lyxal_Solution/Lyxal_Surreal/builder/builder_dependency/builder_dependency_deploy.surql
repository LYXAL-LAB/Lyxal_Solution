DEFINE FUNCTION IF NOT EXISTS fn::builder_dependency_deploy(
  $parent_run_id: option<string>,
  $phase: string
) {
  LET $run_id = rand::uuid();
  LET $log_phase = IF $phase == NONE OR string::trim($phase) == '' THEN 'log_deploy' ELSE $phase END;
  LET $start = fn::system_log_create_record([$log_phase, 'log_sub_module', 'log_deploy', 'log_start', 'log_initialise'], 'Start: déploiement du sous-module builder_dependency', { run_id: $run_id, parent_run_id: $parent_run_id });
  LET $total_steps = 6;

  -- Étape 1: créer le sous-module builder_dependency
  LET $p1 = fn::system_log_create_record([$log_phase, 'log_sub_module', 'log_deploy', 'log_inprogress', 'log_advanced'], 'Progress: étape 1/6 - sub_module builder_dependency', { run_id: $run_id, parent_run_id: $parent_run_id, step: 1, total_steps: $total_steps, sub: 'builder_dependency' });
  LET $mod_builder = (SELECT id FROM builder_module WHERE module_code = 'module_builder' LIMIT 1)[0];
  IF $mod_builder == NONE { LET $done_err = fn::system_log_create_record([$phase, 'log_sub_module', 'log_deploy', 'log_done', 'log_failure'], 'Erreur: module parent builder introuvable', { run_id: $run_id, parent_run_id: $parent_run_id }); LET $done = fn::system_log_create_record([$phase, 'log_sub_module', 'log_deploy', 'log_done', 'log_failure'], 'Done: déploiement du sous-module builder_dependency (arrêt sur erreur)', { run_id: $run_id, parent_run_id: $parent_run_id }); RETURN { success: false, run_id: $run_id }; };
  LET $r_sm = fn::builder_sub_module_create_record('builder_dependency', $mod_builder.id, 'Sous-module des dépendances entre entités du builder', true, true, true, $log_phase, ['module_builder']);
  IF $r_sm.success != true { LET $done_err = fn::system_log_create_record([$phase, 'log_sub_module', 'log_deploy', 'log_done', 'log_failure'], 'Erreur: création du sous-module builder_dependency', { run_id: $run_id, parent_run_id: $parent_run_id, result: $r_sm }); LET $done = fn::system_log_create_record([$phase, 'log_sub_module', 'log_deploy', 'log_done', 'log_failure'], 'Done: déploiement du sous-module builder_dependency (arrêt sur erreur)', { run_id: $run_id, parent_run_id: $parent_run_id }); RETURN { success: false, run_id: $run_id }; };

  -- Étape 2: initialiser la création de la table builder_dependency
  LET $p2 = fn::system_log_create_record([$log_phase, 'log_sub_module', 'log_deploy', 'log_inprogress', 'log_advanced'], 'Progress: étape 2/6 - builder_dependency (create_table)', { run_id: $run_id, parent_run_id: $parent_run_id, step: 2, total_steps: $total_steps, sub: 'builder_dependency_create_table' });
  LET $t = fn::builder_dependency_create_table_initialise($run_id, $log_phase);
  IF $t.success != true { LET $done_err = fn::system_log_create_record([$phase, 'log_sub_module', 'log_deploy', 'log_done', 'log_failure'], 'Erreur: initialisation de la fonction builder_dependency_create_table', { run_id: $run_id, parent_run_id: $parent_run_id, result: $t }); LET $done = fn::system_log_create_record([$phase, 'log_sub_module', 'log_deploy', 'log_done', 'log_failure'], 'Done: déploiement du sous-module builder_dependency (arrêt sur erreur)', { run_id: $run_id, parent_run_id: $parent_run_id }); RETURN { success: false, run_id: $run_id }; };

  -- Étape 3: initialiser la création de la table builder_dependency_edge
  LET $p3 = fn::system_log_create_record([$log_phase, 'log_sub_module', 'log_deploy', 'log_inprogress', 'log_advanced'], 'Progress: étape 3/6 - builder_dependency_edge (create_table)', { run_id: $run_id, parent_run_id: $parent_run_id, step: 3, total_steps: $total_steps, sub: 'builder_dependency_edge_create_table' });
  LET $t_edge = fn::builder_dependency_edge_create_table_initialise($run_id, $log_phase);
  IF $t_edge.success != true { LET $done_err = fn::system_log_create_record([$phase, 'log_sub_module', 'log_deploy', 'log_done', 'log_failure'], 'Erreur: initialisation de la fonction builder_dependency_edge_create_table', { run_id: $run_id, parent_run_id: $parent_run_id, result: $t_edge }); LET $done = fn::system_log_create_record([$phase, 'log_sub_module', 'log_deploy', 'log_done', 'log_failure'], 'Done: déploiement du sous-module builder_dependency (arrêt sur erreur)', { run_id: $run_id, parent_run_id: $parent_run_id }); RETURN { success: false, run_id: $run_id }; };

  -- Étape 4: initialiser la fonction de création de record builder_dependency
  LET $p4 = fn::system_log_create_record([$log_phase, 'log_sub_module', 'log_deploy', 'log_inprogress', 'log_advanced'], 'Progress: étape 4/6 - builder_dependency (create_record_fn)', { run_id: $run_id, parent_run_id: $parent_run_id, step: 4, total_steps: $total_steps, sub: 'builder_dependency_create_record' });
  LET $r = fn::builder_dependency_create_record_initialise($run_id, $log_phase);
  IF $r.success != true { LET $done_err = fn::system_log_create_record([$phase, 'log_sub_module', 'log_deploy', 'log_done', 'log_failure'], 'Erreur: initialisation de la fonction builder_dependency_create_record', { run_id: $run_id, parent_run_id: $parent_run_id, result: $r }); LET $done = fn::system_log_create_record([$phase, 'log_sub_module', 'log_deploy', 'log_done', 'log_failure'], 'Done: déploiement du sous-module builder_dependency (arrêt sur erreur)', { run_id: $run_id, parent_run_id: $parent_run_id }); RETURN { success: false, run_id: $run_id }; };

  -- Étape 5: initialiser les actions (helpers) builder_dependency
  LET $p5 = fn::system_log_create_record([$log_phase, 'log_sub_module', 'log_deploy', 'log_inprogress', 'log_advanced'], 'Progress: étape 5/6 - builder_dependency (actions_initialise)', { run_id: $run_id, parent_run_id: $parent_run_id, step: 5, total_steps: $total_steps, sub: 'builder_dependency_actions_initialise' });
  LET $a = fn::builder_dependency_actions_initialise($run_id, $log_phase);
  IF $a.success != true { LET $done_err = fn::system_log_create_record([$phase, 'log_sub_module', 'log_deploy', 'log_done', 'log_failure'], 'Erreur: initialisation des actions builder_dependency', { run_id: $run_id, parent_run_id: $parent_run_id, result: $a }); LET $done = fn::system_log_create_record([$phase, 'log_sub_module', 'log_deploy', 'log_done', 'log_failure'], 'Done: déploiement du sous-module builder_dependency (arrêt sur erreur)', { run_id: $run_id, parent_run_id: $parent_run_id }); RETURN { success: false, run_id: $run_id }; };

  -- Étape 6: référencer les fonctions dans builder_function
  LET $p6 = fn::system_log_create_record([$log_phase, 'log_sub_module', 'log_deploy', 'log_inprogress', 'log_advanced'], 'Progress: étape 6/6 - builder_function records: builder_dependency_deploy, builder_dependency_actions_initialise', { run_id: $run_id, parent_run_id: $parent_run_id, step: 6, total_steps: $total_steps, functions: ['builder_dependency_deploy','builder_dependency_actions_initialise'] });
  LET $r_fn = fn::builder_function_create_record('builder_dependency_deploy', $r_sm.sub_module.id, 'Déploie le sous-module builder_dependency', true, true, true, 'deploy', NONE, $log_phase, ['module_builder'], $run_id);
  IF $r_fn.success != true { LET $done_err = fn::system_log_create_record([$phase, 'log_function', 'log_create', 'log_done', 'log_failure'], 'Erreur: création du record builder_dependency_deploy', { run_id: $run_id, parent_run_id: $parent_run_id, result: $r_fn }); LET $done = fn::system_log_create_record([$phase, 'log_sub_module', 'log_deploy', 'log_done', 'log_failure'], 'Done: déploiement du sous-module builder_dependency (arrêt sur erreur)', { run_id: $run_id, parent_run_id: $parent_run_id }); RETURN { success: false, run_id: $run_id }; };
  LET $r_fn2 = fn::builder_function_create_record('builder_dependency_actions_initialise', $r_sm.sub_module.id, 'Initialise les actions de dépendance (edges, listes)', true, true, true, 'deploy', NONE, $log_phase, ['module_builder'], $run_id);
  IF $r_fn2.success != true { LET $done_err2 = fn::system_log_create_record([$phase, 'log_function', 'log_create', 'log_done', 'log_failure'], 'Erreur: création du record builder_dependency_actions_initialise', { run_id: $run_id, parent_run_id: $parent_run_id, result: $r_fn2 }); LET $done2 = fn::system_log_create_record([$phase, 'log_sub_module', 'log_deploy', 'log_done', 'log_failure'], 'Done: déploiement du sous-module builder_dependency (arrêt sur erreur)', { run_id: $run_id, parent_run_id: $parent_run_id }); RETURN { success: false, run_id: $run_id }; };

  LET $done = fn::system_log_create_record([$log_phase, 'log_sub_module', 'log_deploy', 'log_done', 'log_success'], 'Done: déploiement du sous-module builder_dependency', { run_id: $run_id, parent_run_id: $parent_run_id });
  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Déploie la section builder_dependency'
PERMISSIONS FULL;

-- Supprimé: ancienne définition sans paramètres non conforme au pattern


