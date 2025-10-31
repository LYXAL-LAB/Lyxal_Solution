-- =================================================================================================
-- |
-- | Fichier : system_schedule_folder_get_jobs_initialise.surql
-- | Module : system_schedule
-- | Description : Récupère toutes les tâches d'un dossier
-- |
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_folder_get_jobs_initialise(
  $parent_run_id: option<string>
) {
  -- Paramètres
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_system'];
  LET $run_id = rand::uuid();

  -- Journalisation: début
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], $log_extra_tags),
    'Start: initialisation de la fonction `system_schedule_folder_get_jobs`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  -- Définition de la fonction
  DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_folder_get_jobs(
    $folder_id: string
  ) {
    -- Validation du paramètre
    IF $folder_id = NONE OR $folder_id = '' {
      THROW "L'ID du dossier est requis";
    };
    
    -- Vérifier que le dossier existe
    LET $folder = SELECT * FROM type::thing('system_schedule_folder', $folder_id);
    IF count($folder) = 0 {
      THROW "Le dossier spécifié n'existe pas";
    };
    
    -- Récupérer toutes les tâches de ce dossier via la relation
    LET $jobs = SELECT 
      in.* as job,
      assigned_at,
      notes
    FROM system_schedule_job_folder 
    WHERE out = type::thing('system_schedule_folder', $folder_id);
    
    RETURN {
      folder: $folder[0],
      jobs: $jobs,
      count: count($jobs)
    };
  }
  COMMENT 'Récupère toutes les tâches assignées à un dossier.'
  PERMISSIONS FULL;

  -- Journalisation: fin
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
    'Done: initialisation de la fonction `system_schedule_folder_get_jobs`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN {
    success: true,
    run_id: $run_id
  };
}
COMMENT 'Initialise la fonction de récupération des tâches d\'un dossier.'
PERMISSIONS FULL;
