-- =================================================================================================
-- |
-- | Fichier : system_schedule_job_folder_create_table_initialise.surql
-- | Module : system_schedule
-- | Description : Crée la table relation entre `system_schedule` -> `system_schedule_folder` (edges)
-- |
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_job_folder_create_table_initialise(
  $parent_run_id: option<string>
) {
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_system'];
  LET $run_id = rand::uuid();

  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_table', 'log_create', 'log_start'], $log_extra_tags),
    'Start: création table relation system_schedule_job_folder', { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  -- Définition de la table relation
  DEFINE TABLE IF NOT EXISTS system_schedule_job_folder TYPE RELATION 
    FROM system_schedule TO system_schedule_folder 
    SCHEMAFULL
    PERMISSIONS
      FOR select FULL
      FOR create, update, delete NONE
    COMMENT 'Relation: lie une tâche planifiée à un dossier.';

  -- Définition des champs
  DEFINE FIELD IF NOT EXISTS assigned_at ON system_schedule_job_folder TYPE datetime
  DEFAULT time::now()
  READONLY
  COMMENT "Date d'assignation au dossier";

  DEFINE FIELD IF NOT EXISTS notes ON system_schedule_job_folder TYPE option<string>
  COMMENT "Notes sur l'assignation";

  -- Indexes pour les performances
  DEFINE INDEX IF NOT EXISTS system_schedule_job_folder_from ON system_schedule_job_folder FIELDS in
  COMMENT "Index sur la tâche source";
  
  DEFINE INDEX IF NOT EXISTS system_schedule_job_folder_to ON system_schedule_job_folder FIELDS out
  COMMENT "Index sur le dossier cible";
  
  DEFINE INDEX IF NOT EXISTS system_schedule_job_folder_unique ON system_schedule_job_folder FIELDS in, out UNIQUE
  COMMENT "Une tâche ne peut être que dans un seul dossier";

  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_table', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
    'Done: création table relation system_schedule_job_folder', { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Initialise la table relation system_schedule_job_folder (edges).'
PERMISSIONS FULL;
