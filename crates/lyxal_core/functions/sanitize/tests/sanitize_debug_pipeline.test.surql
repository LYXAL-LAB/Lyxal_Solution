-- ============================================================================
-- TESTS — fn::sanitize_debug_pipeline
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_debug_pipeline("NAME"," A ","a",[{rule:"trim"},{rule:"lowercase"}]);
