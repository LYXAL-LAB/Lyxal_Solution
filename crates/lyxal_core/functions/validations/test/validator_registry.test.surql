-- ============================================================================
-- TESTS — fn::validation_validator_registry
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_validator_registry(
    [
        {name:"email",enabled:true},
        {name:"iban",enabled:false}
    ]
);
