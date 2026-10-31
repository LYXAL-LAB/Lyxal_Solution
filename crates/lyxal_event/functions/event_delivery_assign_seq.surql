-- ============================================================================
-- Function   : fn::event_delivery_assign_seq
-- Module     : lyxal_event
-- Description: Assigne de façon atomique un numéro de séquence contigu sans trou
--              et crée la livraison dans event_delivery sous protection de fencing.
-- Contrat    : Retourne fn::result_ok($delivery)
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::event_delivery_assign_seq(
    $params: object
) {
    IF $params.outbox_event == NONE OR $params.subscription == NONE OR $params.node_id == NONE OR $params.generation == NONE {
        RETURN fn::error_result("EVENT_INVALID_PARAMETERS", "fr", { message: "outbox_event, subscription, node_id, and generation are mandatory" });
    };

    LET $outbox_event = <record<event_outbox>> $params.outbox_event;
    LET $subscription = <record<event_subscription>> $params.subscription;
    LET $target_module = IF $params.target_module != NONE AND $params.target_module != NULL { <string> $params.target_module } ELSE { "unknown" };
    LET $node_id = <string> $params.node_id;
    LET $generation = <number> $params.generation;
    LET $context = IF $params.context != NONE AND $params.context != NULL { $params.context } ELSE { {} };
    LET $lock_seconds = IF $params.lock_seconds != NONE AND $params.lock_seconds != NULL THEN <number> $params.lock_seconds ELSE 30 END;
    LET $lock_duration = <duration> string::concat($lock_seconds, "s");
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

    -- 2. Idempotence : Vérifie si la livraison existe déjà pour cette paire (outbox_event, subscription)
    LET $existing = (
        SELECT * FROM event_delivery
        WHERE outbox_event = $outbox_event
          AND subscription = $subscription
        LIMIT 1
    );

    IF array::len($existing) > 0 {
        LET $ex = $existing[0];
        IF $ex.delivery_seq != NONE AND $ex.delivery_seq != NULL {
            -- Si déjà dans un état terminal, la retourner immédiatement
            IF $ex.status IN ["delivered", "dead_letter", "dropped"] {
                RETURN fn::result_ok($ex);
            };

            -- Récupération post-crash : verrouille la livraison pour le leader actif sans modifier delivery_seq
            LET $locked = (
                UPDATE $ex.id SET
                    status = "processing",
                    locked_until = $now + $lock_duration,
                    lease_owner = $node_id,
                    attempts = attempts + 1
                RETURN AFTER
            );
            RETURN fn::result_ok($locked[0]);
        };

        -- Si la livraison existait sans séquence (ex: créée par fanout initial), on lui alloue la séquence
        LET $prog_rec = type::record(string::concat("event_subscription_progress:prog_", record::id($subscription)));
        LET $prog = (SELECT * FROM ONLY $prog_rec);

        LET $current_seq = IF $prog != NONE THEN $prog.last_assigned_seq ELSE 0 END;
        LET $current_cursor = IF $prog != NONE THEN $prog.last_persisted_cursor ELSE 0 END;
        LET $next_seq = $current_seq + 1;

        UPSERT $prog_rec CONTENT {
            subscription: $subscription,
            partition: 0,
            last_assigned_seq: $next_seq,
            last_persisted_cursor: $current_cursor,
            updated_at: $now
        };

        LET $updated = (
            UPDATE $ex.id SET
                delivery_seq = $next_seq,
                status = "processing",
                locked_until = $now + $lock_duration,
                lease_owner = $node_id,
                attempts = attempts + 1,
                target_module = IF $ex.target_module != NONE AND $ex.target_module != "unknown" THEN $ex.target_module ELSE $target_module END
            RETURN AFTER
        );
        RETURN fn::result_ok($updated[0]);
    };

    -- 3. Allocation atomique de la séquence contiguë
    -- Identification canonique du record de progression
    LET $prog_rec = type::record(string::concat("event_subscription_progress:prog_", record::id($subscription)));
    LET $prog = (SELECT * FROM ONLY $prog_rec);

    LET $current_seq = IF $prog != NONE THEN $prog.last_assigned_seq ELSE 0 END;
    LET $current_cursor = IF $prog != NONE THEN $prog.last_persisted_cursor ELSE 0 END;
    LET $next_seq = $current_seq + 1;

    -- Persistance immédiate du compteur incrémenté
    UPSERT $prog_rec CONTENT {
        subscription: $subscription,
        partition: 0,
        last_assigned_seq: $next_seq,
        last_persisted_cursor: $current_cursor,
        updated_at: $now
    };

    -- 4. Création atomique de la livraison
    LET $created = (
        CREATE event_delivery CONTENT {
            outbox_event: $outbox_event,
            subscription: $subscription,
            target_module: $target_module,
            context: $context,
            status: "processing",
            delivery_seq: $next_seq,
            attempts: 1,
            max_attempts: 5,
            locked_until: $now + $lock_duration,
            lease_owner: $node_id,
            next_retry_at: $now,
            created_at: $now
        }
    );

    RETURN fn::result_ok($created[0]);
} COMMENT "Attribue atomiquement une séquence contiguë et crée la livraison sous garde de fencing.";

