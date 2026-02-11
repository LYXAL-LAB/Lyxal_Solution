-- =================================================================================================
-- |
-- | Fichier : system_schedule_update_job_cronjoborg_initialise.surql
-- | Module : system_schedule
-- | Description : Met à jour un job cron-job.org (PATCH /jobs/<jobId>).
-- |
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_update_job_cronjoborg_initialise(
  $parent_run_id: option<string>
) {
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_system'];
  LET $run_id = rand::uuid();

  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], $log_extra_tags),
    'Start: initialisation de la fonction `fn::system_schedule_update_job_cronjoborg`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_update_job_cronjoborg(
    $job_id: int,
    $job_delta: object
  ) {
    RETURN function() {
      const api_url = `https://api.cron-job.org/jobs/${$job_id}`;
      const payload = { job: $job_delta };
      return fetch(api_url, {
        method: "PATCH",
        headers: {
          "Authorization": `Bearer ${$cronjob_api_key}`,
          "Content-Type": "application/json"
        },
        body: JSON.stringify(payload)
      })
      .then(res => {
        if (!res.ok) {
          return res.json().then(err => Promise.reject({ status: res.status, statusText: res.statusText, body: err }));
        }
        return res.json();
      })
      .catch(err => ({ error: err }));
    };
  }
  COMMENT 'Met à jour un job cron-job.org (PATCH /jobs/<jobId>).'
  PERMISSIONS FULL;

  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
    'Done: initialisation de la fonction `fn::system_schedule_update_job_cronjoborg`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Initialise la fonction de mise à jour d\'un job cron-job.org.'
PERMISSIONS FULL;
