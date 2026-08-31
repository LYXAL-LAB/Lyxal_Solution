-- ============================================================================
-- TESTS — fn::validation_validator_registry_by_capability
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_validator_registry_by_capability(
    {
        entries:[
            {name:"email",capability:"format",enabled:true},
            {name:"trim",capability:"transform",enabled:true}
        ]
    },
    "format",
    true
);
