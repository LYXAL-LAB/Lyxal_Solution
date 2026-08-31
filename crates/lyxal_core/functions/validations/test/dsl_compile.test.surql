-- ============================================================================
-- TESTS — fn::validation_dsl_compile
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_dsl_compile(
    {
        name:"user",
        version:"v1",
        fields:{
            name:{required:true,trim:true,type:"string"}
        }
    }
);
