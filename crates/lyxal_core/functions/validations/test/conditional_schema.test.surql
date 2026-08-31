-- ============================================================================
-- TESTS — fn::validation_conditional_schema
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_conditional_schema(true,{company:{required:true}},NONE);
