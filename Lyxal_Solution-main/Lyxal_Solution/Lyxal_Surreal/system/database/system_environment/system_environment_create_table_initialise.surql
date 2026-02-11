-- ================================================================================================
-- | Fichier : system_environment_create_table_initialise.surql
-- | Module  : system_environment
-- | Desc.   : Crée la table unifiée `system_environment`
-- ================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::system_environment_create_table_initialise(
  $parent_run_id: option<string>
) {
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_system', 'system_environment', 
  'create_table_environment'];
  LET $run_id = rand::uuid();

  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'],
     $log_extra_tags),
    'Start: création de la table unifiée `system_environment`', 
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  DEFINE TABLE IF NOT EXISTS system_environment 
  COMMENT "Hiérarchie unifiée: instance → namespace → database"
  PERMISSIONS FULL;

  DEFINE FIELD IF NOT EXISTS parent ON system_environment 
  TYPE option<record<system_environment>> 
  COMMENT "Parent environment (NONE pour instance)";

  DEFINE FIELD IF NOT EXISTS name ON system_environment 
  TYPE string 
  COMMENT "Nom logique";

  DEFINE FIELD IF NOT EXISTS label ON system_environment 
  TYPE string 
  COMMENT "Libellé";

  DEFINE FIELD IF NOT EXISTS description ON system_environment 
  TYPE string 
  COMMENT "Description";
  DEFINE FIELD IF NOT EXISTS created_at ON system_environment 
  TYPE datetime 
  COMMENT "Date de création";

  DEFINE FIELD IF NOT EXISTS updated_at ON system_environment 
  TYPE datetime 
  COMMENT "Date de mise à jour";

  DEFINE INDEX IF NOT EXISTS system_environment_key ON system_environment 
  FIELDS parent, name UNIQUE 
  COMMENT "Clé unique (parent,name)";

  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'], 
    $log_extra_tags),
    'Done: création de la table unifiée `system_environment`', 
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Initialise la création de la table unifiée system_environment.'
PERMISSIONS FULL;


