-- =================================================================================================
-- | Fichier : system_schedule_reference_tags_initialise.surql
-- | Module  : system_schedule
-- | Desc.   : Crée les tags de référence dédiés à system_schedule
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_reference_tags_initialise(
  $parent_run_id: option<string>
) {
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_system'];
  LET $run_id = rand::uuid();

  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], $log_extra_tags),
    'Start: initialisation system_schedule_reference_tags', { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_reference_tags(
    $parent_run_id: option<string>
  ) {
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra = ['module_system', 'log_reference_tags'];

    -- Tags de base dédiés au module system_schedule
    fn::system_tag_create_record_system('system_schedule', 'System Schedule', 'Module System Schedule', '#455A64', 10, true, $log_extra, $parent_run_id);
    fn::system_tag_create_record_system('system_schedule_job', 'Schedule: Job', 'Tag pour identifier un job planifié', '#1E88E5', 20, true, $log_extra, $parent_run_id);
    fn::system_tag_create_record_system('system_schedule_gateway', 'Schedule: Gateway', 'Tag pour les fonctions gateway cron-job.org', '#6D4C41', 30, true, $log_extra, $parent_run_id);
    fn::system_tag_create_record_system('system_schedule_history', 'Schedule: History', 'Tag pour les fonctions d\'historique', '#00897B', 40, true, $log_extra, $parent_run_id);
    fn::system_tag_create_record_system('system_schedule_sync', 'Schedule: Sync', 'Tag pour la synchronisation globale', '#7CB342', 50, true, $log_extra, $parent_run_id);
    fn::system_tag_create_record_system('system_schedule_relation', 'Schedule: Relation', 'Tag pour la relation schedule <-> tag', '#8E24AA', 60, true, $log_extra, $parent_run_id);

    RETURN { success: true };
  }
  COMMENT 'Crée les tags de référence dédiés au module system_schedule.'
  PERMISSIONS FULL;

  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
    'Done: initialisation system_schedule_reference_tags', { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Initialise la fonction de création des tags de référence system_schedule.'
PERMISSIONS FULL;
