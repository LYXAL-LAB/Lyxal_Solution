-- ============================================================================
-- TESTS — fn::security_redact_array
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_redact_array(
    ["public","secret","public"],
    [1]
);
