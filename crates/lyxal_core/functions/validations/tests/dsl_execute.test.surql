-- ============================================================================
-- TESTS — fn::validation_dsl_execute
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_dsl_execute(
    {
        name:"user",
        version:"v1",
        fields:{
            name:{
                required:true,
                trim:true,
                lowercase:true
            }
        }
    },
    {name:" LYXAL "},
    20
);
