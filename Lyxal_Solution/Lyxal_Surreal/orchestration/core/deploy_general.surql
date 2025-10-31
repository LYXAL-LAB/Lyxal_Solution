DEFINE FUNCTION IF NOT EXISTS fn::deploy_general(
  $parent_run_id: string -- run_id du parent
) {

  -- Paramètres
      LET $parent_run_id = $parent_run_id OR NONE;
      LET $run_id = rand::uuid();
      LET $log_extra_tags = ['module_deploy'];

  -- Récupération des codes de deploy_configuration
          LET $cfg = fn::deploy_configuration_get_codes_by_id(deploy_general);
          LET $codes = $cfg.codes;
          LET $steps_total = $cfg.count;
          LET $step = 0;
          LET $step_success = 0;

  -- Lancement du déploiement général
  ---- Journalisation de début du déploiement général
          fn::deploy_log_helper('saas', 'start', 'initialise','Déploiement général du SaaS', 
          $run_id, $parent_run_id, $log_extra_tags, $steps, $step_success, $steps_total);

  -- Module System
  ---- Déploiement du module système selon le template saas
        IF array::contains($codes, 'function_system_core_deploy') {
            ---- Mise à jour du nombre de steps en cours
            LET $steps = $steps + 1;
            ----Journalisation de début de l'étape
            fn::deploy_log_helper('module', 'inprogress', 'initialise','Déploiement du module 
            `system`',$run_id, $parent_run_id, $log_extra_tags, $steps, $step_success, $steps_total);
        
        
        
        }





  -- Étape 1: Déploiement du module système
  -- Mise à jour du numéro d'étape
  LET $step = $step + 1;
  -- Journalisation de début
   LET $tags_s1 = [$phase, $log_extra_tags, 'log_create', 'log_start', 'log_module'];
   LET $tag_records_s1 = array::map(
    array::filter($tags_s1, |$s| $s != NONE && $s != ''),
    |$s| type::thing('system_tag', $s)
  );
   CREATE system_log SET
     timestamp = time::now(),
     session_id = session::id(),
     tags = $tag_records_s1,
     severity = 'INFO',
     message = 'Étape ' + type::string($step) + '/' + type::string($total_steps) + 
     ': Déploiement du module `system`',
     details = { run_id: $run_id, step: $step, total_steps: $total_steps },
     environment = type::thing('system_environment', 'system');
  -- appel de la fonction system_core_deploy_initialise
   fn::system_core_deploy_initialise($run_id);
   LET $system_result = fn::system_core_deploy($run_id);
 

  -- Étape : Déploiement du module builder
  -- Mise à jour du numéro d'étape
  LET $step = $step + 1;
  -- Journalisation de début
  fn::system_log_helper_deploy_step($step, $total_steps, 'log_module',
  'Déploiement du module `builder`', 'start', $run_id, NONE, $log_extra_tags);
  -- Initialisation de la fonction
  fn::builder_deploy_initialise($run_id);
  -- Déploiement du module
  LET $builder_result = fn::builder_deploy($run_id);
  -- Journalisation de fin
  fn::system_log_helper_deploy_step($step, $total_steps, 'log_module',
  'Déploiement du module `builder`', 'done', $run_id, NONE, $log_extra_tags);

  -- Étape : Déploiement du module storage
  -- Mise à jour du numéro d'étape
  LET $step = $step + 1;
  -- Journalisation de début
  fn::system_log_helper_deploy_step($step, $total_steps, 'log_module',
  'Déploiement du module `storage`', 'start', $run_id, NONE, $log_extra_tags);
  -- Initialisation de la fonction
  fn::storage_deploy_initialise($run_id);
  -- Déploiement du module
  LET $storage_result = fn::storage_deploy($run_id);
  -- Journalisation de fin
  fn::system_log_helper_deploy_step($step, $total_steps, 'log_module',
  'Déploiement du module `storage`', 'done', $run_id, NONE, $log_extra_tags);

  -- Étape : Déploiement des tables base (agrégateur database)
  LET $step = $step + 1;
  fn::system_log_helper_deploy_step($step, $total_steps, 'log_module_section',
  'Déploiement des tables du module Base', 'start', $run_id, NONE, $log_extra_tags);
  fn::base_database_deploy_initialise($run_id);
  LET $base_db_result = fn::base_database_deploy($run_id);
  fn::system_log_helper_deploy_step($step, $total_steps, 'log_module_section',
  'Déploiement des tables du module Base', 'done', $run_id, NONE, $log_extra_tags);

  -- Étape : Déploiement du module configuration
  -- Mise à jour du numéro d'étape
  LET $step = $step + 1;
  -- Journalisation de début
  fn::system_log_helper_deploy_step($step, $total_steps, 'log_module',
  'Déploiement du module `configuration`', 'start', $run_id, NONE, $log_extra_tags);
  -- Initialisation de la fonction
  fn::configuration_deploy_initialise($run_id);
  -- Déploiement du module
  LET $configuration_result = fn::configuration_deploy($run_id);
  -- Journalisation de fin
  fn::system_log_helper_deploy_step($step, $total_steps, 'log_module',
  'Déploiement du module `configuration`', 'done', $run_id, NONE, $log_extra_tags);

  -- Étape : Déploiement du module integrations
  -- Mise à jour du numéro d'étape
  LET $step = $step + 1;
  -- Journalisation de début
  fn::system_log_helper_deploy_step($step, $total_steps, 'log_module',
  'Déploiement du module `integrations`', 'start', $run_id, NONE, $log_extra_tags);
  -- Initialisation de la fonction
  fn::integrations_deploy_initialise($run_id);
  -- Déploiement du module
  LET $integrations_result = fn::integrations_deploy($run_id);
  -- Journalisation de fin
  fn::system_log_helper_deploy_step($step, $total_steps, 'log_module',
  'Déploiement du module `integrations`', 'done', $run_id, NONE, $log_extra_tags);

  -- Étape : Déploiement du module automation
  -- Mise à jour du numéro d'étape
  LET $step = $step + 1;
  -- Journalisation de début
  fn::system_log_helper_deploy_step($step, $total_steps, 'log_module',
  'Déploiement du module `automation`', 'start', $run_id, NONE, $log_extra_tags);
  -- Initialisation de la fonction
  fn::automation_deploy_initialise($run_id);
  -- Déploiement du module
  LET $automation_result = fn::automation_deploy($run_id);
  -- Journalisation de fin
  fn::system_log_helper_deploy_step($step, $total_steps, 'log_module',
  'Déploiement du module `automation`', 'done', $run_id, NONE, $log_extra_tags);

  -- Journalisation du succès global
  LET $summary = fn::system_log_deploy_helper_summary('Déploiement général du SaaS', 'finish', 
  $run_id, NONE, $log_extra_tags);

  -- Retour final
  RETURN {
    success: true,
    run_id: $run_id,
    summary: $summary,
    results: {
      system: $system_result,
      builder: $builder_result,
      storage: $storage_result,
      base_database: $base_db_result,
      configuration: $configuration_result,
      integrations: $integrations_result,
      automation: $automation_result
      -- scheduler: $scheduler_result
    }
  };
}
COMMENT 'Déploie la fonction deploy_general'
PERMISSIONS FULL;   