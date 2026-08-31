-- ============================================================================
-- TESTS — fn::validation_validator_registry_find
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_validator_registry_find(
    {
        entries:[
            {name:"email",version:"v1",enabled:true}
        ]
    },
    "email",
    NONE,
    true
);
