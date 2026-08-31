-- ============================================================================
-- TESTS — fn::sanitize_sdk_object
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_sdk_object({name:"user",version:"v1",fields:{name:{pipeline:[{rule:"trim"}]}},unknown_keys_policy:"strip"},{name:" A "},NONE);
