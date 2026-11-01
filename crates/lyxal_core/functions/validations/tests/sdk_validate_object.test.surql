-- ============================================================================
-- TESTS — fn::validation_sdk_validate_object
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_sdk_validate_object(
    {
        name:"user",
        version:"v1",
        schema:{
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
