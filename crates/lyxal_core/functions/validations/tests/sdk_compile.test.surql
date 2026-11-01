-- ============================================================================
-- TESTS — fn::validation_sdk_compile
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_sdk_compile(
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
    true
);
