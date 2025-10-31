-- =================================================================================================
-- | Fichier : system_schedule_helper_basic_auth_initialise.surql
-- | Module  : system_schedule
-- | Desc.   : Helper - construction de l'auth HTTP basic
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_helper_basic_auth_initialise(
  $parent_run_id: option<string>
) {
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_system'];
  LET $run_id = rand::uuid();

  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], $log_extra_tags),
    'Start: initialisation helper basic_auth', { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_cronjoborg_build_basic_auth(
    $enable: bool,
    $user: string,
    $password: string
  ) { RETURN { enable: $enable, user: $user, password: $password }; }
  COMMENT 'Construit l\'objet auth HTTP basic pour DetailedJob.'
  PERMISSIONS FULL;

  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
    'Done: initialisation helper basic_auth', { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Initialise le helper d\'auth HTTP basic.'
PERMISSIONS FULL;
