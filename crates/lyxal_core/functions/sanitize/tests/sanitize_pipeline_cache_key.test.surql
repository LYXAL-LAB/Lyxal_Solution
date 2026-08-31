-- ============================================================================
-- TESTS — fn::sanitize_pipeline_cache_key
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_pipeline_cache_key(
 "user::name",
 "v1",
 [{rule:"trim"}]
);
