-- ============================================================================
-- Function   : fn::event_lease_acquire
-- Module     : lyxal_event
-- Description: Tente d'acquérir le bail de streaming outbox pour le nœud demandeur.
--              Garantit l'attribution d'une génération monotone strictement croissante
--              en cas de reprise de bail expiré ou libéré.
-- Contrat    : Retourne fn::result_ok({ acquired: bool, generation: int, owner_node_id: string, expires_at: datetime })
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::event_lease_acquire(
    $params: object
) {
    IF $params.node_id == NONE OR $params.node_id == NULL {
        RETURN fn::error_result("EVENT_INVALID_PARAMETERS", "fr", { field: "node_id", message: "node_id is mandatory" });
    };

    LET $node_id = <string> $params.node_id;
    LET $ttl_seconds = IF $params.ttl_seconds != NONE AND $params.ttl_seconds != NULL { <number> $params.ttl_seconds } ELSE { 6 };
    LET $now = time::now();
    LET $new_expiry = $now + <duration> string::concat($ttl_seconds, "s");
    LET $lease_rec = event_stream_lease:outbox_leader;

    LET $lease = (SELECT * FROM ONLY $lease_rec);

    -- 1. Cas initial : Aucun bail n'existe en base
    IF $lease == NONE {
        LET $created = (
            CREATE $lease_rec CONTENT {
                generation: 1,
                owner_node_id: $node_id,
                acquired_at: $now,
                expires_at: $new_expiry,
                last_flushed_at: $now,
                is_released: false
            }
        );
        IF array::len($created) > 0 {
            RETURN fn::result_ok({
                acquired: true,
                generation: 1,
                owner_node_id: $node_id,
                expires_at: $new_expiry
            });
        };
    };

    -- 2. Cas ré-acquisition par le même nœud encore valide
    IF $lease.owner_node_id == $node_id AND $lease.is_released == false AND $lease.expires_at >= $now {
        UPDATE $lease_rec SET
            expires_at = $new_expiry,
            last_flushed_at = $now;
        RETURN fn::result_ok({
            acquired: true,
            generation: $lease.generation,
            owner_node_id: $node_id,
            expires_at: $new_expiry
        });
    };

    -- 3. Cas reprise sur expiration ou libération explicite : incrément de génération
    IF $lease.is_released == true OR $lease.expires_at < $now {
        LET $next_gen = $lease.generation + 1;
        LET $updated = (
            UPDATE $lease_rec SET
                generation = $next_gen,
                owner_node_id = $node_id,
                acquired_at = $now,
                expires_at = $new_expiry,
                last_flushed_at = $now,
                is_released = false
            WHERE id = $lease_rec AND generation = $lease.generation
            RETURN AFTER
        );
        IF array::len($updated) > 0 {
            RETURN fn::result_ok({
                acquired: true,
                generation: $next_gen,
                owner_node_id: $node_id,
                expires_at: $new_expiry
            });
        };
    };

    -- 4. Bail détenu par un autre nœud actif : échec d'acquisition
    RETURN fn::result_ok({
        acquired: false,
        generation: $lease.generation,
        owner_node_id: $lease.owner_node_id,
        expires_at: $lease.expires_at
    });
} COMMENT "Tente d'acquérir le bail exclusif de streaming outbox avec incrément de génération."
PERMISSIONS FULL;
