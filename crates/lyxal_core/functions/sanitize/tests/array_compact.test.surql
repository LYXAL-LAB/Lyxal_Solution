-- ============================================================================
-- TESTS — fn::sanitize_array_compact
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_array_compact(
    [NONE,NULL,"","A"],
    true,
    true
);
