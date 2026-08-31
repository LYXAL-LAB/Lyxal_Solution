-- ============================================================================
-- TESTS — fn::validation_sdk_manifest
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_sdk_manifest(
    {
        entries:[
            {
                name:"email",
                version:"v1",
                capability:"format",
                enabled:true
            }
        ]
    },
    [
        {
            name:"user",
            version:"v1",
            status:"active"
        }
    ]
);
