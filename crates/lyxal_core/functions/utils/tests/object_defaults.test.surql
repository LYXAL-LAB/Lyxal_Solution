-- ============================================================================
-- TESTS — fn::utils_object_defaults
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_object_defaults(
    {name:"Lyxal"},
    {name:"Default",active:true}
);
