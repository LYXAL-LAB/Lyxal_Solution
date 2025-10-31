-- =================================================================================================
-- | Fichier : system_schedule_relation_add_initialise.surql
-- | Module  : system_schedule
-- | Desc.   : Fonction pour relier un tag à un job system_schedule (add)
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_relation_add_initialise(
  $parent_run_id: option<string>
) {
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_system'];
  LET $run_id = rand::uuid();

  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], $log_extra_tags),
    'Start: initialisation fonction relation add', { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_tag_add(
    $schedule_id: record<system_schedule>,
    $tag_id: record<system_tag>
  ) {
    LET $exists = SELECT id FROM system_schedule_tag WHERE in = $schedule_id AND out = $tag_id LIMIT 1;
    IF array::len($exists) = 0 THEN {
      RELATE $schedule_id->system_schedule_tag->$tag_id;
    } END;
    RETURN { success: true };
  }
  COMMENT 'Ajoute un tag à un job system_schedule (idempotent).'
  PERMISSIONS FULL;

  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
    'Done: initialisation fonction relation add', { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Initialise la fonction relationnelle (add) entre system_schedule et system_tag.'
PERMISSIONS FULL;
