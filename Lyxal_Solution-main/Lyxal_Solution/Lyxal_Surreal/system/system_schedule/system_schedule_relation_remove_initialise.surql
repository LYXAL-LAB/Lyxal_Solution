-- =================================================================================================
-- | Fichier : system_schedule_relation_remove_initialise.surql
-- | Module  : system_schedule
-- | Desc.   : Fonction pour délier un tag d'un job system_schedule (remove)
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_relation_remove_initialise(
  $parent_run_id: option<string>
) {
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_system'];
  LET $run_id = rand::uuid();

  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], $log_extra_tags),
    'Start: initialisation fonction relation remove', { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_tag_remove(
    $schedule_id: record<system_schedule>,
    $tag_id: record<system_tag>
  ) {
    DELETE system_schedule_tag WHERE in = $schedule_id AND out = $tag_id;
    RETURN { success: true };
  }
  COMMENT 'Supprime le lien tag d\'un job system_schedule.'
  PERMISSIONS FULL;

  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
    'Done: initialisation fonction relation remove', { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Initialise la fonction relationnelle (remove) entre system_schedule et system_tag.'
PERMISSIONS FULL;
