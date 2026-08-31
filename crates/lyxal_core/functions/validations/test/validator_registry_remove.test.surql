-- ============================================================================
-- TESTS — fn::validation_validator_registry_remove
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_validator_registry_remove(
    {
        entries:[
            {name:"email",version:"v1",enabled:true},
            {name:"email",version:"v2",enabled:true}
        ]
    },
    "email",
    "v1"
);
