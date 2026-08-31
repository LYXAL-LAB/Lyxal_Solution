-- ============================================================================
-- TESTS — fn::sanitize_array_objects
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_array_objects([
    {name:"A"},
    "B",
    {name:"C"}
]);
