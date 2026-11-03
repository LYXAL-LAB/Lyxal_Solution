-- ============================================================================
-- Function: fn::event_purge_garbage
-- Description: Nettoie les événements et livraisons terminés ayant dépassé le délai de rétention.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::event_purge_garbage(
    $params: object
) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            retention_days: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 3650 } }], default: 7 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("EVENT_INVALID_PARAMETERS", $params.language, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $retention_days = $p.retention_days;

    LET $cutoff = time::now() - <duration> string::concat($retention_days, "d");

    -- Suppression des livraisons complétées anciennes
    DELETE event_delivery 
    WHERE status = "delivered" 
      AND delivered_at != NONE 
      AND delivered_at < $cutoff;

    -- Suppression des événements outbox déjà ventilés et anciens, sauf ceux dont une livraison
    -- n'est pas livrée (en attente, en retry ou en dead letter rejouable) : la livraison
    -- deviendrait incomplète
    LET $referenced = array::distinct(
        SELECT VALUE outbox_event FROM event_delivery WHERE status != "delivered"
    );
    DELETE event_outbox
    WHERE status = "fanned_out"
      AND fanned_out_at != NONE
      AND fanned_out_at < $cutoff
      AND id NOT IN $referenced;

    RETURN fn::result_ok(true);
} COMMENT "Purge les événements et livraisons archivés selon la politique de rétention"
PERMISSIONS FULL;
