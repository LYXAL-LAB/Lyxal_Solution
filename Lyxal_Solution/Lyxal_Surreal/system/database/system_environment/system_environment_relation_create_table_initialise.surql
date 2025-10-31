-- ================================================================================================
-- | Fichier : system_environment_relation_create_table_initialise.surql
-- | Module  : system_environment
-- | Desc.   : Relation de tags pour typer et activer/désactiver les environments
-- ================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::system_environment_relation_create_table_initialise(
  $parent_run_id: option<string>
) {
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_system', 'system_environment', 
  'create_table_environment_tag'];
  LET $run_id = rand::uuid();

  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], 
    $log_extra_tags),
    'Start: création de la relation `system_environment_tag`', 
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  DEFINE TABLE IF NOT EXISTS system_environment_tag 
  TYPE RELATION FROM system_environment TO system_tag 
  COMMENT "Tags pour typer/état des environments"
  PERMISSIONS FULL;

  DEFINE INDEX IF NOT EXISTS system_environment_tag_from_to ON system_environment_tag 
  FIELDS in, out UNIQUE
  COMMENT 'Clé unique (in, out)';

  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'],
     $log_extra_tags),
    'Done: création de la relation `system_environment_tag`', 
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Initialise la relation de tags entre system_environment et system_tag.'
PERMISSIONS FULL;


