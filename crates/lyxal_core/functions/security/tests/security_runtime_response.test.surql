-- ============================================================================
-- TESTS — fn::security_runtime_response
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_runtime_response(
 {request_id:"r",context:{schema_name:"req",schema_version:"v1",started_at:d"2026-08-03T12:00:00Z"}},
 {findings:[],decisions:[],output:{}},
 d"2026-08-03T12:00:01Z"
);
