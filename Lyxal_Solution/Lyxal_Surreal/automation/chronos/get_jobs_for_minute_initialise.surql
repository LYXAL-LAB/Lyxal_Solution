-- =================================================================================================
-- DEBUT DE L'INITIALISATION DE LA FONCTION `fn::scheduler::chronos::get_jobs_for_minute`
-- =================================================================================================

DEFINE FUNCTION fn::scheduler_chronos_get_jobs_for_minute_initialise() {
    -- Création de la fonction
    fn::system_log_create_record_system(['scheduler_chronos_get_jobs_for_minute_initialise', 'start'], 'Initialisation de la fonction `fn::scheduler::chronos::get_jobs_for_minute`.');

    DEFINE FUNCTION fn::scheduler::chronos::get_jobs_for_minute() {
        // Cette fonction est le "cerveau" du scheduler. Elle est appelée chaque minute
        // pour sélectionner tous les jobs qui doivent être exécutés.
        // Elle s'inspire de la requête complexe dans `App::processJobsForTimeZone`.

        LET $now = time::now();
        // On se base sur le début de la minute actuelle pour être précis.
        LET $current_minute = time::floor($now, 1m);

        // On doit tester la planification pour chaque fuseau horaire distinct présent dans les jobs.
        LET $timezones = (SELECT VALUE DISTINCT(timezone) FROM scheduler_job WHERE enabled = true);
        LET $all_jobs_to_run = [];

        FOR $tz IN $timezones {
            // Convertir la minute actuelle dans le fuseau horaire du job
            LET $local_time = time::timezone($current_minute, $tz);
            
            LET $y = time::year($local_time);
            LET $m = time::month($local_time);
            LET $d = time::day($local_time);
            LET $h = time::hour($local_time);
            LET $i = time::minute($local_time);
            LET $w = time::wday($local_time); // 0=Dim, 1=Lun, ...

            // 1. Sélectionner les jobs qui sont "pending" (planifiés) ou "retrying" (en attente de nouvelle tentative)
            LET $jobs_to_process_for_tz = (
                SELECT * FROM scheduler_job 
                WHERE 
                    enabled = true
                    AND timezone = $tz
                    AND (
                        // Condition 1: Job planifié normalement et en attente
                        (
                            (->scheduler_job_tag->system_tag.name CONTAINS "scheduler_job_status_pending")
                            AND (-1 IN (SELECT VALUE value FROM scheduler_job_months WHERE jobid = id) OR $m IN (SELECT VALUE value FROM scheduler_job_months WHERE jobid = id))
                            AND (-1 IN (SELECT VALUE value FROM scheduler_job_mdays WHERE jobid = id) OR $d IN (SELECT VALUE value FROM scheduler_job_mdays WHERE jobid = id))
                            AND (-1 IN (SELECT VALUE value FROM scheduler_job_wdays WHERE jobid = id) OR $w IN (SELECT VALUE value FROM scheduler_job_wdays WHERE jobid = id))
                            AND (-1 IN (SELECT VALUE value FROM scheduler_job_hours WHERE jobid = id) OR $h IN (SELECT VALUE value FROM scheduler_job_hours WHERE jobid = id))
                            AND (-1 IN (SELECT VALUE value FROM scheduler_job_minutes WHERE jobid = id) OR $i IN (SELECT VALUE value FROM scheduler_job_minutes WHERE jobid = id))
                        )
                        OR 
                        // Condition 2: Job en attente de retry et dont l'heure est dépassée
                        (
                            (->scheduler_job_tag->system_tag.name CONTAINS "scheduler_job_status_retrying")
                            AND next_retry_at <= $now
                        )
                    )
                    // Vérification de l'expiration globale
                    AND (expires_at IS NONE OR expires_at > $now)
            );
            
            // 2. Pour chaque job trouvé, changer atomiquement son état vers "processing"
            FOR $job IN $jobs_to_process_for_tz {
                // Déterminer le tag source à supprimer
                LET $source_tag_name = IF (SELECT VALUE ->scheduler_job_tag->system_tag.name FROM ONLY $job.id) CONTAINS "scheduler_job_status_pending" 
                                        THEN "scheduler_job_status_pending" 
                                        ELSE "scheduler_job_status_retrying" END;
                LET $tag_source = type::thing("system_tag", $source_tag_name);
                LET $tag_processing = system_tag:scheduler_job_status_processing;

                // Cette transaction garantit que la suppression et l'ajout sont atomiques.
                BEGIN TRANSACTION;
                    PERFORM fn::scheduler::job::relation::remove(
                        $job.id,
                        $tag_source
                    );
                    PERFORM fn::scheduler::job::relation::add(
                        $job.id,
                        $tag_processing
                    );
                COMMIT TRANSACTION;
            }

            // 3. Ajouter les jobs maintenant verrouillés à la liste globale
            $all_jobs_to_run = array::union($all_jobs_to_run, $jobs_to_process_for_tz);
        }

        RETURN $all_jobs_to_run;
    };
    
    fn::system_log_create_record_system(['scheduler_chronos_get_jobs_for_minute_initialise', 'success'], 'Fonction `fn::scheduler::chronos::get_jobs_for_minute` initialisée avec succès.');

    RETURN true;
};
