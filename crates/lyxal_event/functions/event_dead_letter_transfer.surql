-- ============================================================================
-- Function   : fn::event_dead_letter_transfer
-- Module     : lyxal_event
-- Description: Transfère de façon atomique et idempotente une livraison empoisonnée
--              dans la table event_dead_letter avec une clé déterministe (dlq_<delivery_id>).
--              Préserve les métadonnées originales en cas de ré-exécution.
-- Contrat    : Retourne fn::result_ok({ dead_lettered: bool, dlq_id: string })
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::event_dead_letter_transfer(
    $params: object
) {
    -- Fonction interne du moteur d'événements (appelée par le code Rust avec des types
    -- vérifiés, à chaque livraison) : validation par les primitives de lyxal_core plutôt que
    -- par fn::validation_object_execute, dont le coût par appel pèserait sur le débit
    -- (décision CTO, reprise lyxal_event).
    LET $checks = {
        delivery_id: fn::validation_record_id($params.delivery_id, ["event_delivery"]),
        error: fn::validation_required_string($params.error, 1, 4000),
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
    LET $error_msg = $p.error;
    LET $host = $p.host;
    LET $node_id = $p.node_id;
    LET $generation = $p.generation;

    LET $now = time::now();
    -- Bail du chef des événements de cet hôte (un bail par hôte)
    LET $lease_rec = type::record("event_stream_lease", $host);

    -- 1. Garde transactionnelle de Fencing (Écriture conditionnelle sur le bail)
    LET $guard = (
        UPDATE $lease_rec SET
            last_flushed_at = $now
        WHERE id = $lease_rec
          AND generation = $generation
          AND owner_node_id = $node_id
          AND is_released = false
          AND expires_at >= $now
        RETURN AFTER
    );

    IF array::len($guard) == 0 {
        THROW "EVENT_STALE_LEADER_FENCED";
    };

    -- 2. Chargement de la livraison
    LET $del = (SELECT * FROM ONLY $delivery_id);
    IF $del == NONE {
        THROW "EVENT_DELIVERY_NOT_FOUND";
    };

    -- Contrôle de propriété, dans la même transaction que la garde : la livraison appartient à
    -- l'hôte de ce bail (hôte inscrit sur la livraison, qui reste le sien quand l'abonnement a
    -- été supprimé)
    IF $del.host != $host {
        RETURN fn::error_result("EVENT_SUBSCRIPTION_NOT_OWNED", $params.language, {
            delivery: <string> $delivery_id,
            host: $host,
            owner_host: $del.host
        });
    };

    -- 3. Construction de la clé DLQ déterministe
    LET $dlq_id = type::record("event_dead_letter", string::concat("dlq_", record::id($delivery_id)));

    -- 4. Idempotence : Vérifie si l'enregistrement DLQ existe déjà
    LET $existing_dlq = (SELECT * FROM ONLY $dlq_id);

    IF $existing_dlq == NONE {
        -- Récupération du payload d'origine dans outbox
        LET $outbox = (SELECT * FROM ONLY $del.outbox_event);

        CREATE $dlq_id CONTENT {
            delivery: $del.id,
            delivery_id_str: <string> $del.id,
            outbox_event: $del.outbox_event,
            subscription: $del.subscription,
            target_module: $del.target_module,
            context: $del.context,
            attempts: $del.attempts,
            last_error: $error_msg,
            payload: IF $outbox != NONE THEN $outbox.payload ELSE {} END,
            metadata: IF $outbox != NONE THEN $outbox.metadata ELSE {} END,
            replayed: false,
            exhausted_at: $now
        };
    };

    -- 5. Mise à jour atomique de la livraison
    UPDATE $delivery_id SET
        status = "dead_letter",
        dead_letter_ref = $dlq_id,
        last_error = $error_msg,
        locked_until = NONE,
        lease_owner = NONE;

    RETURN fn::result_ok({
        dead_lettered: true,
        dlq_id: <string> $dlq_id
    });
} COMMENT "Transfère une livraison en dead-letter ({ delivery_id, error, host, node_id, generation }) de façon atomique et strictement idempotente, sous la garde du bail de l'hôte (EVENT_STALE_LEADER_FENCED) ; livraison d'un autre hôte : EVENT_SUBSCRIPTION_NOT_OWNED."
PERMISSIONS FULL;

