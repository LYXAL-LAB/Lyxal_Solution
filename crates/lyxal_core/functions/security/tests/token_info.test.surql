-- ============================================================================
-- TESTS — fn::security_token_info
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_token_info(
    rand::uuid::v7(),
    "opaque",
    d"2026-08-03T12:00:00Z",
    d"2026-08-03T13:00:00Z",
    "active"
);
