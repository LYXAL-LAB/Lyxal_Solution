-- ============================================================================
-- TESTS — fn::sanitize_runtime_response
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_runtime_response(
 {
  request_id:"req-001",
  payload:{name:" A "},
  context:{
   schema_name:"user",
   schema_version:"v1",
   mode:"strict",
   started_at:d"2026-08-03T12:00:00Z"
  }
 },
 {name:"A"},
 d"2026-08-03T12:00:01Z"
);
