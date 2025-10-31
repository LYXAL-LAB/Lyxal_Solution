-- =================================================================================================
-- |
-- | Fichier : system_core_deploy_updates_initialise.surql
-- | Module : system_core
-- | Description : Initialise le script de déploiement pour les mises à jour et configurations post-installation.
-- |
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::system_core_deploy_updates_initialise(
  $parent_run_id: option<string>
) {
  -- Paramètres
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_system_core'];
  LET $run_id = rand::uuid();

  -- Journalisation: début
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], $log_extra_tags),
    'Start: initialisation de la fonction `fn::system_core_deploy_updates`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  -- Définition de la fonction de déploiement des mises à jour
  DEFINE FUNCTION IF NOT EXISTS fn::system_core_deploy_updates(
    $parent_run_id: option<string>
  ) {
    -- Paramètres
    LET $run_id = rand::uuid();
    LET $total_steps = 4;
    LET $step = 0;
    LET $log_extra_tags = ['module_system_core', 'log_deploy_updates'];

    -- Journalisation: début du déploiement
    fn::system_log_deploy_helper_step($step, $total_steps, 'log_component',
      'Déploiement des mises à jour post-installation', 'start',
      $run_id, $parent_run_id, $log_extra_tags);

    -- =================================================================
    -- Étape 1: Créer l'environnement système
    -- =================================================================
    LET $step = $step + 1;
    fn::system_log_deploy_helper_step($step, $total_steps, 'log_environment',
      'Vérification/Création de l`environnement système', 'start',
      $run_id, $parent_run_id, $log_extra_tags);

    LET $system_env_id = type::thing('system_environment', 'system');
    LET $system_env = SELECT * FROM $system_env_id;
    IF count($system_env) = 0 {
      fn::system_environment_create_record(
        NONE, 'system', 'Environnement Système', 
        'Environnement racine pour les opérations globales du système.',
        'system_environment_type_instance'
      );
    };

    fn::system_log_deploy_helper_step($step, $total_steps, 'log_environment',
      'Vérification/Création de l`environnement système', 'done',
      $run_id, $parent_run_id, $log_extra_tags);

    -- =================================================================
    -- Étape 2: Créer le dossier de planification système
    -- =================================================================
    LET $step = $step + 1;
    fn::system_log_deploy_helper_step($step, $total_steps, 'log_folder',
      'Vérification/Création du dossier de planification système', 'start',
      $run_id, $parent_run_id, $log_extra_tags);

    LET $system_folder_id = type::thing('system_schedule_folder', 'system_schedule_folder_system');
    LET $system_folder = SELECT * FROM $system_folder_id;
    IF count($system_folder) = 0 {
      fn::system_schedule_folder_create($system_env_id, 'Dossier pour les tâches de maintenance système.');
    };

    fn::system_log_deploy_helper_step($step, $total_steps, 'log_folder',
      'Vérification/Création du dossier de planification système', 'done',
      $run_id, $parent_run_id, $log_extra_tags);

    -- =================================================================
    -- Étape 3: Créer le cron job pour l'archivage des logs
    -- =================================================================
    LET $step = $step + 1;
    fn::system_log_deploy_helper_step($step, $total_steps, 'log_cronjob',
      'Vérification/Création du cron job d`archivage des logs', 'start',
      $run_id, $parent_run_id, $log_extra_tags);

    LET $archive_job_title = "Maintenance: Archivage des Logs";
    LET $archive_job_exists = (SELECT count() FROM system_schedule WHERE title = $archive_job_title)[0];
    IF !$archive_job_exists {
        fn::system_schedule_create_job(
            $system_folder_id,
            'RETURN fn::system_log_archive(30);',
            0, -- 0:POST, 1:GET, 2:PUT, 3:DELETE
            { timezone: "Europe/Paris", hours: [1], minutes: [0] }, -- Tous les jours à 1h00
            true,
            true,
            $archive_job_title,
            NONE, NONE, NONE, NONE
        );
    };

    fn::system_log_deploy_helper_step($step, $total_steps, 'log_cronjob',
      'Vérification/Création du cron job d`archivage des logs', 'done',
      $run_id, $parent_run_id, $log_extra_tags);

    -- =================================================================
    -- Étape 4: Créer le cron job pour le nettoyage des logs
    -- =================================================================
    LET $step = $step + 1;
    fn::system_log_deploy_helper_step($step, $total_steps, 'log_cronjob',
      'Vérification/Création du cron job de nettoyage des logs', 'start',
      $run_id, $parent_run_id, $log_extra_tags);
      
    LET $cleanup_job_title = "Maintenance: Nettoyage des Archives de Logs";
    LET $cleanup_job_exists = (SELECT count() FROM system_schedule WHERE title = $cleanup_job_title)[0];
    IF !$cleanup_job_exists {
        fn::system_schedule_create_job(
            $system_folder_id,
            'RETURN fn::system_log_cleanup(365);',
            0, -- 0:POST, 1:GET, 2:PUT, 3:DELETE
            { timezone: "Europe/Paris", hours: [3], minutes: [0], weekdays: [0] }, -- Tous les dimanches à 3h00
            true,
            true,
            $cleanup_job_title,
            NONE, NONE, NONE, NONE
        );
    };

    fn::system_log_deploy_helper_step($step, $total_steps, 'log_cronjob',
      'Vérification/Création du cron job de nettoyage des logs', 'done',
      $run_id, $parent_run_id, $log_extra_tags);

    -- Journalisation: fin du déploiement
    fn::system_log_deploy_helper_summary('Déploiement des mises à jour post-installation',
      'finish', $run_id, $parent_run_id, $log_extra_tags);

    RETURN { success: true, run_id: $run_id };
  }
  COMMENT 'Déploie les configurations post-installation (cron jobs, etc.).'
  PERMISSIONS FULL;

  -- Journalisation: fin
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
    'Done: initialisation de la fonction `fn::system_core_deploy_updates`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Initialise la fonction de déploiement des mises à jour.'
PERMISSIONS FULL;
