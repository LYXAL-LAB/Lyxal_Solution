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
    -- Fonction interne du moteur d'événements (appelée par le code Rust avec des types
    -- vérifiés, à chaque livraison) : validation par les primitives de lyxal_core plutôt que
    -- par fn::validation_object_execute, dont le coût par appel pèserait sur le débit
    -- (décision CTO, reprise lyxal_event).
    LET $checks = {
        outbox_event: fn::validation_record_id($params.outbox_event, ["event_outbox"]),
        subscription: fn::validation_record_id($params.subscription, ["event_subscription"]),
        target_module: IF !fn::validation_required_string($params.target_module, 1, 64).valid { fn::validation_required_string($params.target_module, 1, 64) } ELSE { fn::validation_regex($params.target_module, "^[a-z][a-z0-9_]*$") },
        node_id: fn::validation_required_string($params.node_id, 1, 128),
        generation: fn::validation_integer($params.generation, 1, NONE),
        context: fn::validation_object($params.context ?? {}),
        lock_seconds: fn::validation_integer(($params.lock_seconds ?? 30), 1, 3600),
        language: fn::validation_language_code($params.language ?? "fr", false, NONE)
    };
    LET $invalid = object::from_entries(array::map(array::filter(object::entries($checks), |$e| !$e[1].valid), |$e| [$e[0], [$e[1].code]]));
    IF object::len($invalid) > 0 {
        RETURN fn::error_result("EVENT_INVALID_PARAMETERS", $params.language, { fields: $invalid });
    };
    LET $p = object::from_entries(array::map(object::entries($checks), |$e| [$e[0], $e[1].value]));
    LET $outbox_event = $p.outbox_event;
    LET $subscription = $p.subscription;
    LET $target_module = $p.target_module;
    LET $node_id = $p.node_id;
    LET $generation = $p.generation;
    LET $context = $p.context;
    LET $lock_seconds = $p.lock_seconds;

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
                target_module = $ex.target_module ?? $target_module
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
            locked_until: $now + $lock_duration,
            lease_owner: $node_id,
            next_retry_at: $now,
            created_at: $now
        }
    );

    RETURN fn::result_ok($created[0]);
} COMMENT "Attribue atomiquement une séquence contiguë et crée la livraison sous garde de fencing."
PERMISSIONS FULL;

