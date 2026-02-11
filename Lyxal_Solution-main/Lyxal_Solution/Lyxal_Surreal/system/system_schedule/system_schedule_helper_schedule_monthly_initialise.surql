-- =================================================================================================
-- | Fichier : system_schedule_helper_schedule_monthly_initialise.surql
-- | Module  : system_schedule
-- | Desc.   : Helper - schedule mensuel (mdays, HH:MM)
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_helper_schedule_monthly_initialise(
  $parent_run_id: option<string>
) {
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_system'];
  LET $run_id = rand::uuid();

  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], $log_extra_tags),
    'Start: initialisation helper schedule_monthly', { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_cronjoborg_build_schedule_monthly(
    $mdays: array<int>,
    $hour: int,
    $minute: int,
    $timezone: string
  ) {
    RETURN { timezone: $timezone, expiresAt: 0, hours: [$hour], minutes: [$minute], mdays: $mdays, months: [-1], wdays: [-1] };
  }
  COMMENT 'Construit un schedule mensuel (mdays 1..31).'
  PERMISSIONS FULL;

  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
    'Done: initialisation helper schedule_monthly', { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Initialise le helper de schedule mensuel.'
PERMISSIONS FULL;
