-- ============================================================================
-- TESTS — fn::security_conditional_schema
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_conditional_schema(true,{name:"strict"},{name:"relaxed"});
