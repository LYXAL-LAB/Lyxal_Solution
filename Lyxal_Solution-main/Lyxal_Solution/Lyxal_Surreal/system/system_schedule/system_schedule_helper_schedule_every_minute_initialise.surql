-- =================================================================================================
-- | Fichier : system_schedule_helper_schedule_every_minute_initialise.surql
-- | Module  : system_schedule
-- | Desc.   : Helper - schedule chaque minute
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_helper_schedule_every_minute_initialise(
  $parent_run_id: option<string>
) {
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_system'];
  LET $run_id = rand::uuid();

  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], $log_extra_tags),
    'Start: initialisation helper schedule_every_minute', { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_cronjoborg_build_schedule_every_minute(
    $timezone: string
  ) {
    RETURN { timezone: $timezone, expiresAt: 0, hours: [-1], minutes: [-1], mdays: [-1], months: [-1], wdays: [-1] };
  }
  COMMENT 'Construit un schedule qui s\'exécute chaque minute.'
  PERMISSIONS FULL;

  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
    'Done: initialisation helper schedule_every_minute', { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Initialise le helper de schedule chaque minute.'
PERMISSIONS FULL;
