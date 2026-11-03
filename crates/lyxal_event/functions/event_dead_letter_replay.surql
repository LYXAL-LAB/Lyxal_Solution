-- ============================================================================
-- Function: fn::event_dead_letter_replay
-- Description: Réinitialise une livraison dead-letter en statut actif pour rejeu contrôlé.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::event_dead_letter_replay(
    $params: object
) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            dead_letter_id: { pipeline: [{ rule: "record_id", options: { allowed_tables: ["event_dead_letter"] } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("EVENT_INVALID_PARAMETERS", $params.language, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $dead_letter_id = $p.dead_letter_id;

    LET $dl = (SELECT * FROM ONLY $dead_letter_id);

    IF $dl == NONE {
        RETURN fn::result_ok(false);
    };

    -- La séquence de la livraison doit être couverte par le curseur persisté : la livraison
    -- reçoit ensuite une nouvelle séquence en fin de flux, sans laisser de trou.
    LET $delivery = (SELECT delivery_seq, subscription FROM ONLY $dl.delivery);
    IF $delivery == NONE {
        RETURN fn::error_result("EVENT_DELIVERY_NOT_FOUND", $p.language, { delivery: <string> $dl.delivery });
    };
    LET $progress = (SELECT last_persisted_cursor FROM ONLY type::record(string::concat("event_subscription_progress:prog_", record::id($delivery.subscription))));
    LET $cursor = $progress.last_persisted_cursor ?? 0;
    IF $delivery.delivery_seq != NONE AND $delivery.delivery_seq > $cursor {
        RETURN fn::error_result("EVENT_DEAD_LETTER_REPLAY_NOT_SETTLED", $p.language, {
            delivery_seq: $delivery.delivery_seq,
            persisted_cursor: $cursor
        });
    };

    -- Marque la dead letter comme rejouée
    UPDATE $dl.id SET
        replayed = true,
        replayed_at = time::now();

    -- Réinitialise la livraison associée en statut 'pending'
    UPDATE $dl.delivery SET
        status = "pending",
        delivery_seq = NONE,
        attempts = 0,
        next_retry_at = time::now(),
        locked_until = NONE,
        lease_owner = NONE,
        last_error = NONE;

    RETURN fn::result_ok(true);
} COMMENT "Rejoue une dead letter : sa livraison repasse en pending et recevra une nouvelle séquence. Refusé tant que le curseur persisté ne couvre pas l'ancienne séquence."
PERMISSIONS FULL;
