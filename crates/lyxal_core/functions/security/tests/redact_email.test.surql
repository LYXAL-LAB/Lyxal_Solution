-- ============================================================================
-- TESTS — fn::security_redact_email
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_redact_email(
    "yaniss@example.com"
);
