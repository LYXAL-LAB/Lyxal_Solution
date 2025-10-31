-- =================================================================================================
-- |
-- | Fichier : system_schedule_deploy_initialise.surql
-- | Module : system_schedule
-- | Description : Ce fichier gère le déploiement complet du composant `system_schedule`.
-- |
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_deploy_initialise(
  $parent_run_id: option<string>
) {
  -- Paramètres
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_system'];
  LET $run_id = rand::uuid();

  -- Journalisation: début de l'initialisation
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], $log_extra_tags),
    'Start: initialisation de la fonction de déploiement pour `system_schedule`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  -- Définition de la fonction de déploiement
  DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_deploy(
    $parent_run_id: option<string>
  ) {
    -- Paramètres
    LET $run_id = rand::uuid();
    LET $total_steps = 31;
    LET $step = 0;
    LET $log_extra_tags = ['module_system', 'log_deploy'];

    -- Journalisation: début du déploiement
    fn::system_log_create_record_system(
      array::union(['log_deploy', 'log_module', 'log_start'], $log_extra_tags),
      'Start: déploiement du composant `system_schedule`', 
      { run_id: $run_id, parent_run_id: $parent_run_id, total_steps: $total_steps }
    );

    -- Étape: Définir les paramètres
    LET $step = $step + 1;
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_parameter', 'définition des paramètres de session', 'start', 
      $run_id, $parent_run_id, $log_extra_tags
    );
    fn::system_schedule_parameters_initialise($run_id);
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_parameter', 'définition des paramètres de session', 'done',
      $run_id, $parent_run_id, $log_extra_tags
    );

    -- Étape: Initialiser la sécurité (utilisateur et méthode d'accès)
    LET $step = $step + 1;
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_security', 'initialisation de la sécurité', 'start', 
      $run_id, $parent_run_id, $log_extra_tags
    );
    fn::system_schedule_security_initialise($run_id);
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_security', 'initialisation de la sécurité', 'done',
      $run_id, $parent_run_id, $log_extra_tags
    );

    -- Étape: Créer la table `system_schedule`
    LET $step = $step + 1;
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_table', 'création de la table `system_schedule`', 'start', 
      $run_id, $parent_run_id, $log_extra_tags
    );
    fn::system_schedule_create_table_initialise($run_id);
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_table', 'création de la table `system_schedule`', 'done',
      $run_id, $parent_run_id, $log_extra_tags
    );

    -- Étape: Créer la table `system_schedule_folder`
    LET $step = $step + 1;
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_table', 'création de la table `system_schedule_folder`', 'start', 
      $run_id, $parent_run_id, $log_extra_tags
    );
    LET $res_folder = fn::system_schedule_folder_create_table_initialise($run_id);
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_table', 'création de la table `system_schedule_folder`', 'done',
      $run_id, $parent_run_id, $log_extra_tags
    );

    -- Étape: Créer la fonction `system_schedule_folder_create`
    LET $step = $step + 1;
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'création de la fonction `system_schedule_folder_create`', 'start', 
      $run_id, $parent_run_id, $log_extra_tags
    );
    fn::system_schedule_folder_create_initialise($run_id);
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'création de la fonction `system_schedule_folder_create`', 'done',
      $run_id, $parent_run_id, $log_extra_tags
    );

    -- Étape: Créer la fonction `system_schedule_folder_delete`
    LET $step = $step + 1;
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'création de la fonction `system_schedule_folder_delete`', 'start', 
      $run_id, $parent_run_id, $log_extra_tags
    );
    fn::system_schedule_folder_delete_initialise($run_id);
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'création de la fonction `system_schedule_folder_delete`', 'done',
      $run_id, $parent_run_id, $log_extra_tags
    );

    -- Étape: Créer la fonction `system_schedule_folder_get_jobs`
    LET $step = $step + 1;
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'création de la fonction `system_schedule_folder_get_jobs`', 'start', 
      $run_id, $parent_run_id, $log_extra_tags
    );
    fn::system_schedule_folder_get_jobs_initialise($run_id);
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'création de la fonction `system_schedule_folder_get_jobs`', 'done',
      $run_id, $parent_run_id, $log_extra_tags
    );

    -- Étape: Créer la fonction `system_schedule_folder_list`
    LET $step = $step + 1;
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'création de la fonction `system_schedule_folder_list`', 'start', 
      $run_id, $parent_run_id, $log_extra_tags
    );
    fn::system_schedule_folder_list_initialise($run_id);
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'création de la fonction `system_schedule_folder_list`', 'done',
      $run_id, $parent_run_id, $log_extra_tags
    );

    -- Étape: Créer la fonction `system_schedule_folder_list_recursive`
    LET $step = $step + 1;
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'création de la fonction `system_schedule_folder_list_recursive`', 'start', 
      $run_id, $parent_run_id, $log_extra_tags
    );
    fn::system_schedule_folder_list_recursive_initialise($run_id);
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'création de la fonction `system_schedule_folder_list_recursive`', 'done',
      $run_id, $parent_run_id, $log_extra_tags
    );

    -- Étape: Créer la fonction `system_schedule_folder_disable_jobs`
    LET $step = $step + 1;
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'création de la fonction `system_schedule_folder_disable_jobs`', 'start', 
      $run_id, $parent_run_id, $log_extra_tags
    );
    fn::system_schedule_folder_disable_jobs_initialise($run_id);
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'création de la fonction `system_schedule_folder_disable_jobs`', 'done',
      $run_id, $parent_run_id, $log_extra_tags
    );

    -- Étape: Créer la fonction `system_schedule_folder_enable_jobs`
    LET $step = $step + 1;
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'création de la fonction `system_schedule_folder_enable_jobs`', 'start', 
      $run_id, $parent_run_id, $log_extra_tags
    );
    fn::system_schedule_folder_enable_jobs_initialise($run_id);
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'création de la fonction `system_schedule_folder_enable_jobs`', 'done',
      $run_id, $parent_run_id, $log_extra_tags
    );

    -- Étape: Créer la fonction `system_schedule_create_job` (orchestrateur)
    LET $step = $step + 1;
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'création de la fonction `system_schedule_create_job`', 'start', 
      $run_id, $parent_run_id, $log_extra_tags
    );
    fn::system_schedule_create_job_initialise($run_id);
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'création de la fonction `system_schedule_create_job`', 'done',
      $run_id, $parent_run_id, $log_extra_tags
    );

    -- Étape: Créer la fonction `system_schedule_gateway_history`
    LET $step = $step + 1;
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'création de la fonction `system_schedule_gateway_history`', 'start', 
      $run_id, $parent_run_id, $log_extra_tags
    );
    fn::system_schedule_gateway_history_initialise($run_id);
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'création de la fonction `system_schedule_gateway_history`', 'done',
      $run_id, $parent_run_id, $log_extra_tags
    );

    -- Étape: Créer la fonction `system_schedule_gateway_jobs`
    LET $step = $step + 1;
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'création de la fonction `system_schedule_gateway_jobs`', 'start', 
      $run_id, $parent_run_id, $log_extra_tags
    );
    fn::system_schedule_gateway_jobs_initialise($run_id);
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'création de la fonction `system_schedule_gateway_jobs`', 'done',
      $run_id, $parent_run_id, $log_extra_tags
    );

    -- Étape: Créer la table relation `system_schedule_job_folder`
    LET $step = $step + 1;
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_table', 'création de la table relation `system_schedule_job_folder`', 'start', 
      $run_id, $parent_run_id, $log_extra_tags
    );
    LET $res_job_folder = fn::system_schedule_job_folder_create_table_initialise($run_id);
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_table', 'création de la table relation `system_schedule_job_folder`', 'done',
      $run_id, $parent_run_id, $log_extra_tags
    );

    -- Étape: Définir la méthode d'accès BEARER
    LET $step = $step + 1;
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'définition de la méthode d\'accès BEARER', 'start', 
      $run_id, $parent_run_id, $log_extra_tags
    );
    fn::system_schedule_access_bearer_initialise($run_id);
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'définition de la méthode d\'accès BEARER', 'done',
      $run_id, $parent_run_id, $log_extra_tags
    );

    -- Étape: Créer la fonction de création de job cron-job.org
    LET $step = $step + 1;
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'création de la fonction `create_job_cronjoborg`', 'start', 
      $run_id, $parent_run_id, $log_extra_tags
    );
    fn::system_schedule_create_job_cronjoborg_initialise($run_id);
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'création de la fonction `create_job_cronjoborg`', 'done',
      $run_id, $parent_run_id, $log_extra_tags
    );

    -- Étape: Créer la fonction `system_schedule_get_all_jobs_cronjoborg`
    LET $step = $step + 1;
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'création de la fonction `system_schedule_get_all_jobs_cronjoborg`', 'start', 
      $run_id, $parent_run_id, $log_extra_tags
    );
    fn::system_schedule_get_all_jobs_cronjoborg_initialise($run_id);
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'création de la fonction `system_schedule_get_all_jobs_cronjoborg`', 'done',
      $run_id, $parent_run_id, $log_extra_tags
    );

    -- Étape: Créer la fonction `system_schedule_register_job_cronjoborg`
    LET $step = $step + 1;
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'création de la fonction `system_schedule_register_job_cronjoborg`', 'start', 
      $run_id, $parent_run_id, $log_extra_tags
    );
    fn::system_schedule_register_job_cronjoborg_initialise($run_id);
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'création de la fonction `system_schedule_register_job_cronjoborg`', 'done',
      $run_id, $parent_run_id, $log_extra_tags
    );

    -- Étape: Créer la fonction `system_schedule_get_job_details_cronjoborg`
    LET $step = $step + 1;
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'création de la fonction `system_schedule_get_job_details_cronjoborg`', 'start', 
      $run_id, $parent_run_id, $log_extra_tags
    );
    fn::system_schedule_get_job_details_cronjoborg_initialise($run_id);
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'création de la fonction `system_schedule_get_job_details_cronjoborg`', 'done',
      $run_id, $parent_run_id, $log_extra_tags
    );

    -- Étape: Créer la fonction `system_schedule_update_job_cronjoborg`
    LET $step = $step + 1;
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'création de la fonction `system_schedule_update_job_cronjoborg`', 'start', 
      $run_id, $parent_run_id, $log_extra_tags
    );
    fn::system_schedule_update_job_cronjoborg_initialise($run_id);
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'création de la fonction `system_schedule_update_job_cronjoborg`', 'done',
      $run_id, $parent_run_id, $log_extra_tags
    );

    -- Étape: Créer la fonction `system_schedule_delete_job_cronjoborg`
    LET $step = $step + 1;
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'création de la fonction `system_schedule_delete_job_cronjoborg`', 'start', 
      $run_id, $parent_run_id, $log_extra_tags
    );
    fn::system_schedule_delete_job_cronjoborg_initialise($run_id);
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'création de la fonction `system_schedule_delete_job_cronjoborg`', 'done',
      $run_id, $parent_run_id, $log_extra_tags
    );

    -- Étape: Initialiser les helpers cronjob.org
    LET $step = $step + 1;
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'initialisation des helpers cronjob.org', 'start', 
      $run_id, $parent_run_id, $log_extra_tags
    );
    fn::system_schedule_helper_title_initialise($run_id);
    fn::system_schedule_helper_request_method_initialise($run_id);
    fn::system_schedule_helper_schedule_daily_initialise($run_id);
    fn::system_schedule_helper_schedule_weekly_initialise($run_id);
    fn::system_schedule_helper_schedule_monthly_initialise($run_id);
    fn::system_schedule_helper_schedule_every_minute_initialise($run_id);
    fn::system_schedule_helper_schedule_every_hour_initialise($run_id);
    fn::system_schedule_helper_url_initialise($run_id);
    fn::system_schedule_helper_headers_initialise($run_id);
    fn::system_schedule_helper_notifications_initialise($run_id);
    fn::system_schedule_helper_basic_auth_initialise($run_id);
    fn::system_schedule_helper_request_timeout_initialise($run_id);
    fn::system_schedule_helper_redirect_success_initialise($run_id);
    fn::system_schedule_helper_schedule_custom_initialise($run_id);
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'initialisation des helpers cronjob.org', 'done',
      $run_id, $parent_run_id, $log_extra_tags
    );

    -- Étape: Créer la fonction `system_schedule_get_job_history_cronjoborg`
    LET $step = $step + 1;
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'création de la fonction `system_schedule_get_job_history_cronjoborg`', 'start', 
      $run_id, $parent_run_id, $log_extra_tags
    );
    fn::system_schedule_get_job_history_cronjoborg_initialise($run_id);
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'création de la fonction `system_schedule_get_job_history_cronjoborg`', 'done',
      $run_id, $parent_run_id, $log_extra_tags
    );

    -- Étape: Créer la fonction `system_schedule_get_job_history_item_cronjoborg`
    LET $step = $step + 1;
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'création de la fonction `system_schedule_get_job_history_item_cronjoborg`', 'start', 
      $run_id, $parent_run_id, $log_extra_tags
    );
    fn::system_schedule_get_job_history_item_cronjoborg_initialise($run_id);
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'création de la fonction `system_schedule_get_job_history_item_cronjoborg`', 'done',
      $run_id, $parent_run_id, $log_extra_tags
    );

    -- Étape: Synchronisation globale (sync_all)
    LET $step = $step + 1;
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'initialisation de la synchronisation globale (sync_all)', 'start', 
      $run_id, $parent_run_id, $log_extra_tags
    );
    fn::system_schedule_sync_all_cronjoborg_initialise($run_id);
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'initialisation de la synchronisation globale (sync_all)', 'done',
      $run_id, $parent_run_id, $log_extra_tags
    );

    -- Étape: Synchronisation après mise à jour (sync_after_update)
    LET $step = $step + 1;
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'initialisation de la synchronisation après mise à jour', 'start', 
      $run_id, $parent_run_id, $log_extra_tags
    );
    fn::system_schedule_sync_after_update_cronjoborg_initialise($run_id);
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'initialisation de la synchronisation après mise à jour', 'done',
      $run_id, $parent_run_id, $log_extra_tags
    );

    -- Étape: Créer la table relation system_schedule_tag
    LET $step = $step + 1;
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_table', 'création de la table relation system_schedule_tag', 'start', 
      $run_id, $parent_run_id, $log_extra_tags
    );
    fn::system_schedule_relation_create_table_initialise($run_id);
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_table', 'création de la table relation system_schedule_tag', 'done',
      $run_id, $parent_run_id, $log_extra_tags
    );

    -- Étape: Fonction relation add
    LET $step = $step + 1;
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'initialisation de la fonction relation (add)', 'start', 
      $run_id, $parent_run_id, $log_extra_tags
    );
    fn::system_schedule_relation_add_initialise($run_id);
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'initialisation de la fonction relation (add)', 'done',
      $run_id, $parent_run_id, $log_extra_tags
    );

    -- Étape: Fonction relation remove
    LET $step = $step + 1;
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'initialisation de la fonction relation (remove)', 'start', 
      $run_id, $parent_run_id, $log_extra_tags
    );
    fn::system_schedule_relation_remove_initialise($run_id);
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_function', 'initialisation de la fonction relation (remove)', 'done',
      $run_id, $parent_run_id, $log_extra_tags
    );

    -- Étape: Tags de référence system_schedule (initialise)
    LET $step = $step + 1;
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_tag', 'initialisation des tags de référence system_schedule', 'start', 
      $run_id, $parent_run_id, $log_extra_tags
    );
    fn::system_schedule_reference_tags_initialise($run_id);
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_tag', 'initialisation des tags de référence system_schedule', 'done',
      $run_id, $parent_run_id, $log_extra_tags
    );

    -- Étape: Création des tags de référence (exécution)
    LET $step = $step + 1;
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_tag', 'création des tags de référence system_schedule', 'start', 
      $run_id, $parent_run_id, $log_extra_tags
    );
    fn::system_schedule_reference_tags($run_id);
    fn::system_log_deploy_helper_step(
      $step, $total_steps, 'log_tag', 'création des tags de référence system_schedule', 'done',
      $run_id, $parent_run_id, $log_extra_tags
    );

    -- Journalisation: fin du déploiement
    fn::system_log_deploy_helper_summary(
      'Déploiement du composant `system_schedule`', 'finish', 
      $run_id, $parent_run_id, $log_extra_tags
    );
 
    RETURN { 
      success: true,
      run_id: $run_id
    };
  }
  COMMENT 'Déploie le composant `system_schedule`.'
  PERMISSIONS FULL;

  -- Journalisation: fin de l'initialisation
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
    'Done: initialisation de la fonction de déploiement pour `system_schedule`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN {
    success: true,
    run_id: $run_id
  };
}
COMMENT 'Initialise la fonction de déploiement pour le composant `system_schedule`.'
PERMISSIONS FULL;
