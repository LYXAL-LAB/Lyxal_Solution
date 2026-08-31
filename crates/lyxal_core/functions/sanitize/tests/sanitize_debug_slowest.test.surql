-- ============================================================================
-- TESTS — fn::sanitize_debug_slowest
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_debug_slowest({traces:[{duration:1ms},{duration:5ms}]},1);
