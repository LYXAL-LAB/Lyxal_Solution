-- ============================================================================
-- Function   : fn::event_delivery_get
-- Module     : lyxal_event
-- Description: Récupère un enregistrement de livraison par son identifiant.
-- Contrat    : Retourne fn::result_ok($delivery) ou fn::result_ok(NONE)
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::event_delivery_get(
    $params: object
) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            id: { pipeline: [{ rule: "record_id", options: { allowed_tables: ["event_delivery"] } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("EVENT_INVALID_PARAMETERS", $params.language, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $id = $p.id;

    LET $delivery = (SELECT * FROM ONLY $id);

    RETURN fn::result_ok($delivery);
} COMMENT "Récupère un enregistrement de livraison par son identifiant"
PERMISSIONS FULL;

