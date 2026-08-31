-- ============================================================================
-- TESTS — fn::validation_default_value
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_default_value(NONE,"pending");
RETURN fn::validation_default_value(NULL,"pending");
