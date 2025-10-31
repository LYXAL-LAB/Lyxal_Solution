-- =================================================================================================
-- | Fichier : system_schedule_helper_request_method_initialise.surql
-- | Module  : system_schedule
-- | Desc.   : Helper - mapping nom de méthode HTTP -> RequestMethod cronjob.org
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_helper_request_method_initialise(
  $parent_run_id: option<string>
) {
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_system'];
  LET $run_id = rand::uuid();

  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], $log_extra_tags),
    'Start: initialisation helper request_method', { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_cronjoborg_request_method_from_name(
    $name: string
  ) {
    LET $n = string::lowercase($name);
    RETURN IF $n = 'get' THEN 0 ELSE IF $n = 'post' THEN 1 ELSE IF $n = 'options' THEN 2 ELSE IF $n = 'head' THEN 3 ELSE IF $n = 'put' THEN 4 ELSE IF $n = 'delete' THEN 5 ELSE IF $n = 'trace' THEN 6 ELSE IF $n = 'connect' THEN 7 ELSE 8 END;
  }
  COMMENT 'Mappe le nom de méthode HTTP sur la valeur `RequestMethod` cron-job.org.'
  PERMISSIONS FULL;

  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
    'Done: initialisation helper request_method', { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Initialise le helper de mapping de méthode HTTP.'
PERMISSIONS FULL;
