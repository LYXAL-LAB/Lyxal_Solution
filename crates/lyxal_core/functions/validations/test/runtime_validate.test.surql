-- ============================================================================
-- TESTS — fn::validation_runtime_validate
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================
RETURN fn::validation_runtime_validate({name:"user",version:"v1",schema:{name:{required:true,trim:true}}},{name:" LYXAL "},[],"aabbccddeeff0011",1h,20,"req-001");
