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
    LET $user_id_filter = $f['user_id'] OR NONE;
    LET $reason_key_filter = $f['result.reason_key'] OR NONE;
    LET $resource_table_filter = $f['resource.table_id'] OR NONE;
    LET $resource_id_filter = $f['resource.id'] OR NONE;
    LET $start_date_filter = $f['log_date.start'] OR NONE;
    LET $end_date_filter = $f['log_date.end'] OR NONE;

    LET $direction = string::uppercase($order_dir OR 'DESC');
    LET $start_at = $start OR 0;
    LET $page_limit = $limit OR 50;

    LET $filtered_logs = (
        SELECT * FROM log
        WHERE
            ($run_id_filter IS NONE OR operation.run_id = $run_id_filter)
            AND
            ($user_id_filter IS NONE OR user_id = type::thing($user_id_filter))
            AND
            ($reason_key_filter IS NONE OR result.reason_key = type::thing($reason_key_filter))
            AND
            ($start_date_filter IS NONE OR log_date.timestamp >= type::datetime($start_date_filter))
            AND
            ($end_date_filter IS NONE OR log_date.timestamp <= type::datetime($end_date_filter))
    );

    -- Appliquer le tri et la pagination
    LET $raw_logs = IF $direction = 'ASC' THEN
        (SELECT * FROM $filtered_logs ORDER BY log_date.timestamp ASC START $start_at LIMIT $page_limit)
    ELSE
        (SELECT * FROM $filtered_logs ORDER BY log_date.timestamp DESC START $start_at LIMIT $page_limit)
    END;

    -- Étape 2: Enrichir chaque log avec les traductions
    LET $enriched_logs = [];
    FOR ($log IN $raw_logs) {
        -- Traduire le message principal (depuis error_code)
        LET $reason_key_rec = (SELECT VALUE message_key FROM $log.result.reason_key)[0];
        LET $translated_reason = { message: "" };
        IF $reason_key_rec IS NOT NONE {
            LET $reason_key_str = string::split(type::string($reason_key_rec), ':')[1];
            $translated_reason = fn::i18n_translation_get($reason_key_str, $langue_id, {});
        };
        
        -- Traduire le message additionnel s'il existe
        LET $translated_message = { message: "" };
        IF $log.message.key IS NOT NONE {
            LET $msg_key_str = string::split(type::string($log.message.key), ':')[1];
            $translated_message = fn::i18n_translation_get($msg_key_str, $langue_id, $log.message.vars);
        };
        
        -- Fusionner le log original avec les traductions et l'ajouter au tableau
        LET $enriched_log = $log.extend({
            display: {
                reason_message: $translated_reason.message,
                message: $translated_message.message
            }
        });
        LET $enriched_logs = $enriched_logs + [$enriched_log];
    };
    
    -- Étape 3: Construire la réponse finale
    LET $reason_key_str = IF array::len($enriched_logs) > 0 {
        "log.get.list.success"
    } ELSE {
        "log.get.list.empty"
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