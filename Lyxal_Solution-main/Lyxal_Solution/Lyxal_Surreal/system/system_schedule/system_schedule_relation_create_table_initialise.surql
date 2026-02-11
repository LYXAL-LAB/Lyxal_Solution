-- =================================================================================================
-- | Fichier : system_schedule_relation_create_table_initialise.surql
-- | Module  : system_schedule
-- | Desc.   : Crée la table relation entre `system_schedule` -> `system_tag` (edges)
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_relation_create_table_initialise(
  $parent_run_id: option<string>
) {
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_system'];
  LET $run_id = rand::uuid();

  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], $log_extra_tags),
    'Start: création table relation system_schedule_tag', { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  DEFINE TABLE IF NOT EXISTS system_schedule_tag TYPE RELATION FROM system_schedule TO system_tag COMMENT 'Relation: lie un record system_schedule à un system_tag.';

  DEFINE INDEX IF NOT EXISTS system_schedule_tag_from ON system_schedule_tag FIELDS in;
  DEFINE INDEX IF NOT EXISTS system_schedule_tag_to ON system_schedule_tag FIELDS out;

  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
    'Done: création table relation system_schedule_tag', { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Initialise la table relation system_schedule_tag (edges).'
PERMISSIONS FULL;
