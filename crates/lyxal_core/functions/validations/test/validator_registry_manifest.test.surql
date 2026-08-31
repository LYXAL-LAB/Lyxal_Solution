-- ============================================================================
-- TESTS — fn::validation_validator_registry_manifest
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_validator_registry_manifest(
    {
        entries:[
            {
                name:"email",
                version:"v1",
                capability:"format",
                enabled:true
            }
        ]
    }
);
