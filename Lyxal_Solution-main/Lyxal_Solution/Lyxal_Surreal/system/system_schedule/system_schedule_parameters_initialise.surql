-- =================================================================================================
-- |
-- | Fichier : system_schedule_parameters_initialise.surql
-- | Module : system_schedule
-- | Description : Définit les paramètres de session requis pour la configuration des
-- |              tâches planifiées externes. Ces paramètres doivent être fournis lors de la
-- |              connexion à la base de données.
-- |
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_parameters_initialise(
  $parent_run_id: option<string>
) {
  -- Paramètres
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_system'];
  LET $run_id = rand::uuid();

  -- Journalisation: début
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_parameter', 'log_define', 'log_start'], 
    $log_extra_tags),
    'Start: initialisation des paramètres du planificateur', 
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  -- Paramètre pour l'API de cron-job.org
  DEFINE PARAM IF NOT EXISTS $cronjob_api_key VALUE ''
  COMMENT "Clé API de cron-job.org";

  DEFINE PARAM IF NOT EXISTS $cronjob_surreal_token VALUE ''
  COMMENT "Token de SurrealDB Cloud";

  -- Paramètre pour le dossier cron-job.org
  DEFINE PARAM IF NOT EXISTS $cronjob_folder_id VALUE 0;

  -- Journalisation: fin
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_parameter', 'log_define', 'log_done', 'log_success'],
     $log_extra_tags),
    'Done: initialisation des paramètres du planificateur', 
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN {
    success: true,
    run_id: $run_id
  };
}
COMMENT 'Définit les paramètres de session pour le module de planification.'
PERMISSIONS FULL;
