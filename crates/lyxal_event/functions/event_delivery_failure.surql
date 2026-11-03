-- ============================================================================
-- Function: fn::event_delivery_failure
-- Description: Enregistre l'échec transitoire d'une livraison et la date de son prochain essai.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::event_delivery_failure(
    $params: object
) {
    -- Fonction interne du moteur d'événements (appelée par le code Rust avec des types
    -- vérifiés, à chaque livraison) : validation par les primitives de lyxal_core plutôt que
    -- par fn::validation_object_execute, dont le coût par appel pèserait sur le débit
    -- (décision CTO, reprise lyxal_event).
    LET $checks = {
        delivery_id: fn::validation_record_id($params.delivery_id, ["event_delivery"]),
        error: fn::validation_required_string($params.error, 1, 4000),
        retry_delay_seconds: fn::validation_integer(($params.retry_delay_seconds ?? 5), 0, 86400),
        language: fn::validation_language_code($params.language ?? "fr", false, NONE)
    };
    LET $invalid = object::from_entries(array::map(array::filter(object::entries($checks), |$e| !$e[1].valid), |$e| [$e[0], [$e[1].code]]));
    IF object::len($invalid) > 0 {
        RETURN fn::error_result("EVENT_INVALID_PARAMETERS", $params.language, { fields: $invalid });
    };
    LET $p = object::from_entries(array::map(object::entries($checks), |$e| [$e[0], $e[1].value]));
    LET $delivery_id = $p.delivery_id;
    LET $error = $p.error;
    LET $retry_delay_seconds = $p.retry_delay_seconds;

    LET $delivery = (SELECT * FROM ONLY $delivery_id);

    IF $delivery == NONE {
        RETURN fn::error_result("EVENT_DELIVERY_NOT_FOUND", $p.language, { delivery_id: $delivery_id });
    };

    -- Enregistre l'échec et la date du prochain essai. Le leader garde le message en mémoire et
    -- son verrou : la décision de dead letter appartient au moteur (barrière DLQ protégée par le
    -- bail, fn::event_dead_letter_transfer), jamais à cette fonction.
    UPDATE $delivery.id SET
        status = "failed",
        last_error = $error,
        next_retry_at = time::now() + <duration> string::concat($retry_delay_seconds, "s");

    RETURN fn::result_ok(true);
} COMMENT "Enregistre l'échec transitoire d'une livraison et la date de son prochain essai ; la mise en dead letter relève de la barrière DLQ du moteur"
PERMISSIONS FULL;
