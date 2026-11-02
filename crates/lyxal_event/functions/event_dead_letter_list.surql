-- ============================================================================
-- Function   : fn::event_dead_letter_list
-- Module     : lyxal_event
-- Description: Liste les enregistrements de dead-letter ordonnés par date d'épuisement décroissante.
-- Contrat    : Retourne fn::result_ok(Vec<EventDeadLetter>)
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::event_dead_letter_list(
    $params: object
) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 1000 } }], default: 100 },
            delivery: { pipeline: [{ rule: "record_id", options: { allowed_tables: ["event_delivery"] } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("EVENT_INVALID_PARAMETERS", $params.language, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $limit = $p.limit;
    LET $delivery = $p.delivery;

    LET $items = IF $delivery != NONE {
        (SELECT * FROM event_dead_letter WHERE delivery = $delivery ORDER BY exhausted_at DESC LIMIT $limit)
    } ELSE {
        (SELECT * FROM event_dead_letter ORDER BY exhausted_at DESC LIMIT $limit)
    };

    RETURN fn::result_ok($items);
} COMMENT "Liste les enregistrements en quarantaine dead-letter"
PERMISSIONS FULL;

