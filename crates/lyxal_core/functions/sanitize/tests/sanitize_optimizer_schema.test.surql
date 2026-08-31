-- ============================================================================
-- TESTS — fn::sanitize_optimizer_schema
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_optimizer_schema({compiled_fields:{name:{field:"NAME",steps:[{rule:"trim"},{rule:"trim"}]}}});
