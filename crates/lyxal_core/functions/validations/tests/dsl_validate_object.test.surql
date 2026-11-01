-- ============================================================================
-- TESTS — fn::validation_dsl_validate_object
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_dsl_validate_object(
    {
        name:"user",
        version:"v1",
        fields:{
            name:{required:true,type:"string"}
        }
    }
);
