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
    -- Fonction interne du moteur d'événements (appelée par le code Rust avec des types
    -- vérifiés, à chaque livraison) : validation par les primitives de lyxal_core plutôt que
    -- par fn::validation_object_execute, dont le coût par appel pèserait sur le débit
    -- (décision CTO, reprise lyxal_event).
    LET $checks = {
        node_id: fn::validation_required_string($params.node_id, 1, 128),
        generation: fn::validation_integer($params.generation, 1, NONE),
        ttl_seconds: fn::validation_integer(($params.ttl_seconds ?? 6), 1, 3600),
        language: fn::validation_language_code($params.language ?? "fr", false, NONE)
    };
    LET $invalid = object::from_entries(array::map(array::filter(object::entries($checks), |$e| !$e[1].valid), |$e| [$e[0], [$e[1].code]]));
    IF object::len($invalid) > 0 {
        RETURN fn::error_result("EVENT_INVALID_PARAMETERS", $params.language, { fields: $invalid });
    };
    LET $p = object::from_entries(array::map(object::entries($checks), |$e| [$e[0], $e[1].value]));
    LET $node_id = $p.node_id;
    LET $generation = $p.generation;
    LET $ttl_seconds = $p.ttl_seconds;

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

