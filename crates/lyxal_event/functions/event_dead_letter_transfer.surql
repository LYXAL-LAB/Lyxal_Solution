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
    IF $params.delivery_id == NONE OR $params.error == NONE OR $params.node_id == NONE OR $params.generation == NONE {
        RETURN fn::error_result("EVENT_INVALID_PARAMETERS", "fr", { message: "delivery_id, error, node_id, and generation are mandatory" });
    };

    LET $delivery_id = <record<event_delivery>> $params.delivery_id;
    LET $error_msg = <string> $params.error;
    LET $node_id = <string> $params.node_id;
    LET $generation = <number> $params.generation;
    LET $now = time::now();
    LET $lease_rec = event_stream_lease:outbox_leader;

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

    -- 3. Construction de la clé DLQ déterministe
    LET $dlq_id = type::record(string::concat("event_dead_letter:dlq_", record::id($delivery_id)));

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
} COMMENT "Transfère une livraison en dead-letter de façon atomique et strictement idempotente."
PERMISSIONS FULL;

