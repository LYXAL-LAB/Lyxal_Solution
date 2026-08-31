-- ============================================================================
-- TESTS — fn::validation_sdk_diagnose
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_sdk_diagnose(
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
    [],
    [
        {
            name:"user",
            version:"v1",
            status:"active"
        }
    ],
    d"2026-08-03T12:00:00Z"
);
