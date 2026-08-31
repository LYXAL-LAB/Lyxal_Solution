-- ============================================================================
-- TESTS — fn::security_redact_pipeline
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_redact_pipeline(
    "yaniss@example.com",
    [{rule:"email"}]
);
