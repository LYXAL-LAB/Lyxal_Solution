-- ============================================================================
-- Function: fn::event_claim_batch
-- Description: Réclame atomiquement un lot de livraisons prêtes et pose un bail exclusif.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::event_claim_batch(
    $params: object
) {
    LET $limit = IF $params.limit != NONE { $params.limit } ELSE { 20 };
    LET $lease_seconds = IF $params.lease_seconds != NONE { $params.lease_seconds } ELSE { 30 };
    LET $worker_id = IF $params.worker_id != NONE { $params.worker_id } ELSE { "worker_default" };
    LET $instance_id = IF $params.instance_id != NONE AND $params.instance_id != NULL { $params.instance_id } ELSE { NONE };
    LET $now = time::now();
    LET $lease_until = time::now() + duration::from::secs($lease_seconds);

    -- Sélection ordonnée des livraisons éligibles
    LET $eligible = IF $instance_id != NONE {
        (
            SELECT id, next_retry_at FROM event_delivery
            WHERE (
                (status = "pending" AND next_retry_at != NONE AND next_retry_at <= $now)
                OR (status = "failed" AND next_retry_at != NONE AND next_retry_at <= $now)
                OR (status = "processing" AND locked_until != NONE AND locked_until < $now)
            )
            AND context.instance_id = $instance_id
            ORDER BY next_retry_at ASC
            LIMIT $limit
        )
    } ELSE {
        (
            SELECT id, next_retry_at FROM event_delivery
            WHERE (
                (status = "pending" AND next_retry_at != NONE AND next_retry_at <= $now)
                OR (status = "failed" AND next_retry_at != NONE AND next_retry_at <= $now)
                OR (status = "processing" AND locked_until != NONE AND locked_until < $now)
            )
            ORDER BY next_retry_at ASC
            LIMIT $limit
        )
    };

    IF array::len($eligible) == 0 {
        RETURN fn::result_ok([]);
    };

    -- 2. Acquisition atomique du bail pour chaque livraison
    LET $claimed = (
        UPDATE $eligible.id
        SET status = "processing",
            locked_until = $lease_until,
            lease_owner = $worker_id,
            attempts = attempts + 1
        WHERE (status = "pending" AND next_retry_at != NONE AND next_retry_at <= $now)
           OR (status = "failed" AND next_retry_at != NONE AND next_retry_at <= $now)
           OR (status = "processing" AND locked_until != NONE AND locked_until < $now)
        RETURN AFTER
    );

    RETURN fn::result_ok($claimed);
}; COMMENT "Réclame atomiquement un lot de livraisons d'événements et applique un bail exclusif";
