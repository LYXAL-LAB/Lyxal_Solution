-- ============================================================================
-- Function   : fn::event_outbox_get
-- Module     : lyxal_event
-- Description: Récupère un enregistrement outbox par son identifiant.
-- Contrat    : Retourne fn::result_ok($event) ou fn::result_ok(NONE)
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::event_outbox_get(
    $params: object
) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            id: { pipeline: [{ rule: "record_id", options: { allowed_tables: ["event_outbox"] } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("EVENT_INVALID_PARAMETERS", $params.language, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $id = $p.id;

    LET $event = (SELECT * FROM ONLY $id);

    RETURN fn::result_ok($event);
} COMMENT "Récupère un événement outbox par son identifiant"
PERMISSIONS FULL;

