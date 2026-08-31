-- ============================================================================
-- TESTS — fn::sanitize_debug_report
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_debug_report({request_id:"r",schema_name:"user",started_at:time::now(),traces:[{changed:true,duration:1ms}]});
