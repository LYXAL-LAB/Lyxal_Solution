-- ============================================================================
-- TESTS — fn::sanitize_pipeline_info
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_pipeline_info({
 field:"NAME",
 steps:[{rule:"trim"}],
 compiled_at:time::now()
});
