-- ============================================================================
-- TESTS — fn::validation_optimizer_report
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================
RETURN fn::validation_optimizer_report({name:"user",version:"v1",fields:{name:[{rule:"trim"},{rule:"trim"}]}},{name:"user",version:"v1",fields:{name:[{rule:"trim"}]}});
