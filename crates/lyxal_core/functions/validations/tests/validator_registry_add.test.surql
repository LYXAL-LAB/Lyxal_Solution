-- ============================================================================
-- TESTS — fn::validation_validator_registry_add
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_validator_registry_add(
    {entries:[{name:"email",version:"v1",enabled:true}]},
    {name:"email",version:"v2",enabled:true}
);
