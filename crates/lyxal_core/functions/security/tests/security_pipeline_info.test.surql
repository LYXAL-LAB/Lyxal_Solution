-- ============================================================================
-- TESTS — fn::security_pipeline_info
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_pipeline_info({name:"x",version:"v1",steps:[{rule:"detect_payload"}],compiled_at:time::now()});
