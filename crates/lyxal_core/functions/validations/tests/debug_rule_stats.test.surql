-- ============================================================================
-- TESTS — fn::validation_debug_rule_stats
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================
RETURN fn::validation_debug_rule_stats({traces:[{rule:"trim",success:true},{rule:"trim",success:false}]},"trim");
