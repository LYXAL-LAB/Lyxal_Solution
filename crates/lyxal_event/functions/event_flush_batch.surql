-- ============================================================================
-- Function   : fn::event_flush_batch
-- Module     : lyxal_event
-- Description: Applique de façon granulaire les états terminaux d'un lot de livraisons
--              (delivered, dead_letter, dropped) et avance le curseur contigu sûr
--              sous vérification stricte de l'invariant de contiguïté et de fencing.
-- Contrat    : Retourne fn::result_ok({ flushed: bool, persisted_cursor: int, ... })
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::event_flush_batch(
    $params: object
) {
    IF $params.subscription == NONE OR $params.target_cursor == NONE OR $params.node_id == NONE OR $params.generation == NONE {
        RETURN fn::error_result("EVENT_INVALID_PARAMETERS", "fr", { message: "subscription, target_cursor, node_id, and generation are mandatory" });
    };

    LET $subscription = <record<event_subscription>> $params.subscription;
    LET $target_cursor = <number> $params.target_cursor;
    LET $node_id = <string> $params.node_id;
    LET $generation = <number> $params.generation;
    LET $delivered_ids = IF $params.delivered_ids != NONE AND $params.delivered_ids != NULL { $params.delivered_ids } ELSE { [] };
    LET $dead_letter_ids = IF $params.dead_letter_ids != NONE AND $params.dead_letter_ids != NULL { $params.dead_letter_ids } ELSE { [] };
    LET $dropped_ids = IF $params.dropped_ids != NONE AND $params.dropped_ids != NULL { $params.dropped_ids } ELSE { [] };
    LET $drop_reason = IF $params.drop_reason != NONE AND $params.drop_reason != NULL { <string> $params.drop_reason } ELSE { "dropped_by_policy" };
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

    -- 2. Chargement de la progression de l'abonnement
    LET $prog_rec = type::record(string::concat("event_subscription_progress:prog_", record::id($subscription)));
    LET $prog = (SELECT * FROM ONLY $prog_rec);

    LET $current_cursor = IF $prog != NONE THEN $prog.last_persisted_cursor ELSE 0 END;
    LET $last_assigned_seq = IF $prog != NONE THEN $prog.last_assigned_seq ELSE 0 END;

    -- Contrôle de monotonicité
    IF $target_cursor < $current_cursor {
        THROW "EVENT_CURSOR_NON_MONOTONIC";
    };

    -- Contrôle de borne supérieure
    IF $target_cursor > $last_assigned_seq {
        THROW "EVENT_CURSOR_EXCEEDS_ASSIGNED_SEQ";
    };

    -- 3. Application granulaire des statuts terminaux
    -- 3.1. Livraisons avec succès (delivered)
    FOR $id IN $delivered_ids {
        LET $rec = <record> $id;
        UPDATE $rec SET
            status = "delivered",
            delivered_at = $now,
            locked_until = NONE,
            lease_owner = NONE;
    };

    -- 3.2. Livraisons en quarantaine (dead_letter)
    FOR $id IN $dead_letter_ids {
        LET $rec = <record> $id;
        UPDATE $rec SET
            status = "dead_letter",
            locked_until = NONE,
            lease_owner = NONE;
    };

    -- 3.3. Livraisons abandonnées (dropped)
    FOR $id IN $dropped_ids {
        LET $rec = <record> $id;
        UPDATE $rec SET
            status = "dropped",
            dropped_at = $now,
            drop_reason = $drop_reason,
            locked_until = NONE,
            lease_owner = NONE;
    };

    -- 4. Vérification de l'invariant de contiguïté si le curseur avance
    IF $target_cursor > $current_cursor {
        -- Vérification 4.1 : Aucune séquence non résolue ne doit subsister dans la plage
        LET $unresolved = (
            SELECT VALUE delivery_seq FROM event_delivery
            WHERE subscription = $subscription
              AND delivery_seq > $current_cursor
              AND delivery_seq <= $target_cursor
              AND status NOT IN ["delivered", "dead_letter", "dropped"]
        );

        IF array::len($unresolved) > 0 {
            THROW "EVENT_CURSOR_INVARIANT_VIOLATION_UNRESOLVED_SEQUENCES";
        };

        -- Vérification 4.2 : Aucune séquence ne doit manquer (absence de trou)
        LET $count_rows = (
            SELECT count() FROM event_delivery
            WHERE subscription = $subscription
              AND delivery_seq > $current_cursor
              AND delivery_seq <= $target_cursor
            GROUP ALL
        );
        LET $found_count = IF array::len($count_rows) > 0 THEN $count_rows[0].count ELSE 0 END;
        LET $expected_count = $target_cursor - $current_cursor;

        IF $found_count != $expected_count {
            THROW "EVENT_CURSOR_MISSING_SEQUENCE_HOLE";
        };

        -- 5. Avancement persistant du curseur
        UPSERT $prog_rec CONTENT {
            subscription: $subscription,
            partition: 0,
            last_assigned_seq: $last_assigned_seq,
            last_persisted_cursor: $target_cursor,
            updated_at: $now
        };
    };

    RETURN fn::result_ok({
        flushed: true,
        persisted_cursor: $target_cursor,
        delivered_count: array::len($delivered_ids),
        dead_letter_count: array::len($dead_letter_ids),
        dropped_count: array::len($dropped_ids)
    });
} COMMENT "Applique les statuts terminaux et avance le curseur sous invariant contigu et garde de fencing."
PERMISSIONS FULL;

