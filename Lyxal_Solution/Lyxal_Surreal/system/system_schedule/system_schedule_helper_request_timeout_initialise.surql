-- =================================================================================================
-- | Fichier : system_schedule_helper_request_timeout_initialise.surql
-- | Module  : system_schedule
-- | Desc.   : Helper - valeur de requestTimeout (en secondes)
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_helper_request_timeout_initialise(
  $parent_run_id: option<string>
) {
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_system'];
  LET $run_id = rand::uuid();

  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], $log_extra_tags),
    'Start: initialisation helper request_timeout', { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_cronjoborg_build_request_timeout(
    $seconds: int
  ) { RETURN $seconds; }
  COMMENT 'Retourne la valeur de requestTimeout (en secondes).'
  PERMISSIONS FULL;

  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
    'Done: initialisation helper request_timeout', { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Initialise le helper de requestTimeout.'
PERMISSIONS FULL;
