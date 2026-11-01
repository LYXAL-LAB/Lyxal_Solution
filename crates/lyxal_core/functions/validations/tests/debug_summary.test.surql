-- ============================================================================
-- TESTS — fn::validation_debug_summary
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================
RETURN fn::validation_debug_summary({request_id:"r",schema_name:"user",enabled:true,started_at:d"2026-08-03T12:00:00Z",traces:[{success:true},{success:false}]});
