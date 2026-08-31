-- ============================================================================
-- TESTS — fn::sanitize_debug_summary
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_debug_summary({request_id:"r",schema_name:"user",started_at:time::now(),traces:[{changed:true},{changed:false}]});
