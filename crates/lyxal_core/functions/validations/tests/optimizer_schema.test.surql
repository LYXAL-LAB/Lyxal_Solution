-- ============================================================================
-- TESTS — fn::validation_optimizer_schema
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================
RETURN fn::validation_optimizer_schema({name:"user",version:"v1",fields:{name:[{rule:"trim"},{rule:"trim"}]}});
