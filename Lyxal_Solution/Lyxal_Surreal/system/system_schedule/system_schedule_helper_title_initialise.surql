-- =================================================================================================
-- | Fichier : system_schedule_helper_title_initialise.surql
-- | Module  : system_schedule
-- | Desc.   : Helper - construction de titre standardisé pour cronjob.org
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_helper_title_initialise(
  $parent_run_id: option<string>
) {
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_system'];
  LET $run_id = rand::uuid();

  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], $log_extra_tags),
    'Start: initialisation helper title', { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_cronjoborg_build_title(
    $namespace: string,
    $database: string,
    $job_type: string,
    $base_title: string
  ) { RETURN '[Lyxal]' + '[NS:' + $namespace + ']' + '[DB:' + $database + ']' + '[Type:' + $job_type + '] ' + $base_title; }
  COMMENT 'Construit un titre de job conventionné.'
  PERMISSIONS FULL;

  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
    'Done: initialisation helper title', { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Initialise le helper de titre cronjob.org.'
PERMISSIONS FULL;
