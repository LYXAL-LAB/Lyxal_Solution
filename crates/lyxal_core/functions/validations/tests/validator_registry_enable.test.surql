-- ============================================================================
-- TESTS — fn::validation_validator_registry_enable
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_validator_registry_enable(
    {
        entries:[
            {name:"email",version:"v1",enabled:false}
        ]
    },
    "email",
    true
);
