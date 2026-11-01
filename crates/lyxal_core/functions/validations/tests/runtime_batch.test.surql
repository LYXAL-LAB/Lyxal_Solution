-- ============================================================================
-- TESTS — fn::validation_runtime_batch
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================
RETURN fn::validation_runtime_batch({fields:{name:[{rule:"trim"}]}},[{name:" A "},{name:" B "}],10);
