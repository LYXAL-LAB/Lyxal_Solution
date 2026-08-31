-- ============================================================================
-- TESTS — fn::sanitize_sdk_batch
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_sdk_batch({name:"user",version:"v1",fields:{name:{pipeline:[{rule:"trim"}]}},unknown_keys_policy:"strip"},[{name:" A "},{name:" B "}],NONE);
