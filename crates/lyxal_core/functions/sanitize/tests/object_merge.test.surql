-- ============================================================================
-- TESTS — fn::sanitize_object_merge
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_object_merge(
    {name:"A",active:false},
    {name:"B"}
);
