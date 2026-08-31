-- ============================================================================
-- TESTS — fn::sanitize_optimizer_stats
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_optimizer_stats({compiled_fields:{name:{steps:[{rule:"trim"}]}}});
