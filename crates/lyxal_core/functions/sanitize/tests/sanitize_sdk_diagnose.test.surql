-- ============================================================================
-- TESTS — fn::sanitize_sdk_diagnose
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_sdk_diagnose({name:"user",version:"v1",fields:{name:{pipeline:[{rule:"trim"},{rule:"trim"}]}},unknown_keys_policy:"strip"});
