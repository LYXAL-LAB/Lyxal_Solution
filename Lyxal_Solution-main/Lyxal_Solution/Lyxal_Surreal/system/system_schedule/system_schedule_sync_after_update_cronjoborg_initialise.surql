-- =================================================================================================
-- | Fichier : system_schedule_sync_after_update_cronjoborg_initialise.surql
-- | Module  : system_schedule
-- | Desc.   : Wrapper update + synchronisation locale `system_schedule`
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_sync_after_update_cronjoborg_initialise(
  $parent_run_id: option<string>
) {
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_system'];
  LET $run_id = rand::uuid();

  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], $log_extra_tags),
    'Start: initialisation sync_after_update', { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_sync_after_update_cronjoborg(
    $job_id: int,
    $job_delta: object
  ) {
    LET $api_result = fn::system_schedule_update_job_cronjoborg($job_id, $job_delta);

    -- synchronisation locale (seulement les champs pertinents si présents)
    IF $job_delta.enabled != NONE THEN {
      UPDATE system_schedule SET enabled = $job_delta.enabled WHERE cron_job_id = $job_id;
    } END;
    IF $job_delta.saveResponses != NONE THEN {
      UPDATE system_schedule SET save_responses = $job_delta.saveResponses WHERE cron_job_id = $job_id;
    } END;
    IF $job_delta.requestMethod != NONE THEN {
      UPDATE system_schedule SET request_method = $job_delta.requestMethod WHERE cron_job_id = $job_id;
    } END;
    IF $job_delta.schedule != NONE THEN {
      UPDATE system_schedule SET schedule = $job_delta.schedule WHERE cron_job_id = $job_id;
    } END;
    IF $job_delta.title != NONE THEN {
      UPDATE system_schedule SET title = $job_delta.title WHERE cron_job_id = $job_id;
    } END;

    UPDATE system_schedule SET last_sync = time::now(), status = 'updated' WHERE cron_job_id = $job_id;

    -- Auto-tag idempotent (gateway)
    LET $schedule_row = SELECT id FROM system_schedule WHERE cron_job_id = $job_id LIMIT 1;
    IF array::len($schedule_row) > 0 THEN {
      LET $schedule_id = $schedule_row[0].id;
      LET $tag_module = type::thing('system_tag', 'system_schedule');
      LET $tag_gateway = type::thing('system_tag', 'system_schedule_gateway');
      fn::system_schedule_tag_add($schedule_id, $tag_module);
      fn::system_schedule_tag_add($schedule_id, $tag_gateway);
    } END;

    RETURN { success: true, job_id: $job_id, api_result: $api_result };
  }
  COMMENT 'Met à jour le job via l\'API et synchronise la table locale.'
  PERMISSIONS FULL;

  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
    'Done: initialisation sync_after_update', { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Initialise le wrapper de synchronisation après update.'
PERMISSIONS FULL;
