-- ============================================================================
-- TESTS — fn::validation_runtime_response
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================
RETURN fn::validation_runtime_response({request_id:"r",context:{schema_name:"user",schema_version:"v1",mode:"fail_fast",started_at:d"2026-08-03T12:00:00Z"}},{valid:true,value:{},errors:[],warnings:[]},true,d"2026-08-03T12:00:01Z");
