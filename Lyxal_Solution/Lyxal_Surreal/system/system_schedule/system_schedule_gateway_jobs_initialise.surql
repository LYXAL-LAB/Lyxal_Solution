-- =================================================================================================
-- | Fichier : system_schedule_gateway_jobs_initialise.surql
-- | Module  : system_schedule
-- | Desc.   : Gateway jobs cron-job.org (create/list/details/update/delete)
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_gateway_jobs_initialise(
  $parent_run_id: option<string>
) {
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_system'];
  LET $run_id = rand::uuid();

  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], $log_extra_tags),
    'Start: initialisation gateway jobs', { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_cronjoborg_jobs_gateway(
    $action: string,
    $params: object
  ) {
    RETURN function() {
      const a = String($action || '').toLowerCase();
      function ok(data){ return { success: true, data }; }
      function ko(err){ return { success: false, error: err }; }

      try {
        if (a === 'create') {
          // params attendus: namespace, database, job_type, title, body_query, request_method, schedule, enabled, save_responses, notification?, auth?, request_timeout?, redirect_success?
          return fn::system_schedule_register_job_cronjoborg(
            $params.namespace,
            $params.database,
            $params.job_type,
            $params.title,
            $params.body_query,
            $params.request_method,
            $params.schedule,
            $params.enabled,
            $params.save_responses,
            $params.notification,
            $params.auth,
            $params.request_timeout,
            $params.redirect_success
          ).then(ok).catch(ko);
        }
        if (a === 'list') {
          return fn::system_schedule_get_all_jobs_cronjoborg().then(ok).catch(ko);
        }
        if (a === 'sync_all') {
          return fn::system_schedule_sync_all_cronjoborg().then(ok).catch(ko);
        }
        if (a === 'details') {
          // params: job_id
          return fn::system_schedule_get_job_details_cronjoborg($params.job_id).then(ok).catch(ko);
        }
        if (a === 'update') {
          // params: job_id, job_delta
          return fn::system_schedule_sync_after_update_cronjoborg($params.job_id, $params.job_delta).then(ok).catch(ko);
        }
        if (a === 'delete') {
          // params: job_id
          return fn::system_schedule_delete_job_cronjoborg($params.job_id).then(function (res){
            // purge locale si succès
            if (res && !res.error) {
              DELETE system_schedule WHERE cron_job_id = $params.job_id;
            }
            return ok(res);
          }).catch(ko);
        }
        return ko({ message: 'unknown action', action: a });
      } catch (err) {
        return ko(err);
      }
    };
  }
  COMMENT 'Gateway unifiée des appels jobs cron-job.org.'
  PERMISSIONS FULL;

  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
    'Done: initialisation gateway jobs', { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Initialise la gateway jobs cronjob.org.'
PERMISSIONS FULL;
