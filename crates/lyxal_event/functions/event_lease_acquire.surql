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
    -- Fonction interne du moteur d'événements (appelée par le code Rust avec des types
    -- vérifiés, à chaque livraison) : validation par les primitives de lyxal_core plutôt que
    -- par fn::validation_object_execute, dont le coût par appel pèserait sur le débit
    -- (décision CTO, reprise lyxal_event).
    LET $checks = {
        node_id: fn::validation_required_string($params.node_id, 1, 128),
        ttl_seconds: fn::validation_integer(($params.ttl_seconds ?? 6), 1, 3600),
        language: fn::validation_language_code($params.language ?? "fr", false, NONE)
    };
    LET $invalid = object::from_entries(array::map(array::filter(object::entries($checks), |$e| !$e[1].valid), |$e| [$e[0], [$e[1].code]]));
    IF object::len($invalid) > 0 {
        RETURN fn::error_result("EVENT_INVALID_PARAMETERS", $params.language, { fields: $invalid });
    };
    LET $p = object::from_entries(array::map(object::entries($checks), |$e| [$e[0], $e[1].value]));
    LET $node_id = $p.node_id;
    LET $ttl_seconds = $p.ttl_seconds;

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
