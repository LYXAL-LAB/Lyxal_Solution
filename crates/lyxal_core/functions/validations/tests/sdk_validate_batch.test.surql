-- ============================================================================
-- TESTS — fn::validation_sdk_validate_batch
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_sdk_validate_batch(
    {
        name:"user",
        version:"v1",
        schema:{
            name:{
                required:true,
                trim:true
            }
        }
    },
    [
        {name:" A "},
        {name:" B "}
    ],
    NONE
);
