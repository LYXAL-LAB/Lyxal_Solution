-- ============================================================================
-- TESTS — fn::security_debug_field
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_debug_field(
    {traces:[{field:"payload"},{field:"headers"}]},
    "payload"
);
