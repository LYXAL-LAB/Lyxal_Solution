-- ============================================================================
-- Function   : fn::event_delivery_fetch_pending
-- Module     : lyxal_event
-- Description: Récupère les livraisons éligibles au traitement outbox ou à la reprise après crash.
-- Contrat    : Retourne fn::result_ok(Vec<PendingDelivery>)
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::event_delivery_fetch_pending(
    $params: object
) {
    -- Fonction interne du moteur d'événements (appelée par le code Rust avec des types
    -- vérifiés, à chaque livraison) : validation par les primitives de lyxal_core plutôt que
    -- par fn::validation_object_execute, dont le coût par appel pèserait sur le débit
    -- (décision CTO, reprise lyxal_event).
    LET $checks = {
        limit: fn::validation_integer(($params.limit ?? 50), 1, 1000),
        instance_id: IF $params.instance_id IS NONE { { valid: true, value: NONE } } ELSE { fn::validation_optional_string($params.instance_id, 1, 128) },
        subscription: IF $params.subscription IS NONE { { valid: true, value: NONE } } ELSE { fn::validation_record_id($params.subscription, ["event_subscription"]) },
        language: fn::validation_language_code($params.language ?? "fr", false, NONE)
    };
    LET $invalid = object::from_entries(array::map(array::filter(object::entries($checks), |$e| !$e[1].valid), |$e| [$e[0], [$e[1].code]]));
    IF object::len($invalid) > 0 {
        RETURN fn::error_result("EVENT_INVALID_PARAMETERS", $params.language, { fields: $invalid });
    };
    LET $p = object::from_entries(array::map(object::entries($checks), |$e| [$e[0], $e[1].value]));
    LET $limit = $p.limit;
    LET $instance_id = $p.instance_id;
    LET $subscription = $p.subscription;

    LET $now = time::now();

    LET $deliveries = (
        SELECT 
            id,
            created_at,
            outbox_event,
            subscription,
            delivery_seq,
            target_module,
            context,
            outbox_event.event_id AS event_id,
            outbox_event.event_type AS event_type,
            outbox_event.version AS version,
            outbox_event.producer AS producer,
            outbox_event.source AS source,
            outbox_event.correlation_id AS correlation_id,
            outbox_event.causation_id AS causation_id,
            outbox_event.payload AS payload,
            outbox_event.metadata AS metadata
        FROM event_delivery
        WHERE status NOT IN ['delivered', 'dead_letter', 'dropped']
          AND (locked_until = NONE OR locked_until < $now)
          AND (next_retry_at = NONE OR next_retry_at <= $now)
          AND ($instance_id = NONE OR context.instance_id = $instance_id)
          AND ($subscription = NONE OR subscription = $subscription)
        ORDER BY created_at ASC
        LIMIT $limit
    );

    RETURN fn::result_ok($deliveries);
} COMMENT "Récupère les livraisons éligibles au traitement outbox ou à la reprise post-crash"
PERMISSIONS FULL;

