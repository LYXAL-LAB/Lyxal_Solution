-- ============================================================================
-- TESTS — fn::validation_contract_version
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_contract_version("V2","VERSION");
RETURN fn::validation_contract_version("1.0","VERSION");
