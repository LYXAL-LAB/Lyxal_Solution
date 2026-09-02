-- ============================================================================
-- Function: fn::event_delivery_success
-- Description: Acquitte avec succès le traitement d'une livraison d'événement.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::event_delivery_success(
    $params: object
) {
    LET $delivery_id = $params.delivery_id;

    LET $updated = (
        UPDATE $delivery_id SET
            status = "delivered",
            delivered_at = time::now(),
            locked_until = NONE,
            lease_owner = NONE,
            last_error = NONE
        RETURN AFTER
    )[0];

    RETURN fn::result_ok($updated != NONE);
} COMMENT "Acquitte avec succès une livraison d'événement et libère son bail";
