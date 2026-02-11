-- =================================================================================================
-- DEBUT DE L'INITIALISATION DE LA FONCTION `fn::scheduler::chronos::create_notification`
-- =================================================================================================

DEFINE FUNCTION fn::scheduler_chronos_create_notification_initialise() {
    -- Création de la fonction
    fn::system_log_create_record_system(['scheduler_chronos_create_notification_initialise', 'start'], 'Initialisation de la fonction `fn::scheduler::chronos::create_notification`.');

    DEFINE FUNCTION fn::scheduler::chronos::create_notification(
        $job_id: record<scheduler_job>,
        $history_id: record<scheduler_history>,
        $type: string // "onFailure", "onSuccess", ou "onDisable"
    ) {
        // Cette fonction est l'équivalent d'une partie du `NotificationThread` de chronos.
        // Elle crée un enregistrement de notification qui sera ensuite traité
        // par un système externe pour l'envoi réel (ex: email).

        LET $job = (SELECT * FROM ONLY $job_id);

        CREATE scheduler_notification SET
            jobid = $job_id,
            userid = $job.userid,
            joblogid = $history_id,
            date = time::now(),
            type = $type,
            date_started = $history_id.date,
            date_planned = $history_id.date_planned,
            url = $job.url OR $job.function_name, // On utilise l'URL ou le nom de la fonction
            execution_status_text = $history_id.status_text,
            http_status = $history_id.http_status;

        RETURN true;
    };
    
    fn::system_log_create_record_system(['scheduler_chronos_create_notification_initialise', 'success'], 'Fonction `fn::scheduler::chronos::create_notification` initialisée avec succès.');

    RETURN true;
};
