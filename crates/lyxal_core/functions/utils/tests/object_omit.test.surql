-- ============================================================================
-- TESTS — fn::utils_object_omit
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_object_omit(
    {name:"Lyxal",password:"secret",active:true},
    ["password"]
);
