-- ============================================================================
-- TESTS — fn::sanitize_runtime_stats
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_runtime_stats(
 [{changed:true},{changed:false},{changed:true}]
);
