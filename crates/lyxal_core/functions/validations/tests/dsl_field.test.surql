-- ============================================================================
-- TESTS — fn::validation_dsl_field
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_dsl_field(
    "name",
    {required:true,type:"string",min_length:2}
);
