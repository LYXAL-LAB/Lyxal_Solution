-- ============================================================================
-- TESTS — fn::security_token_parse
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_token_parse(
    "lyxal_abcdefghijklmnopqrstuvwxyz"
);
