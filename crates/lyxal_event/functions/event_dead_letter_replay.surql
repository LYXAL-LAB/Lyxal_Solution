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

    -- Marque la dead letter comme rejouée
    UPDATE $dl.id SET
        replayed = true,
        replayed_at = time::now();

    -- Réinitialise la livraison associée en statut 'pending'
    UPDATE $dl.delivery SET
        status = "pending",
        attempts = 0,
        next_retry_at = time::now(),
        locked_until = NONE,
        lease_owner = NONE,
        last_error = NONE;

    RETURN fn::result_ok(true);
} COMMENT "Rejoue une dead letter en réinitialisant sa livraison en statut pending"
PERMISSIONS FULL;
