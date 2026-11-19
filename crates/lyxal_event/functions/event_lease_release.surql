-- ============================================================================
-- Function   : fn::event_lease_release
-- Module     : lyxal_event
-- Description: Libère volontairement le bail du chef des événements d'un hôte lors de son arrêt
--              gracieux.
-- Contrat    : Retourne fn::result_ok({ released: bool })
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::event_lease_release(
    $params: object
) {
    -- Fonction interne du moteur d'événements (appelée par le code Rust avec des types
    -- vérifiés, à chaque livraison) : validation par les primitives de lyxal_core plutôt que
    -- par fn::validation_object_execute, dont le coût par appel pèserait sur le débit
    -- (décision CTO, reprise lyxal_event).
    LET $checks = {
        host: fn::validation_regex($params.host, "^[a-z][a-z0-9_]{0,63}$"),
        node_id: fn::validation_required_string($params.node_id, 1, 128),
        generation: fn::validation_integer($params.generation, 1, NONE),
        language: fn::validation_language_code($params.language ?? "fr", false, NONE)
    };
    LET $invalid = object::from_entries(array::map(array::filter(object::entries($checks), |$e| !$e[1].valid), |$e| [$e[0], [$e[1].code]]));
    IF object::len($invalid) > 0 {
        RETURN fn::error_result("EVENT_INVALID_PARAMETERS", $params.language, { fields: $invalid });
    };
    LET $p = object::from_entries(array::map(object::entries($checks), |$e| [$e[0], $e[1].value]));
    LET $host = $p.host;
    LET $node_id = $p.node_id;
    LET $generation = $p.generation;

    LET $now = time::now();
    -- Bail du chef des événements de cet hôte (un bail par hôte)
    LET $lease_rec = type::record("event_stream_lease", $host);

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
} COMMENT "Libère formellement le bail du chef des événements d'un hôte ({ host, node_id, generation }) pour permettre une reprise immédiate par un autre nœud du même hôte."
PERMISSIONS FULL;

