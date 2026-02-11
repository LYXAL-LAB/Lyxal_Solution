-- =================================================================================================
-- |
-- | Fichier : system_schedule_folder_create_table_initialise.surql
-- | Module : system_schedule
-- | Description : Ce fichier initialise la table `system_schedule_folder` qui stockera les
-- |              dossiers pour organiser les tâches planifiées.
-- |
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_folder_create_table_initialise(
  $parent_run_id: option<string>
) {
  -- Paramètres
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_system'];
  LET $run_id = rand::uuid();

  -- Journalisation: début
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_table', 'log_create', 'log_start'], 
    $log_extra_tags),
    'Start: initialisation de la création de la table `system_schedule_folder`', 
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  -- Définition de la table
  DEFINE TABLE IF NOT EXISTS system_schedule_folder TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
      FOR select FULL
      FOR create, update, delete NONE;

  -- Définition des champs
  DEFINE FIELD IF NOT EXISTS name ON system_schedule_folder TYPE string
  ASSERT $value != NONE AND $value != '' AND string::len($value) <= 255
  COMMENT "Nom du dossier";

  DEFINE FIELD IF NOT EXISTS description ON system_schedule_folder TYPE option<string>
  COMMENT "Description du dossier";
  
  DEFINE FIELD IF NOT EXISTS environment ON system_schedule_folder TYPE record<system_environment>
  ASSERT $value != NONE
  COMMENT "Environnement associé";
  
  DEFINE FIELD IF NOT EXISTS created_at ON system_schedule_folder TYPE datetime
  DEFAULT time::now()
  READONLY
  COMMENT "Date de création";
  
  DEFINE FIELD IF NOT EXISTS updated_at ON system_schedule_folder TYPE datetime
  DEFAULT time::now()
  COMMENT "Date de dernière modification";

  -- Indexes pragmatiques
  DEFINE INDEX IF NOT EXISTS system_schedule_folder_name ON system_schedule_folder 
  FIELDS name
  COMMENT "Index sur le nom du dossier";

  DEFINE INDEX IF NOT EXISTS system_schedule_folder_environment ON system_schedule_folder 
  FIELDS environment
  COMMENT "Index sur l'environnement";
  
  DEFINE INDEX IF NOT EXISTS system_schedule_folder_unique ON system_schedule_folder 
  FIELDS name, environment UNIQUE
  COMMENT "Un nom de dossier unique par environnement";

  -- Journalisation: fin
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_table', 'log_create', 'log_done', 'log_success'], 
    $log_extra_tags),
    'Done: initialisation de la création de la table `system_schedule_folder`', 
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN {
    success: true,
    run_id: $run_id
  };
}
COMMENT 'Initialise la définition de la table `system_schedule_folder`.'
PERMISSIONS FULL;
