-- ============================================================================
-- TESTS — fn::security_redact_secret
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_redact_secret(
    "lyxal_abcdefghijklmnopqrstuvwxyz",
    6,
    4
);
