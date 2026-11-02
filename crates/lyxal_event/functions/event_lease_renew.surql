-- ============================================================================
-- Function   : fn::event_lease_renew
-- Module     : lyxal_event
-- Description: Renouvelle le TTL du bail actif pour le leader courant.
--              Effectue une écriture conditionnelle stricte sur le propriétaire et la génération.
-- Contrat    : Retourne fn::result_ok({ renewed: bool, generation: int, expires_at: datetime })
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::event_lease_renew(
    $params: object
) {
    IF $params.node_id == NONE OR $params.generation == NONE {
        RETURN fn::error_result("EVENT_INVALID_PARAMETERS", "fr", { message: "node_id and generation are mandatory" });
    };

    LET $node_id = <string> $params.node_id;
    LET $generation = <number> $params.generation;
    LET $ttl_seconds = IF $params.ttl_seconds != NONE AND $params.ttl_seconds != NULL { <number> $params.ttl_seconds } ELSE { 6 };
    LET $now = time::now();
    LET $new_expiry = $now + <duration> string::concat($ttl_seconds, "s");
    LET $lease_rec = event_stream_lease:outbox_leader;

    LET $updated = (
        UPDATE $lease_rec SET
            expires_at = $new_expiry,
            last_flushed_at = $now
        WHERE id = $lease_rec
          AND owner_node_id = $node_id
          AND generation = $generation
          AND is_released = false
        RETURN AFTER
    );

    IF array::len($updated) == 0 {
        RETURN fn::result_ok({
            renewed: false,
            generation: $generation,
            expires_at: NONE
        });
    };

    RETURN fn::result_ok({
        renewed: true,
        generation: $generation,
        expires_at: $new_expiry
    });
} COMMENT "Renouvelle le bail de streaming outbox sous condition stricte d'identité et de génération."
PERMISSIONS FULL;

