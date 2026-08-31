-- ============================================================================
-- TESTS — fn::utils_compare_objects
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_compare_objects(
    {name:"A",active:true},
    {name:"B",active:true}
);
