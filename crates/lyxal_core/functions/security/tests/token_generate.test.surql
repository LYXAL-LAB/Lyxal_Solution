-- ============================================================================
-- TESTS — fn::security_token_generate
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_token_generate(
    "lyxal",
    32,
    d"2026-08-03T12:00:00Z",
    1h
);
