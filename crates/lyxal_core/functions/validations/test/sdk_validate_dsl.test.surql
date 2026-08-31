-- ============================================================================
-- TESTS — fn::validation_sdk_validate_dsl
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_sdk_validate_dsl(
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
    NONE
);
