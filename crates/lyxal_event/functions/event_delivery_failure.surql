-- ============================================================================
-- Function: fn::event_delivery_failure
-- Description: Enregistre un échec de traitement, recalcule le retry ou bascule en Dead-Letter.
-- Invariant: 1 tentative réelle = 1 incrément (incrémenté au claim/assign_seq, non répété ici).
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

    -- Vérifie si le quota maximal de tentatives est atteint
    IF $delivery.attempts >= $delivery.max_attempts {
        LET $outbox = (SELECT * FROM ONLY $delivery.outbox_event);

        -- Enregistrement dans la table Dead-Letter pour audit et rejeu
        CREATE event_dead_letter CONTENT {
            delivery: $delivery.id,
            outbox_event: $delivery.outbox_event,
            target_module: $delivery.target_module,
            context: $delivery.context,
            attempts: $delivery.attempts,
            last_error: $error,
            payload: IF $outbox != NONE THEN $outbox.payload ELSE {} END,
            metadata: IF $outbox != NONE THEN $outbox.metadata ELSE {} END,
            replayed: false,
            exhausted_at: time::now()
        };

        -- Marque la livraison comme dead_letter sans ré-incrémenter attempts
        UPDATE $delivery.id SET
            status = "dead_letter",
            last_error = $error,
            locked_until = NONE,
            lease_owner = NONE;
    } ELSE {
        -- Calcul du prochain instant de tentative
        LET $next_retry = time::now() + <duration> string::concat($retry_delay_seconds, "s");

        UPDATE $delivery.id SET
            status = "failed",
            last_error = $error,
            next_retry_at = $next_retry,
            locked_until = NONE,
            lease_owner = NONE;
    };

    RETURN fn::result_ok(true);
} COMMENT "Enregistre l'échec d'une livraison, replanifie avec backoff ou met en quarantaine (DLQ)"
PERMISSIONS FULL;
