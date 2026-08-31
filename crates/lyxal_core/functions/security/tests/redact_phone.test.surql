-- ============================================================================
-- TESTS — fn::security_redact_phone
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_redact_phone(
    "+33 6 12 34 56 78",
    4
);
