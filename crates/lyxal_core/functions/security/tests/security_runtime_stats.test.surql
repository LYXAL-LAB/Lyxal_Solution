-- ============================================================================
-- TESTS — fn::security_runtime_stats
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_runtime_stats([{blocked:false,score:0},{blocked:true,score:80}]);
