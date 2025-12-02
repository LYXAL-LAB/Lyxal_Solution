-- =============================================================================================
-- |
-- | Fichier : log_get_record_by_id.surql
-- | Module : system / log
-- | Description : Récupère un seul log par son ID et retourne une réponse complète et traduite.
-- |
-- | Paramètres :
-- |   - $log_id: string (ex: 'log:xxxx')
-- |   - $langue_id: string (ex: 'fr')
-- |
-- | Retour :
-- |   - object : { success, message, reason_code, data }
-- =============================================================================================
DEFINE FUNCTION fn::log_get_record_by_id(
    $log_id: string,
    $langue_id: string
) {
    -- Étape 1: Récupérer le log brut
    LET $log = (SELECT * FROM type::thing($log_id))[0];

    IF $log IS NONE {
        LET $reason_key_str = "log_get_record_by_id_not_found";
        RETURN {
            success: false,
            reason_code: $reason_key_str,
            data: NONE
        };
    };

    -- Étape 2: Enrichir le log avec les traductions
    LET $reason_key_rec = (SELECT VALUE message_key FROM $log.result.reason_key)[0];
    LET $translated_reason = { message: "" };
    IF $reason_key_rec IS NOT NONE {
        LET $reason_key_str = string::split(type::string($reason_key_rec), ':')[1];
        $translated_reason = fn::i18n_translation_get($reason_key_str, $langue_id, {});
    };
    
    LET $translated_message = { message: "" };
    IF $log.message.key_id IS NOT NONE {
        LET $msg_key_str = string::split(type::string($log.message.key_id), ':')[1];
        $translated_message = fn::i18n_translation_get($msg_key_str, $langue_id, $log.message.vars);
    };
    
    LET $enriched_log = $log.extend({
        display: {
            reason_message: $translated_reason.message,
            message: $translated_message.message
        }
    });

    -- Étape 3: Construire la réponse de succès
    LET $reason_key_str = "log_get_record_by_id_success";
    LET $response_translation = fn::i18n_translation_get($reason_key_str, $langue_id, {});
    
    RETURN {
        success: true,
        message: $response_translation.message,
        reason_code: $reason_key_str,
        data: $enriched_log
    };
}
COMMENT 'Récupère et traduit un seul log par son ID, en retournant une réponse complète.';
