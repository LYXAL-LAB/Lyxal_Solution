-- ============================================================================
-- Function: fn::event_delivery_failure
-- Description: Enregistre l'échec transitoire d'une livraison et la date de son prochain essai.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::event_delivery_failure(
    $params: object
) {
    -- Fonction interne du moteur d'événements (appelée par le code Rust avec des types
    -- vérifiés, à chaque livraison) : validation par les primitives de lyxal_core plutôt que
    -- par fn::validation_object_execute, dont le coût par appel pèserait sur le débit
    -- (décision CTO, reprise lyxal_event).
    LET $checks = {
        delivery_id: fn::validation_record_id($params.delivery_id, ["event_delivery"]),
        error: fn::validation_required_string($params.error, 1, 4000),
        retry_delay_seconds: fn::validation_integer(($params.retry_delay_seconds ?? 5), 0, 86400),
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
    LET $delivery_id = $p.delivery_id;
    LET $error = $p.error;
    LET $retry_delay_seconds = $p.retry_delay_seconds;
    LET $host = $p.host;
    LET $now = time::now();
    LET $lease_rec = type::record("event_stream_lease", $host);

    -- Garde de fencing, comme fn::event_flush_batch : seul le chef en place de cet hôte
    -- (nœud et génération du bail, non expiré) écrit l'échec ; un ancien chef est refusé
    LET $guard = (
        UPDATE $lease_rec SET
            last_flushed_at = $now
        WHERE id = $lease_rec
          AND generation = $p.generation
          AND owner_node_id = $p.node_id
          AND is_released = false
          AND expires_at >= $now
        RETURN AFTER
    );
    IF array::len($guard) == 0 {
        THROW "EVENT_STALE_LEADER_FENCED";
    };

    LET $delivery = (SELECT * FROM ONLY $delivery_id);

    IF $delivery == NONE {
        RETURN fn::error_result("EVENT_DELIVERY_NOT_FOUND", $p.language, { delivery_id: $delivery_id });
    };

    -- Contrôle de propriété : la livraison appartient à l'hôte de ce bail
    IF $delivery.host != $host {
        RETURN fn::error_result("EVENT_SUBSCRIPTION_NOT_OWNED", $p.language, {
            delivery_id: <string> $delivery_id,
            host: $host,
            owner_host: $delivery.host
        });
    };

    -- Enregistre l'échec et la date du prochain essai. Le leader garde le message en mémoire et
    -- son verrou : la décision de dead letter appartient au moteur (barrière DLQ protégée par le
    -- bail, fn::event_dead_letter_transfer), jamais à cette fonction.
    UPDATE $delivery.id SET
        status = "failed",
        last_error = $error,
        next_retry_at = $now + <duration> string::concat($retry_delay_seconds, "s");

    RETURN fn::result_ok(true);
} COMMENT "Enregistre l'échec transitoire d'une livraison ({ delivery_id, error, retry_delay_seconds, host, node_id, generation }) et la date de son prochain essai, sous la garde du bail du chef de l'hôte (EVENT_STALE_LEADER_FENCED) et pour une livraison de cet hôte seulement (EVENT_SUBSCRIPTION_NOT_OWNED) ; la mise en dead letter relève de la barrière DLQ du moteur"
PERMISSIONS FULL;
