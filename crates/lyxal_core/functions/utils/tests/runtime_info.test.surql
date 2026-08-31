-- ============================================================================
-- TESTS — fn::utils_runtime_info
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_runtime_info(
    {name:"lyxal_utils",version:"1.0.0",contract:"v1"},
    {engine:"surrealdb",language:"surrealql"},
    {name:"production",debug:false},
    d"2026-08-03T12:00:00Z"
);
