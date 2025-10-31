-- =================================================================================================
-- | Fichier : system_schedule_helper_notifications_initialise.surql
-- | Module  : system_schedule
-- | Desc.   : Helper - construction des notifications pour DetailedJob
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_helper_notifications_initialise(
  $parent_run_id: option<string>
) {
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_system'];
  LET $run_id = rand::uuid();

  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], $log_extra_tags),
    'Start: initialisation helper notifications', { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_cronjoborg_build_notifications(
    $onFailure: bool,
    $onSuccess: bool,
    $onDisable: bool
  ) { RETURN { onFailure: $onFailure, onSuccess: $onSuccess, onDisable: $onDisable }; }
  COMMENT 'Construit l\'objet notification pour DetailedJob.'
  PERMISSIONS FULL;

  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
    'Done: initialisation helper notifications', { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Initialise le helper de notifications cronjob.org.'
PERMISSIONS FULL;
