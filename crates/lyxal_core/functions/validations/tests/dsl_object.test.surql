-- ============================================================================
-- TESTS — fn::validation_dsl_object
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_dsl_object(
    "user::profile",
    "v1",
    {name:{required:true,type:"string"}}
);
