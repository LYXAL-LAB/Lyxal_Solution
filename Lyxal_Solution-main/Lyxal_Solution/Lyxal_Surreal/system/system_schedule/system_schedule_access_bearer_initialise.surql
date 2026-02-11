-- =================================================================================================
-- |
-- | Fichier : system_schedule_access_bearer_initialise.surql
-- | Module : system_schedule
-- | Description : Définit la méthode d'accès de type BEARER pour générer des tokens
-- |              d'authentification sécurisés pour le service de planification.
-- |
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_access_bearer_initialise(
  $parent_run_id: option<string>
) {
  -- Paramètres
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_system'];
  LET $run_id = rand::uuid();

  -- Journalisation: début
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_access', 'log_create', 'log_start'], $log_extra_tags),
    'Start: initialisation de la méthode d\'accès BEARER `scheduler_access`', 
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  -- Définir une méthode d'accès de type BEARER pour générer des tokens pour les utilisateurs système.
  -- FOR GRANT 1y : Le "droit de générer des tokens" expire au bout d'1 an.
  DEFINE ACCESS IF NOT EXISTS scheduler_access ON NAMESPACE
    TYPE BEARER FOR USER
    DURATION FOR GRANT 1y;

  -- Journalisation: fin
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_access', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
    'Done: initialisation de la méthode d\'accès BEARER `scheduler_access`', 
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN {
    success: true,
    run_id: $run_id
  };
}
COMMENT 'Initialise la méthode d\'accès BEARER pour le planificateur.'
PERMISSIONS FULL;
