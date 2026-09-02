-- ============================================================================
-- Function: fn::event_fanout
-- Description: Éclate de manière idempotente un événement outbox vers tous les abonnements correspondants.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::event_fanout(
    $params: object
) {
    LET $outbox_id = $params.outbox_id;
    LET $event = (SELECT * FROM $outbox_id)[0];

    IF $event == NONE {
        RETURN fn::result_ok({
            deliveries_created: 0,
            status: "not_found"
        });
    };

    -- Recherche de tous les abonnements actifs dont le pattern correspond
    LET $type = $event.event_type;
    LET $all_subs = (SELECT * FROM event_subscription WHERE is_active = true);
    
    LET $created_count = 0;

    FOR $sub IN $all_subs {
        LET $pat = $sub.event_pattern;
        LET $matches = ($pat == $type) 
            OR ($pat == "*")
            OR (string::ends_with($pat, ".*") AND string::starts_with($type, string::slice($pat, 0, string::len($pat) - 1)));

        IF $matches {
            -- Vérification d'idempotence stricte : UNIQUE(outbox_event, subscription)
            LET $existing = (
                SELECT id FROM event_delivery 
                WHERE outbox_event = $event.id 
                  AND subscription = $sub.id
            )[0];

            IF $existing == NONE {
                CREATE event_delivery CONTENT {
                    outbox_event: $event.id,
                    subscription: $sub.id,
                    target_module: $sub.target_module,
                    context: $event.context,
                    status: "pending",
                    attempts: 0,
                    max_attempts: $sub.max_attempts,
                    next_retry_at: time::now(),
                    created_at: time::now()
                };
                LET $created_count = $created_count + 1;
            };
        };
    };

    -- Marque l'événement outbox comme ventilé (fanned_out)
    UPDATE $event.id SET 
        status = "fanned_out", 
        fanned_out_at = time::now();

    RETURN fn::result_ok({
        outbox_id: $event.id,
        deliveries_created: $created_count,
        status: "fanned_out"
    });
} COMMENT "Ventile un événement outbox vers ses abonnés de façon strictement idempotente";
