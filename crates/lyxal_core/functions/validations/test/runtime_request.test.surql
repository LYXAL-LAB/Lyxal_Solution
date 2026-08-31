-- ============================================================================
-- TESTS — fn::validation_runtime_request
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================
RETURN fn::validation_runtime_request({schema_name:"user",schema_version:"v1",mode:"fail_fast"},{name:"Lyxal"},"req-001",NONE);
