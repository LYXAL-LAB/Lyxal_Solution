-- ============================================================================
-- Function   : fn::event_lease_release
-- Module     : lyxal_event
-- Description: Libère volontairement le bail de streaming lors de l'arrêt gracieux du leader.
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
        node_id: fn::validation_required_string($params.node_id, 1, 128),
        generation: fn::validation_integer($params.generation, 1, NONE),
        language: fn::validation_language_code($params.language ?? "fr", false, NONE)
    };
    LET $invalid = object::from_entries(array::map(array::filter(object::entries($checks), |$e| !$e[1].valid), |$e| [$e[0], [$e[1].code]]));
    IF object::len($invalid) > 0 {
        RETURN fn::error_result("EVENT_INVALID_PARAMETERS", $params.language, { fields: $invalid });
    };
    LET $p = object::from_entries(array::map(object::entries($checks), |$e| [$e[0], $e[1].value]));
    LET $node_id = $p.node_id;
    LET $generation = $p.generation;

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
} COMMENT "Libère formellement le bail de streaming outbox pour permettre une reprise immédiate."
PERMISSIONS FULL;

