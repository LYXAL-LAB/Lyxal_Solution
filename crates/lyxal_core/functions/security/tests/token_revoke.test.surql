-- ============================================================================
-- TESTS — fn::security_token_revoke
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_token_revoke(
    rand::uuid::v7(),
    d"2026-08-03T12:00:00Z",
    "rotation",
    "system"
);
