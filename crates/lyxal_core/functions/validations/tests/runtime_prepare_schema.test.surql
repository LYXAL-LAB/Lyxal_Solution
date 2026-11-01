-- ============================================================================
-- TESTS — fn::validation_runtime_prepare_schema
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================
RETURN fn::validation_runtime_prepare_schema({name:"user",version:"v1",schema:{name:{required:true}}},[],"aabbccddeeff0011",1h,d"2026-08-03T12:00:00Z");
