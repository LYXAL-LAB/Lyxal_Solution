-- =================================================================================================
-- |
-- | Fichier : system_schedule_get_all_jobs_cronjoborg_initialise.surql
-- | Module : system_schedule
-- | Description : Définit la fonction pour lister tous les jobs cron-job.org.
-- |
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_get_all_jobs_cronjoborg_initialise(
  $parent_run_id: option<string>
) {
  -- Paramètres
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_system'];
  LET $run_id = rand::uuid();

  -- Journalisation: début
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], $log_extra_tags),
    'Start: initialisation de la fonction `fn::system_schedule_get_all_jobs_cronjoborg`', 
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  -- Définition de la fonction
  DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_get_all_jobs_cronjoborg() {
    RETURN function() {
      const api_url = `https://api.cron-job.org/jobs`;
      
      // fetch() avec then() / catch()
      return fetch(api_url, {
        method: "GET",
        headers: {
          "Authorization": `Bearer ${$cronjob_api_key}`
        }
      })
      .then(res => {
        if (!res.ok) {
          return res.json().then(err => Promise.reject({ status: res.status, statusText: res.statusText, body: err }));
        }
        return res.json();
      })
      .then(json => {
        // Retourne tous les jobs sans filtrage
        return json;
      })
      .catch(err => { 
        return { error: err }; 
      });
    };
  }
  COMMENT 'Liste tous les jobs existants dans le compte cron-job.org.'
  PERMISSIONS FULL;

  -- Journalisation: fin
  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
    'Done: initialisation de la fonction `fn::system_schedule_get_all_jobs_cronjoborg`', 
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN {
    success: true,
    run_id: $run_id
  };
}
COMMENT 'Initialise la fonction pour lister tous les jobs cron-job.org.'
PERMISSIONS FULL;
