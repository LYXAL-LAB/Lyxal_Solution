-- =================================================================================================
-- |
-- | Fichier : system_schedule_get_job_details_cronjoborg_initialise.surql
-- | Module : system_schedule
-- | Description : Détail d'un job cron-job.org par son jobId (GET /jobs/<jobId>).
-- |
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_get_job_details_cronjoborg_initialise(
  $parent_run_id: option<string>
) {
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_system'];
  LET $run_id = rand::uuid();

  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], $log_extra_tags),
    'Start: initialisation de la fonction `fn::system_schedule_get_job_details_cronjoborg`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_get_job_details_cronjoborg(
    $job_id: int
  ) {
    RETURN function() {
      const api_url = `https://api.cron-job.org/jobs/${$job_id}`;
      return fetch(api_url, {
        method: "GET",
        headers: { "Authorization": `Bearer ${$cronjob_api_key}` }
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
  COMMENT 'Récupère le détail d\'un job cron-job.org (GET /jobs/<jobId>).'
  PERMISSIONS FULL;

  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
    'Done: initialisation de la fonction `fn::system_schedule_get_job_details_cronjoborg`',
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Initialise la fonction de lecture détaillée des jobs cron-job.org.'
PERMISSIONS FULL;
