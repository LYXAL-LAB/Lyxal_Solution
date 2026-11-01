-- ============================================================================
-- TESTS — fn::validation_schema_source
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_schema_source("user","v1",{name:{type:"string"}});
