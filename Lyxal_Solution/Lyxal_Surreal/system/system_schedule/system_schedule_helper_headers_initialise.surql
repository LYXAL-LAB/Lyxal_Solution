-- =================================================================================================
-- | Fichier : system_schedule_helper_headers_initialise.surql
-- | Module  : system_schedule
-- | Desc.   : Helper - construction des headers pour SurrealDB SQL
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_helper_headers_initialise(
  $parent_run_id: option<string>
) {
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_system'];
  LET $run_id = rand::uuid();

  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], $log_extra_tags),
    'Start: initialisation helper headers', { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_cronjoborg_build_surreal_headers() {
    RETURN {
      'Authorization': 'Bearer ' + $surreal_token,
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'NS': $surreal_namespace,
      'DB': $surreal_database
    };
  }
  COMMENT 'Construit les headers requis pour requêter SurrealDB via /sql.'
  PERMISSIONS FULL;

  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
    'Done: initialisation helper headers', { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Initialise le helper de headers Surreal.'
PERMISSIONS FULL;
