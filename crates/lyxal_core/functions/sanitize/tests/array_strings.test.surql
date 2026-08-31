-- ============================================================================
-- TESTS — fn::sanitize_array_strings
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_array_strings(
    [" A ",1,"B"],
    true,
    true
);
