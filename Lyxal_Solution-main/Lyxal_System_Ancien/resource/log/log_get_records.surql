-- =============================================================================================
-- |
-- | Fichier : log_get_records.surql
-- | Module : system / log
-- | Description : Récupère une liste de logs traduite et prête à l'emploi pour le frontend.
-- |
-- | Paramètres :
-- |   - $langue_id: string (ex: 'fr', 'en')
-- |   - $filters: option<object> (Clés supportées: 'operation.run_id', 'user_id', etc.)
-- |   - $order_dir: option<string> ('ASC' ou 'DESC', défaut 'DESC')
-- |   - $start: option<number> (défaut 0)
-- |   - $limit: option<number> (défaut 50)
-- |
-- | Retour :
-- |   - array<object> : Une liste d'enregistrements de log enrichis avec les textes traduits.
-- =============================================================================================
DEFINE FUNCTION fn::log_get_records(
    $langue_id: string,
    $filters: option<object>,
    $order_dir: option<string>,
    $start: option<number>,
    $limit: option<number>
) {
    -- Étape 1: Récupérer les logs bruts (logique de filtrage existante)
    LET $f = $filters OR {};
    LET $run_id_filter = $f['operation.run_id'] OR NONE;
    LET $user_id_filter = $f['content.user_id'] OR NONE;
    LET $reason_key_filter = $f['result.reason_key'] OR NONE;
    LET $resource_table_filter = $f['resource.table_id'] OR NONE;
    LET $resource_id_filter = $f['resource.id'] OR NONE;
    LET $start_date_filter = $f['timestamp.start'] OR NONE;
    LET $end_date_filter = $f['timestamp.end'] OR NONE;

    LET $direction = string::uppercase($order_dir OR 'DESC');
    LET $start_at = $start OR 0;
    LET $page_limit = $limit OR 50;

    LET $filtered_logs = (
        SELECT * FROM log
        WHERE
            ($run_id_filter IS NONE OR operation.run_id = $run_id_filter)
            AND
            ($user_id_filter IS NONE OR content.user_id = type::thing($user_id_filter))
            AND
            ($reason_key_filter IS NONE OR result.reason_key = type::thing($reason_key_filter))
            AND
            ($start_date_filter IS NONE OR timestamp.created_at >= type::datetime($start_date_filter))
            AND
            ($end_date_filter IS NONE OR timestamp.created_at <= type::datetime($end_date_filter))
    );

    -- Appliquer le tri et la pagination
    LET $raw_logs = IF $direction = 'ASC' THEN
        (SELECT * FROM $filtered_logs ORDER BY timestamp.created_at ASC START $start_at LIMIT $page_limit)
    ELSE
        (SELECT * FROM $filtered_logs ORDER BY timestamp.created_at DESC START $start_at LIMIT $page_limit)
    END;

    -- Étape 2: Enrichir chaque log avec les traductions (utilise array::map pour itérer)
    LET $enriched_logs = array::map($raw_logs, |$log| {
        -- Traduire le message principal (depuis error_code)
        LET $reason_key_rec = (SELECT VALUE message_key FROM $log.result.reason_key)[0];
        LET $translated_reason = IF $reason_key_rec IS NOT NONE {
            LET $reason_key_str = string::split(type::string($reason_key_rec), ':')[1];
            fn::i18n_translation_get($reason_key_str, $langue_id, {});
        } ELSE {
            { message: "" }
        };
        
        -- Traduire le message additionnel s'il existe
        LET $translated_message = IF $log.message.key_id IS NOT NONE {
            LET $msg_key_str = string::split(type::string($log.message.key_id), ':')[1];
            fn::i18n_translation_get($msg_key_str, $langue_id, $log.message.vars);
        } ELSE {
            { message: "" }
        };
        
        -- Fusionner le log original avec les traductions
        RETURN $log.extend({
            display: {
                reason_message: $translated_reason.message,
                message: $translated_message.message
            }
        });
    });
    
    -- Étape 3: Construire la réponse finale
    LET $reason_key_str = IF array::len($enriched_logs) > 0 {
        "log_get_records_success"
    } ELSE {
        "log_get_records_empty"
    };

    LET $response_translation = fn::i18n_translation_get($reason_key_str, $langue_id, {});

    RETURN {
        success: true,
        message: $response_translation.message,
        reason_code: $reason_key_str,
        data: $enriched_logs
    };
}
COMMENT 'Récupère, filtre et traduit les enregistrements de log pour affichage.';