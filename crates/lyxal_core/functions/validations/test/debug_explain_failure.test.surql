-- ============================================================================
-- TESTS — fn::validation_debug_explain_failure
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================
RETURN fn::validation_debug_explain_failure({field:"name",rule:"required",success:false,error_code:"NAME_REQUIRED",input:NONE});
