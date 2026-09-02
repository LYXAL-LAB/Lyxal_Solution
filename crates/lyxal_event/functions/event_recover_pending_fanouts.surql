-- ============================================================================
-- Function: fn::event_recover_pending_fanouts
-- Description: Détecte et reprend les fan-outs interrompus par un crash ou redémarrage.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::event_recover_pending_fanouts(
    $params: object
) {
    LET $limit = IF $params.limit != NONE { $params.limit } ELSE { 50 };

    -- Récupère les événements outbox restés en statut 'pending'
    LET $pending_events = (
        SELECT id, created_at FROM event_outbox 
        WHERE status = "pending" 
        ORDER BY created_at ASC 
        LIMIT $limit
    );

    IF array::len($pending_events) == 0 {
        RETURN fn::result_ok({
            recovered_count: 0
        });
    };

    FOR $ev IN $pending_events {
        fn::event_fanout({
            outbox_id: $ev.id
        });
    };

    RETURN fn::result_ok({
        recovered_count: array::len($pending_events)
    });
} COMMENT "Reprend de manière idempotente les fan-outs d'événements outbox restés en statut pending";
