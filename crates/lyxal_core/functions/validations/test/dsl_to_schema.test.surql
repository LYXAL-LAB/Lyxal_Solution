-- ============================================================================
-- TESTS — fn::validation_dsl_to_schema
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_dsl_to_schema(
    {
        name:"user",
        version:"v1",
        fields:{
            age:{required:true,type:"int",min:18}
        }
    }
);
