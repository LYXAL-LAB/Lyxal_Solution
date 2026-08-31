-- ============================================================================
-- TESTS — fn::security_token_expiration
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_token_expiration(
    d"2026-08-03T12:00:00Z",
    1h,
    d"2026-08-03T12:30:00Z"
);
