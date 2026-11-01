-- ============================================================================
-- TESTS — fn::validation_field_result
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_field_result("name","Lyxal",[],[]);
RETURN fn::validation_field_result("name",NONE,[{code:"NAME_REQUIRED"}],[]);
