-- ============================================================================
-- Function: fn::event_purge_garbage
-- Description: Nettoie les livraisons livrées couvertes par le curseur durable de leur abonnement
--              et les événements ventilés non référencés, au-delà du délai de rétention.
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

    -- Suppression des livraisons livrées anciennes, seulement si le curseur durable de leur
    -- abonnement les couvre : fn::event_flush_batch exige chaque séquence au-delà du curseur
    -- (invariant de contiguïté), une livraison livrée après une séquence encore en attente doit
    -- donc rester jusqu'à l'avancée du curseur.
    FOR $progress IN (SELECT subscription, last_persisted_cursor FROM event_subscription_progress) {
        DELETE event_delivery
        WHERE subscription = $progress.subscription
          AND status = "delivered"
          AND delivered_at != NONE
          AND delivered_at < $cutoff
          AND delivery_seq != NONE
          AND delivery_seq <= $progress.last_persisted_cursor;
    };

    -- Suppression des événements outbox déjà ventilés et anciens qu'aucune livraison restante ne
    -- référence (en attente, en retry, en dead letter rejouable, ou livrée au-delà du curseur)
    LET $referenced = array::distinct(SELECT VALUE outbox_event FROM event_delivery);
    DELETE event_outbox
    WHERE status = "fanned_out"
      AND fanned_out_at != NONE
      AND fanned_out_at < $cutoff
      AND id NOT IN $referenced;

    RETURN fn::result_ok(true);
} COMMENT "Purge, au-delà de la rétention, les livraisons livrées couvertes par le curseur durable de leur abonnement et les événements ventilés qu'aucune livraison ne référence"
PERMISSIONS FULL;
