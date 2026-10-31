-- ============================================================================
-- Function   : fn::event_delivery_fetch_pending
-- Module     : lyxal_event
-- Description: Récupère les livraisons éligibles au traitement outbox ou à la reprise après crash.
-- Contrat    : Retourne fn::result_ok(Vec<PendingDelivery>)
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::event_delivery_fetch_pending(
    $params: object
) {
    LET $limit = IF $params.limit != NONE AND $params.limit != NULL THEN <number> $params.limit ELSE 50 END;
    LET $instance_id = IF $params.instance_id != NONE AND $params.instance_id != NULL THEN <string> $params.instance_id ELSE NONE END;
    LET $subscription = IF $params.subscription != NONE AND $params.subscription != NULL THEN <record<event_subscription>> $params.subscription ELSE NONE END;
    LET $now = time::now();

    LET $deliveries = (
        SELECT 
            id,
            created_at,
            outbox_event,
            subscription,
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
} COMMENT "Récupère les livraisons éligibles au traitement outbox ou à la reprise post-crash";

