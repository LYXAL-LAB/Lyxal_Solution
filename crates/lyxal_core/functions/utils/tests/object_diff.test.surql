-- ============================================================================
-- TESTS — fn::utils_object_diff
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_object_diff(
    {name:"A",active:true},
    {name:"B",active:true}
);
