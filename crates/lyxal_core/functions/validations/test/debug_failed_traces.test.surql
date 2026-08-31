-- ============================================================================
-- TESTS — fn::validation_debug_failed_traces
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================
RETURN fn::validation_debug_failed_traces({traces:[{success:true},{success:false}]});
