-- =================================================================================================
-- DEBUT DE L'INITIALISATION DE LA FONCTION `fn::scheduler::chronos::process_job_result`
-- =================================================================================================

DEFINE FUNCTION fn::scheduler_chronos_process_job_result_initialise() {
    -- Création de la fonction
    fn::system_log_create_record_system(['scheduler_chronos_process_job_result_initialise', 'start'], 'Initialisation de la fonction `fn::scheduler::chronos::process_job_result`.');

    DEFINE FUNCTION fn::scheduler::chronos::process_job_result(
        $result: object // Attributs attendus : job_id, execution_status, return_value, start_time, end_time, duration_ms
    ) {
        // Cette fonction est l'équivalent du `UpdateThread` de chronos.
        // Elle prend le résultat brut de l'exécution d'un job et met à jour
        // toutes les tables nécessaires de manière atomique.
        
        BEGIN TRANSACTION;

        LET $job = (SELECT * FROM ONLY $result.job_id);
        LET $user_id = $job.userid;
        LET $node_id = $job.nodeid;

        // --- 1. Mettre à jour la table `scheduler_history` ---
        // On crée l'enregistrement et on capture son contenu pour l'utiliser plus tard.
        LET $history_record = (CREATE scheduler_history SET
            jobid = $result.job_id,
            userid = $user_id,
            date = $result.end_time,
            date_planned = $result.start_time,
            duration = $result.duration_ms * 1ms,
            status_text = IF $result.execution_status == 'success' THEN 'OK' ELSE type::string($result.return_value) END,
            http_status = IF $result.execution_status == 'success' THEN 200 ELSE 500 END,
            body = IF $result.execution_status == 'success' THEN type::string($result.return_value) ELSE NONE END
        )[0];


        // --- 2. Mettre à jour l'enregistrement `scheduler_job` ---
        
        // Initialiser les variables pour la logique de retry
        LET $new_retry_count = 0;
        LET $next_retry_at = NONE;
        LET $final_tag_after_processing = system_tag:scheduler_job_status_pending; // Par défaut, on repasse en 'pending'

        IF $result.execution_status == 'failure' {
            // Le job a échoué, on incrémente le compteur de tentatives
            $new_retry_count = $job.retry_count + 1;
            
            IF $new_retry_count < $job.max_retries {
                // Le nombre max de tentatives n'est pas atteint, on planifie un retry
                // Le délai augmente avec le nombre de tentatives (backoff linéaire simple)
                $next_retry_at = time::now() + ($job.retry_delay_seconds * $new_retry_count * 1s);
                $final_tag_after_processing = system_tag:scheduler_job_status_retrying;
            } ELSE {
                // Le nombre max de tentatives est atteint, le job est marqué comme échoué
                $final_tag_after_processing = system_tag:scheduler_job_status_failed;
            }
        }

        LET $job_update_data = {
            last_status: $history_record.http_status,
            last_duration: $result.duration_ms,
            last_fetch: $result.end_time,
            fail_counter: IF $result.execution_status == 'failure' THEN $job.fail_counter + 1 ELSE 0 END,
            retry_count: $new_retry_count,
            next_retry_at: $next_retry_at
        };
        
        // --- Logique de désactivation automatique ---
        LET $usergroup = (SELECT max_failures FROM ONLY $job.usergroupid);
        IF $usergroup.max_failures > 0 AND $fail_counter >= $usergroup.max_failures {
            $job_update_data.enabled = false;
            // Si le job est désactivé et que les notifications pour cela sont activées, on en crée une.
            IF $job.notification_on_disable {
                fn::scheduler::chronos::create_notification($result.job_id, $history_record.id, 'onDisable');
            }
        }

        UPDATE $result.job_id MERGE $job_update_data;

        // --- 3. Libérer le verrou et positionner le tag final ---
        LET $tag_processing = system_tag:scheduler_job_status_processing;

        PERFORM fn::scheduler::job::relation::remove(
            $result.job_id,
            $tag_processing
        );
        PERFORM fn::scheduler::job::relation::add(
            $result.job_id,
            $final_tag_after_processing
        );

        // --- 4. Mettre à jour la table `scheduler_nodestats` ---
        // Crée ou met à jour l'entrée pour le noeud, l'année, le mois, le jour, l'heure et la minute actuels.
        LET $now = time::now();
        LET $y = time::year($now);
        LET $m = time::month($now);
        LET $d = time::day($now);
        LET $h = time::hour($now);
        LET $i = time::minute($now);
        
        LET $stat = UPDATE scheduler_nodestats SET jobs += 1 WHERE nodeid = $node_id AND y = $y AND m = $m AND d = $d AND h = $h AND i = $i;
        IF count($stat) == 0 {
            CREATE scheduler_nodestats SET
                nodeid = $node_id,
                y = $y, m = $m, d = $d, h = $h, i = $i,
                jobs = 1;
        };

        COMMIT TRANSACTION;

        RETURN $history_record.id;
    };
    
    fn::system_log_create_record_system(['scheduler_chronos_process_job_result_initialise', 'success'], 'Fonction `fn::scheduler::chronos::process_job_result` initialisée avec succès.');

    RETURN true;
};
