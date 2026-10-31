-- ============================================================================
-- Function   : fn::event_lease_release
-- Module     : lyxal_event
-- Description: Libère volontairement le bail de streaming lors de l'arrêt gracieux du leader.
-- Contrat    : Retourne fn::result_ok({ released: bool })
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::event_lease_release(
    $params: object
) {
    IF $params.node_id == NONE OR $params.generation == NONE {
        RETURN fn::error_result("EVENT_INVALID_PARAMETERS", "fr", { message: "node_id and generation are mandatory" });
    };

    LET $node_id = <string> $params.node_id;
    LET $generation = <number> $params.generation;
    LET $now = time::now();
    LET $lease_rec = event_stream_lease:outbox_leader;

    LET $updated = (
        UPDATE $lease_rec SET
            is_released = true,
            expires_at = $now,
            last_flushed_at = $now
        WHERE id = $lease_rec
          AND owner_node_id = $node_id
          AND generation = $generation
        RETURN AFTER
    );

    RETURN fn::result_ok({
        released: array::len($updated) > 0
    });
} COMMENT "Libère formellement le bail de streaming outbox pour permettre une reprise immédiate.";

