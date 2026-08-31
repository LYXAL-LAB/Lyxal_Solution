-- ============================================================================
-- TESTS — fn::security_secret_mask
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_secret_mask(
    "lyxal_abcdefghijklmnopqrstuvwxyz",
    6,
    4,
    "*"
);
