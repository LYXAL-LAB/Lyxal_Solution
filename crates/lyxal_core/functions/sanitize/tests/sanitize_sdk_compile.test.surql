-- ============================================================================
-- TESTS — fn::sanitize_sdk_compile
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_sdk_compile({name:"user",version:"v1",fields:{name:{pipeline:[{rule:"trim"}]}},unknown_keys_policy:"strip"},NONE);
