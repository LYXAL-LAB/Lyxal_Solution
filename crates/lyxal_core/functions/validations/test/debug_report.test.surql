-- ============================================================================
-- TESTS — fn::validation_debug_report
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================
RETURN fn::validation_debug_report({request_id:"r",schema_name:"user",enabled:true,started_at:d"2026-08-03T12:00:00Z",traces:[{field:"name",rule:"required",success:false,error_code:"NAME_REQUIRED",input:NONE,duration:1ms}]});
