-- ============================================================================
-- PURGE AUTOMATIQUE DES SESSIONS EXPIREES
-- MODULE : lyxal_booking
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::booking_cleanup_expired_sessions(
    $params: object
) {
    LET $now = time::now();
    DELETE booking_session WHERE expires_at <= $now;

    RETURN fn::result_ok({ cleaned: true });
};
