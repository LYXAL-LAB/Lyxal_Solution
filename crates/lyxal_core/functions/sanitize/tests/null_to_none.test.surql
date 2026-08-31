-- ============================================================================
-- TESTS — fn::sanitize_null_to_none
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_null_to_none(
    {name:NULL,age:1}
);
