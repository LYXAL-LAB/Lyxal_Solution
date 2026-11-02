-- ============================================================================
-- Function: fn::event_recover_pending_fanouts
-- Description: Détecte et reprend les fan-outs interrompus par un crash ou redémarrage.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::event_recover_pending_fanouts(
    $params: object
) {
    -- Fonction interne du moteur d'événements (appelée par le code Rust avec des types
    -- vérifiés, à chaque livraison) : validation par les primitives de lyxal_core plutôt que
    -- par fn::validation_object_execute, dont le coût par appel pèserait sur le débit
    -- (décision CTO, reprise lyxal_event).
    LET $checks = {
        limit: fn::validation_integer(($params.limit ?? 50), 1, 1000),
        language: fn::validation_language_code($params.language ?? "fr", false, NONE)
    };
    LET $invalid = object::from_entries(array::map(array::filter(object::entries($checks), |$e| !$e[1].valid), |$e| [$e[0], [$e[1].code]]));
    IF object::len($invalid) > 0 {
        RETURN fn::error_result("EVENT_INVALID_PARAMETERS", $params.language, { fields: $invalid });
    };
    LET $p = object::from_entries(array::map(object::entries($checks), |$e| [$e[0], $e[1].value]));
    LET $limit = $p.limit;

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
} COMMENT "Reprend de manière idempotente les fan-outs d'événements outbox restés en statut pending"
PERMISSIONS FULL;
