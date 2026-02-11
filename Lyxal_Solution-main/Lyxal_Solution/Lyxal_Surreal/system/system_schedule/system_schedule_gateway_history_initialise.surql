-- =================================================================================================
-- | Fichier : system_schedule_gateway_history_initialise.surql
-- | Module  : system_schedule
-- | Desc.   : Gateway history cron-job.org (list/item)
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_gateway_history_initialise(
  $parent_run_id: option<string>
) {
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_system'];
  LET $run_id = rand::uuid();

  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], $log_extra_tags),
    'Start: initialisation gateway history', { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_cronjoborg_history_gateway(
    $action: string,
    $params: object
  ) {
    RETURN function() {
      const a = String($action || '').toLowerCase();
      function ok(data){ return { success: true, data }; }
      function ko(err){ return { success: false, error: err }; }

      try {
        if (a === 'list') {
          // params: job_id
          return fn::system_schedule_get_job_history_cronjoborg($params.job_id).then(ok).catch(ko);
        }
        if (a === 'item') {
          // params: job_id, history_id
          return fn::system_schedule_get_job_history_item_cronjoborg($params.job_id, $params.history_id).then(ok).catch(ko);
        }
        return ko({ message: 'unknown action', action: a });
      } catch (err) {
        return ko(err);
      }
    };
  }
  COMMENT 'Gateway unifiée des appels history cron-job.org.'
  PERMISSIONS FULL;

  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
    'Done: initialisation gateway history', { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Initialise la gateway history cronjob.org.'
PERMISSIONS FULL;
