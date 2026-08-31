-- ============================================================================
-- TESTS — fn::validation_sdk_validate_field
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_sdk_validate_field(
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
    "name",
    " LYXAL ",
    NONE
);
