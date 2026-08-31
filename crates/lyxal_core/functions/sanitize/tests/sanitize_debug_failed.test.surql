-- ============================================================================
-- TESTS — fn::sanitize_debug_failed
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_debug_failed({traces:[{error_code:NONE},{error_code:"X"}]});
