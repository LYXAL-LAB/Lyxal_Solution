-- =================================================================================================
-- |
-- | Fichier : system_schedule_folder_disable_jobs_initialise.surql
-- | Module : system_schedule
-- | Description : Désactive toutes les tâches cron (via API) dans un dossier spécifique.
-- |
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_folder_disable_jobs_initialise(
  $parent_run_id: option<string>
) {
  -- Paramètres
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_system'];
  LET $run_id = rand::uuid();

  -- Journalisation: début
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], $log_extra_tags),
    'Start: initialisation de la fonction `system_schedule_folder_disable_jobs`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  -- Définition de la fonction
  DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_folder_disable_jobs(
    $folder_id: string
  ) {
    -- 1. Récupérer les enregistrements complets des tâches du dossier
    LET $jobs_to_disable = (SELECT in.* FROM system_schedule_job_folder 
      WHERE out = type::thing('system_schedule_folder', $folder_id));
    
    LET $disabled_jobs_count = count($jobs_to_disable);
    LET $disabled_job_ids = [];

    -- 2. Désactiver chaque tâche distante via l'API cron-job.org
    IF $disabled_jobs_count > 0 {
      FOR $job IN $jobs_to_disable {
        -- L'ID externe est stocké dans 'job_id'
        -- On met à jour le job pour le désactiver
        fn::system_schedule_update_job_cronjoborg($job.job_id, { enabled: false });
        LET $disabled_job_ids = array::push($disabled_job_ids, $job.id);
      }
    };
    
    -- 3. Journalisation de fin
    fn::system_log_create_record_system(
        ['log_function', 'log_update', 'log_done', 'log_success'],
        "Tâches du dossier désactivées avec succès.",
        { 
            folder_id: $folder_id,
            disabled_jobs_count: $disabled_jobs_count,
            disabled_job_ids: $disabled_job_ids
        }
    );

    RETURN {
      success: true,
      folder_id: $folder_id,
      disabled_jobs_count: $disabled_jobs_count,
      disabled_job_ids: $disabled_job_ids
    };
  }
  COMMENT 'Désactive toutes les tâches cron d\'un dossier via l\'API externe.'
  PERMISSIONS FULL;

  -- Journalisation: fin
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
    'Done: initialisation de la fonction `system_schedule_folder_disable_jobs`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN {
    success: true,
    run_id: $run_id
  };
}
COMMENT 'Initialise la fonction pour désactiver les tâches d\'un dossier.'
PERMISSIONS FULL;
