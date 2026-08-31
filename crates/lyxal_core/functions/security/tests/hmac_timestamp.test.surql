-- ============================================================================
-- TESTS — fn::security_hmac_timestamp
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_hmac_timestamp(
    d"2026-08-03T12:00:00Z"
);
