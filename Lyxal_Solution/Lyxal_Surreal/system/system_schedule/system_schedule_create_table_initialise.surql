-- =================================================================================================
-- |
-- | Fichier : system_schedule_create_table_initialise.surql
-- | Module : system_schedule
-- | Description : Ce fichier initialise la table `system_schedule` qui stockera les
-- |              informations sur les tâches planifiées externes (ex: cron jobs).
-- |
-- =================================================================================================

DEFINE FUNCTION fn::system_schedule_create_table_initialise(
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
    'Start: initialisation de la création de la table `system_schedule`', 
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  -- Définition de la table
  DEFINE TABLE IF NOT EXISTS system_schedule TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
      FOR select FULL
      FOR create, update, delete NONE;

  -- Définition des champs
  DEFINE FIELD IF NOT EXISTS namespace ON system_schedule TYPE string
  COMMENT "Namespace SurrealDB";

  DEFINE FIELD IF NOT EXISTS database ON system_schedule TYPE string
  COMMENT "Base de données SurrealDB";
  
  DEFINE FIELD IF NOT EXISTS job_type ON system_schedule TYPE string
  COMMENT "Type de tâche";
  
  DEFINE FIELD IF NOT EXISTS title ON system_schedule TYPE string
  COMMENT "Titre de la tâche";
  
  DEFINE FIELD IF NOT EXISTS request_method ON system_schedule TYPE int
  COMMENT "Méthode de requête";
  
  DEFINE FIELD IF NOT EXISTS schedule ON system_schedule TYPE object
  COMMENT "Planification de la tâche";
  
  DEFINE FIELD IF NOT EXISTS enabled  ON system_schedule TYPE bool
  COMMENT "Est activé";
  
  DEFINE FIELD IF NOT EXISTS save_responses ON system_schedule TYPE bool
  COMMENT "Enregistrer les réponses";
  
  DEFINE FIELD IF NOT EXISTS cron_job_id ON system_schedule TYPE int
  COMMENT "ID de la tâche cron-job.org";
  
  DEFINE FIELD IF NOT EXISTS last_sync ON system_schedule TYPE datetime
  COMMENT "Dernière synchronisation";
  
  DEFINE FIELD IF NOT EXISTS status ON system_schedule TYPE string
  COMMENT "Statut de la tâche";

  -- Indexes pragmatiques
  DEFINE INDEX IF NOT EXISTS system_schedule_key ON system_schedule 
  FIELDS namespace, database, title UNIQUE
  COMMENT "Index unique pour les tâches";

  DEFINE INDEX IF NOT EXISTS system_schedule_cron_job_id ON system_schedule 
  FIELDS cron_job_id
  COMMENT "Index pour l'ID de la tâche cron-job.org";

  -- Journalisation: fin
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_table', 'log_create', 'log_done', 'log_success'], 
    $log_extra_tags),
    'Done: initialisation de la création de la table `system_schedule`', 
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN {
    success: true,
    run_id: $run_id
  };
}
COMMENT 'Initialise la définition de la table `system_schedule`.'
PERMISSIONS FULL;
