-- ================================================================================================
-- | Fichier : system_schedule_sync_all_cronjoborg_initialise.surql
-- | Module  : system_schedule
-- | Desc.   : Synchronisation complète depuis cron-job.org vers la table system_schedule
-- ================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_sync_all_cronjoborg_initialise(
  $parent_run_id: option<string>
) {
  LET $parent_run_id = $parent_run_id OR NONE;
  LET $log_extra_tags = ['module_system'];
  LET $run_id = rand::uuid();

  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], $log_extra_tags),
    'Start: initialisation fn::system_schedule_sync_all_cronjoborg', 
    { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_sync_all_cronjoborg() {
    -- 1. Récupérer tous les jobs distants et locaux
    LET $remote_jobs_response = fn::system_schedule_get_all_jobs_cronjoborg();
    IF $remote_jobs_response.error {
      THROW $remote_jobs_response.error;
    };
    LET $remote_jobs = $remote_jobs_response.jobs;
    LET $local_jobs = SELECT * FROM system_schedule;

    -- 2. Préparer les listes d'IDs pour la comparaison
    LET $remote_job_ids = $remote_jobs.*.jobId;
    LET $local_job_ids = $local_jobs.*.job_id;

    -- 3. Identifier les jobs à supprimer localement
    LET $jobs_to_delete = SELECT * FROM $local_jobs WHERE job_id NOT IN $remote_job_ids;
    IF count($jobs_to_delete) > 0 {
      -- Important: On supprime l'enregistrement local et la relation, mais on ne peut pas appeler l'API
      -- car le job n'existe déjà plus sur le serveur distant.
      DELETE $jobs_to_delete;
    };

    -- 4. Identifier les jobs à mettre à jour
    LET $updated_jobs_count = 0;
    FOR $local_job IN $local_jobs {
      LET $remote_match = (SELECT * FROM $remote_jobs WHERE jobId = $local_job.job_id)[0];
      IF $remote_match {
        -- Mettre à jour si le titre ou le statut enabled a changé
        IF $local_job.title != $remote_match.title OR $local_job.enabled != $remote_match.enabled {
          UPDATE $local_job.id SET title = $remote_match.title, enabled = $remote_match.enabled;
          LET $updated_jobs_count = $updated_jobs_count + 1;
        }
      }
    };

    -- 5. Identifier les jobs distants qui n'existent pas localement (pour le rapport)
    LET $untracked_remote_jobs = (SELECT * FROM $remote_jobs WHERE jobId NOT IN $local_job_ids);

    -- 6. Journalisation et retour
    LET $report = {
        deleted_local_jobs: $jobs_to_delete.*.id,
        updated_local_jobs_count: $updated_jobs_count,
        untracked_remote_jobs_count: count($untracked_remote_jobs),
        untracked_remote_job_ids: $untracked_remote_jobs.*.jobId
    };
    
    fn::system_log_create_record_system(
        ['log_function', 'log_sync', 'log_done', 'log_success'],
        "Synchronisation des jobs terminée.",
        $report
    );

    RETURN {
        success: true,
        report: $report
    };
  }
  COMMENT 'Synchronise la table locale avec tous les jobs de cron-job.org.'
  PERMISSIONS FULL;

  fn::system_log_create_record_system(
    array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
    'Done: initialisation fn::system_schedule_sync_all_cronjoborg', { run_id: $run_id, parent_run_id: $parent_run_id }
  );

  RETURN { success: true, run_id: $run_id };
}
COMMENT 'Initialise la synchronisation globale des jobs cron-job.org.'
PERMISSIONS FULL;
