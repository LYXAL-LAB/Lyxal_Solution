-- ============================================================================
-- TESTS — fn::sanitize_safe_path
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_safe_path("../modules//scheduler/./manifest.surql","VALUE");
