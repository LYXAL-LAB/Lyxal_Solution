-- =================================================================================================
-- |
-- | Fichier : system_schedule_folder_delete_initialise.surql
-- | Module : system_schedule
-- | Description : Supprime un dossier et gère les tâches orphelines
-- |
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_folder_delete_initialise(
  $parent_run_id: option<string>
) {
  -- Paramètres
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_system'];
  LET $run_id = rand::uuid();

  -- Journalisation: début
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], $log_extra_tags),
    'Start: initialisation de la fonction `system_schedule_folder_delete`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  -- Définition de la fonction
  DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_folder_delete(
    $folder_id: string
  ) {
    -- Validation du paramètre
    IF $folder_id = NONE OR $folder_id = '' {
      THROW "L'ID du dossier est requis";
    };
    
    -- Vérifier que le dossier existe
    LET $folder = SELECT * FROM type::thing('system_schedule_folder', $folder_id);
    IF count($folder) = 0 {
      -- Si le dossier n'existe pas, on considère que la suppression a réussi
      -- car l'état final est celui souhaité (le dossier n'existe plus).
      RETURN {
        success: true,
        message: "Le dossier n'existait pas déjà.",
        deleted_folder_id: $folder_id
      };
    };
    
    -- Récupérer les enregistrements complets des tâches à supprimer
    LET $jobs_to_delete = (SELECT in.* FROM system_schedule_job_folder 
      WHERE out = type::thing('system_schedule_folder', $folder_id));
    
    LET $deleted_jobs_count = count($jobs_to_delete);
    
    -- Supprimer chaque tâche distante via l'API cron-job.org
    IF $deleted_jobs_count > 0 {
      FOR $job IN $jobs_to_delete {
        -- L'ID externe est stocké dans 'job_id'
        fn::system_schedule_delete_job_cronjoborg($job.job_id);
      };
      -- Supprimer les enregistrements locaux des tâches
      DELETE $jobs_to_delete;
    };
    
    -- Supprimer les relations
      DELETE system_schedule_job_folder WHERE out = type::thing('system_schedule_folder', $folder_id);
    
    -- Supprimer le dossier
    DELETE type::thing('system_schedule_folder', $folder_id);
    
    -- Journalisation de fin
    fn::system_log_create_record_system(
        ['log_function', 'log_delete', 'log_done', 'log_success'],
        "Dossier de planification et tâches associées supprimés avec succès.",
        { 
            deleted_folder_id: $folder_id,
            deleted_jobs_count: $deleted_jobs_count
        }
    );
    
    RETURN {
      success: true,
      deleted_folder_id: $folder_id,
      deleted_jobs_count: $deleted_jobs_count
    };
  }
  COMMENT 'Supprime un dossier et toutes les tâches associées (suppression en cascade).'
  PERMISSIONS FULL;

  -- Journalisation: fin
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
    'Done: initialisation de la fonction `system_schedule_folder_delete`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN {
    success: true,
    run_id: $run_id
  };
}
COMMENT 'Initialise la fonction de suppression de dossier.'
PERMISSIONS FULL;
