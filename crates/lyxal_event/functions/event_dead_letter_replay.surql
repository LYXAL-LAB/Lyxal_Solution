-- ============================================================================
-- Function: fn::event_dead_letter_replay
-- Description: Réinitialise une livraison dead-letter en statut actif pour rejeu contrôlé.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::event_dead_letter_replay(
    $params: object
) {
    LET $dead_letter_id = $params.dead_letter_id;

    LET $dl = (SELECT * FROM ONLY $dead_letter_id);

    IF $dl == NONE {
        RETURN fn::result_ok(false);
    };

    -- Marque la dead letter comme rejouée
    UPDATE $dl.id SET
        replayed = true,
        replayed_at = time::now();

    -- Réinitialise la livraison associée en statut 'pending'
    UPDATE $dl.delivery SET
        status = "pending",
        attempts = 0,
        next_retry_at = time::now(),
        locked_until = NONE,
        lease_owner = NONE,
        last_error = NONE;

    RETURN fn::result_ok(true);
} COMMENT "Rejoue une dead letter en réinitialisant sa livraison en statut pending";
