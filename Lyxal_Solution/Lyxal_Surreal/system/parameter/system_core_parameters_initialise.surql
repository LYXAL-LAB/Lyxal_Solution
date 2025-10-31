-- =================================================================================================
-- |
-- | Fichier : system_core_parameters_initialise.surql
-- | Module : system_core
-- | Description : Définit les paramètres de session globaux requis pour l'application,
-- |              comme les détails de l'instance SurrealDB.
-- |
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::system_core_parameters_initialise(
  $parent_run_id: option<string>
) {
  -- Paramètres
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_system', 'sub_module_system_core', 'parameters'];
  LET $run_id = rand::uuid();

  -- Journalisation: début
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_parameter', 'log_define', 'log_start'], 
    $log_extra_tags),
    'Start: initialisation des paramètres core', 
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );
  
  -- Paramètres pour SurrealDB Cloud
  DEFINE PARAM IF NOT EXISTS $surreal_instance VALUE '' 
  COMMENT "Nom de l'instance SurrealDB Cloud (ex: my-instance.surrealdb.cloud)";
  DEFINE PARAM IF NOT EXISTS $surreal_namespace VALUE '' 
  COMMENT "Namespace à utiliser dans l'instance";
  DEFINE PARAM IF NOT EXISTS $surreal_database VALUE '' 
  COMMENT "Base de données à utiliser dans le namespace";

  -- Journalisation: fin
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_parameter', 'log_define', 'log_done', 'log_success'],
     $log_extra_tags),
    'Done: initialisation des paramètres core', 
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN {
    success: true,
    run_id: $run_id
  };
}
COMMENT "Définit les paramètres de session core pour l'application."
PERMISSIONS FULL;
