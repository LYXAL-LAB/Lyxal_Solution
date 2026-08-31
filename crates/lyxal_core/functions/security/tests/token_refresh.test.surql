-- ============================================================================
-- TESTS — fn::security_token_refresh
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_token_refresh(
    rand::uuid::v7(),
    rand::uuid::v7(),
    d"2026-08-03T12:00:00Z",
    d"2026-08-03T12:05:00Z"
);
