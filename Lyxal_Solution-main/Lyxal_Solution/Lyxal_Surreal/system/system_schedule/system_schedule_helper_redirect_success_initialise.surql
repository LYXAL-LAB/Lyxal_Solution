-- =================================================================================================
-- | Fichier : system_schedule_helper_redirect_success_initialise.surql
-- | Module  : system_schedule
-- | Desc.   : Helper - valeur de redirectSuccess (considérer 3xx comme succès)
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_helper_redirect_success_initialise(
  $parent_run_id: option<string>
) {
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_system'];
  LET $run_id = rand::uuid();

  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], $log_extra_tags),
    'Start: initialisation helper redirect_success', { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_cronjoborg_build_redirect_success(
    $redirect: bool
  ) { RETURN $redirect; }
  COMMENT 'Retourne la valeur de redirectSuccess.'
  PERMISSIONS FULL;

  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
    'Done: initialisation helper redirect_success', { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Initialise le helper de redirectSuccess.'
PERMISSIONS FULL;
