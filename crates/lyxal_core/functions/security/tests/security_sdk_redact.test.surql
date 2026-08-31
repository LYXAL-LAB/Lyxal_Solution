-- ============================================================================
-- TESTS — fn::security_sdk_redact
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_sdk_redact(
    "yaniss@example.com",
    [{rule:"email"}]
);
