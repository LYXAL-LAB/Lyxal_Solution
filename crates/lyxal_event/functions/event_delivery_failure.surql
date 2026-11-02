-- ============================================================================
-- Function: fn::event_delivery_failure
-- Description: Enregistre un échec de traitement, recalcule le retry ou bascule en Dead-Letter.
-- Invariant: 1 tentative réelle = 1 incrément (incrémenté au claim/assign_seq, non répété ici).
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::event_delivery_failure(
    $params: object
) {
    IF $params.delivery_id == NONE OR $params.delivery_id == NULL {
        RETURN fn::result_ok(false);
    };

    IF $params.error == NONE OR $params.error == NULL {
        RETURN fn::result_ok(false);
    };

    LET $delivery_id = <record> $params.delivery_id;
    LET $error = $params.error;
    LET $retry_delay_seconds = IF $params.retry_delay_seconds != NONE AND $params.retry_delay_seconds != NULL { $params.retry_delay_seconds } ELSE { 5 };

    LET $delivery = (SELECT * FROM ONLY $delivery_id);

    IF $delivery == NONE {
        RETURN fn::result_ok(false);
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
